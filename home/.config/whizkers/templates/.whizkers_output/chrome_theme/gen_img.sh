#!/usr/bin/env bash
images=~/.whizkers_output/chrome_theme/images

mkdir -p "$images"
convert -size 30x256 xc:{{ bgc }} "$images/theme_frame.png"
convert -size 30x256 xc:{{ fgc }} "$images/theme_toolbar.png"
