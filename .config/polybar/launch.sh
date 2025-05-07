#!/usr/bin/env bash

# Terminate already running bar instances
killall -q polybar
sleep 0.1

# restart i3 if requested
if [[ $1 = "restart" ]]; then
	i3-msg restart
fi

# Launch bars dynamically on all connected monitors
echo "---" | tee -a /tmp/polybar.log

if type "xrandr"; then
  for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
    MONITOR=$m polybar --reload statusbar 2>&1 | tee -a /tmp/polybar_$m.log &
  done
else
  polybar --reload statusbar &
fi

echo "Bars launched..."

