#!/bin/bash

sh $HOME/dotfiles/bin/keyboard.sh

nm-applet &

exec i3
