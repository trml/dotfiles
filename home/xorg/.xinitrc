#!/bin/bash

# Dbus fix
if [ -z "$DBUS_SESSION_BUS_ADDRESS" ]; then
    eval "$(dbus-launch --sh-syntax --exit-with-session)"
fi

xrandr --output VGA1 --primary --auto --output LVDS1 --auto --left-of VGA1 &
xbacklight -set 40 &
setxkbmap -model asus_laptop -layout no -variant nodeadkeys -option caps:swapescape
pulseaudio --start
exec i3
