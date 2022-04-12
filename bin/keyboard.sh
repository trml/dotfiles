#!/bin/bash
setxkbmap -layout no -option caps:escape -option nbsp:none
xmodmap -e 'keycode 0x3b = comma semicolon comma semicolon less dead_ogonek dead_cedilla' # bind altgr+comma/period to < and >
xmodmap -e 'keycode 0x3c = period colon period colon greater periodcentered ellipsis'
#test -f ~/.Xresources && xrdb -merge -I$HOME ~/.Xresources
#test -f ~/.Xkeymap    && xkbcomp -w 3 ~/.Xkeymap $DISPLAY
