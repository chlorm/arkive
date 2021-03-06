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

function FFmpeg::Video.filters {
  Function::RequiredArgs '3' "$#"
  local -r File="$2"
  local -a Filters
  local -r Index="$3"
  local -r Stream="$1"

  # NOTE: the order of filters here is the order in which they are applied
  #Filters+=("$(FFmpeg::Video.filters:de_interlace "$Stream" "$File")")
  Filters+=("$(FFmpeg::Video.filters:black_bar_crop "$Stream" "$File")")
  #Filters+=("$(FFmpeg::Video.filters:colorspace "$Stream" "$File")")
  #Filters+=("$(FFmpeg::Video.filters:denoise)")
  #Filters+=("$(FFmpeg::Video.filters:scale "$Stream" "$File")")
  Filters+=("$(FFmpeg::Video.filters:zscale "$Stream" "$File")")
  if [ "$FFMPEG_VIDEO_ENCODER" == 'vaapi-h264' ]; then
    Filters+=(
      'format=nv12'
      'hwupload'
    )
  fi

  if [ -n "${Filters[*]}" ]; then
    local IFS=","
    echo "-filter:$Index" "${Filters[*]}"
  fi
}
