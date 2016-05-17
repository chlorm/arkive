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

# FIXME: rewite mappings
# Enforce a consistent audio channel layout by remapping non-conformant streams.
function FFmpeg::Audio.channel_layout_map {
  local Stream="${1}"

  # https://github.com/FFmpeg/FFmpeg/blob/master/libavutil/channel_layout.c
  # https://github.com/FFmpeg/FFmpeg/blob/master/doc/utils.texi

  # 0 = FL - Front Left
  # 1 = FR - Front Right
  # 2 = FC - Front Center
  # 3 = LFE - Low Frequency
  # 4 = BL - Back Left
  # 5 = BR - Back Fight
  # 6 = FLC - Front Left-of-Center
  # 7 = FRC - Front Right-of-Center
  # 8 = BC - Back Center
  # 9 = SL - Side Left
  # 10 = SR - Side Right
  # 11 = TC - Top Center
  # 12 = TFL - Top Front Left
  # 13 = TFC - Top Front Center
  # 14 = TFR - Top Front Right
  # 15 = TBL - Top Back Left
  # 16 = TBC - Top Back Center
  # 17 = TBR - Top Back Right
  # 29 = DL - Downmix Left
  # 30 = DR - Downmix Right
  # 31 = WL - Wide Left
  # 32 = WR - Wide Right
  # 33 = SDL - Surround Direct Right
  # 34 = SDR - Surround Direct Left
  # 35 = LFE2 - Low Frequency 2

  # AC3 channel ordering

  # 0. FL
  # 1. FR
  # 2. FC
  # 3. LFE
  # 4. BL
  # 5. BR

  # Layouts

  # LFE is purposely remapped back into all output channels
  # - You should locally use lowpass filtering on subwoofer channels &
  #   optionally highpass filtering on speaker channels.
  # http://hometheaterhifi.com/volume_7_2/feature-article-misunderstood-lfe-channel-april-2000.html

  # stereo    - FL+FR
  # 5.0(side) - FL+FR+FC+SL+SR
  # 7.0       - FL+FR+FC+SL+SR+BL+BR
  # TODO: add additional options including the top speakers

  # TODO:
  # - FIXME: fix channel remappings to reflect design changes
  # - filter LFE(2) back into all channels
  # - look into audio level manipulation for certain remappings
  # - TOP channel support
  # - mix flc/frc in fc/fl/fr for 5.0 & 7.0

  # if_lfe2_l() {
  #   echo "+LFE"
  # }

  # if_lfe2_l() {
  #   echo "+LFE2"
  # }

  'pan=stereo|FL<FL+FLC+FC+BL+BC+SL+DL+WL+SDL+LFE+LFE2|FR<FR+FRC+FC+BR+BC+SR+DR+WR+SDR+LFE+LFE2'
  'pan=5.0(side)|SL<BL+BC+SL+LFE+LFE2|FL<FL+LFE+LFE2|FC<FC+LFE+LFE2|FR<FR+LFE+LFE2|SR<BR+BC+SR+LFE+LFE2'
  'pan=7.0|BL|SL|FL|FC|FR|SR|BR'

  case "$(Audio::ChannelLayout "${Stream}")" in
    'mono') # FC -> stereo
      echo "pan=stereo|FL<FC|FR<FC"
      ;;
    'stereo') # FL+FR -> stereo
      echo "pan=stereo|FL<FL|FR<FR"
      ;;
    '2.1') # FL+FR+LFE -> stereo
      echo "pan=stereo|FL<FL+LFE|FR<FR+LFE"
      ;;
    '3.0') # FL+FR+FC -> stereo
      echo "pan=stereo|FL<FL+FC|FR<FR+FC"
      ;;
    '3.0(back)') # FL+FR+BC -> stereo
      echo "pan=stereo|FL<FL+BC|FR<FR+BC"
      ;;
    '4.0') # FL+FR+FC+BC -> stereo
      echo "pan=stereo|FL<FL+FC+BC|FR<FR+FC+BC"
      ;;
    'quad') # FL+FR+BL+BR -> 7.0
      echo "pan=5.1|FL<FL|FR<FR|FC<FL+FR|LFE<FL+FR+BL+BR|BL<BLBR<BR"
      ;;
    'quad(side)') # FL+FR+SL+SR -> 5.0
      echo "pan=stereo|FL<FL+SL|FR<FR+SR"
      ;;
    '3.1') # FL+FR+FC+LFE -> stereo
      echo "pan=stereo|FL<FL+FC+LFE|FR<FR+FC+LFE"
      ;;
    '4.1') # FL+FR+FC+LFE+BC -> stereo
      echo "pan=stereo|FL<FL+FC+BC+LFE|FR<FR+FC+BC+LFE"
      ;;
    '5.0') # FL+FR+FC+BL+BR -> 7.0
      echo "pan=5.1|FL<FL|FR<FR|FC<FC|LFE<FL+FR+FC+BL+BR|BL<BL|BR<BR"
      ;;
    '5.0(side)') # FL+FR+FC+SL+SR -> 5.0
      echo "pan=5.1|FL<FL|FR<FR|FC<FC|LFE<FL+FR+FC+SL+SR|BL<SL|BR<SR"
      ;;
    '5.1') # FL+FR+FC+LFE+BL+BR -> 7.0
      echo "pan=5.1|FL<FL|FR<FR|FC<FC|LFE<LFE|BL<BL|BR<BR"
      ;;
    '5.1(side)') # FL+FR+FC+LFE+SL+SR -> 5.0
      echo "pan=5.1|FL<FL|FR<FR|FC<FC|LFE<LFE|BL<SL|BR<SR"
      ;;
    '6.0') # FL+FR+FC+BC+SL+SR -> 7.0
      echo "pan=5.1|FL<FL|FR<FR|FC<FC|LFE<FL+FR+FC+BC+SL+SR|BL<SL+BC|BR<SR+BC"
      ;;
    '6.0(front)') # FL+FR+FLC+FRC+SL+SR -> 5.0
      echo "pan=5.1|FL<FL+FLC|FR<FR+FRC|FC<FC+FLC+FRC|LFE<FL+FR+FLC+FRC+SL+SR|BL<SL|BR<SR"
      ;;
    'hexagonal') # FL+FR+FC+BL+BR+BC -> 7.0
      echo "pan=5.1|FL<FL|FR<FR|FC<FC|LFE<FL+FR+FC+BL+BR+BC|BL<BL+BC|BR<BL+BC"
      ;;
    '6.1') # FL+FR+FC+LFE+BC+SL+SR -> 7.0
      echo "pan=5.1|FL<FL|FR<FR|FC<FC|LFE<LFE|BL<SL+BC|BR<SR+BC"
      ;;
    '6.1(back)') # FL+FR+FC+LFE+BL+BR+BC -> 7.0
      echo "pan=5.1|FL<FL|FR<FR|FC<FC|LFE<LFE|BL<BL+BC|BR<BR+BC"
      ;;
    '6.1(front)') # FL+FR+LFE+FLC+FRC+SL+SR -> 5.0
      echo "pan=5.1|FL<FL+FLC|FR<FR+FRC|FC<FLC+FRC+FL+FR|LFE<FL+FR+LFE+FLC+FRC+SL+SR|BL<SL|BR<SR"
      ;;
    '7.0') # FL+FR+FC+BL+BR+SL+SR -> 7.0
      echo "pan=5.1|FL<FL|FR<FR|FC<FC|LFE<FL+FR+FC+BL+BR+SL+SR|BL<BL+SL|BR<BR+SR"
      ;;
    '7.0(front)') # FL+FR+FC+FLC+FRC+SL+SR -> 5.0
      echo "pan=5.1|FL<FL+FLC|FR<FR+FRC|FC<FC+FLC+FRC|LFE<FL+FR+FC+FLC+FRC+SL+SR|BL<SL|BR<SR"
      ;;
    '7.1') # FL+FR+FC+LFE+BL+BR+SL+SR -> 7.0
      echo "pan=5.1|FL<FL|FR<FR|FC<FC|LFE<LFE|BL<BL+SL|BR<BR+SR"
      ;;
    '7.1(wide)') # FL+FR+FC+LFE+BL+BR+FLC+FRC -> 7.0
      echo "pan=5.1|FL<FL+FLC|FR<FR+FRC|FC<FC+FLC+FRC|LFE<LFE|BL<BL|BR<BR"
      ;;
    '7.1(wide-side)') # FL+FR+FC+LFE+FLC+FRC+SL+SR -> 5.0
      echo "pan=5.1|FL<FL+FLC|FR<FR+FRC|FC<FLC+FRC|LFE<LFE|BL<SL|BR<SR"
      ;;
    'octagonal') # FL+FR+FC+BL+BR+BC+SL+SR -> 7.0
      echo "pan=5.1|FL<FL|FR<FR|FC<FC|LFE<FL+FR+FC+BL+BR+BC+SL+SR|BL<BL+BC+SL|BR<BR+BC+SR"
      ;;
    'downmix') # DL+DR -> stereo
      echo "pan=stereo|FL<DL|FR<DR"
      ;;
    *)
      echo "ERROR: Unsupported channel layout"
      return 1
      ;;
  esac
}
