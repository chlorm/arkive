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

function Input::Check.input {
  local file="${1}"
  [ -f "${file}" ]
  #[ "${file##*.}" == 'mkv' ]
  # FIXME: check requirements
  # audio streams (== 1/2 & lang codes)
  # video streams (== 1 & lang code)
  # subtitle streams (== 0/1/2 & lang codes)
  # chapter streams (== 0/1)
}

function Input::Check.output {
  [ -n "${1}" ]
  [ -d "${1}" ]
}

function Input::Check.tmp {
  if [ ! -d "${INPUTDIR}/.arktmp" ] ; then
    mkdir "${INPUTDIR}/.arktmp"
  fi
}

# Parses, validates, and exports input
function Input::Parser {
  local input="$@"

  Args::Define 'short=i' 'long=input'  'variable=RAW_INPUTFILE' 'desc=Input video file'
  Args::Define 'short=o' 'long=output' 'variable=RAW_OUTPUTDIR' 'desc=Output directory'
  source "$(Args::Build)"

  if [ -z "${input}" ] ; then
    Error::Message 'no input'
    arkive::Usage
    return 1
  fi

  Input::Check.input "${RAW_INPUTFILE}"
  pushd "$(dirname "${RAW_INPUTFILE}")" > /dev/null
    export INPUTFILE="$(pwd)/$(basename "${RAW_INPUTFILE}")"
    export INPUTDIR="$(pwd)"
  popd > /dev/null

  if Input::Check.output "${RAW_OUTPUTDIR}" ; then
    pushd "${RAW_OUTPUTDIR}" > /dev/null
      export OUTPUTDIR="$(pwd)"
    popd > /dev/null
  else
    export OUTPUTDIR="${INPUTDIR}"
  fi

  Input::Check.tmp
  export TMPDIR="${INPUTDIR}/.arktmp"
}