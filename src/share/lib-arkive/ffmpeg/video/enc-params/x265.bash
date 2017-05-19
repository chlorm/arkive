# Copyright (c) 2013-2016, Cody Opel <codyopel@gmail.com>
# All Rights Reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice,
#    this list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.
#
# 3. Neither the name of the copyright holder nor the names of its contributors
#    may be used to endorse or promote products derived from this software
#    without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.

# WARNING:
# This mock-up implementation in shell is for testing and demonstration
# purposes only.

# Generates formatted ffmpeg x265-params key/values
function FFmpeg::Video.codec:x265_params {
  Function::RequiredArgs '2' "$#"
  local Bitrate
  local BufSize
  local ColorTransfer
  local -r File="${2}"
  local FrameRate
  local -i HighBitDepth=0
  local MeRange
  local Param
  local -a __parameters
  local ParamHasValue
  local ParamList
  local RcLookahead
  local -r Stream="${1}"

  Bitrate="$(FFmpeg::Video.bitrate "${Stream}" "${File}")"

  # Buffer size is bitrate +10%
  BufSize=$(echo "scale=10;${Bitrate}*1.10)" | bc -l | xargs printf "%1.0f")

  FrameRate="$(
    echo "scale=10;$(FFmpeg::Video.frame_rate "${Stream}" "${File}")" |
        bc -l |
        xargs printf "%1.0f"
  )"
  if [ ${FrameRate} -gt 500 ]; then
    RcLookahead=250
  else
    RcLookahead=${FrameRate}
  fi

  MeRange="$(FFmpeg::Video.motion_estimation_range "${Stream}" "${File}")"
  # Motion Estimation ranges below 57 reduce coding efficiency
  # http://forum.doom9.org/showthread.php?p=1713094#post1713094
  if [ ${MeRange} -lt 58 ]; then
    MeRange=58
  fi

  if [ ${FFMPEG_VIDEO_BITDEPTH} -gt 8 ]; then
    HighBitDepth=1
  fi

  __parameters+=(
    'log-level=info'
    # Use a single frame thread to prevent ghosting artifacts in some cases.
    # Static such as in the HBO intro is an example where this occurs with
    # frame thread parallelism.  If objects in scenes look like the edges
    # are blurred or not very well defined it is usually due to this issue.
    'frame-threads=1'
  )
  __parameters+=("pools=$(Cpu::Logical)") # FIXME
    #numa-pools # char
  __parameters+=(
    'wpp=1'
    'pmode=0'
    'pme=0'
    #'dither'
    'interlace=0'
  )
  __parameters+=("level-idc=$(FFmpeg::Video.level:h265 "${Stream}" "${File}")")
  __parameters+=(
    'high-tier=0'
    # value <= 6 due to b-frames & b-pyramid
    'ref=3'
    'allow-non-conformance=0'
    'uhd-bd=0'
    'rd=3'
    'ctu=64'
    'min-cu-size=8'
    'limit-refs=0'
    'limit-modes=0'
    'rect=0'  # 2x performance penalty
    'amp=0'  # 2x performance penalty
    'early-skip=0'
    'rskip=0'  # Increases performance 2x+, decreases detail at CU borders.
    'fast-intra=0'
    'b-intra=0'  # May require serialized decoding when enabled
    'cu-lossless=0'
    'tskip-fast=0'
    'rd-refine=0'
    'refine-level=5'  # XXX: maybe use 10???
    'rdoq-level=0'  # rdoq is overly argressive causing hot-spots & deadzones.
    'tu-intra-depth=1'  # Performance penalty for > 1 for minimal improvement.
    'tu-inter-depth=1'  # Performance penalty for > 1 for minimal improvement.
    'limit-tu=0'
    'nr-intra=0'
    'nr-inter=0'
    'tskip=0'
    'rdpenalty=0'
    'max-tu-size=32'
    'max-merge=3'
    'me=2'  # 3(star) produces blocking artifacts in high energy scenes
            # that contain a lot of motion.
    'subme=2'
    "merange=${MeRange}"
    'temporal-mvp=1'  # TODO
    'weightp=1'
    # Segfault if weightb is disabled (possibly only when in combination
    # with another flag)
    'weightb=1'
    'strong-intra-smoothing=0'
    'constrained-intra=1'
    # For psy-rd(oq), favor lower more conservative values.  In scenes with
    # high energy dispersed evenly across a frame, higher values will cause
    # hot-spots and dead-zones. (e.g. really bad blocking artifacts with
    # high detail CUs next to low detail CUs). Despite this issue, psy-rd
    # is still necessary to better distribute energy.
    'psy-rd=0.7'  # Values > 1.0 cause color distortions, use < 2.0
    'psy-rdoq=0.0'  # disabled
    'open-gop=0'
  )
  __parameters+=(
    # Ensure 1 keyframe per GOP
    # FIXME: make keyframe interval a multiple of 4
    "keyint=$(FFmpeg::Video.keyframe_interval "${Stream}" "${File}")"
  )
  __parameters+=(
    # For high frame rates ensure multiple keyframes per second
    "min-keyint=$(FFmpeg::Video.min_keyframe_interval "${Stream}" "${File}")"
  )
  __parameters+=(
    'scenecut=0'
    'scenecut-bias=0'
    'intra-refresh=0'
    # Set lookahead to same as key-frame interval to make sure the encoder
    # has the entire GOP for decision making.
    "rc-lookahead=${RcLookahead}" # (> bframes & < 250)
    'lookahead-slices=0'
    'b-adapt=2'
    # Using > 3 bframes has a large performance penalty
    'bframes=3'
    'bframe-bias=0'
    'b-pyramid=1'
    "vbv-bufsize=${BufSize}"
    "vbv-maxrate=${BufSize}"
    'vbv-init=0.9' # float
    'lossless=0'
    'aq-mode=1'
    'aq-strength=0.4'
    'qg-size=16'  # setting to 8 results in segfault
    'cutree=0'
    'strict-cbr=0'
    'cbqpoffs=-4'
    'crqpoffs=-4'
    'ipratio=1.4'
    'pbratio=1.0'
    'qcomp=0.8'  # values < 0.5 segfault, always use >= 0.8 w/ aq-auto-variance
    'qpstep=8'
    'rc-grain=0'
    'qblur=0.0'
    'cplxblur=0.0'
    #'zones=0,250,b=2.0'
    'signhide=1'
    #'qpfile'
    #'scaling-list'
    #'lambda-file'
    'deblock=-6\:-6'
    'sao=0'
    'sao-non-deblock=0'
    'limit-sao=0'
    #'sar'
    #'display-window'
    #'overscan'
    #'videoformat'
  )
  __parameters+=(
    "range=$(
      if [ ${HighBitDepth} -eq 1 ]; then
        echo 'limited'
      else
        echo 'limited'
      fi
    )"
  )
  __parameters+=(
    "colorprim=$(
      if [ ${HighBitDepth} -eq 1 ]; then
        echo 'bt2020'
      else
        echo 'bt709'
      fi
    )"
  )
  __parameters+=(
    "transfer=$(
      if [ ${HighBitDepth} -eq 1 ]; then
        echo "bt2020-${FFMPEG_VIDEO_BITDEPTH}"
        #echo 'smpte-st-2084'
      else
        echo 'bt709'
      fi
    )"
  )
  __parameters+=(
    "colormatrix=$(
      if [ ${HighBitDepth} -eq 1 ]; then
        echo 'bt2020nc'
      else
        echo 'bt709'
      fi
    )"
  )
  __parameters+=(
    #'chromaloc=2'
    #'master-display'
    #'max-cll'
    "hdr=${HighBitDepth}"
    "hdr-opt=${HighBitDepth}"
    #"dhdr10-info"
    'dhdr10-opt=1'
    #'min-luma'
    #'max-luma'
    'annexb=1'
    'repeat-headers=0'
    'aud=0'
    'hrd=1'
    'info=0'
    'hash=2'
    'temporal-layers=0'
  )

  if [ ${FFMPEG_VIDEO_ENCODER_PASSES} -gt 1 ]; then
    __parameters+=(
      "pass=${__pass__}"
      #'slow-firstpass=0'
      "stats=${__tmpdir__}/stats"
      "analysis-file=${__tmpdir__}/analysis"
    )
    # Determine analysis-mode
    if [ ${__pass__} -eq 1 ]; then
      __parameters+=('analysis-mode=1')
    else
      __parameters+=('analysis-mode=2')
    fi
  else
    __parameters+=('analysis-mode=0')
  fi

  echo '-x265-params' "$(FFmpeg::Video.x26x_params)"
}
