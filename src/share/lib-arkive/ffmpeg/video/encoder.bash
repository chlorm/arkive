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

function FFmpeg::Video.codec {
  Function::RequiredArgs '3' "$#"
  local Encoder
  local EncoderParams
  local -r File="${2}"
  local -r Index="${3}"
  local -r Stream="${1}"

  case "${FFMPEG_VIDEO_ENCODER}" in
    'x264')
      Encoder='libx264'
      EncoderParams="$(FFmpeg::Video.codec:x264_params "${Stream}" "${File}")"
      ;;
    'x265')
      Encoder='libx265'
      EncoderParams=("$(FFmpeg::Video.codec:x265_params "${Stream}" "${File}")")
      ;;
    'nvenc-h264')
      Encoder='h264_nvenc'
      EncoderParams="$(FFmpeg::Video.codec:nvenc_h264_params "${Stream}" "${File}" "${Index}")"
      ;;
    'nvenc-h265') echo 'not implemented' ; return 1 ;;
    'vaapi-h264')
      Encoder='h264_vaapi'
      EncoderParams="$(FFmpeg::Video.codec:vaapi_h264_params "${Stream}" "${File}" "${Index}")"
      ;;
    'vp9')
      Encoder='libvpx-vp9'
      EncoderParams="$(FFmpeg::Video.codec:vp9_params "${Stream}" "${File}")"
      ;;
    'av1') echo 'not implemented' ; return 1 ;;
    *) return 1 ;;
  esac

  echo "-c:${Index}" "${Encoder}" "${EncoderParams[@]}"
}
