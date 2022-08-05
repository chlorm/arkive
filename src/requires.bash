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

function arkive_requires_check_ffmpeg {
  stl_func_reqargs '0' "$#"
  local -r reqVersion='3.4.0'
  local version

  version="$(ffmpeg -version | awk -F' ' '/ffmpeg version/ {print $3 ; exit}')"

  # Handle FFmpeg git version strings
  if [[ "$version" =~ ^.*\.git ]]; then
    version='3.999.999'
  fi

  # FIXME
  #stl_symver_atleast "$version" "$reqVersion"
}

# Required dependencies
function arkive_requires_check {
  stl_func_reqargs '0' "$#"
  stl_path_has 'bc'
  stl_path_has 'jq'
  # libx264 (compiled with target bit depth)
  # libx265 >= 2.4 (compiled with multilib or at least target bit depth)
  # libopus >= 1.1 (surround sound improvements)
  stl_path_has 'ffmpeg'
  stl_path_has 'ffprobe'
  arkive_requires_check_ffmpeg

  # Optional, used to convert bitmap subs to plain text
  # if not available, bitmap subs are ignored
  #stl_path_has 'vobsub2srt'

  [ $(stl_cpu_address_space) -eq 64 ]
}
