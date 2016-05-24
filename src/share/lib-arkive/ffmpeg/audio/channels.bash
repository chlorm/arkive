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

function FFmpeg::Audio.channels {
  local File="${2}"
  local Channels
  local ChannelLayout
  local Stream="${1}"

  ChannelLayout="$(Audio::ChannelLayout "${Stream}" "${File}")"

  # Determine output audio channel count
  # (these are all sperate arguments to allow restructuring in the future)
  case "${ChannelLayout}" in
    # -> 2 (2.0)
    'mono'|'stereo'|'2.1'|'3.0'|'3.0(back)'|'3.1'|'downmix'|'4.1')
      Channels=2 ;;
    # -> 5 (5.0(side))
    '4.0'|'quad(side)'|'5.0(side)'|'5.1(side)'|\
    '6.0(front)'|'6.1(front)'|'7.0(front)'|'7.1(wide-side)')
      Channels=5 ;;
    # -> 7 (7.0)
    'quad'|'5.0'|'5.1'|'6.0'|'hexagonal'|'6.1'|'6.1(back)'|\
    '7.0'|'7.1'|'7.1(wide)'|'octagonal')
      Channels=7 ;;
    *)
      Error::Message "Unsupported channel layout: ${ChannelLayout}"
      return 1
      ;;
  esac

  String::NotNull "${Channels}"

  echo "${Channels}"
}
