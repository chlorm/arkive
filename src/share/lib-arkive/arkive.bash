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

function Arkive::Run {
  local __filename__
  local __filenamefmt__
  local __outputdir__
  local __subtitlestreams__
  local __tmpdir__

  local AllowOverwrite
  local Audio
  local AudioPass
  local FFmpegArg
  local -a FFmpegArgs
  local FFmpegArgsList
  local File
  local Subtitle
  local Chapter
  local Video
  local Metadata
  local OutputFile
  # Initial pass number, DO NOT CHANGE VALUE
  local PassArgs
  local Pass=1

  local as
  local asa
  local cs
  local ss
  local ssa
  local vs

  if ${ARKIVE_ALLOW_OVERWRITING_FILES} ; then
    AllowOverwrite='-y'
  elif ! ${ARKIVE_ALLOW_OVERWRITING_FILES} ; then
    AllowOverwrite='-n'
  else
    Error::Message "ARKIVE_ALLOW_OVERWRITING_FILES must be true/false: ${ARKIVE_ALLOW_OVERWRITING_FILES}"
    return 1
  fi

  File="${INPUTFILE}"
  __filename__="$(Filename::Original.base "${File}")"
  __filenamefmt__="$(Filename::Formatted "${File}")"
  __tmpdir__="${TMPDIR}"
  __outputdir__="${OUTPUTDIR}"
  OutputFile="${__outputdir__}/${__filenamefmt__}.${ARKIVE_CONTAINER}"

  asa=($(Stream::Select 'audio' "${File}"))
  [[ ${#asa[@]} == +(1|2) ]]
  for as in ${asa[@]} ; do
    Audio="${Audio:+${Audio} }$(FFmpeg::Audio "${as}" "${File}")"
  done

  #ssa=($(Stream::Select 'subtitle' "${File}"))
  #[[ ${#ssa[@]} == +(1|2) ]]
  #for ss in ${ssa[@]} ; do
  #  Subtitle="${Subtitle:+${Subtitle} }$(FFmpeg::Subtitle "${ss}" "${File}")"
  #done

  vs="$(Stream::Select 'video' "${File}")"
  #VideoFilters="$(FFmpeg::Video.filters "${vs}" "${File}")"
  #VideoBitrate="$(FFmpeg::Video.bitrate "${vs}" "${File}")"
  #VideoCodec="$(FFmpeg::Video.codec "${vs}" "${File}")"
  #VideoPixelFormat="$(FFmpeg::Video.pixel_format "${vs}" "${File}")"

  #Chapter="$(FFmpeg::Chapter)"

  # Metadata
  #Metadata="$(FFmpeg::Metadata)"

  while [ ${Pass} -le ${ARKIVE_VIDEO_ENCODING_PASSES} ] ; do
    Video="$(FFmpeg::Video "${vs}" "${File}")"
    if [ ${ARKIVE_VIDEO_ENCODING_PASSES} -gt 1 ] ; then
      PassArgs="-pass ${Pass} -passlogfile ${__tmpdir__}/${__filenamefmt__}.ffmpeg-passlog"
    else
      unset PassArgs
    fi
    # Only encode audio on last pass
    if [ ${Pass} -eq ${ARKIVE_VIDEO_ENCODING_PASSES} ] ; then
      AudioPass="${Audio}"
    else
      AudioPass='-an'
    fi
    # Overwrite the file for multipass encodes
    if [ ${Pass} -gt 1 ] ; then
      AllowOverwrite='-y'
    fi
    FFmpegArgs=(
      "${AllowOverwrite}"
      '-nostdin'
      '-hide_banner'
      '-stats'
      '-loglevel info'
      "-r $(Video::FrameRate "${vs}" "${File}")"
      "-i ${File}"
      '-threads 1'
      "${PassArgs}"
      "${Video}"
      '-movflags faststart'
      '-movflags frag_keyframe'
      "${AudioPass}"
      "${OutputFile}"
    )

    for FFmpegArg in "${FFmpegArgs[@]}" ; do
      if [ -n "${FFmpegArg}" ] ; then
        FFmpegArgsList="${FFmpegArgsList}${FFmpegArgsList:+ }${FFmpegArg}"
      fi
    done

    echo "ffmpeg ${FFmpegArgsList}"
    @FFMPEG_PATH@ ${FFmpegArgsList}

    unset FFmpegArg FFmpegArgs FFmpegArgsList
    Pass=$(( ${Pass} + 1 ))
  done
}
