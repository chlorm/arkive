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

# Uses the ffmpeg cropdetect filter to check for blackbars at 5 second
# intervals until 10 identical results for both width and height are found.
function FFmpeg::Video.filters:black_bar_crop {
  # TODO:
  # - fix setting crop rounding value dynamically
  #   h264: prefer multiples of 16 for compression efficiency, or multiple
  #     of 2, 4, or 8?
  #   h265: use multiple of min CU size
  #   vp9: multiple of 16, cite bug

  local CropDetect
  local CropHeight
  local CropHeightArray
  local CropHeightMatches
  local CropWidth
  local CropWidthArray
  local CropWidthMatches
  local CropXOffset
  local CropXOffsetArray
  local CropYOffset
  local CropYOffsetArray
  local LoopIter
  local Skip
  local SourceHeight
  local SourceWidth
  local Stream

  CropHeight=0
  CropHeightArray=()
  CropHeightMatches=0
  CropWidth=0
  CropWidthArray=()
  CropWidthMatches=0
  CropXOffsetArray=()
  CropXOffsetMatches=0
  CropYOffsetArray=()
  CropYOffsetMatches=0
  LoopIter=1
  SourceHeight=$(Video::Height)
  SourceWidth=$(Video::Width)

  function mode {
    echo "${@}" |
      sed -r 's/[[:space:]]+/\n/g' |
      uniq -c |
      sort -n -k 1 -r |
      awk '{ print $2 ; exit }'
  }

  function mode_count {
    echo "${@}" |
      sed -r 's/[[:space:]]+/\n/g' |
      uniq -c |
      sort -n -k 1 -r |
      awk '{ print $1 ; exit }'
  }

  while [[ ${CropHeightMatches} -lt 5 && \
           ${CropWidthMatches} -lt 5 && \
           ${CropXOffsetMatches} -lt 5 && \
           ${CropYOffsetMatches} -lt 5 ]] ; do
    Skip=$(( ${LoopIter} * 5 ))
    # https://ffmpeg.org/pipermail/ffmpeg-user/2011-July/001795.html
    # https://ffmpeg.org/pipermail/ffmpeg-user/2012-August/008767.html
    # -ss before -i uses seeking, -ss after -i uses skipping and is very slow
    CropDetect="$(
      ffmpeg \
        -threads "$(Cpu::Logical)" \
        -ss ${Skip} \
        -i "${__file__}" \
        -ss 0 \
        -t 1 \
        -an \
        -filter:${__videostream__} cropdetect=30:0:0 \
        -f null - 2>&1 |
        awk -F'=' '/crop/ { print $NF }' |
        tail -1
    )"

    # Find crop height
    CropHeight=$(echo "${CropDetect}" | awk -F':' '{ print $2 ; exit }')
    # Find crop width
    CropWidth=$(echo "${CropDetect}" | awk -F':' '{ print $1 ; exit }')
    # Sanity check
    if [[ ${CropHeight} -gt $(( ${SourceHeight} / 2 )) && \
          ${CropWidth} -gt $(( ${SourceWidth} / 2 )) ]] ; then
      CropXOffsetArray+=(
        "$(echo "${CropDetect}" | awk -F':' '{ print $3 ; exit }')"
      )
      CropYOffsetArray+=(
        "$(echo "${CropDetect}" | awk -F':' '{ print $4 ; exit }')"
      )
      CropHeightArray+=("${CropHeight}")
      CropWidthArray+=("${CropWidth}")
    fi

    # Find count of mode values
    CropWidthMatches=$(mode_count "${CropWidthArray[@]}")
    CropHeightMatches=$(mode_count "${CropHeightArray[@]}")
    CropXOffsetMatches=$(mode_count "${CropXOffsetArray[@]}")
    CropYOffsetMatches=$(mode_count "${CropYOffsetArray[@]}")

    LoopIter=$(( ${LoopIter} + 1 ))

    # Exit if cropdetect is probably failing to prevent infinite loops
    [ ${LoopIter} -le 50 ]
  done

  # Find crop width mode
  CropWidth=$(mode "${CropWidthArray[@]}")
  String::NotNull "${CropWidth}"

  # Find crop height mode
  CropHeight=$(mode "${CropHeightArray[@]}")
  String::NotNull "${CropHeight}"

  # Find X offset mode
  CropXOffset=$(mode "${CropXOffsetArray[@]}")
  String::NotNull "${CropXOffset}"

  # Find Y offset mode
  CropYOffset=$(mode "${CropYOffsetArray[@]}")
  String::NotNull "${CropYOffset}"

  echo "crop=${CropWidth}:${CropHeight}:${CropXOffset}:${CropYOffset}"
}
