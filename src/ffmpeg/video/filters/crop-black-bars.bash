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

# This function uses the ffmpeg cropdetect filter to check for blackbars
# at 5 second intervals until 10 identical results for both width and
# height are found.
function ffmpeg_video_filters_black_bar_crop {
  stl_func_reqargs '2' "$#"
  # TODO:
  # - fix setting crop rounding value dynamically
  #   h264: prefer multiples of 16 for compression efficiency, or multiple
  #     of 2, 4, or 8?
  #   h265: use multiple of min CU size
  #   vp9: multiple of 16, cite bug

  local cropDetect
  local cropDetectArgs
  local -a cropDetectArgsList
  local cropHeight
  local cropHeightArray
  local cropHeightMatches
  local cropWidth
  local cropWidthArray
  local cropWidthMatches
  local cropXOffset
  local cropXOffsetArray
  local cropYOffset
  local cropYOffsetArray
  local -r file="$2"
  local loopIter
  local skip
  local sourceHeight
  local sourceWidth
  local -r stream="$1"

  cropHeight=0
  cropHeightArray=()
  cropHeightMatches=0
  cropWidth=0
  cropWidthArray=()
  cropWidthMatches=0
  cropXOffsetArray=()
  cropXOffsetMatches=0
  cropYOffsetArray=()
  cropYOffsetMatches=0
  loopIter=1
  sourceHeight=$(arkibe_video_height "$stream" "$file")
  stl_log_info "source height: $sourceHeight"
  sourceWidth=$(arkibe_video_width "$stream" "$file")
  stl_log_info "source width: $sourceWidth"

  while [[ $cropHeightMatches -lt 5 && \
           $cropWidthMatches -lt 5 && \
           $cropXOffsetMatches -lt 5 && \
           $cropYOffsetMatches -lt 5 ]]; do
    skip=$(( $loopIter * 5 ))
    # https://ffmpeg.org/pipermail/ffmpeg-user/2011-July/001795.html
    # https://ffmpeg.org/pipermail/ffmpeg-user/2012-August/008767.html
    # -ss before -i uses seeking, -ss after -i uses skipping and is very slow
    cropDetectArgsList=(
      '-nostdin'
      '-hide_banner'
      '-loglevel' 'info'
      '-threads' "$(Cpu::Logical)"
      '-ss' "$skip"
      '-i' "$file"
      '-ss' '0'
      '-t' '1'
      # The file index must be specified or cropdetect with fail when the
      # video stream index is not 0.
      "-filter:0:$stream" 'cropdetect=30:0:0'
      '-an'
      '-f' 'null' '-'
    )

    cropDetectArgs="${cropDetectArgsList[@]}"
    stl_log_info "ffmpeg $cropDetectArgs"

    cropDetect="$(
      ffmpeg "${cropDetectArgsList[@]}" 2>&1 |
        awk -F'=' '/crop/ { print $NF }' |
        tail -1
    )"

    stl_log_info "$loopIter: $cropDetect"

    # Find crop height
    cropHeight=$(echo "$cropDetect" | awk -F':' '{ print $2 ; exit }')
    # Find crop width
    cropWidth=$(echo "$cropDetect" | awk -F':' '{ print $1 ; exit }')
    # Sanity check
    if [[ $cropHeight -gt $(( $sourceHeight / 2 )) && \
          $cropWidth -gt $(( $sourceWidth / 2 )) ]]; then
      cropXOffsetArray+=(
        "$(echo "$cropDetect" | awk -F':' '{ print $3 ; exit }')"
      )
      cropYOffsetArray+=(
        "$(echo "$cropDetect" | awk -F':' '{ print $4 ; exit }')"
      )
      cropHeightArray+=("$cropHeight")
      cropWidthArray+=("$cropWidth")
    fi

    stl_log_info "${loopIter} - W:$cropWidth H:$cropHeight X:${cropXOffsetArray[-1]} Y:${cropYOffsetArray[-1]}"

    # Find count of mode values
    cropWidthMatches=$(STL_MATH_MODE_COUNT=1 stl_math_mode "${cropWidthArray[@]}")
    cropHeightMatches=$(STL_MATH_MODE_COUNT=1 stl_math_mode "${cropHeightArray[@]}")
    cropXOffsetMatches=$(STL_MATH_MODE_COUNT=1 stl_math_mode "${cropXOffsetArray[@]}")
    cropYOffsetMatches=$(STL_MATH_MODE_COUNT=1 stl_math_mode "${cropYOffsetArray[@]}")

    stl_log_info "MODE - W:$cropWidthMatches H:$cropHeightMatches X:$cropXOffsetMatches Y:$cropYOffsetMatches"

    (( loopIter++ ))

    unset cropDetectArg cropDetectArgs cropDetectArgsList

    # Exit if cropdetect is probably failing to prevent infinite loops
    [ $loopIter -le 50 ]
  done

  # Find crop width mode
  cropWidth=$(stl_math_mode "${cropWidthArray[@]}")
  stl_type_int "$cropWidth"

  # Find crop height mode
  cropHeight=$(stl_math_mode "${cropHeightArray[@]}")
  stl_type_int "$cropHeight"

  # Find X offset mode
  cropXOffset=$(stl_math_mode "${cropXOffsetArray[@]}")
  stl_type_int "$cropXOffset"

  # Find Y offset mode
  cropYOffset=$(stl_math_mode "${cropYOffsetArray[@]}")
  stl_type_int "$cropYOffset"

  stl_log_info "FINAL: W:$cropWidth H:$cropHeight X:$cropXOffset Y:$cropYOffset"

  echo "crop=${cropWidth}:${cropHeight}:${cropXOffset}:${cropYOffset}"
}
