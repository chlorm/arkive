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

# This is a rudimentary system for setting the minimum decoder level, it
# is in now way precise.  Level 3.0 is the minimum supported level.
function FFmpeg::Video.level:h264 {
  local File="${2}"
  local Stream="${1}"

  # FIXME: used cropped width
  FrameWidth="$(Video::Width "${Stream}" "${File}")"
  # Evaluate frame rate incase a fractional number is returned
  FrameRate="$(echo "$(Video::FrameRate "${Stream}" "${File}")" | bc)"

  if [ ${FrameWidth} -le 720 ] ; then
    echo "3"
  elif [ ${FrameWidth} -le 1280 ] && [ ${FrameRate} -le 60 ] ; then
    echo "3.2"
  elif [ ${FrameWidth} -le 1920 ] && [ ${FrameRate} -le 30 ] ; then
    echo "4.1"
  elif [ ${FrameWidth} -le 1920 ] && [ ${FrameRate} -le 60 ] ; then
    echo "4.2"
  elif [ ${FrameWidth} -le 2560 ] && [ ${FrameRate} -le 30 ] ; then
    echo "5"
  elif [ ${FrameWidth} -le 4096 ] && [ ${FrameRate} -le 29 ] ; then
    echo "5.1"
  elif [ ${FrameWidth} -le 4096 ] && [ ${FrameRate} -le 60 ] ; then
    echo "5.2"
  else
    Error::Message 'failed to detect decoder level'
    return 1
  fi
}