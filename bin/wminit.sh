#!/usr/bin/env bash

source ~/.bash_exports
source ~/.bash_functions

change_layout us
touchpad_disable
set_resolutions
xset b off
xrdb -merge ~/.Xdefaults
xscreensaver -no-splash 2> /dev/null &
