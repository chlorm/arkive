cmake_minimum_required (VERSION 3.0)
project (arkive)

find_program(HAS_LIB_BASH lib-bash)
find_program(HAS_FFMPEG ffmpeg)
find_program(HAS_FFPROBE ffprobe)

if(NOT HAS_LIB_BASH)
    message(FATAL_ERROR "lib-bash not found")
endif()
if(NOT HAS_FFMPEG)
    message(FATAL_ERROR "ffmpeg not found")
endif()
if(NOT HAS_FFPROBE)
    message(FATAL_ERROR "ffprobe not found")
endif()

# Set path to lib-bash at build time
file(READ ${CMAKE_CURRENT_LIST_DIR}/src/bin/arkive LIB_BASH_IN)
string(REPLACE "(lib-bash)" "(${HAS_LIB_BASH})" LIB_BASH_OUT ${LIB_BASH_IN})
file(WRITE ${CMAKE_CURRENT_LIST_DIR}/src/bin/arkive ${LIB_BASH_OUT})

# Set path to ffmpeg at build time
file(READ ${CMAKE_CURRENT_LIST_DIR}/src/share/lib-arkive/arkive.bash LIB_FFMPEG_IN)
string(REPLACE "ffmpeg \\" "${HAS_FFMPEG} \\" LIB_FFMPEG_OUT ${LIB_FFMPEG_IN})
file(WRITE ${CMAKE_CURRENT_LIST_DIR}/src/share/lib-arkive/arkive.bash ${LIB_FFMPEG_OUT})

# Set path to ffprobe at build time
file(READ ${CMAKE_CURRENT_LIST_DIR}/src/share/lib-arkive/ffprobe.bash LIB_FFPROBE_IN)
string(REPLACE "ffprobe \\" "${HAS_FFPROBE} \\" LIB_FFPROBE_OUT ${LIB_FFPROBE_IN})
file(WRITE ${CMAKE_CURRENT_LIST_DIR}/src/share/lib-arkive/ffprobe.bash ${LIB_FFPROBE_OUT})

install(PROGRAMS ${CMAKE_CURRENT_LIST_DIR}/src/bin/arkive DESTINATION bin)
install(PROGRAMS ${CMAKE_CURRENT_LIST_DIR}/src/bin/arkive-remux DESTINATION bin)

install(DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/src/share/lib-arkive DESTINATION share)
