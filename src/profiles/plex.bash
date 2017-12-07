# Plex compatible h.264/AVC main profile, ACC-LC stereo

# Plex is a pile of crap and most clients default to 2Mbps 720p, anything
# higher automatically transcodes regardless of compatibility.
arkive_profile_plex() {
  FFMPEG_CONTAINER_FORMAT='mkv'
  FFMPEG_VIDEO_ENCODER='x264'
  #FFMPEG_VIDEO_BITSPERPIXEL='0.04218205761316872427'  # 2048
  #FFMPEG_VIDEO_BITSPERPIXEL='0.05272757201646090534'  # 2560
  FFMPEG_VIDEO_BITSPERPIXEL='0.08436411522633744855'  # 4096
  FFMPEG_VIDEO_BITDEPTH=8
  FFMPEG_VIDEO_ENCODER_PASSES=2
  FFMPEG_VIDEO_FRAMERATE='source'
  FFMPEG_VIDEO_HEIGHT=720
  FFMPEG_VIDEO_WIDTH=1280
  FFMPEG_AUDIO_ENCODER='fdk-aac'
  FFMPEG_AUDIO_CHANNEL_LAYOUT_MAPPINGS=(
    ['mono']='stereo'
    ['stereo']='stereo'
    ['2.1']='stereo'
    ['3.0']='stereo'
    ['3.0(back)']='stereo'
    ['4.0']='stereo'
    ['quad']='stereo'
    ['quad(side)']='stereo'
    ['3.1']='stereo'
    ['5.0']='stereo'
    ['5.0(side)']='stereo'
    ['4.1']='stereo'
    ['5.1']='stereo'
    ['5.1(side)']='stereo'
    ['6.0']='stereo'
    ['6.0(front)']='stereo'
    ['hexagonal']='stereo'
    ['6.1']='stereo'
    ['6.1(back)']='stereo'
    ['6.1(front)']='stereo'
    ['7.0']='stereo'
    ['7.0(front)']='stereo'
    ['7.1']='stereo'
    ['7.1(wide)']='stereo'
    ['7.1(wide-side)']='stereo'
    ['octagonal']='stereo'
    ['hexadecagonal']='stereo'
    ['downmix']='stereo'
  )
  FFMPEG_AUDIO_FILTER_EBUR128_I='-21.0'
  FFMPEG_AUDIO_FILTER_EBUR128_LRA='8.0'
  # Negative values cause choppy harmonic distortion when applying gain.
  FFMPEG_AUDIO_FILTER_EBUR128_TP='0.0'
  ARKIVE_SUBTITLES=false
}
