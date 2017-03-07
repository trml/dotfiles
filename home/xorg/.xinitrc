#!/bin/bash

export DE=i3

# Dbus fix
if [ -z "$DBUS_SESSION_BUS_ADDRESS" ]; then
    eval "$(dbus-launch --sh-syntax --exit-with-session)"
fi

xrandr --output VGA1 --primary --auto --output LVDS1 --mode 1280x720 --auto --left-of VGA1 &
xbacklight -set 0 &
setxkbmap -layout no -variant nodeadkeys
pulseaudio --start
exec i3
