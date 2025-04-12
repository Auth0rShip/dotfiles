#!/usr/bin/env bash

# Terminate already running bar instances
# If all your bars have ipc enabled, you can use 
#polybar-msg cmd quit
# Otherwise you can use the nuclear option:

# restart i3
if [[ $1 = "restart" ]]; then
	i3-msg restart
	sleep 1
fi

killall -q polybar

# Launch bar1 and bar2
echo "---" | tee -a /tmp/polybar1.log /tmp/polybar2.log
#polybar 2>&1 | tee -a /tmp/polybar1.log & disown
#polybar bar2 2>&1 | tee -a /tmp/polybar2.log & disown

MONITOR="DP-2" polybar --reload statusbar & MONITOR="DP-0" polybar --reload statusbar

#if type "xrandr"; then
#  for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
#    MONITOR=$m polybar --reload statusbar &
#  done
#else
#	polybar --reload example &
#fi

echo "Bars launched..."
