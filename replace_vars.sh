#!/usr/bin/env bash

if [ "${1}" == '--revert' ] ; then
  sed -i src/bin/arkive \
    -e 's/source "$(.*lib-bash)"/source "$(@LIB_BASH_PATH@)"/'

  sed -i src/share/lib-arkive/ffprobe.bash \
    -e 's/ffprobe /@FFPROBE_PATH@ /'

  sed -i src/bin/arkive \
    -e 's/ffmpeg ${FFmpegArgsList}/@FFMPEG_PATH@ ${FFmpegArgsList}/'
else
  if [ -f "$(readlink -f "$(pwd)/vendor/lib-bash/src/bin/lib-bash")" ] ; then
    file="$(readlink -f "$(pwd)/vendor/lib-bash/src/bin/lib-bash")"
    sed -i src/bin/arkive \
      -e "s,\@LIB_BASH_PATH\@,$file,"
  else
    sed -i src/bin/arkive \
      -e 's/@LIB_BASH_PATH@/lib-bash/'
  fi

  sed -i src/share/lib-arkive/ffprobe.bash \
    -e 's/@FFPROBE_PATH@/ffprobe/'

  sed -i src/bin/arkive \
    -e 's/@FFMPEG_PATH@ ${FFmpegArgsList}/ffmpeg ${FFmpegArgsList}/'
fi
