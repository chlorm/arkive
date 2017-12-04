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

ffmpeg_audio_filters_ebu_r128() {
  Function::RequiredArgs '2' "$#"
  local EBUR128
  local -r File="${2}"
  local Parameter
  local -a Parameters
  local ParameterString
  local R128I="${FFMPEG_AUDIO_FILTER_EBUR128_I}"
  local R128LRA="${FFMPEG_AUDIO_FILTER_EBUR128_LRA}"
  local R128TP="${FFMPEG_AUDIO_FILTER_EBUR128_TP}"
  local R128THRESH
  local R128OFFSET
  local -r Stream="${1}"

  Log::Message 'info' 'detecting ebu r128 levels, this will take a while'

  EBUR128="$(
    ffmpeg -i "${File}" \
      -hide_banner \
      -map 0:${Stream} \
      -filter:0 "loudnorm=i=${R128I}:lra=${R128LRA}:tp=${R128TP}:dual_mono=1:print_format=json" \
      -f null - 2>&1 || {
        Log::Message 'error' "ebur filter failed"
        return 1
      }
  )"

  # FIXME: The output text and json are inter-mingled and this assumes
  #        that the last 12 lines are the json output.
  EBUR128="$(echo "${EBUR128}" | tail -12)"

  R128I="$(echo "${EBUR128}" | jq -r -c -M '.input_i')"
  Var::Type.string "${R128I}"
  # Fallback for null audio
  if [ "${R128I}" == '-inf' ]; then
    R128I="${FFMPEG_AUDIO_FILTER_EBUR128_I}"
  fi
  Log::Message 'info' "ebur128 I: ${R128I}"
  R128LRA="$(echo "${EBUR128}" | jq -r -c -M '.input_lra')"
  Var::Type.string "${R128LRA}"
  Log::Message 'info' "ebur128 LRA: ${R128LRA}"
  R128TP="$(echo "${EBUR128}" | jq -r -c -M '.input_tp')"
  Var::Type.string "${R128TP}"
  # Fallback for null audio
  if [ "${R128TP}" == '-inf' ]; then
    R128TP="${FFMPEG_AUDIO_FILTER_EBUR128_TP}"
  fi
  Log::Message 'info' "ebur128 TP: ${R128TP}"
  R128THRESH="$(echo "${EBUR128}" | jq -r -c -M '.input_thresh')"
  Var::Type.string "${R128THRESH}"
  Log::Message 'info' "ebur128 Thresh: ${R128THRESH}"
  R128OFFSET="$(echo "${EBUR128}" | jq -r -c -M '.target_offset')"
  Var::Type.string "${R128OFFSET}"
  Log::Message 'info' "ebur128 Offset: ${R128OFFSET}"
  # Fallback for null audio
  if [ "${R128OFFSET}" == 'inf' ]; then
    R128OFFSET='0'
  fi

  Parameters=(
    "i=${FFMPEG_AUDIO_FILTER_EBUR128_I}"
    "lra=${FFMPEG_AUDIO_FILTER_EBUR128_LRA}"
    "tp=${FFMPEG_AUDIO_FILTER_EBUR128_TP}"
    "measured_i=${R128I}"
    "measured_lra=${R128LRA}"
    "measured_tp=${R128TP}"
    "measured_thresh=${R128THRESH}"
    "offset=${R128OFFSET}"
    'linear=1'
    'dual_mono=1'
  )

  local IFS=":"
  echo "loudnorm=${Parameters[*]}"
}
