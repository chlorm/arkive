#!/usr/bin/env bash
# Copyright (c) 2017, Cody Opel <codyopel@gmail.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -o errexit
set -o errtrace
set -o functrace
set -o nounset
set -o pipefail

HOME="${HOME:-}"
XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
if [ "$XDG_DATA_HOME" != "$HOME/.local/share" ] && [ -z "$PREFIX" ]; then
  echo "non standard XDG_DATA_HOME, you must explicitly set PREFIX" >&2
  echo "run: PREFIX=\"<install prefix>\" install.sh"
  exit 1
fi
XDG_PREFIX="$(dirname "$XDG_DATA_HOME")"
PREFIX="${PREFIX:-$XDG_PREFIX}"

DIR="$(readlink -f "$(readlink -f "$(dirname "$(readlink -f "$0")")")")"

BASH_BIN="$(type -P bash)"

declare -a REQUIRED_UTILS=(
  awk
  bash
  bc
  curl
  cut
  dirname
  ffmpeg
  ffprobe
  find
  grep
  iconv
  install
  jq
  ln
  mkdir
  mktemp
  readlink
  rm
  sed
  sleep
  sort
  touch
  tr
  uniq
)

declare -a ARKIVE_PATHS=()
for requiredutil in "${REQUIRED_UTILS[@]}"; do
  if ! type $requiredutil >/dev/null; then
    echo "$requiredutil not found" >&2
    exit 1
  fi
  ARKIVE_PATHS+=("$(dirname "$(type -P "$requiredutil")")")
done

# Filter out duplicate prefixes
mapfile -t ARKIVE_PATHS_FILTERED < <(
  printf '%s\n' "${ARKIVE_PATHS[@]}" | sort -u
)

unset ARKIVE_PATH
for Path in "${ARKIVE_PATHS_FILTERED[@]}"; do
  ARKIVE_PATH+="${ARKIVE_PATH:+:}$Path"
done

if ! type lib-bash; then
  if [ ! -f "$DIR"/vendor/lib-bash/src/bin/lib-bash ]; then
    if ! type git; then
      echo "need lib-bash or git to use vendored lib-bash git submodule" >&2
      exit 1
    fi
    pushd "$DIR"
      git submodule update --init --recursive
    popd
  fi
  install -D -m755 -v "$DIR"/vendor/lib-bash/src/bin/lib-bash \
    "$PREFIX"/bin/lib-bash
  install -D -m644 -v "$DIR"/vendor/lib-bash/src/share/lib-bash/lib.bash \
    "$PREFIX"/share/lib-bash/lib.bash
fi

for bin in "$DIR"/src/bin/*; do
  install -D -m755 -v "$bin" "$PREFIX/bin/$(basename "$bin")"
  sed -i "$PREFIX/bin/$(basename "$bin")" \
    -e "s,^#!bash,#!$BASH_BIN," \
    -e "s,#PATH#,PATH=\"$ARKIVE_PATH\","
done

if [ -d "$PREFIX"/share/arkive ]; then
  rm -rv "$PREFIX"/share/arkive
fi

mapfile -t datafiles < <(find "$DIR/src/share/arkive/" -type f -printf "%P\n")
for data in "${datafiles[@]}"; do
  install -D -m644 -v "$DIR/src/share/arkive/$data" "$PREFIX/share/arkive/$data"
done
