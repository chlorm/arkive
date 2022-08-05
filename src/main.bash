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
  stl_func_reqargs '0' "$#"
  local __filename__
  local __filenamefmt__
  local __outputdir__
  # Initial pass number, DO NOT CHANGE VALUE
  local __pass__=1
  local __subtitlestreams__
  local __tmpdir__

  local -a audio
  local audioPass
  local ffmpegArg
  local -a ffmpegArgs
  local ffmpegArgsList
  local file
  local index=0
  local subtitle
  local chapter
  local metadata
  local outputFile
  local -a streamIndexMap=()
  local -a videoArgs

  # Stream identifiers
  local as
  local asa
  local cs
  local ss
  local ssa
  local vs

  file="$INPUTFILE"
  __filename__="$(arkive_filename_original_base "$file")"
  __filenamefmt__="$(arkive_filename_formatted "$file")"
  __tmpdir__="$TMPDIR"
  __outputdir__="$OUTPUTDIR"
  outputFile="${__outputdir__}/${__filenamefmt__}.${FFMPEG_CONTAINER_FORMAT}"

  #arkive_ffprobe 'v' '-' 'stream' 'index' "${file}"

  # FIXME: arkive_stream_select may return multiple values in the future so
  #        vs should be an array, Indexs will also have to be fixed for
  #        audio and video streams.
  if $ARKIVE_VIDEO; then
    vs="$(arkive_stream_select 'video' "$file")"
    # Assign the video stream index 0
    streamIndexMap[0]="-map 0:${vs}"
    if [ "${FFMPEG_VIDEO_ENCODER}" != 'copy' ]; then
      videoArgs+=('-b:0' "$(ffmpeg_video_bitrate "$vs" "$file")k")
      # Force constant frame rate
      videoArgs+=('-vsync:0' 'cfr')
      videoArgs+=('-r:0' "$(ffmpeg_video_frame_rate "$vs" "$file")")
      videoArgs+=("$(ffmpeg_video_filters "$vs" "$file" '0')")
      videoArgs+=('-pix_fmt' "$(ffmpeg_video_pixel_format)")
      # if [ ${FFMPEG_VIDEO_BITDEPTH} -gt 8 ] ; then
      #   videoArgs+=('-colorspace:0' 'bt2020')
      # else
      #   videoArgs+=('-colorspace:0' 'bt709')
      # fi
      #videoArgs+=('-color_range' 'mpeg')
    fi
  fi

  if $ARKIVE_AUDIO; then
    asa=($(arkive_stream_select 'audio' "${file}"))
    [[ ${#asa[@]} == @(1|2) ]] || {
      stl_log_error "unsupported number of audio streams: ${#asa[@]}"
      stl_log_error "${asa[*]}"
      return 1
    }
    for as in ${asa[@]}; do
      index=${#streamIndexMap[@]}
      # Assign stream index, assuming video is 0, and audio starts from 1 ->
      # number of streams + 1.
      streamIndexMap[${index}]="-map 0:${as}"
      audio+=($(ffmpeg_audio "$as" "$file" "$index"))
    done
  fi

  # if $ARKIVE_SUBTITLES; then
  #   ssa=($(arkive_stream_select 'subtitle' "$file"))
  #   [[ ${#ssa[@]} == +(1|2) ]]
  #   for ss in ${ssa[@]}; do
  #     subtitle="${subtitle:+${subtitle} }$(ffmpeg_subtitle "$ss" "$file")"
  #   done
  # fi

  #chapter="$(ffmpeg_chapter)"

  # Metadata
  #metadata="$(ffmpeg_metadata)"

  if ! $ARKIVE_VIDEO; then
    FFMPEG_VIDEO_ENCODER_PASSES=1
  fi

  while [ $__pass__ -le $FFMPEG_VIDEO_ENCODER_PASSES ]; do
    # Always overwrite the file for multipass encodes or if requestedaaaaaa
    if [ $__pass__ -gt 1 ] || $ARKIVE_ALLOW_OVERWRITING_FILES; then
      ffmpegArgs+=('-y')
    else
      ffmpegArgs+=('-n')
    fi
    ffmpegArgs+=(
      '-nostdin'
      '-hide_banner'
      '-stats'
      '-loglevel' 'info'
      '-i' "$file"
      # FIXME: specify thread count per stream
      # Video encoders specify their own thread count seperate from FFmpeg's
      '-threads' '1'
      # FIXME: disable mapping metadata for testing
      #'-map_metadata' '-1'

      '-map_metadata' '0'
    )
    if [ $FFMPEG_VIDEO_ENCODER_PASSES -gt 1 ]; then
      ffmpegArgs+=(
        '-pass' "$__pass__"
        '-passlogfile' "${__tmpdir__}/ffmpeg-passlog"
      )
    fi
    ffmpegArgs+=(${streamIndexMap[0]})
    # Only encode non-video streams on the final pass
    if $ARKIVE_VIDEO; then
      ffmpegArgs+=(${videoArgs[@]})
      ffmpegArgs+=($(ffmpeg_video_codec "$vs" "$file" '0'))
    fi
    if [[ "$FFMPEG_CONTAINER_FORMAT" == @('m4a'|'m4v'|'mp4'|'mov') ]]; then
      ffmpegArgs+=('-movflags' '+faststart')
    fi
    # Only encode audio on last pass
    if ! $ARKIVE_VIDEO || [ $__pass__ -eq $FFMPEG_VIDEO_ENCODER_PASSES ]; then
      ffmpegArgs+=("${audio[@]}")
    fi
    ffmpegArgs+=("$outputFile")

    echo "ffmpeg ${ffmpegArgs[@]}"
    ffmpeg "${ffmpegArgs[@]}"

    unset ffmpegArg ffmpegArgs ffmpegArgsList
    __pass__=$(( $__pass__ + 1 ))
  done
}

function arkive_main {
  set -o errexit
  set -o errtrace
  set -o functrace
  set -o nounset
  set -o pipefail

  LOG_LEVEL='debug'

  ARKIVE_VERSION='0.1.0'

  PROGRAM_NAME='arkive'

  trap 'stl_log_func' DEBUG
  trap 'Tmp::Cleanup' SIGINT SIGTERM
  trap -- 'Tmp::Cleanup ; stl_log_trace ; exit 1' ERR

  arkive_requires_check

  arkive_declare_defaults

  arkive_cli_parser "${@}"

  if [ -n "${RAW_BITPERPIXEL}" ]; then
    ffmpeg_video_bpp "${RAW_BITPERPIXEL}"
    exit 0
  fi

  arkive_run

  Tmp::Cleanup

  exit 0
}
