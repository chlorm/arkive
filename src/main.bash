# Copyright (c) 2013-2017, Cody Opel <codyopel@gmail.com>
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

# FIXME: merge audio specific portion into arkive itself

function arkive_run {
  Function::RequiredArgs '0' "$#"
  local __filename__
  local __filenamefmt__
  local __outputdir__
  # Initial pass number, DO NOT CHANGE VALUE
  local __pass__=1
  local __subtitlestreams__
  local __tmpdir__

  local -a Audio
  local AudioPass
  local FFmpegArg
  local -a FFmpegArgs
  local FFmpegArgsList
  local File
  local Index=0
  local Subtitle
  local Chapter
  local Metadata
  local OutputFile
  local -a StreamIndexMap=()
  local -a VideoArgs

  # Stream identifiers
  local as
  local asa
  local cs
  local ss
  local ssa
  local vs

  File="${INPUTFILE}"
  __filename__="$(Filename::Original.base "${File}")"
  __filenamefmt__="$(Filename::Formatted "${File}")"
  __tmpdir__="${TMPDIR}"
  __outputdir__="${OUTPUTDIR}"
  OutputFile="${__outputdir__}/${__filenamefmt__}.${FFMPEG_CONTAINER_FORMAT}"

  #FFprobe 'v' '-' 'stream' 'index' "${File}"

  # FIXME: Stream::Select may return multiple values in the future so
  #        vs should be an array, Indexs will also have to be fixed for
  #        audio and video streams.
  if $ARKIVE_VIDEO; then
    vs="$(Stream::Select 'video' "${File}")"
    # Assign the video stream index 0
    StreamIndexMap[0]="-map 0:${vs}"
    if [ "${FFMPEG_VIDEO_ENCODER}" != 'copy' ]; then
      VideoArgs+=('-b:0' "$(FFmpeg::Video.bitrate "${vs}" "${File}")k")
      # Force constant frame rate
      VideoArgs+=('-vsync:0' 'cfr')
      VideoArgs+=('-r:0' "$(FFmpeg::Video.frame_rate "${vs}" "${File}")")
      VideoArgs+=("$(FFmpeg::Video.filters "${vs}" "${File}" '0')")
      VideoArgs+=('-pix_fmt' "$(FFmpeg::Video.pixel_format)")
      # if [ ${FFMPEG_VIDEO_BITDEPTH} -gt 8 ] ; then
      #   VideoArgs+=('-colorspace:0' 'bt2020')
      # else
      #   VideoArgs+=('-colorspace:0' 'bt709')
      # fi
      #VideoArgs+=('-color_range' 'mpeg')
    fi
  fi

  if $ARKIVE_AUDIO; then
    asa=($(Stream::Select 'audio' "${File}"))
    [[ ${#asa[@]} == @(1|2) ]] || {
      Log::Message 'error' "unsupported number of audio streams: ${#asa[@]}"
      Log::Message 'error' "${asa[*]}"
      return 1
    }
    for as in ${asa[@]}; do
      Index=${#StreamIndexMap[@]}
      # Assign stream index, assuming video is 0, and audio starts from 1 ->
      # number of streams + 1.
      StreamIndexMap[${Index}]="-map 0:${as}"
      Audio+=($(FFmpeg::Audio "${as}" "${File}" "${Index}"))
    done
  fi

  # if $ARKIVE_SUBTITLES; then
  #   ssa=($(Stream::Select 'subtitle' "${File}"))
  #   [[ ${#ssa[@]} == +(1|2) ]]
  #   for ss in ${ssa[@]} ; do
  #     Subtitle="${Subtitle:+${Subtitle} }$(FFmpeg::Subtitle "${ss}" "${File}")"
  #   done
  # fi

  #Chapter="$(FFmpeg::Chapter)"

  # Metadata
  #Metadata="$(FFmpeg::Metadata)"

  if ! $ARKIVE_VIDEO; then
    FFMPEG_VIDEO_ENCODER_PASSES=1
  fi

  while [ ${__pass__} -le ${FFMPEG_VIDEO_ENCODER_PASSES} ]; do
    # Always overwrite the file for multipass encodes or if requestedaaaaaa
    if [ ${__pass__} -gt 1 ] || ${ARKIVE_ALLOW_OVERWRITING_FILES}; then
      FFmpegArgs+=('-y')
    else
      FFmpegArgs+=('-n')
    fi
    FFmpegArgs+=(
      '-nostdin'
      '-hide_banner'
      '-stats'
      '-loglevel' 'info'
      '-i' "${File}"
      # FIXME: specify thread count per stream
      # Video encoders specify their own thread count seperate from FFmpeg's
      '-threads' '1'
      # FIXME: disable mapping metadata for testing
      #'-map_metadata' '-1'

      '-map_metadata' '0'
    )
    if [ ${FFMPEG_VIDEO_ENCODER_PASSES} -gt 1 ]; then
      FFmpegArgs+=(
        '-pass' "${__pass__}"
        '-passlogfile' "${__tmpdir__}/ffmpeg-passlog"
      )
    fi
    FFmpegArgs+=(${StreamIndexMap[0]})
    # Only encode non-video streams on the final pass
    if $ARKIVE_VIDEO; then
      FFmpegArgs+=(${VideoArgs[@]})
      FFmpegArgs+=($(FFmpeg::Video.codec "${vs}" "${File}" '0'))
    fi
    if [[ "${FFMPEG_CONTAINER_FORMAT}" == @('m4a'|'m4v'|'mp4'|'mov') ]]; then
      FFmpegArgs+=('-movflags' '+faststart')
    fi
    # Only encode audio on last pass
    if ! $ARKIVE_VIDEO || [ ${__pass__} -eq ${FFMPEG_VIDEO_ENCODER_PASSES} ]; then
      FFmpegArgs+=("${Audio[@]}")
    fi
    FFmpegArgs+=("${OutputFile}")

    echo "ffmpeg ${FFmpegArgs[@]}"
    ffmpeg "${FFmpegArgs[@]}"

    unset FFmpegArg FFmpegArgs FFmpegArgsList
    __pass__=$(( ${__pass__} + 1 ))
  done
}

function arkive_main {
  set -o errexit
  set -o errtrace
  set -o functrace
  #set -o nounset
  set -o pipefail

  LOG_LEVEL='debug'

  ARKIVE_VERSION='0.1.0'

  PROGRAM_NAME='arkive'

  trap 'Log::Func' DEBUG
  trap 'Tmp::Cleanup' SIGINT SIGTERM
  trap -- 'Tmp::Cleanup ; Log::Trace ; exit 1' ERR

  #Requires::Check

  arkive_declare_defaults

  Input::Parser "${@}"

  if [ -n "${RAW_BITPERPIXEL}" ]; then
    FFmpeg::Video.bpp "${RAW_BITPERPIXEL}"
    exit 0
  fi

  arkive_run

  Tmp::Cleanup

  exit 0
}
