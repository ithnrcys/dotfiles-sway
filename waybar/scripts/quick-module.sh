#!/usr/bin/env bash
# Quick access for the top bar (was the bluetooth module). Click opens the swaync panel:
# bluetooth, screenshot, screen recording, pomodoro, KDE Connect, notes, calculator.
# Prints the panel icon, preceded while they run by the recording mark and the pomodoro time.

S=~/.config/waybar/scripts
ICON="<span size='11pt'>󰘮</span>"
out=""

if pgrep -x obs >/dev/null && [ "$("$S/obs-record.py" status)" = true ]; then
    out+="<span size='8pt'>●</span> REC   "
fi
pomo=$("$S/pomodoro.sh" --bar)
[ -n "$pomo" ] && out+="$pomo   "

echo "${out}${ICON}"
