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

function FFmpeg::Video.codec:vp9_params {
  Function::RequiredArgs '2' "$#"
  local -r File="${2}"
  local Key
  local KeyInt
  local Parameter
  local -a Parameters
  local -r Stream="${1}"
  local Value
  local Vp9Params

  KeyInt=$(FFmpeg::Video.min_keyframe_interval "${Stream}" "${File}")

  Parameters=(
    # Quality Deadline
    'deadline=best'
    #threads FIXME: need ffmpeg's thread count to not be 1
    #profile
    #stereo-mode
    #timebase
    #fps
    #error-resilient
    #test-16bit
    #lag-in-frames
    #drop-frame
    #resize-allowed
#             --resize-width=<arg>         Width of encoded frame
#             --resize-height=<arg>       Height of encoded frame
#             --resize-up=<arg>           Upscale threshold (buf %)
#             --resize-down=<arg>         Downscale threshold (buf %)
#             --end-usage=<arg>           Rate control mode
#                                           vbr, cbr, cq, q
#             --target-bitrate=<arg>      Bitrate (kbps)
#             --min-q=<arg>               Minimum (best) quantizer
#             --max-q=<arg>               Maximum (worst) quantizer
#             --undershoot-pct=<arg>      Datarate undershoot (min) target (%)
#             --overshoot-pct=<arg>       Datarate overshoot (max) target (%)
#             --buf-sz=<arg>              Client buffer size (ms)
#             --buf-initial-sz=<arg>      Client initial buffer size (ms)
#             --buf-optimal-sz=<arg>      Client optimal buffer size (ms)

# Twopass Rate Control Options:
#             --bias-pct=<arg>            CBR/VBR bias (0=CBR, 100=VBR)
#             --minsection-pct=<arg>      GOP min bitrate (% of target)
#             --maxsection-pct=<arg>      GOP max bitrate (% of target)

# Keyframe Placement Options:
#             --kf-min-dist=<arg>         Minimum keyframe interval (frames)
#             --kf-max-dist=<arg>         Maximum keyframe interval (frames)
#             --disable-kf                Disable keyframe placement

# VP9 Specific Options:
#             --cpu-used=<arg>            CPU Used (-8..8)
#             --auto-alt-ref=<arg>        Enable automatic alt reference frames
#             --sharpness=<arg>           Loop filter sharpness (0..7)
#             --static-thresh=<arg>       Motion detection threshold
    # Number of tile columns to use, log2
    'tile-columns=0'
    # Number of tile rows to use, log2 (set to 0 while threads > 1)
    'tile-rows=0'
#             --arnr-maxframes=<arg>      AltRef max frames (0..15)
#             --arnr-strength=<arg>       AltRef filter strength (0..6)
#             --arnr-type=<arg>           AltRef type
#             --tune=<arg>                Material to favor
#                                           psnr, ssim
#             --cq-level=<arg>            Constant/Constrained Quality level
#             --max-intra-rate=<arg>      Max I-frame bitrate (pct)
#             --max-inter-rate=<arg>      Max P-frame bitrate (pct)
#             --gf-cbr-boost=<arg>        Boost for Golden Frame in CBR mode (pct)
    'lossless=false'
    'frame-parallel=false'
    # Adaptive quantization mode
    # 0: off (default), 1: variance 2: complexity, 3: cyclic refresh,
    # 4: equator360
    'aq-mode=0'
#             --alt-ref-aq=<arg>          Special adaptive quantization for the alternate reference frames.
#             --frame-boost=<arg>         Enable frame periodic boost (0: off (default), 1: on)
#             --noise-sensitivity=<arg>   Noise sensitivity (frames to blur)
#             --tune-content=<arg>        Tune content type
#                                           default, screen
    # The color space of input content:
    # unknown, bt601, bt709, smpte170, smpte240, bt2020, reserved, sRGB
    ###'colorspace=bt2020_ncl'
#             --min-gf-interval=<arg>     min gf/arf frame interval (default 0, indicating in-built behavior)
#             --max-gf-interval=<arg>     max gf/arf frame interval (default 0, indicating in-built behavior)
#             --target-level=<arg>        Target level (255: off (default); 0: only keep level stats; 10: level 1.0; 11: level 1.1; ... 62: level 6.2)
#   -b <arg>, --bit-depth=<arg>           Bit depth for codec (8 for version <=1, 10 or 12 for version 2)
#                                           8, 10, 12
#             --input-bit-depth=<arg>     Bit depth of input





    #'g=9999'
    'g=250'
    "keyint_min=${KeyInt}"
    'bufsize=31250'
    'maxrate=31250'
  )

  if [ ${FFMPEG_VIDEO_ENCODER_PASSES} -gt 1 ] ; then
    if [ ${__pass__} -eq 1 ] ; then
      Parameters+=(
        #  'speed=4'
      )
    else
      Parameters+=(
        #'speed=0'
        'auto-alt-ref=1'
        'lag-in-frames=25'
      )
    fi
  else
    Parameters+=(
      'speed=0'
      'auto-alt-ref=1'
      'lag-in-frames=25'
    )
  fi

  # FIXME: interpret booleans (true/false -> 1/0)
  for Parameter in "${Parameters[@]}" ; do
    Key="$(echo "${Parameter}" | awk -F'=' '{print $1 ; exit}')"
    Value="$(echo "${Parameter}" | awk -F'=' '{print $2 ; exit}')"
    if [ "${Value}" == 'null' ] ; then
      unset Value
    elif [ "${Value}" == true ] ; then
      Value=1
    elif [ "${Value}" == false ] ; then
      Value=0
    fi
    Vp9Params="${Vp9Params:+${Vp9Params} }-${Key}${Value:+ ${Value}}"
  done

  echo "${Vp9Params}"
}
