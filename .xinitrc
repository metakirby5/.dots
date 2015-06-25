#!/usr/bin/env bash

RESOURCES = (
  "~/.Xresources"
)

for resource in "${RESOURCES[@]}"; do
  [ -f "$resource" ] && xrdb -merge "$resource"
done

xset dpms 120 300 600 s 60
