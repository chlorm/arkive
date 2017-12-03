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

function Video::AspectRatio {
  Function::RequiredArgs '2' "$#"
  local -r File="$2"
  local SourceAspectRatio
  local -r Stream="$1"

  SourceAspectRatio="$(
    FFprobe '-' "$Stream" 'stream' 'display_aspect_ratio' "$File"
  )"

  Var::Type.string "$SourceAspectRatio"

  echo "$SourceAspectRatio"
}

function Video::ColorPrimaries {
  Function::RequiredArgs '2' "$#"
  local -r File="$2"
  local SourceColorPrimaries
  local -r Stream="$1"

  SourceColorPrimaries="$(
    FFprobe '-' "$Stream" 'stream' 'color_primaries' "$File"
  )"

  # Fallback
  if [ "$SourceColorPrimaries" == 'unknown' ]; then
    SourceColorPrimaries='bt709'
  fi

  Var::Type.string "$SourceColorPrimaries"

  echo "$SourceColorPrimaries"
}

function Video::ColorRange {
  Function::RequiredArgs '2' "$#"
  local -r File="$2"
  local SourceColorRange
  local -r Stream="$1"

  SourceColorRange="$(FFprobe '-' "$Stream" 'stream' 'color_range' "$File")"

  # Fallback
  if [ "$SourceColorRange" == 'N/A' ]; then
    SourceColorRange='mpeg'
  fi

  Var::Type.string "$SourceColorRange"

  echo "$SourceColorRange"
}

function Video::ColorSpace {
  Function::RequiredArgs '2' "$#"
  local -r File="$2"
  local SourceColorSpace
  local -r Stream="$1"

  SourceColorSpace="$(FFprobe '-' "$Stream" 'stream' 'color_space' "$File")"

  # Fallback
  if [ "$SourceColorSpace" == 'unknown' ]; then
    SourceColorSpace='bt709'
  fi

  Var::Type.string "$SourceColorSpace"

  echo "$SourceColorSpace"
}

function Video::ColorTransfer {
  Function::RequiredArgs '2' "$#"
  local -r File="$2"
  local SourceColorTransfer
  local -r Stream="$1"

  SourceColorTransfer="$(
    FFprobe '-' "$Stream" 'stream' 'color_transfer' "$File"
  )"

  # Fallback
  if [ "$SourceColorTransfer" == 'unknown' ]; then
    SourceColorTransfer='bt709'
  fi

  Var::Type.string "$SourceColorTransfer"

  echo "$SourceColorTransfer"
}

function Video::FrameRate {
  Function::RequiredArgs '2' "$#"
  local -r File="$2"
  local SourceFrameRate
  local -r Stream="$1"

  SourceFrameRate="$(FFprobe '-' "$Stream" 'stream' 'r_frame_rate' "$File")"

  Var::Type.string "$SourceFrameRate"

  echo "$SourceFrameRate"
}

function Video::Height {
  Function::RequiredArgs '2' "$#"
  local -r File="$2"
  local Height
  local -r Stream="$1"

  Height=$(FFprobe '-' "$Stream" 'stream' 'height' "$File")

  Var::Type.integer "$Height"

  echo "$Height"
}

function Video::Width {
  Function::RequiredArgs '2' "$#"
  local -r File="$2"
  local -r Stream="$1"
  local Width

  Width=$(FFprobe '-' "$Stream" 'stream' 'width' "$File")

  Var::Type.integer "$Width"

  echo "$Width"
}
