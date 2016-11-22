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

function FFmpeg::Audio.encoder {
  Function::RequiredArgs '3' "$#"
  local Encoder EncoderParams
  local -r File="${2}"
  local -r Index="${3}"
  local -r Stream="${1}"

  case "${FFMPEG_AUDIO_ENCODER}" in
    'copy')
      Encoder='copy'
      ;;
    'ffaac')
      Encoder='aac'
      EncoderParams="$(FFmpeg::Audio.encoder:ffaac "${Index}")"
      ;;
    'fdk-aac')
      Encoder='libfdk_aac'
      EncoderParams="$(FFmpeg::Audio.encoder:fdk_aac "${Index}")"
      ;;
    'opus')
      Encoder='libopus'
      EncoderParams="$(FFmpeg::Audio.encoder:opus "${Index}")"
      ;;
    'flac') Encoder='flac' ;;
    *)
      Log::Message 'error' "invalid audio encoder \`${FFMPEG_AUDIO_ENCODER}' specified"
      return 1
      ;;
  esac

  echo "-c:${Index} ${Encoder}${EncoderParams:+ ${EncoderParams}}"
}
