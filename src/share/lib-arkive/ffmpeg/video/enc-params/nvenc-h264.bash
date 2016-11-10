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

function FFmpeg::Video.codec:nvenc_h264_params {
  Function::RequiredArgs '3' "$#"
  local -r File="${2}"
  local FrameRate
  local -r Index="${3}"
  local -a Parameters=()
  local -r Stream="${1}"

  FrameRate="$(FFmpeg::Video.frame_rate "${Stream}" "${File}")"

# h264_nvenc AVOptions:
#   -preset            <int>        E..V.... Set the encoding preset (from 0 to 11) (default medium)
#      default                      E..V....
#      slow                         E..V.... hq 2 passes
#      medium                       E..V.... hq 1 pass
#      fast                         E..V.... hp 1 pass
#      hp                           E..V....
#      hq                           E..V....
#      bd                           E..V....
#      ll                           E..V.... low latency
#      llhq                         E..V.... low latency hq
#      llhp                         E..V.... low latency hp
#      lossless                     E..V....
#      losslesshp                   E..V....
#   -profile           <int>        E..V.... Set the encoding profile (from 0 to 3) (default main)
#      baseline                     E..V....
#      main                         E..V....
#      high                         E..V....
#      high444p                     E..V....
#   -level             <int>        E..V.... Set the encoding level restriction (from 0 to 51) (default auto)
#      auto                         E..V....
#      1                            E..V....
#      1.0                          E..V....
#      1b                           E..V....
#      1.0b                         E..V....
#      1.1                          E..V....
#      1.2                          E..V....
#      1.3                          E..V....
#      2                            E..V....
#      2.0                          E..V....
#      2.1                          E..V....
#      2.2                          E..V....
#      3                            E..V....
#      3.0                          E..V....
#      3.1                          E..V....
#      3.2                          E..V....
#      4                            E..V....
#      4.0                          E..V....
#      4.1                          E..V....
#      4.2                          E..V....
#      5                            E..V....
#      5.0                          E..V....
#      5.1                          E..V....
#   -rc                <int>        E..V.... Override the preset rate-control (from -1 to INT_MAX) (default -1)
#      constqp                      E..V.... Constant QP mode
#      vbr                          E..V.... Variable bitrate mode
#      cbr                          E..V.... Constant bitrate mode
#      vbr_minqp                    E..V.... Variable bitrate mode with MinQP
#      ll_2pass_quality             E..V.... Multi-pass optimized for image quality (only for low-latency presets)
#      ll_2pass_size                E..V.... Multi-pass optimized for constant frame size (only for low-latency presets)
#      vbr_2pass                    E..V.... Multi-pass variable bitrate mode
#   -rc-lookahead      <int>        E..V.... Number of frames to look ahead for rate-control (from -1 to INT_MAX) (default -1)
#   -surfaces          <int>        E..V.... Number of concurrent surfaces (from 0 to INT_MAX) (default 32)
#   -cbr               <boolean>    E..V.... Use cbr encoding mode (default false)
#   -2pass             <boolean>    E..V.... Use 2pass encoding mode (default auto)
#   -gpu               <int>        E..V.... Selects which NVENC capable GPU to use. First GPU is 0, second is 1, and so on. (from -2 to INT_MAX) (default any)
#      any                          E..V.... Pick the first device available
#      list                         E..V.... List the available devices
#   -delay             <int>        E..V.... Delay frame output by the given amount of frames (from 0 to INT_MAX) (default INT_MAX)
#   -no-scenecut       <boolean>    E..V.... When lookahead is enabled, set this to 1 to disable adaptive I-frame insertion at scene cuts (default false)
#   -forced-idr        <boolean>    E..V.... If forcing keyframes, force them as IDR frames. (default auto)
#   -b_adapt           <boolean>    E..V.... When lookahead is enabled, set this to 0 to disable adaptive B-frame decision (default true)
#   -spatial-aq        <boolean>    E..V.... set to 1 to enable Spatial AQ (default false)
#   -temporal-aq       <boolean>    E..V.... set to 1 to enable Temporal AQ (default false)
#   -zerolatency       <boolean>    E..V.... Set 1 to indicate zero latency operation (no reordering delay) (default false)
#   -nonref_p          <boolean>    E..V.... Set this to 1 to enable automatic insertion of non-reference P-frames (default false)
#   -strict_gop        <boolean>    E..V.... Set 1 to minimize GOP-to-GOP rate fluctuations (default false)
#   -aq-strength       <int>        E..V.... When Spatial AQ is enabled, this field is used to specify AQ strength. AQ strength scale is from 1 (low) - 15 (aggressive) (from 1 to 15) (default 8)
#   -cq                <int>        E..V.... Set target quality level (0 to 51, 0 means automatic) for constant quality mode in VBR rate control (from 0 to 51) (default 0)
  Parameters+=(
    "-preset:${Index} slow"
    "-profile:${Index} main"
  )
  Parameters+=(
    "-level:${Index} $(FFmpeg::Video.level:h264 "${Stream}" "${File}")"
  )
  Parameters+=(
    "-rc:${Index} ll_2pass_quality"
  )
  Parameters+=(
    "-rc-lookahead:${Index} $(( ${FrameRate} * 10 ))"
  )
  Parameters+=(
    #"-surfaces "
    #"-cbr 1"
    "-2pass:${Index} 1"
    "-gpu:${Index} any"
    "-delay:${Index} 3000"
    "-no-scenecut:${Index} 1"
    "-forced-idr 0"
    "-b_adapt 1"
    "-spatial-aq 1"
    "-temporal-aq 1"
    # '-zerolatency 0'
    '-nonref_p 1'
    "-strict_gop 1"
    "-aq-strength 1"
    #"-cq 1"
    "-qmin 28"
    "-qmax 1"
  )

  echo "${Parameters[@]}"
}
