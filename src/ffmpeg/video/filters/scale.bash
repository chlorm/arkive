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

function ffmpeg_video_filters_scale {
  stl_func_reqargs '2' "$#"
  local -r file="$1"
  local height
  local heightTarget
  local -a paramaters
  local -r stream="$2"
  local width
  local widthTarget

  if [ "$FFMPEG_VIDEO_HEIGHT" == 'source' ] && \
     [ "$FFMPEG_VIDEO_WIDTH" == 'source' ]; then
    return 0
  fi

  height="$(arkive_video_height "$file" "$stream")"
  width="$(arkive_video_width "$file" "$stream")"

  if [ "$FFMPEG_VIDEO_HEIGHT" == 'source' ]; then
    heightTarget=$height
  else
    heightTarget=$FFMPEG_VIDEO_HEIGHT
  fi

  if [ "$FFMPEG_VIDEO_WIDTH" == 'source' ]; then
    widthTarget=$width
  else
    widthTarget=$FFMPEG_VIDEO_WIDTH
  fi

  if [ $height -eq $heightTarget ] && \
     [ $width -eq $widthTarget ]; then
    return 0
  fi

  paramaters=(
    "h=$heightTarget"
    "w=$widthTarget"
    'force_original_aspect_ratio=decrease'
  )

  local IFS=":"
  echo "scale=${paramaters[*]}"
}
