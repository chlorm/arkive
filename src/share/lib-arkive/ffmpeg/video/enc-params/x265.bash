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
  local MeRange
  local Param
  local Parameters
  local ParamHasValue
  local ParamList

  MeRange="$(FFmpeg::Video.motion_estimation_range)"
  # Motion Estimation ranges below 57 reduce coding efficiency
  # http://forum.doom9.org/showthread.php?p=1713094#post1713094
  if [ ${MeRange} -lt 58 ] ; then
    MeRange=58
  fi

  Parameters=(
    'log-level=info'
    "frame-threads=1" # FIXME
    #"frame-threads=1"
    "pools=$(Cpu::Logical)" # FIXME
    #numa-pools # char
    'wpp=true' # FIXME: disable is cpu threads=1
    'pmode=true'
    'pme=false'
    #'dither'
    #fps # float/int/fraction
    'interlace=false'
    #'level-idc' # int/flost
    #'high-tier' # bool
    'ref=6' # <=6 due to b-frames & b-pyramid
    'allow-non-conformance=false'
    #'uhd-bd' # bool?
    'rd=5'
    'ctu=64'
    'min-cu-size=8'
    #'limit-refs' # int
    'limit-modes=false'
    'rect=true'
    'amp=true'
    'early-skip=false'
    'fast-intra=false'
    'b-intra=true'
    'cu-lossless=false'
    'tskip-fast=false'
    #'rd-refine=true'
    # Use rdoq-level 1
    # http://forum.doom9.org/showthread.php?p=1713406#post1713406
    'rdoq-level=1' # int
    'tu-intra-depth=2' # int
    'tu-inter-depth=2' # int
    'nr-intra=0' # int
    'nr-inter=0' # int
    'tskip=false'
    'rdpenalty=0' # int
    'max-tu-size=32'
    'max-merge=5' # int
    'me=3'
    'subme=5' # int
    "merange=${MeRange}"
    'temporal-mvp=true'
    'weightp=true'
    'weightb=true'
    'strong-intra-smoothing=false'
    'constrained-intra=false'
    #'psy-rd=0.3' # use < 0.9
    #'psy-rdoq=4.0' # use > 3 & < 5
    'open-gop=true'
    "keyint=$(FFmpeg::Video.keyframe_interval)"
    "min-keyint=$(FFmpeg::Video.min_keyframe_interval)"
    'scenecut=40'                # int
    #'intera-refresh' # bool?
    'rc-lookahead=60' # int (> bframes & < 250)
    'lookahead-slices=0' # int
    'b-adapt=0'
    # bframes 3 gets better performance than 4
    'bframes=3'
    'bframe-bias=0'
    'b-pyramid=true'
    #'bitrate' # int
    'vbv-bufsize=31250' # int
    'vbv-maxrate=31250' # int
    'vbv-init=0.9' # float
    'lossless=false'
    'aq-mode=0' # something with aq is causing crashes on 2nd pass encodes
    'aq-strength=0' # maybe the crash is caused by aq-strength >2.0
    #'qg-size' # int
    'cutree=true'
    'strict-cbr=false'
    'cbqpoffs=0' # int
    'crqpoffs=0' # int
    'ipratio=1.4' # float
    'pbratio=1.3' # float
    'qcomp=0.6' # values < 0.5 segfault, use 0.6, > values blur
    #'qpstep=4'
    #'rc-grain=true'
    #'qblur=0.8'
    #'cplxblur=10.0' # <=20
    #'zones'
    #'signhide=false'
    #'qpfile'                  # char
    #'scaling-list'            # char
    #'lambda-file'             # char
    #'deblock=1\\:1'
    #'sao=true'
    #'sao-non-deblock=true'
    #'sar'
    #'display-window'
    #'overscan'
    #'videoformat'
    #'range'
    #'colorprim'
    #'transfer'
    #'colormatrix'
    #'chromaloc'
    #'master-display'
    #'max-cll'
    #'min-luma'
    #'max-luma'
    #'annexb=false'
    #'repeat-headers=false'
    #'aud=false'
    #'hrd=false'
    #'info=false'
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
    TMP_FILES+=(
      "${__tmpdir__}/${__filenamefmt__}.stats"
      "${__tmpdir__}/${__filenamefmt__}.analysis"
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
