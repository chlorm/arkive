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

function arkive_input_check {
  stl_func_reqargs '1' "$#"
  local -r file="$1"
  [ -f "$file" ]
  #[ "${file##*.}" == 'mkv' ]
  # FIXME: check requirements
  # audio streams (== 1/2 & lang codes)
  # video streams (== 1 & lang code)
  # subtitle streams (== 0/1/2 & lang codes)
  # chapter streams (== 0/1)
}

function arkive_input_check_output {
  stl_func_reqargs '1' "$#"
  [ -n "$1" ]
  [ -d "$1" ]
}

function arkive_input_check_tmp {
  stl_func_reqargs '1' "$#"
  if [ ! -d "$1" ]; then
    # Don't use --parents, we want it to fail
    mkdir "$1"
  fi
}

# Parses, validates, and exports input
function arkive_cli_parser {
  local -r input="$@"   # Only for testing for input

  stl_arg_define \
      'short=i' \
      'long=input' \
      'variable=RAW_INPUTFILE' \
      'desc=Input video file'
  stl_arg_define \
      'short=o' \
      'long=output' \
      'variable=RAW_OUTPUTDIR' \
      'desc=Output directory'
  stl_arg_define \
      'short=p' \
      'long=profile' \
      'variable=RAW_PROFILE' \
      'desc=Specify profile to use'
  stl_arg_define \
      'short=b' \
      'long=bpp' \
      'variable=RAW_BITPERPIXEL' \
      'desc=Calculate bits per pixel'
  # Build and source script that parses $@
  source "$(stl_args_build)"

  if [ -z "$input" ]; then
    stl_log_error 'no input'
    arkive_usage
    return 1
  fi

  # Profiles
  if [ -f "$RAW_PROFILE" ]; then
    source "$RAW_PROFILE"
  elif type arkive_profile_$RAW_PROFILE >/dev/null; then
    arkive_profile_$RAW_PROFILE
  else
    stl_log_error "invalid profile specified: $RAW_PROFILE"
    return 1
  fi

  if [ -z "${RAW_BITPERPIXEL:-}" ]; then
    arkive_input_check "$RAW_INPUTFILE"
    INPUTFILE="$(readlink -f "$RAW_INPUTFILE")"
    INPUTDIR="$(dirname "$INPUTFILE")"

    if arkive_input_check_output "$RAW_OUTPUTDIR"; then
      OUTPUTDIR="$(readlink -f "$RAW_OUTPUTDIR")"
    else
      export OUTPUTDIR="$INPUTDIR"
    fi

    export TMPDIR="$INPUTDIR/.arkive.$RANDOM"
    arkive_input_check_tmp "$TMPDIR"
  fi
}
