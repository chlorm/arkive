ARKhive
=======

Bash frontend to ffmpeg, mkvtoolnix, x265 and other utilities to prepare video for archiving according to Chlorm's ARK specifications.

Dependencies: ffmpeg[libopus,(any necessary decoders)], mkvtoolnix, opus, vobsub2srt, x265

Finished:
   * Chapter List Handling
   * CPU Detection
   * Crop Detection
   * Audio Encoding
   * Video Encoding

TODO:
   * Mux audio, video, subtitles, and chapters
```
    mkvmerge vs. ffmpeg
```

   * Convert VobSub subtitles to simple text SRT subtitles with VobSub2SRT
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

   * Detect if temp file exists before trying to remove
   * Add terminal color support detection
   * Update HELP information
   * Add multiple ERROR exit codes
```
    code 0: ?
    code 1: ?
    code 2: ?
```

   * Improve code portability for shells other than bash
   * Add support to allow for user defined output directory
```
    if [ -z $userOutputPath ]; then $userOutputPath=$userInputPath;
    elif [ !-d $userOutputPath ]; then echo "ERROR: not a directory";exit 0;fi
```

   * Add support to allow for user defined tmp directory
```
    if [ -z $userTmpPath ]; then $userTmpPath=$userInputPath;
    elif [ !-d $userTmpPath ]; then echo "ERROR: not a directory";exit 0;fi
```
