#!/bin/bash

# Dbus fix
#if [ -z "$DBUS_SESSION_BUS_ADDRESS" ]; then
#    eval "$(dbus-launch --sh-syntax --exit-with-session)"
#fi

#if xrandr | grep -q "HDMI-2 connected"; then
#	xrandr --output HDMI-2 --primary --auto --output eDP-1 --below HDMI-2 --auto
#fi
#xbacklight -set 40 &
#setxkbmap -model acer_c300 -layout no -variant nodeadkeys # chromebook acer r11
#xmodmap -e "keycode 111 = Up NoSymbol Up NoSymbol Prior Prior" # Shift-Up = PageUp
#xmodmap -e "keycode 116 = Down NoSymbol Down NoSymbol Next Next" # Shift-Down = PageDown
#xmodmap -e "control keycode 111 = Home" # Control-Up = Home
#xmodmap -e "control keycode 116 = End" # Cotrol-Down = End
#xinput --map-to-output 10 eDP-1 # make sure touchscreen is only mapped to laptop screen
#xinput set-prop 11 "libinput Disable While Typing Enabled" 0 # don't disable touchpad while typing
# pulseaudio --start # pulseaudio doesnt work with current working .asoundrc, so leave commented
#pidgin 
#touchegg &
#udiskie -ant2 &
#parcellite -n &
#pgrep redshift &> /dev/null || redshift -b 1.0:0.8 -t 5500:2500 &> /dev/null &
#xmodmap -e 'clear Lock'
#xmodmap -e 'keycode 0x42 = Escape'
# bind altgr+comma/period to < and >
#xmodmap -e "keycode 58 = Escape" & # swap escape and super key
#xmodmap -e "keycode 9 = Super_L" # swap escape and super key
nm-applet &

setxkbmap -layout no -option caps:escape -option nbsp:none
xmodmap -e 'keycode 0x3b = comma semicolon comma semicolon less dead_ogonek dead_cedilla' # bind altgr+comma/period to < and >
xmodmap -e 'keycode 0x3c = period colon period colon greater periodcentered ellipsis'

xinput --set-prop "SYNA32A0:00 06CB:CE14 Touchpad" "libinput Tapping Enabled" 1
bluetoothctl power on
bluetoothctl agent on

exec i3
