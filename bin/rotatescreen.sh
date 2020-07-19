#!/bin/bash
#if [ $# -ne 1 ]; then
	#exit 0
#xrandr | grep eDP-1 | sed 's/.*[^a-z] (normal.*//;s/.*\( [a-z]* (normal\).*/\1/;s/ (normal//;s/ //'
#position="$(xrandr | grep eDP-1 | awk '{print $4}')"

declare -A transform
transform[0]="1 0 0 0 1 0 0 0 1"
transform[1]="0 -1 1 1 0 0 0 0 1"
transform[2]="-1 0 1 0 -1 1 0 0 1"
transform[3]="0 1 0 -1 0 1 0 0 1"

position="$(xrandr | grep eDP-1 | sed 's/.*[^a-z] (normal.*//;s/.*\( [a-z]* (normal\).*/\1/;s/ (normal//;s/ //')"

declare -i n=0
#TODO reverse cases
case $1 in
	"--counter-clockwise") n=1 ;;
	"--reverse") n=2 ;;
	"--clockwise") n=3 ;; esac
case $position in
	"left") n=n+1 ;;
	"inverted") n=n+2 ;;
	"right") n=n+3 ;; esac
n=n%4 # 0=normal, 1=left, 2=inverted, 3=right

echo "direction = $1"
echo "position = $position"
echo "n = $n"
xrandr -o $n
xinput set-prop 12 144 ${transform[$n]}

exit 0


#rotate $n


function rotate()
{
	echo $1
	xrandr --output eDP-1 --rotate $1
	xinput set-prop 12 144 ${transform[$1]}
	#keystate=0
	#[ $1 == "normal" ] && keystate=1
	#keystate=1
	#xinput set-prop "AT Translated Set 2 keyboard" "Device Enabled" $keystate
	#xinput set-prop "Elan Touchpad" "Device Enabled" $keystate
}



if [ $1 == "--counter-clockwise" ]; then
	case $position in
		"left") rotate inverted ;;
		"inverted") rotate right ;;
		"right") rotate normal ;;
		*) rotate left ;; esac
elif [ $1 == "--clockwise" ]; then
	case $position in
		"left") rotate normal ;;
		"inverted") rotate left ;;
		"right") rotate inverted ;;
		*) rotate right ;; esac
elif [ $1 == "--reverse" ]; then
	case $position in
		"left") rotate right ;;
		"inverted") rotate normal ;;
		"right") rotate left ;;
		*) rotate inverted ;; esac
else
	rotate $(echo $1 | cut -c 3-)
fi

# [0,1,2,3] + [0,1,2,3] => [0,1,2,3]


