#!/usr/bin/env bash

if [ "${1}" == '--revert' ] ; then
  sed -i src/bin/arkive \
    -e 's/(lib-bash)/(@LIB_BASH_PATH@)/'

  sed -i src/share/lib-arkive/ffprobe.bash \
    -e 's/ffprobe \\/@FFPROBE_PATH@ \\/'

  sed -i src/share/lib-arkive/arkive.bash \
    -e 's/ffmpeg \\/@FFMPEG_PATH@ \\/'
else
  sed -i src/bin/arkive \
    -e 's/@LIB_BASH_PATH@/lib-bash/'

  sed -i src/share/lib-arkive/ffprobe.bash \
    -e 's/@FFPROBE_PATH@/ffprobe/'

  sed -i src/share/lib-arkive/arkive.bash \
    -e 's/@FFMPEG_PATH@/ffmpeg/'
fi
