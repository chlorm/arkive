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
  Function::RequiredArgs '2' "$#"
  local Bitrate
  local BufSize
  local -r File="${2}"
  local MeRange
  local -a __parameters=()
  local RcLookahead
  local -r Stream="${1}"
  local X26xParams

  Bitrate="$(FFmpeg::Video.bitrate "${Stream}" "${File}")"

  # Buffer size is bitrate +10%
  BufSize=$(echo "scale=10;${Bitrate}*1.10)" | bc -l | xargs printf "%1.0f")

  FrameRate="$(
    echo "scale=10;$(FFmpeg::Video.frame_rate "${Stream}" "${File}")" |
        bc -l |
        xargs printf "%1.0f"
  )"
  RcLookahead=${FrameRate}
  if [ ${RcLookahead} -gt 250 ] ; then
    RcLookahead=250
  fi

  MeRange="$(FFmpeg::Video.motion_estimation_range "${Stream}" "${File}")"
  # Motion Estimation ranges below 57 reduce coding efficiency
  # http://forum.doom9.org/showthread.php?p=1713094#post1713094
  if [ ${MeRange} -lt 58 ] ; then
    MeRange=58
  fi

  __parameters+=(
    "keyint=$(FFmpeg::Video.keyframe_interval "${Stream}" "${File}")"
  )
  __parameters+=(
    "min-keyint=$(FFmpeg::Video.min_keyframe_interval "${Stream}" "${File}")"
  )
  __parameters+=(
    'scenecut=0'
    'intra-refresh=0'
    'bframes=3'
    'b-adapt=0'
    'b-bias=0'
    'b-pyramid=normal'
    'open-gop=0'
    'cabac=1'
    'ref=3'
    'deblock=-6\:-6'
    'slices=0'
    'slices-max=0'
    'slice-max-size=0'
    'slice-max-mbs=0'
    'slice-min-mbs=0'
    'tff=0'
    'bff=0'
    'constrained-intra=1'
    #'pulldown=none'
    'fake-interlaced=0'
    'interlaced=0'
    # TODO: support alternative frame-packing for 3D sources
    'frame-packing=6'
    "rc-lookahead=${RcLookahead}"
    "vbv-maxrate=${BufSize}"
    "vbv-bufsize=${BufSize}"
    'vbv-init=0.9'
    'qpmin=10'
    'qpmax=51' # XXX
    'qpstep=8'
    'ratetol=10.0'
    'ipratio=1.4'
    'pbratio=1.0'
    # If psy-rd or trellis are enabled chroma-qp-offset is offset by -2 each
    # Make sure the offset is at least -4 if either are disabled to counter
    # some artifacting.
    'chroma-qp-offset=0'
    'aq-mode=2'
    'aq-strength=0.3'
    'mbtree=1'
    'qcomp=0.9'
    'cplxblur=0'  # Does nothing when mbtree is enabled
    'qblur=0'
    #'qpfile'
    'partitions=all\:i8x8'
    'direct=auto'
    'weightb=1'
    'weightp=2'
    'me=umh'
    "merange=${MeRange}"
    'subme=10'
    'psy-rd=0.0\:0.7' # FIXME
    'psy=1'
    'mixed-refs=1'
    'chroma-me=1'
    '8x8dct=1'
    'trellis=2'
    'fast-pskip=0'
    'dct-decimate=0'
    'nr=0'
    'deadzone-inter=21'
    'deadzone-intra=11'
    #"cqmfile=${ARKIVE_LIB_DIR}/ffmpeg/video/enc-params/cqm-matrices/prestige_matrix"
    #'overscan'
    #'videoformat'
    ###'range=pc'
    'colorprim=bt709'
    'transfer=bt709'
    'colormatrix=bt709'
    #'chromaloc'
    'nal-hrd=none'
    #'filler'
    #'pic-struct'
    #'crop-rect'
    #'sar'
    #'fps'
  )
  __parameters+=(
    # Without specifing the level some decoders such as Chromium's incorrectly
    # detect the level which results in stuttering playback (chromium falls
    # back to 3.0).
    "level=$(FFmpeg::Video.level:h264 "${Stream}" "${File}")"
  )
  __parameters+=(
    'bluray-compat=0'
    ###'avcintra-class=0'
    'stitchable=0'
    ###'log-level=info'
    'psnr=0'
    'ssim=0'
  )
  __parameters+=("threads=$(Cpu::Logical)")
  __parameters+=(
    'lookahead-threads=1'
    'sliced-threads=0'
    #'sync-lookahead'
    'non-deterministic=0'
    'cpu-independent=0'
    'asm=auto'
    'opencl=0'
    'opencl-clbin=0'
    #'opencl-device'
    #'dump-yuv'
    #'sps-id'
    #'aud=0'
    #'force-cfr'
    #'tcfile-in'
    #'tcfile-out'
    #'timebase'
    ######'dts-compress=0'
  )

  if [ ${FFMPEG_VIDEO_ENCODER_PASSES} -gt 1 ] ; then
    __parameters+=(
      "pass=${__pass__}"
      "stats=${__tmpdir__}/${__filenamefmt__}.stats"
    )
  fi

  X26xParams="$(FFmpeg::Video.x26x_params)"

  echo "-x264-params ${X26xParams}"
}
