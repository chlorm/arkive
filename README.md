ARKhive
=======

Bash frontend to ffmpeg, mkvtoolnix, x265 and other utilities to prepare video for archiving according to Chlorm's ARK specifications.

Dependencies: ffmpeg[libopus,(any necessary decoders)], mkvtoolnix, opus, vobsub2srt, x265

Finished:
   * Chapter List Handling
   * CPU Detection
   * Crop Detection
   * Subtitles
   * Audio Configuration (working, but needs some work with exception handling)
   * Audio Encoding
   * Video Encoding
   * Muxing (currently only mkv is supported)

TODO:
   * Finish error handling and exception cases for subtitles
   * Add more exception handling for audio tracks
```
    Currently won't handle videos with multiple undefined audio tracks or
    videos containing audio tracks but no english tracks
```

   * Add interlaced video detection and handling
```
    ffmpeg -i $userInput -filter:v idet -frames:v 100 -an -f rawvideo -y /dev/null
```

   * ffmpeg audio progress indicator (suppress ffmpeg output)
```
    Redirect output to tmp file: 2>/$userInputPath/$filename.ffaudio &
    PID=$!
    call_progress_function
    Use awk in to get information from line on file 
```

   * x265 progress indicator (suppress x265 output)
```
    Redirect output to tmp file: 2>/$userInputPath/$filename.x265 &
    PID=$!
    call_progress_function
    Use awk in to get information from line on file 
```

   * Remove all temp files on interrupt signal
```
    if [ -f $exampleTmpFile ]; then rm $exampleTmpFile; fi
```

   * Add terminal color support detection
   * Add multiple ERROR exit codes
```
    code 0: ?
    code 1: ?
    code 2: ?
```

   * Improve code portability for shells other than bash (continuous)
   * Find chapter list language if it is set
