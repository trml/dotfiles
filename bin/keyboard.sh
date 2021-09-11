#!/bin/bash
test -f ~/.Xresources && xrdb -merge -I$HOME ~/.Xresources
test -f ~/.Xkeymap    && xkbcomp ~/.Xkeymap $DISPLAY
