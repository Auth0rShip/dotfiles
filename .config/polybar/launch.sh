#!/usr/bin/env bash

LOG=/tmp/polybar.log

echo "--- $(date)" >> "$LOG"

polybar-msg cmd quit >/dev/null 2>&1

for i in {1..20}; do
  pgrep -x polybar >/dev/null || break
  sleep 0.2
done

pkill -x polybar 2>/dev/null

sleep 1

if [[ "${1:-}" = "restart" ]]; then
  i3-msg restart
fi

if command -v xrandr >/dev/null 2>&1; then
  xrandr --query | awk '/ connected/{print $1}' | while read -r m; do
    echo "Launching polybar on $m" >> "$LOG"
    MONITOR="$m" polybar -l trace statusbar >> "/tmp/polybar_$m.log" 2>&1 &
  done
else
  polybar -l trace statusbar >> "$LOG" 2>&1 &
fi

echo "Bars launched..." >> "$LOG"
