#!/bin/bash

# Dbus fix
if [ -z "$DBUS_SESSION_BUS_ADDRESS" ]; then
    eval "$(dbus-launch --sh-syntax --exit-with-session)"
fi

xrandr --output VGA1 --primary --auto --output LVDS1 --auto --left-of VGA1 &
xbacklight -set 40 &
setxkbmap -model acer_c300 -layout no -variant nodeadkeys # chromebook acer r11
xmodmap -e "keycode 133 = Escape" # swap escape and super key
xmodmap -e "keycode 9 = Super_L" # swap escape and super key
xmodmap -e "keycode 111 = Up NoSymbol Up NoSymbol Prior Prior" # Shift-Up = PageUp
xmodmap -e "keycode 116 = Down NoSymbol Down NoSymbol Next Next" # Shift-Down = PageDown
xmodmap -e "control keycode 111 = Home" # Control-Up = Home
xmodmap -e "control keycode 116 = End" # Cotrol-Down = End
pulseaudio --start
pidgin &
touchegg &
exec i3
