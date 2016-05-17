#!/usr/bin/env bash

sed -i src/bin/arkive \
  -e 's/@LIB_BASH_PATH@/lib-bash/'

sed -i src/share/lib-arkive/ffprobe.bash \
  -e 's/@FFPROBE_PATH@/ffprobe/'

sed -i src/share/lib-arkive/arkive.bash \
  -e 's/@FFMPEG_PATH@/ffmpeg/'
