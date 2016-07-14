#!/usr/bin/env bash

set -e

myFunc1() {
  local -a myArray

  myArray=(
    "$(myFunc2)"
    "$(myFunc3)"
  )
}

myFunc2() {
  return 1
}

myFunc3() {
  return 0
}

echo "begin test"
myFunc1 && echo "this shouldn't echo, but it does"

exit 0

