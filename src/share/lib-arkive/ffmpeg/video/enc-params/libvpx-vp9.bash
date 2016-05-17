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

function FFmpeg::Video.codec:vp9_params {
  local Key
  local Parameter
  local Parameters
  local Value
  local Vp9Params

  Parameters=(
    'speed=4'
    #'g=9999'
    'g=250'
    "keyint_min=$(FFmpeg::Video.min_keyframe_interval)"
    #'qmin'
    #'qmax'
    'bufsize=31250'
    #'rc_init_occupancy'
    #'undershoot-pct'
    #'overshoot-pct'
    #'skip_threshold'
    #'qcomp'
    'maxrate=31250'
    #'minrate'
    #minrate, maxrate, b end-usage=cbr
    #'crf' (end-usage=cq, cq-level)
    #'tune' # (psnr/ssim)
    #'deadline=best' # (best/good/realtime)
    #'nr' # (noise-sensitivity)
    #'slices' (token-parts)
    #'max-intra-rate'
    #'force_key_frames'
    #'auto-alt-ref'
    #'arnr-max-frames'
    #'arnr-type'
    #'arnr-strength'
    #'rc-lookahead', 'lag-in-frames'
    #'error-resilient'
    #'lossless'
    'tile-columns=0'
    #'tile-rows'
    'frame-parallel=0'
    'aq-mode=0'
    #'colorspace'
  )

  if [ ${ARKIVE_VIDEO_ENCODING_PASSES} -gt 1 ] ; then
    Parameters+=(
      'speed=1'
    )
  else
    Parameters+=(
      'speed=4'
      'auto-alt-ref=1'
      'lag-in-frames=25'
    )
  fi

  for Parameter in "${Parameters[@]}" ; do
    Key="$(echo "${Parameter}" | awk -F'=' '{print $1 ; exit}')"
    Value="$(echo "${Parameter}" | awk -F'=' '{print $2 ; exit}')"
    Vp9Params="${Vp9Params:+${Vp9Params} }-${Key} ${Value}"
  done

  echo "${Vp9Params}"
}
