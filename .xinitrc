#!/usr/bin/env bash

## VARIABLES

# Personal
ZIPCODE=92129

# System
DPI=276

# Screensaver
SCREENSAVER=360
DPMS_STANDBY=420
DPMS_SUSPEND=480
DPMS_OFF=600

# Resources
RESOURCES=(
  "~/.Xresources"
)

## CONFIG

xrandr --dpi $DPI &

for resource in "${RESOURCES[@]}"; do
  [ -f "$resource" ] && xrdb -merge "$resource" &
done

xset dpms $DPMS_STANDBY $DPMS_SUSPEND $DPMS_OFF s $SCREENSAVER &

## AUTOSTART

urxvt256cd -q -o -f &
mpd &
compton &
/usr/libexec/gnome-settings-daemon &
xautolock &
lightsOn &
dunst &

xflux -z $ZIPCODE &
dropbox start &
# ibus-daemon -xdr &

