#!/usr/bin/env bash

source ~/.bash_exports
source ~/.bash_functions

change_layout us
touchpad_initial_state
touchpad_check_usb_mouse
set_resolutions
xset b off
xrdb -merge ~/.Xdefaults
xscreensaver -no-splash 2> /dev/null &
