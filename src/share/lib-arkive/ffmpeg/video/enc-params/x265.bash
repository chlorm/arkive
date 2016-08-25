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
  local Bitrate
  local BufSize
  local ColorTransfer
  local File="${2}"
  local FrameRate
  local MeRange
  local Param
  local -a __parameters
  local ParamHasValue
  local ParamList
  local RcLookahead
  local Stream="${1}"

  Bitrate="$(FFmpeg::Video.bitrate "${Stream}" "${File}")"

  # Buffer size is bitrate +10%
  BufSize=$(echo "${Bitrate}+(${Bitrate}*0.1)" | bc)

  FrameRate="$(echo "$(FFmpeg::Video.frame_rate "${Stream}" "${File}")" | bc)"
  if [ ${FrameRate} -gt 250 ] ; then
    RcLookahead=250
  else
    RcLookahead=${FrameRate}
  fi

  MeRange="$(FFmpeg::Video.motion_estimation_range "${Stream}" "${File}")"
  # Motion Estimation ranges below 57 reduce coding efficiency
  # http://forum.doom9.org/showthread.php?p=1713094#post1713094
  if [ ${MeRange} -lt 58 ] ; then
    MeRange=58
  fi

  if [ ${ARKIVE_VIDEO_BIT_DEPTH} -lt 10 ] ; then
    ColorTransfer='bt709'
  else
    ColorTransfer="bt2020-${ARKIVE_VIDEO_BIT_DEPTH}"
  fi

  __parameters+=(
    'log-level=info'
    # Use a single frame thread to prevent ghosting artifacts in some cases
    "frame-threads=1"
  )
  __parameters+=("pools=$(Cpu::Logical)") # FIXME
    #numa-pools # char
  __parameters+=(
    "wpp=$(if [ $(Cpu::Logical) -gt 1 ] ; then echo 'true' ; else echo 'false' ; fi)"
  )
  __parameters+=(
    'pmode=false'
    'pme=false'
    #'dither'
    'interlace=false'
  )
  __parameters+=("level-idc=$(FFmpeg::Video.level:h265 "${Stream}" "${File}")")
  __parameters+=(
    #'high-tier' # bool
    # value <= 6 due to b-frames & b-pyramid
    'ref=3'
    'allow-non-conformance=false'
    'uhd-bd=false'
    'rd=3'
    'ctu=64'
    'min-cu-size=8'
    'limit-refs=3'
    'limit-modes=false'
    'rect=false'
    'amp=false'
    'early-skip=false'
    'recursion-skip=true'
    'fast-intra=false'
    # Disable b-intra for performance & to prevent serial decoding limitations
    'b-intra=false'
    'cu-lossless=false'
    'tskip-fast=false'
    #'rd-refine=true'
    # Use rdoq-level <= 1 for grain retention
    # http://forum.doom9.org/showthread.php?p=1713406#post1713406
    'rdoq-level=1'
    # Performance penalty for > 1 and only small quality improvement
    'tu-intra-depth=1'
    'tu-inter-depth=1'
    'nr-intra=0'
    'nr-inter=0'
    'tskip=false'
    'rdpenalty=0' # TODO
    'max-tu-size=32'
    'max-merge=3'
    # me:star(3) seems to be producing artifacts
    'me=2'
    'subme=2'
  )
  __parameters+=("merange=${MeRange}")
  __parameters+=(
    'temporal-mvp=true' # TODO
    'weightp=true'
    # Segfault if weightb is disabled (possibly only when in combination
    # with another flag)
    'weightb=true'
    'strong-intra-smoothing=false'
    'constrained-intra=false'
    'psy-rd=2.3'
    'psy-rdoq=0.1'
    'open-gop=true'
  )
  __parameters+=(
    # Ensure 1 keyframe per GOP
    "keyint=$(FFmpeg::Video.keyframe_interval "${Stream}" "${File}")"
  )
  __parameters+=(
    # For high frame rates ensure multiple keyframes per second
    "min-keyint=$(FFmpeg::Video.min_keyframe_interval "${Stream}" "${File}")"
  )
  __parameters+=(
    ###############'scenecut=40'
    'scenecut=0'
    'intra-refresh=false'
  )
  __parameters+=(
    # Set lookahead to same as key-frame interval to make sure the encoder
    # has the entire GOP for decision making.
    "rc-lookahead=${RcLookahead}" # (> bframes & < 250)
  )
  __parameters+=(
    'lookahead-slices=0'
    'b-adapt=2'
    # Using > 3 bframes has a large performance penalty
    'bframes=3'
    'bframe-bias=0'
    'b-pyramid=true'
  )
  __parameters+=(
    "vbv-bufsize=${BufSize%.*}"
    "vbv-maxrate=${BufSize%.*}"
  )
  __parameters+=(
    'vbv-init=0.9' # float
    'lossless=false'
    # x265's aq causes significant blocking artifacts, negating any usefulness.
    'aq-mode=0' # something with aq is causing crashes on 2nd pass encodes,
    'aq-strength=0' # maybe the crash is caused by aq-strength > 2.0
    #'qg-size' # int
    'cutree=false'
    'strict-cbr=false'
    'cbqpoffs=-4'
    'crqpoffs=-4'
    'ipratio=1.4'
    'pbratio=1.0'
    'qcomp=0.6' # values < 0.5 segfault, use 0.6, > values blur
    'qpstep=4'
    'rc-grain=true'
    'qblur=0.5'
    'cplxblur=20.0'
    #'zones=0,250,b=2.0'
    'signhide=true'
    #'qpfile'
    #'scaling-list'
    #'lambda-file'
    'deblock=0'
    'sao=false'
    'sao-non-deblock=false'
    #'sar'
    #'display-window'
    #'overscan'
    #'videoformat'
    'range=full'
    'colorprim=bt2020'
    "transfer=${ColorTransfer}"
    # bt2020c = constant luminance
    # bt2020nc = non-constant luminance
    'colormatrix=bt2020nc'
    #'chromaloc'
    #'master-display'
    #'max-cll'
    #'min-luma'
    #'max-luma'
    'annexb=true'
    'repeat-headers=false'
    'aud=false'
    #'hrd=false' # XXX
    'info=false'
    'hash=2'
    'temporal-layers=false'
  )

  if [ ${ARKIVE_VIDEO_ENCODING_PASSES} -gt 1 ] ; then
    __parameters+=(
      "pass=${__pass__}"
      'slow-firstpass=false'
      "stats=${__tmpdir__}/${__filenamefmt__}.stats"
      "analysis-file=${__tmpdir__}/${__filenamefmt__}.analysis"
    )
    # Determine analysis-mode
    if [ ${__pass__} -eq 1 ] ; then
      __parameters+=('analysis-mode=1')
    else
      __parameters+=('analysis-mode=2')
    fi
  else
    __parameters+=('analysis-mode=0')
  fi

  echo "-x265-params $(FFmpeg::Video.x26x_params)"
}
