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

function ffmpeg_video_filters_colorspace {
  stl_func_reqargs '2' "$#"
  local colorPrimaries
  local colorRange
  local colorSpace
  local colorTransfer
  local file="$2"
  local inputColorPrimaries
  local inputColorRange
  local inputColorSpace
  local inputColorTransfer
  local -a paramaters
  local stream="$1"

  inputColorPrimaries="$(arkive_video_color_primaries "$stream" "$file")"
  inputColorRange="$(arkive_video_color_range "$stream" "$file")"
  inputColorSpace="$(arkive_video_color_space "$stream" "$file")"
  inputColorTransfer="$(arkive_video_color_transfer "$stream" "$file")"

  if [ $FFMPEG_VIDEO_BITDEPTH -gt 8 ]; then
    colorPrimaries='bt2020'
    colorRange='mpeg'
    colorSpace='bt2020ncl'
    colorTransfer="bt2020-$FFMPEG_VIDEO_BITDEPTH"
    pixelFormat="yuv${FFMPEG_VIDEO_CHROMASUBSAMPLING}p$FFMPEG_VIDEO_BITDEPTH"
  else
    colorPrimaries='bt709'
    colorRange='mpeg'
    colorSpace='bt709'
    colorTransfer='bt709'
    pixelFormat="yuv${FFMPEG_VIDEO_CHROMASUBSAMPLING}p"
  fi

  paramaters=(
    "space=$colorSpace"
    "trc=$colorTransfer"
    "primaries=$colorPrimaries"
    "range=$colorRange"
    "format=$pixelFormat"
    # Don't try to apply Gamma/Primary correction, causes color distortion
    # (faded picture)
    'fast=0'
    'dither=fsb'
    'wpadapt=identity'
    # FFmpeg will fail if it cannot detect input primaries so manually
    # specify them.
  )

  if [ "$inputColorSpace" != 'unknown' ]; then
    paramaters+=("ispace=$inputColorSpace")
  fi

  if [ "$inputColorPrimaries" != 'unknown' ]; then
    paramaters+=("iprimaries=$inputColorPrimaries")
  fi

  if [ "$inputColorTransfer" != 'unknown' ]; then
    paramaters+=("itrc=$inputColorTransfer")
  fi

  if [ "$inputColorRange" != 'unknown' ]; then
    paramaters+=("irange=$inputColorRange")
  fi

  local IFS=":"
  echo "colorspace=${paramaters[*]}"
}
