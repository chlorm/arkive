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

# FIXME: make max stream count for each type configurable and defined in defaults

function arkive_stream_select {
  stl_func_reqargs '2' "$#"
  local -A fftypes
  local -r file="$2"
  local -A reqMaxsStm
  local -A reqMinsStm
  local -a streams
  local -r type="$1"

  # Translate strings to ffmpeg stream type identifiers
  fftypes=(
    ['audio']='a'
    ['chapter']='c'
    ['subtitle']='s'
    ['video']='v'
  )

  mapfile -t streams < <(
    arkive_ffprobe "${fftypes[$type]}" '-' 'stream' 'index' "$file"
  )

  # Minimum number of streams allowed for each type
  reqMinsStm=(
    ['audio']=1
    ['chapter']=0
    ['subtitle']=0
    ['video']=1
  )

  [ ${#streams[@]} -ge ${reqMinsStm[$type]} ] || {
    stl_log_error \
        "At least \`${reqMinsStm[$type]}\` $type stream is required, but \`${#streams[@]}\` found"
    return 1
  }

  # Maximum number of streams allowed for each type
  reqMaxsStm=(
    ['audio']=2
    ['chapter']=1
    ['subtitle']=2
    ['video']=1
  )

  # FIXME
  # [ ${#Streams[@]} -le ${ReqMaxsStm[$type]} ] || {
  #   Log::Message 'error' \
  #       "A maximum of \`${ReqMaxsStm[$type]}\` $type streams are allowed, but found \`${#Streams[@]}\`"
  #   return 1
  # }

  if [ ${#streams[@]} -eq 1 ]; then
    # FIXME: make sure stream meets requirements
    stream=${streams[0]}

  # If multiple audio streams exist, select the correct one(s)
  elif [ ${#streams[@]} -gt 1 ]; then

    # FIXME
    stream=${streams[0]}

    # # Remove streams that contain matching keywords in the stream title
    # for Stream in ${Streams[@]}; do
    #   FindMatch=false
    #   for Keyword in "${FFMPEG_AUDIO_STREAM_DISCARDKEYWORDS[@]}"; do
    #     FindKeyword="$(
    #       echo $(
    #         String::LowerCase $(
    #           FFprobe '-' "$Stream" 'stream_tags' 'title' "$File"
    #         )
    #       ) | grep $Keyword
    #     )"
    #     if [ -n "$FindKeyword" ]; then
    #       FindMatch=true
    #     fi
    #   done
    #   unset Keyword
    #   # Discard matches
    #   if $FindMatch; then
    #     Streams=(${Streams[@]/$Stream})
    #   fi
    # done

    # if [ ${#Streams[@]} -eq 1 ]; then
    #   Stream=${Streams[@]}
    # else
    #   Log::Message 'error' 'multiple streams not implemented'
    #   return 1
    # fi
  fi

  echo "$stream"
}
