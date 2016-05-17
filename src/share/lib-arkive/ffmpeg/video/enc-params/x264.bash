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
  local Parameters

  # https://en.wikibooks.org/wiki/MeGUI/x264_Settings#Old_Settings
  # https://sites.google.com/site/linuxencoding/x264-ffmpeg-mapping
  # http://www.avidemux.org/admWiki/doku.php?id=tutorial:h.264

  Parameters=(
    # Frame-type opions
    'keyint'
    'min-keyint'
    'scenecut'
    'pre-scenecut'
    'bframes'
    'no-b-adapt'
    'b-adapt'
    'b-bias'
    'b-pyramid'
    'no-cabac'
    'ref'
    'no-deblock'
    'deblock'
    'interlaced'
    # Ratecontrol
    'qp'
    'bitrate'
    'crf'
    'vbv-maxrate'
    'vbv-bufsize'
    'vbv-init'
    'qpmin'
    'qpmax'
    'qpstep'
    'ratetol'
    'ipratio'
    'pbratio'
    'chroma-qp-offset'
    'aq-mode'
    'aq-strength'
    'pass'
    'stats'
    'rceq'
    'qcomp'
    'cplxblur'
    'qblur'
    'zones'
    'qpfile'
    # Analysis
    'partitions'
    'direct'
    'direct-8x8'
    'weightb'
    'me'
    'fpel-cmp'
    'merange'
    'mvrange'
    'mvrange-thread'
    'subme'
    'psy-rd'
    'mixed-refs'
    'no-chroma-me'
    '8c8dct'
    'trellis'
    'no-fast-pskip'
    'no-dct-decimate'
    'nr'
    'deadzone-inter'
    'deadzone-intra'
    'cqm'
    'cqmfile'
    'cqm4'
    'cqm8'
    # Input/Output
    'output'
    'sar'
    'fps'
    'seek'
    'frames'
    'level'
    'verbose'
    'progress'
    'quiet'
    'no-psnr'
    'no-ssim'
    'threads'
    'thread-input'
    'non-deterministic'
    'no-asm'
    'visualize'
    'sps-id'
    'aud'
  )

  #echo "-x264-params $(FFmpeg::Video.x26x_params)"
}
