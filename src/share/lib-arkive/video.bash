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

# function Video::ColorMatrix {
#   Function::RequiredArgs '2' "$#"
#   local -r File="${2}"
#   local SourceCodecName
#   local SourceColorPrimaries
#   local -r Stream="${1}"

#   SourceCodecName="$(FFprobe '-' "${Stream}" 'stream' 'codec_name' "${File}")"

#   # We really only care to signal bt2020 for bt2020 sources, for all others
#   # bt709 is signaled.  Ignore testing for bt2020 if the source codec doesn't
#   # support it.
#   case "${SourceCodecName}" in
#     'h265'|'vp9')
#       SourceColorPrimaries="$(FFprobe '-' "${Stream}" 'stream' 'color_primaries' "${File}")"
#       SourcePixelFormat="$(FFprobe '-' "${Stream}" 'stream' 'pix_fmt' "${File}")"
#       # FIXME: only supports yuv currently
#       if [ "${SourcePixelFormat}" =~ yuv4([2]|[4])([0]|[2]|[4])10* ] ; then
#         # FIXME: test for bt2020
#         echo 'bt2020'
#       else
#         # 8bpcc cannot support bt2020, assume bt709
#         echo 'bt709'
#       fi
#       ;;
#     *) echo 'bt709' ;;
#   esac
# }

function Video::FrameRate {
  Function::RequiredArgs '2' "$#"
  local -r File="${2}"
  local SourceFrameRate
  local -r Stream="${1}"

  SourceFrameRate="$(FFprobe '-' "${Stream}" 'stream' 'r_frame_rate' "${File}")"

  Var::Type.string "${SourceFrameRate}"

  echo "${SourceFrameRate}"
}

function Video::Height {
  Function::RequiredArgs '2' "$#"
  local -r File="${2}"
  local Height
  local -r Stream="${1}"

  Height=$(FFprobe '-' "${Stream}" 'stream' 'height' "${File}")

  Var::Type.integer "${Height}"

  echo "${Height}"
}

function Video::Width {
  Function::RequiredArgs '2' "$#"
  local -r File="${2}"
  local -r Stream="${1}"
  local Width

  Width=$(FFprobe '-' "${Stream}" 'stream' 'width' "${File}")

  Var::Type.integer "${Width}"

  echo "${Width}"
}
