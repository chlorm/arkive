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

# Generates formatted ffmpeg x264-params key/values
function FFmpeg::Video.codec:x264_params {
  local Bitrate
  local BufSize
  local File="${2}"
  local FrameRate
  local -a __parameters
  local Stream="${1}"
  local X26xParams

  Bitrate="$(FFmpeg::Video.bitrate "${Stream}" "${File}")"
  # Buffer size is bitrate +10%
  # Setting the buffer size much higher than the bitrate becomes counter
  # productive and can lower visual quality.
  BufSize=$(Math::RoundFloat "$(echo "${Bitrate}+(${Bitrate}*0.1)" | bc -l)")

  FrameRate="$(FFmpeg::Video.frame_rate "${Stream}" "${File}")"



  ### Frame-type opions ###
  __parameters+=(
    "keyint=$(FFmpeg::Video.keyframe_interval "${Stream}" "${File}")"
  )
  __parameters+=(
    "min-keyint=$(FFmpeg::Video.min_keyframe_interval "${Stream}" "${File}")"
  )
  __parameters+=(
    'scenecut=0'
    'intra-refresh=false'
    'bframes=2'
    'b-adapt=1'
    'b-bias=0'
    'b-pyramid=normal'
    'open-gop=true'
    'cabac=true'
    'ref=3'
    'deblock=\-3\:0'
    'slices=0'
    'slices-max=0'
    'slice-max-size=0'
    'slice-max-mbs=0'
    'slice-min-mbs=0'
    'tff=false'
    'bff=false'
    'constrained-intra=false'
    #'pulldown=none'
    'fake-interlaced=false'
    'interlaced=false'
    # TODO: support alternative frame-packing for 3D sources
    'frame-packing=6'
  )
  ### Ratecontrol ###
  # FIXME: limit value to <= 250
  __parameters+=("rc-lookahead=$(( ${FrameRate} * 2 ))")
  __parameters+=("vbv-maxrate=${BufSize}")
  __parameters+=("vbv-bufsize=${BufSize}")
  __parameters+=(
    'vbv-init=0.9'
    'qpmin=0'
    'qpmax=69' # XXX
    'qpstep=4' # XXX
    'ratetol=10.0'
    'ipratio=1.4'
    'pbratio=1.1'
    # If psy-rd or trellis are enabled chroma-qp-offset is offset by -2 each
    # Make sure the offset is at least -4 if either are disabled to counter
    # some artifacting.
    'chroma-qp-offset=0'
    'aq-mode=1'
    'aq-strength=1.0'
    'mbtree=true'
    'qcomp=0.6'
    # Does nothing when mbtree is enabled
    'cplxblur=20.0'
    'qblur=0.5'
    #'qpfile'
  ### Analysis ###
    'partitions=all'
    'direct=auto'
    'weightb=true'
    'weightp=2'
    'me=umh'
  )
  __parameters+=(
    "merange=$(FFmpeg::Video.motion_estimation_range "${Stream}" "${File}")"
  )
  __parameters+=(
    'subme=9'
    'psy-rd=1.0\:0.25' # FIXME
    'psy=true'
    'mixed-refs=true'
    'chroma-me=true'
    '8x8dct=true'
    'trellis=1'
    'fast-pskip=false'
    'dct-decimate=false'
    'nr=0'
    'deadzone-inter=21'
    'deadzone-intra=11'
    #"cqmfile=${ARKIVE_PREFIX}/share/lib-arkive/ffmpeg/video/enc-params/cqm-matrices/eqm_avc_hr_matrix"
  ### Video Usability Info ###
    #'overscan'
    #'videoformat'
    #'range'
    'colorprim=bt709'
    'transfer=bt709'
    'colormatrix=bt709'
    #'chromaloc'
    'nal-hrd=none'
    #'filler'
    #'pic-struct'
    #'crop-rect'
    ### Input/Output ###
    #'sar'
  )
  __parameters+=(
    # Without specifing the level some decoders such as Chromium's incorrectly
    # detect the level which results in stuttering playback (chromium falls
    # back to 3.0).
    "level=$(FFmpeg::Video.level:h264 "${Stream}" "${File}")"
  )
  __parameters+=(
    'bluray-compat=false'
    'avcintra-class=false'
    #'stitchable'
    'psnr=false'
    'ssim=false'
  )
  __parameters+=("threads=$(Cpu::Logical)")
  __parameters+=(
    #'lookahead-threads'
    'sliced-threads=false'
    #'sync-lookahead'
    'non-deterministic=false'
    'asm=auto'
    #'opencl'
    #'opencl-clbin'
    #'opencl-device'
    #'dump-yuv'
    #'sps-id'
    #'aud'
    #'force-cfr'
    #'tcfile-in'
    #'tcfile-out'
    #'timebase'
    ######'dts-compress=false'
  )

  if [ ${ARKIVE_VIDEO_ENCODING_PASSES} -gt 1 ] ; then
    __parameters+=(
      "pass=${__pass__}"
      "stats=${__tmpdir__}/${__filenamefmt__}.stats"
    )
  fi

  X26xParams="$(FFmpeg::Video.x26x_params)"

  echo "-x264-params ${X26xParams}"
}
