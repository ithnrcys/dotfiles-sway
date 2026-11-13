#!/bin/sh
# Starts waybar at login and restarts it on every sway config reload (exec_always).
# This lives in a script because sway treats ';' as its own command separator: the old line
# "exec_always pkill waybar; waybar" ran only the pkill and then failed on "waybar" as an
# unknown sway command, so the bars never came up at login.
pkill -x waybar
while pgrep -x waybar >/dev/null; do sleep 0.1; done
exec waybar
