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

# Bitrate from a fixed bpp value:
# bitrate = (w * h * fps * bpp) / 1024
function FFmpeg::Video.bitrate {
  Function::RequiredArgs '2' "$#"
  local -r Bpp="$FFMPEG_VIDEO_BITSPERPIXEL"
  local -r File="$2"
  local FrameRate
  local Height
  local -r Stream="$1"
  local Width

  if [ "$FFMPEG_VIDEO_FRAMERATE" == 'source' ]; then
    FrameRate="$(FFmpeg::Video.frame_rate "$Stream" "$File")"
  else
    FrameRate="$FFMPEG_VIDEO_FRAMERATE"
  fi
  # FIXME: use output width/height (factor based on crop & scale filters)
  if [ "$FFMPEG_VIDEO_HEIGHT" != 'source' ]; then
    Height=$FFMPEG_VIDEO_HEIGHT
  else
    Height=$(Video::Height "$Stream" "$File")
  fi
  Var::Type.integer "$Height"
  if [ "$FFMPEG_VIDEO_WIDTH" != 'source' ]; then
    Width=$FFMPEG_VIDEO_WIDTH
  else
    Width=$(Video::Width "$Stream" "$File")
  fi
  Var::Type.integer "$Width"

  # XXX: BC defaults to a scale of 0, which will result in a rounding error,
  #      meaning the number may be much lower than it should be.
  Bitrate="$(
    echo "scale=10;(($Width*$Height*($FrameRate)*$Bpp)/1024)" | bc -l
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
  if [ $Width -lt 640 ] && [ $Height -lt 480 ]; then
    Bitrate="$(echo "scale=10;($Bitrate*4)" | bc -l)"
  # Triple the bitrate for 640p
  elif [ $Width -lt 1280 ] && [ $Height -lt 720 ]; then
    Bitrate="$(echo "scale=10;($Bitrate*3)" | bc -l)"
  # Cut the bitrate in half for >=4k
  elif [ $Width -gt 3000 ] && [ $Height -gt 1080 ]; then
    Bitrate="$(echo "scale=10;($Bitrate*0.5)" | bc -l)"
  fi

  # Round to nearest whole number
  Bitrate="$(printf "%1.0f" "$Bitrate")"

  Var::Type.integer "$Bitrate"

  echo "$Bitrate"
}

# Calculate the bits per pixel value based on a fixed resolution and fps
# This formula uses 1920x1080@23.976
# bpp = (bitrate * 1024) / (1920 * 1080 * (24000 / 1001))
function FFmpeg::Video.bpp {
  local -r Bitrate="${1}"
  local Bpp

  Bpp="$(echo "(($Bitrate*1024)/(1920*1080*(24000/1001)))" | bc -l)"

  # BC truncates leading zeros, make sure to add one if necessary
  if [[ "$Bpp" =~ ^. ]]; then
    Bpp="0$Bpp"
  fi

  Var::Type.float "$Bpp"

  echo "$Bpp"
}
