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

# Selects the audio stream to use if multiple exist
function Audio::StreamSelector {
  local Bitrate
  local BitrateAsocArray
  local BitrateBest
  local ChannelLayout
  local ChannelLayoutAsocArray
  local ChannelLayoutBest
  local Channels
  local ChannelsAsocArray
  local ChannelsBest
  local File="${1}"
  local Stream
  local Streams
  local SampleRate
  local SampleRateAsocArray
  local SampleRateBest

  BitrateAsocArray=()
  ChannelLayoutAsocArray=()
  ChannelsAsocArray=()
  SampleRateAsocArray=()
  typeset -A OptimumAsocArray

  Streams=($(FFprobe 'a' '-' 'stream' 'index' "${File}"))

  if [ ${#Streams[@]} -eq 1 ] ; then
    Stream=${Streams[0]}
  # If multiple audio streams exist, select the correct one
  elif [ ${#Streams[@]} -gt 1 ] ; then

    # FIXME: implement support for multiple audio streams
    return 1

    # Remove streams that contain matching keywords in the stream title
    for Stream in ${Streams[@]} ; do
      #ARKIVE_AUDIO_STREAM_DISCARD_KEYWORDS
      FindMatch=false
      for Keyword in "${ARKIVE_AUDIO_STREAM_DISCARD_KEYWORDS[@]}" ; do
        FindKeyword="$(
          echo $(
            String::LowerCase $(
              FFprobe 'a' "${Stream}" 'stream_tags' 'title' "${File}"
            )
          ) | grep ${Keyword}
        )"
        if [[ -n "${FindKeyword}" ]] ; then
          FindMatch=true
        fi
      done
      unset Keyword
      # Discard matches
      if ${FindMatch} ; then
        Streams=( ${Streams[@]/${Stream}} )
      fi
    done
    unset FindMatch
    unset Stream

      # Check number of channels
      Channels=$(audio_channels "${Stream}") || {
        Channels=0
      }
      OptimumAsocArray["channels${Stream}"]=${Channels}

      # Check channel layout
      ChannelLayout=$(audio_channel_layout "${Stream}") || {
        layout=0
      }
      #OptimumAsocArray+=("channel_layout${Stream}" "${ChannelLayout}")

      # Check language
        # add function for manguage code
      # Check bitrate
      Bitrate=$(audio_bitrate) || {
        bitrate=0
      }
      #OptimumAsocArray+=("bit_rate${Stream}" "${Bitrate}")

      # Check audio codec
      # Check duration
   #done

    echo "${OptimumAsocArray["channels1"]}"

    for Stream in "${Streams[@]}" ; do

      key="channel${Stream}"

    done
    #BitrateBest=
    #SampleRateBest
    #ChannelsBest
    #ChannelLayoutBest
    #StreamOrginalIndex
    #StreamLanguage

    # Pick optimal stream
    Error::Message 'multiple audio streams not implemented'
    return 1
  else
    Error::Message 'at least 1 audio stream is required'
  fi

  echo "${Stream}"
}

function Audio::SampleRate {
  local File="${2}"
  local SampleRate
  local Stream="${1}"

  SampleRate=$(FFprobe '-' "${Stream}" 'stream' 'sample_rate' "${File}")

  String::NotNull "${SampleRate}"

  echo "${SampleRate}"
}

function Audio::SampleFormat {
  local File="${2}"
  local SampleFormat
  local Stream="${1}"

  SampleFormat=$(FFprobe '-' "${Stream}" 'stream' 'sample_fmt' "${File}")

  String::NotNull "${SampleFormat}"

  echo "${SampleFormat}"
}

function Audio::Bitrate {
  local Bitrate
  local File="${2}"
  local Stream="${1}"

  Bitrate=$(FFprobe '-' "${Stream}" 'stream' 'bit_rate' "${File}")

  String::NotNull "${Bitrate}"

  echo "${Bitrate}"
}

function Audio::Channels {
  local Channels
  local File="${2}"
  local Stream="${1}"

  Channels=$(FFprobe '-' "${Stream}" 'stream' 'channels' "${File}")

  String::NotNull "${Channels}"

  echo "${Channels}"
}

function Audio::ChannelLayout {
  local ChannelLayout
  local File="${2}"
  local Stream="${1}"

  ChannelLayout="$(FFprobe '-' "${Stream}" 'stream' 'channel_layout' "${File}")"

  String::NotNull "${ChannelLayout}"

  echo "${ChannelLayout}"
}
