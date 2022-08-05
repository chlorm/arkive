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

function arkive_video_aspect_ratio {
  stl_func_reqargs '2' "$#"
  local -r file="$2"
  local sourceAspectRatio
  local -r stream="$1"

  sourceAspectRatio="$(
    arkive_ffprobe '-' "$stream" 'stream' 'display_aspect_ratio' "$file"
  )"

  stl_type_str "$sourceAspectRatio"

  echo "$sourceAspectRatio"
}

function arkive_video_color_primaries {
  stl_func_reqargs '2' "$#"
  local -r file="$2"
  local sourceColorPrimaries
  local -r stream="$1"

  sourceColorPrimaries="$(
    arkive_ffprobe '-' "$stream" 'stream' 'color_primaries' "$file"
  )"

  # Fallback
  if [ "$sourceColorPrimaries" == 'unknown' ]; then
    sourceColorPrimaries='bt709'
  fi

  stl_type_str "$sourceColorPrimaries"

  echo "$sourceColorPrimaries"
}

function arkive_video_color_range {
  stl_func_reqargs '2' "$#"
  local -r file="$2"
  local sourceColorRange
  local -r stream="$1"

  sourceColorRange="$(arkive_ffprobe '-' "$stream" 'stream' 'color_range' "$file")"

  # Fallback
  if [ "$sourceColorRange" == 'N/A' ]; then
    sourceColorRange='mpeg'
  fi

  stl_type_str "$sourceColorRange"

  echo "$sourceColorRange"
}

function arkive_video_color_space {
  stl_func_reqargs '2' "$#"
  local -r file="$2"
  local sourceColorSpace
  local -r stream="$1"

  sourceColorSpace="$(arkive_ffprobe '-' "$stream" 'stream' 'color_space' "$file")"

  # Fallback
  if [ "$sourceColorSpace" == 'unknown' ]; then
    sourceColorSpace='bt709'
  fi

  stl_type_str "$sourceColorSpace"

  echo "$sourceColorSpace"
}

function arkive_video_color_transfer {
  stl_func_reqargs '2' "$#"
  local -r file="$2"
  local sourceColorTransfer
  local -r stream="$1"

  sourceColorTransfer="$(
    arkive_ffprobe '-' "$stream" 'stream' 'color_transfer' "$file"
  )"

  # Fallback
  if [ "$sourceColorTransfer" == 'unknown' ]; then
    sourceColorTransfer='bt709'
  fi

  stl_type_str "$sourceColorTransfer"

  echo "$sourceColorTransfer"
}

function arkive_video_frame_rate {
  stl_func_reqargs '2' "$#"
  local -r file="$2"
  local sourceFrameRate
  local -r stream="$1"

  sourceFrameRate="$(arkive_ffprobe '-' "$stream" 'stream' 'r_frame_rate' "$file")"

  stl_type_str "$sourceFrameRate"

  echo "$sourceFrameRate"
}

function arkive_video_height {
  stl_func_reqargs '2' "$#"
  local -r file="$2"
  local height
  local -r stream="$1"

  height=$(arkive_ffprobe '-' "$stream" 'stream' 'height' "$file")

  stl_type_int "$height"

  echo "$height"
}

function arkive_video_width {
  stl_func_reqargs '2' "$#"
  local -r file="$2"
  local -r stream="$1"
  local width

  width=$(arkive_ffprobe '-' "$stream" 'stream' 'width' "$file")

  stl_type_int "$width"

  echo "$width"
}
