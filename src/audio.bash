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

function arkive_audio_bitrate {
  stl_func_reqargs '2' "$#"
  local -i bitrate
  local -r file="$2"
  local -r stream="$1"

  bitrate=$(arkive_ffprobe '-' "$stream" 'stream' 'bit_rate' "$file")

  stl_type_int "$bitrate"

  echo "$bitrate"
}

function arkive_audio_channel_layout {
  stl_func_reqargs '2' "$#"
  local channelLayout
  local -r file="$2"
  local -r stream="$1"

  channelLayout="$(arkive_ffprobe '-' "$stream" 'stream' 'channel_layout' "$file")"

  stl_type_str "$channelLayout"

  echo "$channelLayout"
}

function arkive_audio_channels {
  stl_func_reqargs '2' "$#"
  local -i channels
  local -r file="$2"
  local -r stream="$1"

  channels=$(arkive_ffprobe '-' "$stream" 'stream' 'channels' "$file")

  stl_type_int "$channels"

  echo "$channels"
}

function arkive_audio_sample_format {
  stl_func_reqargs '2' "$#"
  local -r file="$2"
  local sampleFormat
  local -r stream="$1"

  sampleFormat=$(arkive_ffprobe '-' "$stream" 'stream' 'sample_fmt' "$file")

  stl_type_str "$sampleFormat"

  echo "$sampleFormat"
}

function arkive_audio_sample_rate {
  stl_func_reqargs '2' "$#"
  local -r file="$2"
  local -i sampleRate
  local -r stream="$1"

  sampleRate=$(arkive_ffprobe '-' "$stream" 'stream' 'sample_rate' "$file")

  stl_type_int "$sampleRate"

  echo "$sampleRate"
}
