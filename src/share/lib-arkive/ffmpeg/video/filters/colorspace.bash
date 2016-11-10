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
  #local File="${2}"
  #local Stream="${1}"

  if [ ${FFMPEG_VIDEO_BITDEPTH} -gt 8 ] ; then
    ColorPrimaries='bt2020'
  else
    ColorPrimaries='bt709'
  fi

  if [ "${ColorPrimaries}" == 'bt2020' ] ; then
    ColorSpace='bt2020ncl'
  else
    ColorSpace='bt709'
  fi

  if [ "${ColorPrimaries}" == 'bt2020' ] ; then
    ColorTransfer="bt2020-${FFMPEG_VIDEO_BITDEPTH}"
  else
    ColorTransfer='bt709'
  fi

  if [ ${FFMPEG_VIDEO_BITDEPTH} -gt 8 ] ; then
    PixelFormat="yuv${FFMPEG_VIDEO_CHROMASUBSAMPLING}p${FFMPEG_VIDEO_BITDEPTH}"
  else
    PixelFormat="yuv${FFMPEG_VIDEO_CHROMASUBSAMPLING}p"
  fi

  #echo "colorspace=space=${ColorSpace}:trc=${ColorTransfer}:primaries=${ColorPrimaries}:range=mpeg:format=yuv420p10:dither=fsb"
}