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

# bitrate from a fixed bpp value:
# bitrate = (w * h * fps * bpp) / 1024
function ffmpeg_video_bitrate {
  stl_func_reqargs '2' "$#"
  local -r bpp="$FFMPEG_VIDEO_BITSPERPIXEL"
  local -r file="$2"
  local frameRate
  local height
  local -r stream="$1"
  local width

  if [ "$FFMPEG_VIDEO_FRAMERATE" == 'source' ]; then
    frameRate="$(ffmpeg_video_frame_rate "$stream" "$file")"
  else
    frameRate="$FFMPEG_VIDEO_FRAMERATE"
  fi
  # FIXME: use output width/height (factor based on crop & scale filters)
  if [ "$FFMPEG_VIDEO_HEIGHT" != 'source' ]; then
    height=$FFMPEG_VIDEO_HEIGHT
  else
    height=$(arkive_video_height "$stream" "$file")
  fi
  stl_type_int "$height"
  if [ "$FFMPEG_VIDEO_WIDTH" != 'source' ]; then
    width=$FFMPEG_VIDEO_WIDTH
  else
    width=$(arkive_video_width "$stream" "$file")
  fi
  stl_type_int "$width"

  # XXX: BC defaults to a scale of 0, which will result in a rounding error,
  #      meaning the number may be much lower than it should be.
  bitrate="$(
    echo "scale=10;(($width*$height*($frameRate)*$bpp)/1024)" | bc -l
  )"

  # TODO: refactor the bpp -> bitrate equation to work on a curve.  This is
  #       a hack in the meantime.
  #
  #                                 x
  #                       x
  #                   x
  #                x
  #              x
  #           x
  #       x
  # x x
  #
  # Quadruple the bitrate for 360p and below
  if [ $width -lt 640 ] && [ $height -lt 480 ]; then
    bitrate="$(echo "scale=10;($bitrate*4)" | bc -l)"
  # Triple the bitrate for 640p
  elif [ $width -lt 1280 ] && [ $height -lt 720 ]; then
    bitrate="$(echo "scale=10;($bitrate*3)" | bc -l)"
  # Cut the bitrate in half for >=4k
  elif [ $width -gt 3000 ] && [ $height -gt 1080 ]; then
    bitrate="$(echo "scale=10;($bitrate*0.5)" | bc -l)"
  fi

  # Round to nearest whole number
  bitrate="$(printf "%1.0f" "$bitrate")"

  stl_type_int "$bitrate"

  echo "$bitrate"
}

# Calculate the bits per pixel value based on a fixed resolution and fps
# This formula uses 1920x1080@23.976
# bpp = (bitrate * 1024) / (1920 * 1080 * (24000 / 1001))
function ffmpeg_video_bpp {
  stl_func_reqargs '1' "$#"
  local -r bitrate="$1"
  local bpp

  bpp="$(echo "(($bitrate*1024)/(1920*1080*(24000/1001)))" | bc -l)"

  # BC truncates leading zeros, make sure to add one if necessary
  if [[ "$bpp" =~ ^. ]]; then
    bpp="0$bpp"
  fi

  stl_type_float "$bpp"

  echo "$bpp"
}
