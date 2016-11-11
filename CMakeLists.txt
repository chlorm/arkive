cmake_minimum_required(VERSION 3.0)
project(arkive)

find_program(BC_PATH bc)
find_program(FFMPEG_PATH ffmpeg)
find_program(FFPROBE_PATH ffprobe)
find_program(JQ_PATH jq)
find_program(LIB_BASH_PATH lib-bash)

if (NOT BC_PATH)
  message(FATAL_ERROR "bc not found")
endif()
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
