# Copyright (c) 2013-2017, Cody Opel <codyopel@gmail.com>
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

function ffmpeg_video_codec {
  stl_func_reqargs '3' "$#"
  local encoder
  local -a encoderParams
  local -r file="$2"
  local -r index="$3"
  local -r stream="$1"

  case "$FFMPEG_VIDEO_ENCODER" in
    'copy')
      encoder='copy'
      ;;
    'x264')
      encoder='libx264'
      encoderParams=("$(ffmpeg_video_codec_x264_params "$stream" "$file")")
      ;;
    'x265')
      encoder='libx265'
      encoderParams=("$(ffmpeg_video_codec_x265_params "$stream" "$file")")
      ;;
    'nvenc-h264')
      encoder='h264_nvenc'
      encoderParams=(
        "$(ffmpeg_video_codec_nvenc_h264_params "$stream" "$file" "$Index")"
      )
      ;;
    'nvenc-h265') echo 'not implemented'; return 1 ;;
    'vaapi-h264')
      encoder='h264_vaapi'
      encoderParams=(
        "$(ffmpeg_video_codec_vaapi_h264_params "$stream" "$file" "$Index")"
      )
      ;;
    'vp9')
      encoder='libvpx-vp9'
      encoderParams=("$(ffmpeg_video_codec_vp9_params "$stream" "$file")")
      ;;
    'av1')
      encoder='libaom-av1'
      encoderParams=('-strict' 'experimental')
      ;;
    *) return 1 ;;
  esac

  echo "-c:$index" "$encoder" "${encoderParams[@]}"
}
