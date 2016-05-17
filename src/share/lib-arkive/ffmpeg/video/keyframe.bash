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

# Use 1 keyframe per 20fps, e.g. 60fps = 3
function FFmpeg::Video.min_keyframe_interval {
  local KeyFrames
  local MinKeyInt
  local FrameRate
  local FrameRateRounded
  local Stream="${1}"

  FrameRate="$(Video::FrameRate "${Stream}")"

  # Rounds SourceFrameRate to the nearest whole number
  FrameRateRounded=$(
    printf %.0f $(
      echo ${FrameRate} |
      bc -l
    )
  )

  # Make sure we end up with at least 1 keyframe
  if [ ${FrameRateRounded} -lt 20 ] ; then
    FrameRateRounded=20
  fi

  KeyFrames=$(( ${FrameRateRounded} / 20 ))

  [ ${KeyFrames} -ge 1 ]

  MinKeyInt=$(( ${FrameRate} / ${KeyFrames} ))

  echo "${MinKeyInt}"
}

# Use an interval of 10 seconds for keyframes
function FFmpeg::Video.keyframe_interval {
  local KeyInt
  local FrameRate

  FrameRate="$(Video::FrameRate "${Stream}")"

  KeyInt=$(( ${FrameRate} * 10 ))

  [ ${KeyInt} -gt ${FrameRate} ]

  echo "${KeyInt}"
}
