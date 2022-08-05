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

# TODO: require video to contain at least 5000 frames (at least > 1000)
# FIXME: these values need to be refined further

function ffmpeg_video_filters_de_interlace {
  stl_func_reqargs '2' "$#"
  local -r file="$2"
  local idetAprox=0
  local idetBFF
  local idetInterlaced
  local idetInterlacedPercentage=0
  local idetInterlacedTotal
  local idetProg
  local idetProgressive
  local idetProgressivePercentage=0
  local idetProgressiveTotal
  local idetResults
  local idetTFF
  local idetUnd
  local isInterlaced=false
  local loopIter=0
  local skip=1
  local -r stream="$1"

  checkMinFrames="$(arkive_ffprobe '-' "$stream" 'stream' 'nb_frames' "$file")"

  if [ $checkMinFrames -lt 5000 ]; then
    stl_log_warn "skipping interlace detection, not enough frames: $checkMinFrames"
    return 0
  fi

  # Require 90% of the frames to be interlaced/progressive and a minimum
  # of 5 iterations.
  # TODO: test more content to figure out a better base-line percentage
  while ([ $idetInterlacedPercentage -lt 90 ] || \
         [ $idetProgressivePercentage -lt 90 ]) && \
         [ $loopIter -lt 5 ]; do
    skip=$(( $loopIter * 1000 ))

    idetResults="$(
      ffmpeg \
        -nostdin \
        -hide_banner \
        -loglevel info \
        -threads "$(stl_cpu_logical)" \
        -ss $skip \
        -i "$file" \
        -ss 0 \
        -filter:$stream idet \
        -frames:$stream 1000 \
        -an \
        -f null - 2>&1 |
        egrep 'idet|Input' |
        grep 'Multi frame detection'
    )"
    stl_type_str "$idetResults"

    # Top Field First frames
    idetTFF=$(
      echo "$idetResults" |
        awk -F' ' '{
          for(i=1;i<=NF;i++)
            if ($i == "TFF:")
              print $(i+1)
        }'
    )
    stl_type_int "$idetTFF"
    # Bottom Field First frames
    idetBFF=$(
      echo "$idetResults" |
        awk -F' ' '{
          for(i=1;i<=NF;i++)
            if ($i == "BFF:")
              print $(i+1)
        }'
    )
    stl_type_int "$idetBFF"
    # Progressive frames
    idetProg=$(
      echo "$idetResults" |
        awk -F' ' '{
          for(i=1;i<=NF;i++)
            if ($i == "Progressive:")
              print $(i+1)
        }'
    )
    stl_type_int "$idetProg"
    # Undetermined frames
    idetUnd=$(
      echo "$idetResults" |
        awk -F' ' '{
          for(i=1;i<=NF;i++)
            if ($i == "Undetermined:")
              print $(i+1)
        }'
    )
    stl_type_int "$idetUnd"

    # Assume all TFF & BFF frames are interlaced
    if [ $idetBFF -eq 0 ] && [ $idetTFF -eq 0 ]; then
      # Adding zeros in shell may fail, so set it manually
      idetInterlaced=0
    else
      idetInterlaced=$(( $idetBFF + $idetTFF ))
    fi
    # If a frame is undetermined, make the assumption that it is progressive
    if [ $idetProg -eq 0 ] && [ $idetUnd -eq 0 ]; then
      # Adding zeros in shell may fail, so set it manually
      idetProgressive=0
    else
      idetProgressive=$(( $idetProg + $idetUnd ))
    fi

    # Something is wrong if no frames were detected at all
    [ $(( $idetInterlaced + $idetProgressive )) -gt 0 ] || {
      stl_log_error 'no frames detected'
      return 1
    }

    idetInterlacedTotal=$(( $idetInterlacedTotal + $idetInterlaced ))
    idetProgressiveTotal=$(( $idetProgressiveTotal + $idetProgressive ))
    totalFrames=$(( $idetInterlacedTotal + $idetProgressiveTotal ))

    stl_log_info "Interlaced frames: $idetInterlacedTotal"
    stl_log_info "Progressive frames: $idetProgressiveTotal"
    stl_log_info "Total frames: $totalFrames"

    idetInterlacedPercentage=$(( $idetInterlacedTotal * 100 / $totalFrames ))
    idetProgressivePercentage=$(( $idetProgressiveTotal * 100 / $totalFrames ))

    stl_log_info "Percentage interlaced: $idetInterlacedPercentage"
    stl_log_info "Percentage progressive: $idetProgressivePercentage"

    (( loopIter++ ))

    # Exit if idet is probably failing to prevent infinite loops
    [ $loopIter -le 10 ]
  done

  if [ $idetInterlacedPercentage -ge 90 ]; then
    # FIXME: figure out proper settings
    echo "yadif=1:-1:0,mcdeint=0:0:10"
    return 0
  fi

  # Sanity check to make sure nothing went wrong
  [ $idetProgressivePercentage -ge 90 ]

  return 0
}
