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

  ChannelLayout="${ARKIVE_CHANNEL_LAYOUT_MAPS_LIST[${ChannelLayout}]}" || :

  if [ -z "${ChannelLayout}" ] ; then
    # Force channel count if input has a non-standard channel layout
    ChannelLayout="${ARKIVE_AUDIO_CHANNEL_LAYOUT_FALLBACK}"
  fi

  case "${ChannelLayout}" in
    'mono') Channels=1 ;;
    'stereo'|'downmix') Channels=2 ;;
    '2.1'|'3.0'|'3.0(back)') Channels=3 ;;
    '4.0'|'quad'|'quad(side)'|'3.1') Channels=4 ;;
    '4.1'|'5.0'|'5.0(side)') Channels=5 ;;
    '5.1'|'5.1(side)'|'6.0'|'6.0(front)'|'hexagonal') Channels=6 ;;
    '6.1'|'6.1(back)'|'6.1(front)'|'7.0'|'7.0(front)') Channels=7 ;;
    '7.1'|'7.1(wide)'|'7.1(wide-side)'|'octagonal') Channels=8 ;;
    'hexadecagonal') Channels=16 ;;
    *) return 1 ;;
  esac

  Var::Type.integer "${Channels}"

  echo "${Channels}"
}
