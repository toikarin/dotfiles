#!/usr/bin/env bash

. ~/.bash_functions

msg=$(change_layout)
notify-send "$msg"
