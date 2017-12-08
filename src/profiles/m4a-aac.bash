# Arkive m4a/aac-lc audio
arkive_profile_m4a_aac() {
  ARKIVE_VIDEO=false
  FFMPEG_CONTAINER_FORMAT='m4a'
  FFMPEG_AUDIO_CHANNEL_BITRATE=64
  FFMPEG_AUDIO_ENCODER='ffaac'
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
}
