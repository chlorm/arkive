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

function arkive_ffprobe {
  stl_func_reqargs '5' "$#"
  local streamType="$1"
  local stream="$2"
  local -r entKey="$3"
  local entKey2
  local -r entVal="$4"
  local -r file="$5"
  local ffprobeArgs
  local -a ffprobeArgsList
  local -a ffprobeOutput

  stl_log_info "1:$1, 2:$2, 3:$3, 4:$4, 5:$5,"

  if [ "$streamType" == '-' ]; then
    unset streamType
  elif [[ ! "$streamType" == @('a'|'s'|'v') ]]; then
    stl_log_error "invalid stream type: $streamType"
  fi

  if [ "$stream" == '-' ]; then
    unset stream
  elif [ ! $stream -ge 0 ]; then
    stl_log_error "invalid stream id: $stream"
  fi

  if [ ! -f "$file" ]; then
    stl_log_error "invalid file: $file"
  fi

  ffprobeArgsList=(
    '-v' 'error'
    '-select_streams' "${streamType:-}${streamType:+${stream:+:}}${stream:-}"
    '-show_entries' "$entKey=$entVal"
    '-print_format' 'json'
    "$file"
  )

  ffprobeArgs="${ffprobeArgsList[@]}"
  stl_log_info "ffprobe $ffprobeArgs"
  if [ "$entKey" == 'stream' ]; then
    entKey2='streams'
  else
    entKey2="$entKey"
  fi
  # We have to use this fugly json hack because there is not way to
  # differentiate between programs/streams/key and streams/key.
  # Using -show_entries stream=key always return both if programs exists.
  ffprobeOutput=($(ffprobe "${ffprobeArgsList[@]}" | jq -rcM ".$entKey2[].$entVal"))

  stl_type_str "$ffprobeOutput"

  stl_log_info "ffprobe output: $ffprobeOutput"

  echo "${ffprobeOutput[@]}"
}
