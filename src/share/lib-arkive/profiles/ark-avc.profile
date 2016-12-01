#!/usr/bin/env bash

# Arkive h.264/AVC main profile, ACC HE-AAC, WebVTT

FFMPEG_CONTAINER_FORMAT='mp4'
FFMPEG_VIDEO_ENCODER='x264'
#FFMPEG_VIDEO_BITSPERPIXEL='0.04218205761316872427'  # 2048
FFMPEG_VIDEO_BITSPERPIXEL='0.05272757201646090534'  # 2560
#FFMPEG_VIDEO_BITSPERPIXEL='0.08436411522633744855'  # 4096
FFMPEG_VIDEO_BITDEPTH=8
FFMPEG_VIDEO_ENCODER_PASSES=2
FFMPEG_VIDEO_FRAMERATE='source'
FFMPEG_AUDIO_ENCODER='fdk-aac'
ARKIVE_SUBTITLES=true
ARKIVE_SUBTITLES_LANG_DEFAULT='eng'
ARKIVE_SUBTITLES_LANGS=('eng')
ARKIVE_SUBTITLE_CODEC='webvtt'
