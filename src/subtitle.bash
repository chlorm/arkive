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

function Subtitle::Codec {
  Function::RequiredArgs '2' "$#"
  local Codec
  local -r File="$2"
  local -r Stream="$1"

  Codec="$(FFprobe '-' "$Stream" 'stream' 'codec_name' "$File")"

  Var::Type.string "$Codec"

  echo "$Codec"
}

# Return true is the codec is a bitmap format, false if plaintext
function Subtitle::IsBitmap {
  Function::RequiredArgs '2' "$#"
  local Codec
  local -r File="$2"
  local IsBitmap='null'
  local -r Stream="$1"

  Codec="$(Subtitle::Codec "$Stream" "$File")"

  case "$Codec" in
    'ass'|'jacosub'|'microdvd'|'mov_text'|'mpl2'|'pjs'|'realtext'|'sami'|\
    'srt'|'stl'|'ssa'|'subrip'|'subviewer'|'subviewer1'|'text'|'vplayer'|\
    'webvtt')
      IsBitmap='false'
      ;;
    'dvb_subtitle'|'dvb_teletext'|'dvd_subtitle'|'hdmv_pgs_subtitle'|'xsub')
      IsBitmap='true'
      ;;
    *)
      Log::Message 'error' "unsupported subtitle codec: $Codec"
      return 1
      ;;
  esac

  [[ "$IsBitmap" == 'true' || "$IsBitmap" == 'false' ]]

  echo "$IsBitmap"
}
