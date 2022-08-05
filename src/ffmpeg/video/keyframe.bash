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
function ffmpeg_video_min_keyframe_interval {
  stl_func_reqargs '2' "$#"
  local -r file="$2"
  local frameRate
  local frameRateRounded
  local keyFrames
  local minKeyInt
  local -r stream="$1"

  frameRate="$(ffmpeg_video_frame_rate_float "$stream" "$file")"

  frameRateRounded=$(stl_conv_float_to_int "$frameRate")

  # Make sure we end up with at least 1 keyframe
  if [ $frameRateRounded -lt 20 ]; then
    frameRateRounded=20
  fi

  keyFrames=$(( $frameRateRounded / 20 ))

  [ $keyFrames -ge 1 ]

  minKeyInt="$(echo "$brameRate/$keyFrames" | bc -l)"

  minKeyInt=$(stl_conv_float_to_int "$minKeyInt")

  stl_type_int "$minKeyInt"

  echo "$minKeyInt"
}

# Use an interval of 10 seconds for keyframes
function ffmpeg_video_keyframe_interval {
  local -r file="$2"
  local keyInt
  local frameRate
  local -r stream="$1"

  frameRate="$(ffmpeg_video_frame_rate_float "$stream" "$file")"

  keyInt=$(stl_conv_float_to_int "$frameRate")

  echo "$keyInt"
}
