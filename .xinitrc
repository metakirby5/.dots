#!/usr/bin/env bash

RESOURCES = (
  "~/.Xresources"
)

for resource in "${RESOURCES[@]}"; do
  [ -f "$resource" ] && xrdb -merge "$resource"
done

xset dpms 420 480 600 s 360
