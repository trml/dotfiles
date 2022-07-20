#!/bin/bash

#sh $HOME/dotfiles/bin/keyboard.sh
#xinput --set-prop "SYNA32A0:00 06CB:CE14 Touchpad" "libinput Tapping Enabled" 1
test -f ~/.Xresources && xrdb -merge -I$HOME ~/.Xresources
#setxkbmap -layout us -variant altgr-intl -option caps:escape -option nbsp:none
setxkbmap -layout no -option caps:escape -option nbsp:none
xmodmap -e 'keycode 0x3b = comma semicolon comma semicolon less dead_ogonek dead_cedilla'
xmodmap -e 'keycode 0x3c = period colon period colon greater periodcentered ellipsis'
nm-applet &
exec i3
