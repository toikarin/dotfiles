#!/usr/bin/env bash

. ~/.bash_functions

msg=$(change_layout)
# requires libnotify-bin
notify-send "$msg"
