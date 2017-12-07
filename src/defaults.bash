# Copyright (c) 2016, Cody Opel <codyopel@gmail.com>
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

arkive_declare_defaults() {
  # Allow overwriting existing files
  ARKIVE_ALLOW_OVERWRITING_FILES=true

  ################################# Container ##################################

  # Container format (m4v,mkv,mp4,ogv,webm)
  FFMPEG_CONTAINER_FORMAT='mkv'

  ################################### Video ####################################

  ARKIVE_VIDEO=true
  # Video Codec (x264,x265,nvenc-h264,nvenc-h265,vaapi-h264,vp9)
  FFMPEG_VIDEO_ENCODER='x265'

  # Bits Per Pixel (used to dynamically determine bitrate)
  # 200 (For audio testing purposes only)
  #FFMPEG_VIDEO_BITSPERPIXEL='0.00411934156378600823'
  # 2048
  #FFMPEG_VIDEO_BITSPERPIXEL='0.04218205761316872427'
  # 2560
  FFMPEG_VIDEO_BITSPERPIXEL='0.05272757201646090534'
  # 3072
  #FFMPEG_VIDEO_BITSPERPIXEL='0.06327308641975308641'
  # 4096
  #FFMPEG_VIDEO_BITSPERPIXEL='0.08436411522633744855'
  # 5120
  #FFMPEG_VIDEO_BITSPERPIXEL='0.10545514403292181069'
  # 6144
  #FFMPEG_VIDEO_BITSPERPIXEL='0.12654617283950617283'
  # 7168
  #FFMPEG_VIDEO_BITSPERPIXEL='0.14763720164609053497'
  # 8192
  #FFMPEG_VIDEO_BITSPERPIXEL='0.16872823045267489711'
  # 10240
  #FFMPEG_VIDEO_BITSPERPIXEL='0.21091028806584362139'
  # 20480
  #FFMPEG_VIDEO_BITSPERPIXEL='0.42182057613168724279'

  # Bits per channel color (8,10,12) (ignored for h.264)
  FFMPEG_VIDEO_BITDEPTH=10

  # Chroma Subsampling (420,422,444)
  FFMPEG_VIDEO_CHROMASUBSAMPLING=420

  # Multi-pass video encoding (1-3)
  FFMPEG_VIDEO_ENCODER_PASSES=1

  # Frame Rate (FPS)
  FFMPEG_VIDEO_FRAMERATE='source'

  FFMPEG_VIDEO_HEIGHT='source'
  FFMPEG_VIDEO_WIDTH='source'

  ################################### Audio ####################################

  ARKIVE_AUDIO=true
  # Frequency cutoff (4000,6000,8000,12000,20000)
  FFMPEG_AUDIO_CUTOFF=19600
  # Audio Codec (aac,ac3,eac3,ffaac,fdk-aac,flac,opus,vorbis)
  FFMPEG_AUDIO_ENCODER='opus'
  # AAC codec options
  FFMPEG_AUDIO_ENCODER_AAC_PROFILE='aac_low'  # AAC-LC
  # Opus codec options
  FFMPEG_AUDIO_ENCODER_OPUS_FRAMEDURATION=20
  FFMPEG_AUDIO_ENCODER_OPUS_COMPRESSIONLEVEL=10
  FFMPEG_AUDIO_ENCODER_OPUS_VBR='on'
  FFMPEG_AUDIO_ENCODER_OPUS_CUTOFF=${FFMPEG_AUDIO_CUTOFF}
  FFMPEG_AUDIO_ENCODER_OPUS_APPLICATION='audio'
  FFMPEG_AUDIO_ENCODER_OPUS_EXTRAARGS=
  # Bitrate per audio channel in kbps (5.1 -> 6 * 64 = 384),
  # Ignored if `flac` codec is specified
  FFMPEG_AUDIO_CHANNEL_BITRATE=64
  # Sample rate (44100,48000,96000,192000)
  FFMPEG_AUDIO_SAMPLERATE=48000
  # Set minimum allowed sample rate as a safety check for finding bad sources
  FFMPEG_AUDIO_SAMPLERATE_MINIMUM=44100
  # Streams with phrases from this list in their title are discarded
  FFMPEG_AUDIO_STREAM_DISCARDKEYWORDS=(
    'commentary'
  )
  # Audio default language (ISO 639-2/B)
  ARKIVE_AUDIO_LANG_DEFAULT='eng'
  #### Audio languages to include (ISO 639-2/B)
  # Values over -16 may result in excessive peak limiting and limit the dynamic range
  # Values lower than -20 may not be loud enough to be audible on some devices
  FFMPEG_AUDIO_FILTER_EBUR128_I='-16.0'
  FFMPEG_AUDIO_FILTER_EBUR128_LRA='8.0'
  # Negative values cause choppy harmonic distortion when applying gain.
  FFMPEG_AUDIO_FILTER_EBUR128_TP='0.0'
  # Channel layout mappings
  declare -g -A FFMPEG_AUDIO_CHANNEL_LAYOUT_MAPPINGS
  FFMPEG_AUDIO_CHANNEL_LAYOUT_MAPPINGS=(
    ['mono']='stereo'
    ['stereo']='stereo'
    ['2.1']='stereo'
    ['3.0']='stereo'
    ['3.0(back)']='stereo'
    ['4.0']='7.1'
    ['quad']='7.1'
    ['quad(side)']='5.1(side)'
    ['3.1']='stereo'
    ['5.0']='5.1(side)'
    ['5.0(side)']='5.1(side)'
    ['4.1']='stereo'
    ['5.1']='5.1(side)'
    ['5.1(side)']='5.1(side)'
    ['6.0']='5.1(side)'
    ['6.0(front)']='5.1(side)'
    ['hexagonal']='7.1'
    ['6.1']='7.1'
    ['6.1(back)']='7.1'
    ['6.1(front)']='5.1(side)'
    ['7.0']='7.1'
    ['7.0(front)']='5.1(side)'
    ['7.1']='7.1'
    ['7.1(wide)']='7.1'
    ['7.1(wide-side)']='5.1(side)'
    ['octagonal']='7.1'
    ['hexadecagonal']='7.1'
    ['downmix']='stereo'
  )
  FFMPEG_AUDIO_CHANNEL_LAYOUT_FALLBACK='stereo'

  ################################# Subtitles ##################################

  ###ARKIVE_SUBTITLES_LANGS=('eng')
  # Subtitles, NOT IMPLEMENTED
  ARKIVE_SUBTITLES=true
  # Subtitles default language (ISO 639-2/B)
  ARKIVE_SUBTITLES_LANG_DEFAULT='eng'
  # Subtitle languages to include (ISO 639-2/B)
  ARKIVE_SUBTITLES_LANGS=('eng')
  # Subtitle codec (ass,srt)
  ARKIVE_SUBTITLE_CODEC='ass'

  ################################## Chapters ##################################

  # Chapters, NOT IMPLEMENTED
  ARKIVE_CHAPTERS=true
}
