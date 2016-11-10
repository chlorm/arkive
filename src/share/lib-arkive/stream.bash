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

function Stream::Select {
  Function::RequiredArgs '2' "$#"
  local -A FFtypes
  local -r File="${2}"
  local -A ReqMaxsStm
  local -A ReqMinsStm
  local -a Streams
  local -r Type="${1}"

  # Translate strings to ffmpeg stream type identifiers
  FFtypes=(
    ['audio']='a'
    ['chapter']='c'
    ['subtitle']='s'
    ['video']='v'
  )

  Streams=($(FFprobe "${FFtypes[${Type}]}" '-' 'stream' 'index' "${File}"))

  # Minimum number of streams allowed for each type
  ReqMinsStm=(
    ['audio']=1
    ['chapter']=0
    ['subtitle']=0
    ['video']=1
  )

  [ ${#Streams[@]} -ge ${ReqMinsStm[${Type}]} ]

  # Maximum number of streams allowed for each type
  ReqMaxsStm=(
    ['audio']=2
    ['chapter']=1
    ['subtitle']=2
    ['video']=1
  )

  [ ${#Streams[@]} -le ${ReqMaxsStm[${Type}]} ]

  if [ ${#Streams[@]} -eq 1 ] ; then
    # FIXME: make sure stream meets requirements
    Stream=${Streams[0]}

  # If multiple audio streams exist, select the correct one(s)
  elif [ ${#Streams[@]} -gt 1 ] ; then

    # Remove streams that contain matching keywords in the stream title
    for Stream in ${Streams[@]} ; do
      FindMatch=false
      for Keyword in "${FFMPEG_AUDIO_STREAM_DISCARDKEYWORDS[@]}" ; do
        FindKeyword="$(
          echo $(
            String::LowerCase $(
              FFprobe '-' "${Stream}" 'stream_tags' 'title' "${File}"
            )
          ) | grep ${Keyword}
        )"
        if [ -n "${FindKeyword}" ] ; then
          FindMatch=true
        fi
      done
      unset Keyword
      # Discard matches
      if ${FindMatch} ; then
        Streams=(${Streams[@]/${Stream}})
      fi
    done

    if [ ${#Streams[@]} -eq 1 ] ; then
      Stream=${Streams[@]}
    else
      Log::Message 'error' 'multiple streams not implemented'
      return 1
    fi
  fi

  echo "${Stream}"
}
