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

function FFmpeg::Video.filters:colorspace() {
  local ColorPrimaries
  local ColorRange
  local ColorSpace
  local ColorTransfer
  local File="${2}"
  local InputColorPrimaries
  local InputColorRange
  local InputColorSpace
  local InputColorTransfer
  local -a Paramaters
  local Stream="${1}"

  InputColorPrimaries="$(Video::ColorPrimaries "${Stream}" "${File}")"
  InputColorRange="$(Video::ColorRange "${Stream}" "${File}")"
  InputColorSpace="$(Video::ColorSpace "${Stream}" "${File}")"
  InputColorTransfer="$(Video::ColorTransfer "${Stream}" "${File}")"

  if [ ${FFMPEG_VIDEO_BITDEPTH} -gt 8 ]; then
    ColorPrimaries='bt2020'
    ColorRange='mpeg'
    ColorSpace='bt2020ncl'
    ColorTransfer="bt2020-${FFMPEG_VIDEO_BITDEPTH}"
    PixelFormat="yuv${FFMPEG_VIDEO_CHROMASUBSAMPLING}p${FFMPEG_VIDEO_BITDEPTH}"
  else
    ColorPrimaries='bt709'
    ColorRange='mpeg'
    ColorSpace='bt709'
    ColorTransfer='bt709'
    PixelFormat="yuv${FFMPEG_VIDEO_CHROMASUBSAMPLING}p"
  fi

  Paramaters=(
    "space=${ColorSpace}"
    "trc=${ColorTransfer}"
    "primaries=${ColorPrimaries}"
    "range=${ColorRange}"
    "format=${PixelFormat}"
    # Don't try to apply Gamma/Primary correction, causes color distortion
    # (faded picture)
    'fast=1'
    'dither=none'
    'wpadapt=identity'
    # FFmpeg will fail if it cannot detect input primaries so manually
    # specify them.
    "ispace=${InputColorSpace}"
    "iprimaries=${InputColorPrimaries}"
    "itrc=${InputColorTransfer}"
    "irange=${InputColorRange}"
  )

  local IFS=":"
  echo "colorspace=${Paramaters[*]}"
}
