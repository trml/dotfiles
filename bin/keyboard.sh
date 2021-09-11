#!/bin/bash
test -f ~/.Xresources && xrdb -merge -I$HOME ~/.Xresources
test -f ~/.Xkeymap    && xkbcomp -w 3 ~/.Xkeymap $DISPLAY
