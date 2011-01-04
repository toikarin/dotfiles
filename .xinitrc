#!/usr/bin/env sh

# Disable beep
xset b off

# Start xscreensaver
xscreensaver -no-splash &

# Set default keyboard layout
setxkbmap -layout us

# Load xmodmap
xmodmap ~/.Xmodmap

# Load X resources
xrdb ~/.Xdefaults

# Set wallpaper
display -window root wallpaper.png &
DISPLAY=:0.1 display -window root wallpaper.png &

i3
