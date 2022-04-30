#!/bin/bash
sh $HOME/dotfiles/bin/keyboard.sh
xinput --set-prop "SYNA32A0:00 06CB:CE14 Touchpad" "libinput Tapping Enabled" 1

nm-applet &

exec i3
