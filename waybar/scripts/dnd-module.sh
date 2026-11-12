#!/usr/bin/env bash
# Do not disturb for the bottom bar: pauses dunst. Notifications that arrive while paused
# are held back and shown when it is switched off again.
#   (no argument)   print the icon: filled when on, dimmed empty variant when off
# Icons are SF Symbols characters (font: SF Pro, not in this repo).
#   --toggle        flip it and refresh the module

I_ON=$'\U001002E0' I_OFF=$'\U001002DB'    # filled / empty
FONT="SF Pro"
DIM="#7C7C84"
SIGNAL=10                                    # waybar "signal" of custom/dnd

if [ "$1" = "--toggle" ]; then
    dunstctl set-paused toggle
    pkill -RTMIN+"$SIGNAL" -x waybar
    exit 0
fi

if [ "$(dunstctl is-paused 2>/dev/null)" = "true" ]; then
    echo "<span font_family='$FONT'>$I_ON</span>"
else
    echo "<span font_family='$FONT' color='$DIM'>$I_OFF</span>"
fi
