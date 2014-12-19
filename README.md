ARKhive
=======

Bash frontend to ffmpeg, mkvtoolnix, x265 and other utilities to prepare video for archiving according to Chlorm's ARK specifications.

Dependencies: ffmpeg, vobsub2srt, x265, coreutils, gawk, grep

TODO:
  * Interlace detection
  * Audio & Subtitle automatic stream selection
  * Bitmap subtitle conversion to plain text (uses OCR)
  * Mux streams using ffmpeg
  * implement proper error codes and error logging
  * remove bash specific syntax
  * improve colored terminal output
  * find method to accuratly get total frames (skew exists between x265 and ffmpeg)
  * allow user to input a directory and recursively encode files within

Outputs a file according to the follwing specs:
  * Audio
    + Prefers english audio stream if available
    + Channel Layouts: stereo or 5.1(rear) depending upon input
    + Automatically remaps audio channels in a consistent manner
    + Samplerate: stereo=44100 5.1=48000
    + Bitrate: stereo=256 5.1=640
    + codec: aac or ac3, currently undecided
  * Subtitles
    + Only excepts english subtitles
    + Converts bitmap formats to plain test
    + Outputs with formated ASS subtitle
  * Chapters
    + add chapters if available
  * Video
    + Automatically detects and crops black bars
    + Automatically checks for and deinterlaces interlaced video
  * Container
    + mp4 or mkv