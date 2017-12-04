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

function FFmpeg::Audio.filters:resample {
  Function::RequiredArgs '2' "$#"
  local ChannelCount
  local ChannelLayout
  local -r File="$2"
  local SampleFormat
  local SampleRate
  local -r Stream="$1"

  ChannelCount="$(Audio::Channels "$Stream" "$File")"
  ChannelLayout="$(Audio::ChannelLayout "$Stream" "$File")"
  SampleFormat="$(Audio::SampleFormat "$Stream" "$File")"
  SampleRate="$(Audio::SampleRate "$Stream" "$File")"

  case $FFMPEG_AUDIO_SAMPLERATE in
    8000|11025|12000|16000|22050|24000|32000|44100|48000|\
        64000|88200|96000|176400|192000) true ;;
    *)
      Log::Message 'error' "invalid samplerate: $FFMPEG_AUDIO_SAMPLERATE"
      return 1
      ;;
  esac

  # http://forum.videohelp.com/threads/373264-FFMpeg-List-of-working-sample-formats-per-format-and-encoder
  case "$FFMPEG_AUDIO_ENCODER" in
    'flac') OutputSampleFormat='s32' ;;
    'opus') OutputSampleFormat='flt' ;;
    'ac3'|'ffaac'|'fdk-aac'|'eac3'|'vorbis') OutputSampleFormat='s16' ;;
  esac

  Parameters=(
    "ich=$ChannelCount"
    "och=$ChannelCount"  # Leave input unchanged, pan filter will remap
    "uch=$ChannelCount"
    "isr=$SampleRate"
    "osr=$FFMPEG_AUDIO_SAMPLERATE"
    "isf=$SampleFormat"
    "osf=$OutputSampleFormat"
    #'tsf=s32'  # FIXME
    "icl=$ChannelLayout"
    "ocl=$ChannelLayout"  # Leave input unchanged, pan filter will remap
    'dither_method=0'
    'resampler=soxr'
    'linear_interp=0'
    'cutoff=0.91'
    'precision=28'
    'cheby=1'
    'matrix_encoding=none'
  )

  local IFS=":"
  echo "aresample=${Parameters[*]}"
}
