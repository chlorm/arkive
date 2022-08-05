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

function ffmpeg_audio_filters_ebu_r128() {
  stl_func_reqargs '2' "$#"
  local ebur128
  local -r file="${2}"
  local parameter
  local -a parameters
  local parameterString
  local r128I="${FFMPEG_AUDIO_FILTER_EBUR128_I}"
  local r128LRA="${FFMPEG_AUDIO_FILTER_EBUR128_LRA}"
  local r128TP="${FFMPEG_AUDIO_FILTER_EBUR128_TP}"
  local r128THRESH
  local r128OFFSET
  local -r stream="${1}"

  stl_log_info 'detecting ebu r128 levels, this will take a while'

  ebur128="$(
    ffmpeg -i "${file}" \
      -hide_banner \
      -map 0:${stream} \
      -filter:0 "loudnorm=i=${r128I}:lra=${r128LRA}:tp=${r128TP}:dual_mono=1:print_format=json" \
      -f null - 2>&1 || {
        stl_log_error "ebur filter failed"
        return 1
      }
  )"

  # FIXME: The output text and json are inter-mingled and this assumes
  #        that the last 12 lines are the json output.
  ebur128="$(echo "${ebur128}" | tail -12)"

  r128I="$(echo "${ebur128}" | jq -r -c -M '.input_i')"
  stl_type_str "${r128I}"
  # Fallback for null audio
  if [ "${r128I}" == '-inf' ]; then
    r128I="${FFMPEG_AUDIO_FILTER_EBUR128_I}"
  fi
  stl_log_info "ebur128 I: ${r128I}"
  r128LRA="$(echo "${ebur128}" | jq -r -c -M '.input_lra')"
  stl_type_str "${r128LRA}"
  stl_log_info "ebur128 LRA: ${r128LRA}"
  r128TP="$(echo "${ebur128}" | jq -r -c -M '.input_tp')"
  stl_type_str "${r128TP}"
  # Fallback for null audio
  if [ "${r128TP}" == '-inf' ]; then
    r128TP="${FFMPEG_AUDIO_FILTER_EBUR128_TP}"
  fi
  stl_log_info "ebur128 TP: ${r128TP}"
  r128THRESH="$(echo "${ebur128}" | jq -r -c -M '.input_thresh')"
  stl_type_str "${r128THRESH}"
  stl_log_info "ebur128 Thresh: ${r128THRESH}"
  r128OFFSET="$(echo "${ebur128}" | jq -r -c -M '.target_offset')"
  stl_type_str "${r128OFFSET}"
  stl_log_info "ebur128 Offset: ${r128OFFSET}"
  # Fallback for null audio
  if [ "${r128OFFSET}" == 'inf' ]; then
    r128OFFSET='0'
  fi

  parameters=(
    "i=${FFMPEG_AUDIO_FILTER_EBUR128_I}"
    "lra=${FFMPEG_AUDIO_FILTER_EBUR128_LRA}"
    "tp=${FFMPEG_AUDIO_FILTER_EBUR128_TP}"
    "measured_i=${r128I}"
    "measured_lra=${r128LRA}"
    "measured_tp=${r128TP}"
    "measured_thresh=${r128THRESH}"
    "offset=${r128OFFSET}"
    'linear=1'
    'dual_mono=1'
  )

  local IFS=":"
  echo "loudnorm=${parameters[*]}"
}
