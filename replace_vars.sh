#!/usr/bin/env bash

if [ "${1}" == '--revert' ] ; then
  sed -i src/bin/arkive \
    -e 's/source "$(.*)"/source "$(@LIB_BASH_PATH@)"/'

  sed -i src/share/lib-arkive/ffprobe.bash \
    -e 's/ffprobe /@FFPROBE_PATH@ /'

  sed -i src/share/lib-arkive/arkive.bash \
    -e 's/ffmpeg ${FFmpegArgsList}/@FFMPEG_PATH@ ${FFmpegArgsList}/'
else
  if [ "${1}" == '--local' ] ; then
    file="$(readlink -f "$(pwd)/../lib-bash/src/bin/lib-bash")"
    sed -i src/bin/arkive \
      -e "s,\@LIB_BASH_PATH\@,$file,"
  elif [ -n "${1}" ] ; then
    echo "invalid: ${1}"
  else
    sed -i src/bin/arkive \
      -e 's/@LIB_BASH_PATH@/lib-bash/'
  fi

  sed -i src/share/lib-arkive/ffprobe.bash \
    -e 's/@FFPROBE_PATH@/ffprobe/'

  sed -i src/share/lib-arkive/arkive.bash \
    -e 's/@FFMPEG_PATH@ ${FFmpegArgsList}/ffmpeg ${FFmpegArgsList}/'
fi
