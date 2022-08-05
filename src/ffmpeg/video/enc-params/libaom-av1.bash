

function ffmpeg_video_codec_libaom_av1_params {
  local -a params=()

  params+=('-cpu-used')  # 0-8
  params+=('-auto-alt-ref')
  'lag-in-frames'
  'error-resilience'
  'default'
  'partitions'
  'crf'
  'static-thresh'
  'drop-threshold'
  'noise-sensitivity'

  # Profiles High/Main/Professional
}

