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
  local ChannelLayout
  local ChannelLayoutMap
  local ChannelLayoutMapTo
  local File="${2}"
  local -A PanArgsList
  local Stream="${1}"

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

  # FIXME: implement missing maps
  PanArgsList=(
    ['mono']='pan=mono|FC<'
    ['stereo']='pan=stereo|FL<FL+FLC+FC+BL+BC+SL+DL+WL+SDL+LFE+LFE2|FR<FR+FRC+FC+BR+BC+SR+DR+WR+SDR+LFE+LFE2'
    ['2.1']='pan=2.1|FL|FR|LFE'
    ['3.0']='pan=3.0|FL|FC|FR'
    ['3.0(back)']='pan=3.0(back)|FL|FR|BC'
    ['4.0']='pan=4.0|FL|FC|FR|BC'
    ['quad']='pan=quad|FL|FR|BL|BR'
    ['quad(side)']='pan=quad(side)|'
    ['3.1']='pan=3.1|'
    ['4.1']='pan=4.1|'
    ['5.0']='pan=5.0|'
    ['5.0(side)']='pan=5.0(side)|SL<BL+BC+SL+LFE+LFE2|FL<FL+LFE+LFE2|FC<FC+LFE+LFE2|FR<FR+LFE+LFE2|SR<BR+BC+SR+LFE+LFE2'
    ['5.1']='pan=5.1|'
    ['5.1(side)']='pan=5.1(side)|'
    ['6.0']='pan=6.0|FL|FR|FC|BC|SL|SR'
    ['6.0(front)']='pan=6.0(front)|'
    ['hexagonal']='pan=hexagonal|'
    ['6.1']='pan=6.1|'
    ['6.1(back)']='pan=6.1(back)|'
    ['6.1(front)']='pan=6.1(front)|'
    ['7.0']='pan=7.0|BL|SL|FL|FC|FR|SR|BR'
    ['7.0(front)']='pan=7.0(front)|'
    ['7.1']='pan=7.1|'
    ['7.1(wide)']='pan=7.1(wide)|'
    ['7.1(wide-side)']='pan=7.1(wide-side)|'
    ['octagonal']='pan=octagonal|'
    ['hexadecagonal']='pan=hexadecagonal|'
    ['downmix']='pan=downmix|' #'
  )

  ChannelLayoutMapTo="${ARKIVE_CHANNEL_LAYOUT_MAPS_LIST[${ChannelLayout}]}"

  # TODO: Make sure string is a valid channel layout
  Var::Type.string "${ChannelLayoutMapTo}"

  ChannelLayoutMap="${PanArgsList[${ChannelLayoutMapTo}]}"

  echo "${ChannelLayoutMap}"
}
