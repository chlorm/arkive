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

function ffmpeg_audio_filters_resample {
  stl_func_reqargs '2' "$#"
  local channelCount
  local channelLayout
  local channelLayoutMapTo
  local -r file="$2"
  local sampleFormat
  local sampleRate
  local -r stream="$1"

  channelCount="$(arkive_audio_channels "$stream" "$file")"
  channelLayout="$(arkive_audio_channel_layout "$stream" "$file")"
  sampleFormat="$(arkive_audio_sample_format "$stream" "$file")"
  sampleRate="$(arkive_audio_sample_rate "$stream" "$file")"
  channelLayoutMapTo="${FFMPEG_AUDIO_CHANNEL_LAYOUT_MAPPINGS[$channelLayout]}"

  case $FFMPEG_AUDIO_SAMPLERATE in
    8000|11025|12000|16000|22050|24000|32000|44100|48000|\
        64000|88200|96000|176400|192000) true ;;
    *)
      stl_log_error "invalid samplerate: $FFMPEG_AUDIO_SAMPLERATE"
      return 1
      ;;
  esac

  # http://forum.videohelp.com/threads/373264-FFMpeg-List-of-working-sample-formats-per-format-and-encoder
  case "$FFMPEG_AUDIO_ENCODER" in
    'flac') outputSampleFormat='s32' ;;
    'opus') outputSampleFormat='flt' ;;
    'ac3'|'ffaac'|'fdk-aac'|'eac3'|'vorbis') outputSampleFormat='s16' ;;
  esac

  parameters=(
    "ich=$channelCount"
    "och=$channelCount"  # Leave input unchanged, pan filter will remap
    "uch=$channelCount"
    "isr=$sampleRate"
    "osr=$FFMPEG_AUDIO_SAMPLERATE"
    "isf=$sampleFormat"
    "osf=$outputSampleFormat"
    #'tsf=s32'  # FIXME
    "icl=$channelLayoutMapTo"
    "ocl=$channelLayoutMapTo"  # Leave input unchanged, pan filter will remap
    'dither_method=0'
    'resampler=soxr'
    'linear_interp=0'
    'cutoff=0.91'
    'precision=28'
    'cheby=1'
    'matrix_encoding=none'
  )

  local IFS=":"
  echo "aresample=${parameters[*]}"
}
