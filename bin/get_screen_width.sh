#!/bin/bash
xrandr --screen 0 | grep '*' | uniq | awk '{print $1}' | cut -d 'x' -f 2
