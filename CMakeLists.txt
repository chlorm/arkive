cmake_minimum_required(VERSION 3.0)
project(arkive)

find_program(FFMPEG_PATH ffmpeg)
find_program(FFPROBE_PATH ffprobe)
find_program(JQ_PATH jq)
find_program(LIB_BASH_PATH lib-bash)

if (NOT FFMPEG_PATH)
  message(FATAL_ERROR "ffmpeg not found")
endif()
if (NOT FFPROBE_PATH)
  message(FATAL_ERROR "ffprobe not found")
endif()
if (NOT JQ_PATH)
  message(FATAL_ERROR "jq not found")
endif()
if (NOT LIB_BASH_PATH)
  message(FATAL_ERROR "lib-bash not found")
endif()

# Set path to ffmpeg at build time
configure_file(
  ${CMAKE_CURRENT_LIST_DIR}/src/bin/arkive
  ${CMAKE_CURRENT_LIST_DIR}/src/bin/arkive @ONLY)

# Set path to ffprobe at build time
configure_file(
  ${CMAKE_CURRENT_LIST_DIR}/src/share/lib-arkive/ffprobe.bash
  ${CMAKE_CURRENT_LIST_DIR}/src/share/lib-arkive/ffprobe.bash @ONLY)

# Set path to jq at build time
configure_file(
  ${CMAKE_CURRENT_LIST_DIR}/src/share/lib-arkive/ffmpeg/audio/filters/ebu-r128.bash
  ${CMAKE_CURRENT_LIST_DIR}/src/share/lib-arkive/ffmpeg/audio/filters/ebu-r128.bash @ONLY)

# Set path to lib-bash at build time
configure_file(
  ${CMAKE_CURRENT_LIST_DIR}/src/bin/arkive
  ${CMAKE_CURRENT_LIST_DIR}/src/bin/arkive @ONLY)

install(
  PROGRAMS
    ${CMAKE_CURRENT_LIST_DIR}/src/bin/arkive
  DESTINATION
    bin)

install(
  DIRECTORY
    ${CMAKE_CURRENT_LIST_DIR}/src/share/lib-arkive
  DESTINATION
    share)
