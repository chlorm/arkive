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

function ffmpeg_audio_sample_rate {
  stl_func_reqargs '3' "$#"
  local -r file="$2"
  local -r index="$3"
  local sampleRate
  local -r stream="$1"

  case ${FFMPEG_AUDIO_SAMPLERATE} in
    8000|11025|12000|16000|22050|24000|32000|44100|48000|\
        64000|88200|96000|176400|192000) true ;;
    *)
      stl_log_error "invalid samplerate: $FFMPEG_AUDIO_SAMPLERATE"
      return 1
      ;;
  esac

  sampleRate=$(arkive_audio_sample_rate "$stream" "$file")

  if [ $sampleRate -lt $FFMPEG_AUDIO_SAMPLERATE_MINIMUM ]; then
    stl_log_error \
      "source sample rate less than required $FFMPEG_AUDIO_SAMPLERATE_MINIMUM: $sampleRate in: $file"
    return 1
  fi

  if [ "$FFMPEG_AUDIO_ENCODER" == 'opus' ] && \
     [ $FFMPEG_AUDIO_SAMPLERATE -ne 48000 ]; then
     stl_log_error "opus only supports 48000Hz sample rates"
     return 1
  fi

  echo "-ar:$index $FFMPEG_AUDIO_SAMPLERATE"
}
