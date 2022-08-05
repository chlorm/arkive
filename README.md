arkive
======

arkive is a multimedia processing automation script

Dependencies:
  * bc
  * jq
  * [bash-stl](https://github.com/chlorm/bash-stl)
  * ffmpeg >= 3.1.0 (for libebur128)
    - libebur128
    - libopus >= 1.1.0
    - libvpx >= 1.6.0
    - x264 >= 201611xx (only 8bit/4:2:0 supported)
    - x265 >= 201705xx (for refine-level, ...) (with
      [multi-lib](https://github.com/triton/triton/blob/master/pkgs/all-pkgs/x/x265/default.nix),
      e.g. 8, 10, & 12 bit statically linked into libx265.{a,so})

Extract DTS core from DTS-HD MA track
```
ffmpeg -i input.mp4 -f spdif -dtshd_rate 0 -c copy - | ffmpeg -i - -c copy -y output.flac
```
or
```
ffmpeg -i input.mp4 -bsf:a dca_core -c copy output.mkv
```
