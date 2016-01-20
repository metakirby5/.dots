#!/usr/bin/env bash
images=~/.whizkers_output/chrome_theme/images

mkdir -p "$images"
convert -size 30x256 xc:{{ n_primary }} "$images/theme_frame.png"
convert -size 30x256 xc:{{ n_secondary }} "$images/theme_frame_inactive.png"
convert -size 30x256 xc:{{ n_white }} "$images/theme_tab_background.png"
convert -size 30x256 xc:{{ b_white }} "$images/theme_toolbar.png"
