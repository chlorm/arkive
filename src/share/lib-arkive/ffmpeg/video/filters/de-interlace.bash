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

function FFmpeg::Video.filters:de_interlace {
  local File="${2}"
  local IdetAprox=0
  local IdetBFF
  local IdetInterlaced
  local IdetInterlacedPercentage=0
  local IdetInterlacedTotal
  local IdetProg
  local IdetProgressive
  local IdetProgressivePercentage=0
  local IdetProgressiveTotal
  local IdetResults
  local IdetTFF
  local IdetUnd
  local IsInterlaced=false
  local LoopIter=0
  local Skip=1
  local Stream="${1}"

  CheckMinFrames="$(FFprobe '-' "${Stream}" 'stream' 'nb_frames' "${File}")"

  if [ ${CheckMinFrames} -lt 5000 ] ; then
    Debug::Message 'warn' "skipping interlace detection, not enough frames: ${CheckMinFrames}"
    return 0
  fi

  # Require 90% of the frames to be interlaced/progressive and a minimum
  # of 5 iterations.
  # TODO: test more content to figure out a better base-line percentage
  while ([ ${IdetInterlacedPercentage} -lt 90 ] || \
         [ ${IdetProgressivePercentage} -lt 90 ]) && \
         [ ${LoopIter} -lt 5 ] ; do
    Skip=$(( ${LoopIter} * 1000 ))

    IdetResults="$(
      ffmpeg \
        -nostdin \
        -hide_banner \
        -loglevel info \
        -threads "$(Cpu::Logical)" \
        -ss ${Skip} \
        -i "${File}" \
        -ss 0 \
        -filter:${Stream} idet \
        -frames:${Stream} 1000 \
        -an \
        -f null - 2>&1 |
        egrep 'idet|Input' |
        grep 'Multi frame detection'
    )"
    String::NotNull "${IdetResults}"

    # Top Field First frames
    IdetTFF=$(
      echo "${IdetResults}" |
        awk -F' ' '{
          for(i=1;i<=NF;i++)
            if ($i == "TFF:")
              print $(i+1)
        }'
    )
    Var::Type.integer "${IdetTFF}"
    # Bottom Field First frames
    IdetBFF=$(
      echo "${IdetResults}" |
        awk -F' ' '{
          for(i=1;i<=NF;i++)
            if ($i == "BFF:")
              print $(i+1)
        }'
    )
    Var::Type.integer "${IdetBFF}"
    # Progressive frames
    IdetProg=$(
      echo "${IdetResults}" |
        awk -F' ' '{
          for(i=1;i<=NF;i++)
            if ($i == "Progressive:")
              print $(i+1)
        }'
    )
    Var::Type.integer "${IdetProg}"
    # Undetermined frames
    IdetUnd=$(
      echo "${IdetResults}" |
        awk -F' ' '{
          for(i=1;i<=NF;i++)
            if ($i == "Undetermined:")
              print $(i+1)
        }'
    )
    Var::Type.integer "${IdetUnd}"

    # Assume all TFF & BFF frames are interlaced
    if [ ${IdetBFF} -eq 0 ] && [ ${IdetTFF} -eq 0 ] ; then
      # Adding zeros in shell may fail, so set it manually
      IdetInterlaced=0
    else
      IdetInterlaced=$(( ${IdetBFF} + ${IdetTFF} ))
    fi
    # If a frame is undetermined, make the assumption that it is progressive
    if [ ${IdetProg} -eq 0 ] && [ ${IdetUnd} -eq 0 ] ; then
      # Adding zeros in shell may fail, so set it manually
      IdetProgressive=0
    else
      IdetProgressive=$(( ${IdetProg} + ${IdetUnd} ))
    fi

    # Something is wrong if no frames were detected at all 
    [ $(( ${IdetInterlaced} + ${IdetProgressive} )) -gt 0 ] || {
      Debug::Message 'error' 'no frames detected'
      return 1
    }

    IdetInterlacedTotal=$(( ${IdetInterlacedTotal} + ${IdetInterlaced} ))
    IdetProgressiveTotal=$(( ${IdetProgressiveTotal} + ${IdetProgressive} ))
    TotalFrames=$(( ${IdetInterlacedTotal} + ${IdetProgressiveTotal} ))

    Debug::Message 'info' "Interlaced frames: ${IdetInterlacedTotal}"
    Debug::Message 'info' "Progressive frames: ${IdetProgressiveTotal}"
    Debug::Message 'info' "Total frames: ${TotalFrames}"

    IdetInterlacedPercentage=$(( ${IdetInterlacedTotal} * 100 / ${TotalFrames} ))
    IdetProgressivePercentage=$(( ${IdetProgressiveTotal} * 100 / ${TotalFrames} ))

    Debug::Message 'info' "Percentage interlaced: ${IdetInterlacedPercentage}"
    Debug::Message 'info' "Percentage progressive: ${IdetProgressivePercentage}"

    LoopIter=$(( ${LoopIter} + 1 ))

    # Exit if idet is probably failing to prevent infinite loops
    [ ${LoopIter} -le 10 ]
  done

  if [ ${IdetInterlacedPercentage} -ge 90 ] ; then
    # FIXME: figure out proper settings
    echo "yadif=1:-1:0,mcdeint=0:0:10"
    return 0
  fi

  # Sanity check to make sure nothing went wrong
  [ ${IdetProgressivePercentage} -ge 90 ]

  return 0
}
