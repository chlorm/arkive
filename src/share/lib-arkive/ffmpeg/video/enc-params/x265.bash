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
  local DecoderLevel
  local File="${2}"
  local FrameRate
  local KeyInt
  local MeRange
  local Param
  local Parameters
  local ParamHasValue
  local ParamList
  local RcLookahead
  local Stream="${1}"

  Bitrate="$(FFmpeg::Video.bitrate "${Stream}" "${File}")"

  # Buffer size is bitrate +10%
  BufSize=$(echo "${Bitrate}+(${Bitrate}*0.1)" | bc)

  DecoderLevel="$(FFmpeg::Video.level:h265 "${Stream}" "${File}")"

  FrameRate="$(echo "$(FFmpeg::Video.frame_rate "${Stream}" "${File}")" | bc)"
  if [ ${FrameRate} -gt 125 ] ; then
    RcLookahead=250
  else
    RcLookahead=${FrameRate}
  fi

  KeyInt="$(FFmpeg::Video.keyframe_interval "${Stream}" "${File}")"

  MeRange="$(FFmpeg::Video.motion_estimation_range "${Stream}" "${File}")"
  # Motion Estimation ranges below 57 reduce coding efficiency
  # http://forum.doom9.org/showthread.php?p=1713094#post1713094
  if [ ${MeRange} -lt 58 ] ; then
    MeRange=58
  fi

  MinKeyInt=$(FFmpeg::Video.min_keyframe_interval "${Stream}" "${File}")

  Parameters=(
    'log-level=info'
    # Use a single frame thread to prevent ghosting artifacts in some cases
    "frame-threads=1"
    "pools=$(Cpu::Logical)" # FIXME
    #numa-pools # char
    'wpp=true' # FIXME: disable if cpu threads=1
    'pmode=false'
    'pme=false'
    #'dither'
    #fps # float/int/fraction
    'interlace=false'
    "level-idc=${DecoderLevel}"
    #'high-tier' # bool
    'ref=3' # value <= 6 due to b-frames & b-pyramid
    'allow-non-conformance=false'
    #'uhd-bd' # bool?
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
    'rdpenalty=0' # int TODO
    'max-tu-size=32'
    'max-merge=2' # int TODO
    # star(3) seems to be producing artifacts
    'me=2'
    'subme=2' # int TODO
    "merange=${MeRange}"
    'temporal-mvp=true' # TODO
    'weightp=true'
    # Segfault if weightb is disabled (possibly only when in combination
    # with another flag)
    'weightb=true'
    'strong-intra-smoothing=false'
    'constrained-intra=false' # TODO test this
    'psy-rd=4.0' # use < 0.9
    'psy-rdoq=10.0' # use > 3 & < 5
    'open-gop=true' # TODO
    "keyint=${KeyInt}"
    "min-keyint=${MinKeyInt}"
    'scenecut=40' # int TODO
    #'intera-refresh' # bool? TODO
    # Set lookahead to same as key-frame interval to make sure the encoder
    # has the entire GOP for decision making.
    "rc-lookahead=${RcLookahead}" # int (> bframes & < 250)
    'lookahead-slices=0'
    'b-adapt=2'
    'bframes=3' # values > 3 have a large performance penalty
    'bframe-bias=0' # TODO
    'b-pyramid=true'
    "vbv-bufsize=${BufSize%.*}"
    "vbv-maxrate=${BufSize%.*}"
    'vbv-init=0.9' # float
    'lossless=false'
    # x265's aq causes significant blocking artifacts, negating any usefulness
    'aq-mode=0' # something with aq is causing crashes on 2nd pass encodes,
    'aq-strength=0' # maybe the crash is caused by aq-strength >2.0
    #'qg-size' # int
    'cutree=false'
    'strict-cbr=false'
    'cbqpoffs=0' # int
    'crqpoffs=0' # int
    'ipratio=1.1' # float
    'pbratio=1.0' # float
    'qcomp=0.6' # values < 0.5 segfault, use 0.6, > values blur
    #'qpstep=4'
    'rc-grain=true'
    #'qblur=0.8'
    'cplxblur=2.0' # <=20
    #'zones'
    #'signhide=false'
    #'qpfile' # char
    #'scaling-list' # char
    #'lambda-file' # char
    'deblock=\-3\:0'
    'sao=false'
    #'sao-non-deblock=true'
    #'sar'
    #'display-window'
    #'overscan'
    #'videoformat'
    #'range'
    'colorprim=bt709'
    'transfer=bt709'
    'colormatrix=bt709'
    #'chromaloc'
    #'master-display'
    #'max-cll'
    #'min-luma'
    #'max-luma'
    #'annexb=false'
    'repeat-headers=false'
    #'aud=false'
    #'hrd=false'
    'info=false'
    #'hash=2'
    #'temporal-layers=false'
  )

  if [ ${ARKIVE_VIDEO_ENCODING_PASSES} -gt 1 ] ; then
    Parameters+=(
      "pass=${Pass}"
      'slow-firstpass=false'
      "stats=${__tmpdir__}/${__filenamefmt__}.stats"
      "analysis-file=${__tmpdir__}/${__filenamefmt__}.analysis"
    )
    # Determine analysis-mode
    if [ ${Pass} -eq 1 ] ; then
      Parameters+=('analysis-mode=1')
    else
      Parameters+=('analysis-mode=2')
    fi
  else
    Parameters+=('analysis-mode=0')
  fi

  echo "-x265-params $(FFmpeg::Video.x26x_params)"
}
