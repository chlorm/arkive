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
  local File="${2}"
  local SampleFormat
  local SampleRate
  local Stream="${1}"

  SampleFormat="$(Audio::SampleFormat "${Stream}" "${File}")"
  SampleRate="$(Audio::SampleRate "${Stream}" "${File}")"

  # Supported sample rates
  [[ "${ARKIVE_AUDIO_SAMPLE_RATE}" == +(44100|48000|96000|192000) ]]

  # Refuse to upsample unless the codec is opus or the source sample rate
  # is less than 44100Hz. Opus natively uses 48000Hz.
  if ([ ${ARKIVE_AUDIO_SAMPLE_RATE} -gt ${SampleRate} ] && \
      [ ${SampleRate} -gt 44100 ]) || \
     ([ "${ARKIVE_AUDIO_CODEC}" == 'opus' ] && \
      [ ${ARKIVE_AUDIO_SAMPLE_RATE} -ne 48000 ]) ; then
    Debug::Message 'error' 'upsampling is only allowed for < 44100kHz -> 44100kHz'
    Debug::Message 'error' 'and for opus anything that != 48000kHz'
    return 1
  fi

  # Assume `Planar Floating point format` is 16bit
  if [ "${SampleFormat}" == 'fltp' ] ; then
    SampleFormat='s16'
  fi

  # Only resample when converting sample rates or sample formats (bit depth)
  if [ ${ARKIVE_AUDIO_SAMPLE_RATE} -ne ${SampleRate} ] || \
     [ "${SampleFormat}" != 's16' ] ; then
    echo "aresample=resampler=soxr:precision=28:cheby=1:isf=${SampleFormat}:osf=s16:tsf=s32:isr=${SampleRate}:osr=${ARKIVE_AUDIO_SAMPLE_RATE}:cutoff=0.91:dither_method=0"
  fi
}
