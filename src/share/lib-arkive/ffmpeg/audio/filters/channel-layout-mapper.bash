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

# Enforce a consistent audio channel layout by remapping non-conformant streams.
function FFmpeg::Audio.filters:channel_layout_map {
  Function::RequiredArgs '2' "$#"
  local ChannelLayout
  local ChannelLayoutMap
  local ChannelLayoutMapTo
  local -A ChannelOrderMap
  local -r File="${2}"
  local -A PanArgsList
  local -r Stream="${1}"

  # https://github.com/FFmpeg/FFmpeg/blob/master/libavutil/channel_layout.c
  # https://github.com/FFmpeg/FFmpeg/blob/master/doc/utils.texi

  # Channel Names

  # 0  = FL   - Front Left
  # 1  = FR   - Front Right
  # 2  = FC   - Front Center
  # 3  = LFE  - Low Frequency
  # 4  = BL   - Back Left
  # 5  = BR   - Back Fight
  # 6  = FLC  - Front Left-of-Center
  # 7  = FRC  - Front Right-of-Center
  # 8  = BC   - Back Center
  # 9  = SL   - Side Left
  # 10 = SR   - Side Right
  # 11 = TC   - Top Center
  # 12 = TFL  - Top Front Left
  # 13 = TFC  - Top Front Center
  # 14 = TFR  - Top Front Right
  # 15 = TBL  - Top Back Left
  # 16 = TBC  - Top Back Center
  # 17 = TBR  - Top Back Right
  # 29 = DL   - Downmix Left
  # 30 = DR   - Downmix Right
  # 31 = WL   - Wide Left
  # 32 = WR   - Wide Right
  # 33 = SDL  - Surround Direct Right
  # 34 = SDR  - Surround Direct Left
  # 35 = LFE2 - Low Frequency 2

  # AC3 channel ordering

  # 0. FL
  # 1. FR
  # 2. FC
  # 3. LFE
  # 4. BL
  # 5. BR

  # Channel Layouts

  # mono           = FC
  # stereo         = FL+FR
  # 2.1            = FL+FR+LFE
  # 3.0            = FL+FR+FC
  # 3.0(back)      = FL+FR+BC
  # 4.0            = FL+FR+FC+BC
  # quad           = FL+FR+BL+BR
  # quad(side)     = FL+FR+SL+SR
  # 3.1            = FL+FR+FC+LFE
  # 4.1            = FL+FR+FC+LFE+BC
  # 5.0            = FL+FR+FC+BL+BR
  # 5.0(side)      = FL+FR+FC+SL+SR
  # 5.1            = FL+FR+FC+LFE+BL+BR
  # 5.1(side)      = FL+FR+FC+LFE+SL+SR
  # 6.0            = FL+FR+FC+BC+SL+SR
  # 6.0(front)     = FL+FR+FLC+FRC+SL+SR
  # hexagonal      = FL+FR+FC+BL+BR+BC
  # 6.1            = FL+FR+FC+LFE+BC+SL+SR
  # 6.1(back)      = FL+FR+FC+LFE+BL+BR+BC
  # 6.1(front)     = FL+FR+LFE+FLC+FRC+SL+SR
  # 7.0            = FL+FR+FC+BL+BR+SL+SR
  # 7.0(front)     = FL+FR+FC+FLC+FRC+SL+SR
  # 7.1            = FL+FR+FC+LFE+BL+BR+SL+SR
  # 7.1(wide)      = FL+FR+FC+LFE+BL+BR+FLC+FRC
  # 7.1(wide-side) = FL+FR+FC+LFE+FLC+FRC+SL+SR
  # octagonal      = FL+FR+FC+BL+BR+BC+SL+SR
  # hexadecagonal  = FL+FR+FC+BL+BR+BC+SL+SR+WL+WR+TBL+TBR+TBC+TFC+TFL+TFR
  # downmix        = DL+DR

  # Channel ordering

  # https://developer.apple.com/reference/coreaudio/1572101-audio_channel_layout_tags

  # NOTE
  # LFE is purposely remapped back into all output channels
  # - You should locally use lowpass filtering on subwoofer channels &
  #   optionally highpass filtering on speaker channels.
  # http://hometheaterhifi.com/volume_7_2/feature-article-misunderstood-lfe-channel-april-2000.html

  # TODO:
  # - filter LFE(2) back into all channels
  #   - if LFE and LFE2 exist, balance between left and right
  # - look into audio level manipulation for certain remappings
  # - TOP channel support
  # - mix flc/frc in fc/fl/fr for 5.0 & 7.0

  ChannelLayout="$(Audio::ChannelLayout "${Stream}" "${File}")"

  # FIXME: Mix in Top channels
  PanArgsList=(
    ['stereo']='pan=stereo|FL<FL+FC+LFE+BL+FLC+BC+SL+TC+TFL+TFC+TBL+TBC+DL+WL+SDL|FR<FR+FC+LFE+BR+FRC+BC+SR+TC+TFR+TBR+TBC+DR+WR+SDR'
    # MPEG_5_1_A
    # MPEG_5_1_B
    # MPEG_5_1_C
    # MPEG_5_1_D
    ['5.1(side)']='pan=5.1(side)|FR<FR+FRC+TC+TFR+DR+LFE|FL<FL+FLC+TC+TFL+DL+LFE|FC<FC+FLC+FRC+TC+TFC+LFE|LFE<LFE|SL<BL+BC+SL+TC+TBL+TBC+WL+SDL+LFE|SR<BR+BC+SR+TC+TBC+TBR+WR+SDR+LFE'
    # MPEG_7_1_A
    # MPEG_7_1_C
    ['7.1']='pan=7.1|FL<FL+FLC+LFE|FR<FR+FRC+LFE|FC<FC+FLC+FRC+LFE|LFE<LFE|SL<SL+LFE|SR<SR+LFE|BL<BL+LFE|BR<BR+LFE'
  )

  ChannelLayoutMapTo="${FFMPEG_AUDIO_CHANNEL_LAYOUT_MAPPINGS[${ChannelLayout}]}"

  # TODO: Make sure string is a valid channel layout
  Var::Type.string "${ChannelLayoutMapTo}"

  ChannelLayoutMap="${PanArgsList[${ChannelLayoutMapTo}]}"

  echo "${ChannelLayoutMap}"
}
