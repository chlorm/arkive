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

# Selects the video stream to use if multiple exist
function Video::StreamSelector {
  local VideoStreams=()

  VideoStreams=( $(FFprobe 'v' '-' 'stream' 'index') )

  # At least 1 video stream is required
  if [ ${#VideoStreams[@]} -eq 1 ] ; then
    echo "${VideoStreams[0]}"
  elif [ ${#VideoStreams[@]} -gt 1 ] ; then
    # FIXME: Add support for source with multiple video streams
    return 1
  else
    Error::Message 'no video stream found'
    return 1
  fi
}

function Video::Height {
  local Height

  Height=$(FFprobe '-' "${__videostream__}" 'stream' 'height')

  String::NotNull "${Height}"

  echo "${Height}"
}

function Video::Width {
  local Width

  Width=$(FFprobe '-' "${__videostream__}" 'stream' 'width')

  String::NotNull "${Width}"

  echo "${Width}"
}

function Video::FrameRate {
  local SourceFrameRate

  SourceFrameRate="$(FFprobe '-' "${__videostream__}" 'stream' 'r_frame_rate')"

  String::NotNull "${SourceFrameRate}"

  echo "${SourceFrameRate}"
}