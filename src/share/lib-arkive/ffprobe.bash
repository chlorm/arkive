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

function FFprobe {
  Function::RequiredArgs '5' "$#"
  local StreamType="${1}"
  local Stream="${2}"
  local -r EntKey="${3}"
  local -r EntVal="${4}"
  local -r File="${5}"
  local FFprobeArgs
  local -a FFprobeArgsList
  local -a FFprobeOutput

  Log::Message 'info' "1:${1}, 2:${2}, 3:${3}, 4:${4}, 5:${5},"

  if [ "${StreamType}" == '-' ] ; then
    unset StreamType
  elif [[ ! "${StreamType}" == @('a'|'s'|'v') ]] ; then
    Log::Message 'error' "invalid stream type: ${StreamType}"
  fi

  if [ "${Stream}" == '-' ] ; then
    unset Stream
  elif [ ! ${Stream} -ge 0 ] ; then
    Log::Message 'error' "invalid stream id: ${Stream}"
  fi

  if [ ! -f "${File}" ] ; then
    Log::Message 'error' "invalid file: ${File}"
  fi

  FFprobeArgsList=(
    '-v' 'error'
    '-select_streams' "${StreamType}${StreamType:+${Stream:+:}}${Stream}"
    '-show_entries' "${EntKey}=${EntVal}"
    '-of' 'default=noprint_wrappers=1:nokey=1'
    "${File}"
  )

  FFprobeArgs="${FFprobeArgsList[@]}"
  Log::Message 'info' "ffprobe ${FFprobeArgs}"
  FFprobeOutput=($(ffprobe "${FFprobeArgsList[@]}"))

  Var::Type.string "${FFprobeOutput}"

  Log::Message 'info' "ffprobe output: ${FFprobeOutput}"

  for i in "${FFprobeOutput[@]}" ; do
    echo "${i}"
  done
}
