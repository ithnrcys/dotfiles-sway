#!/usr/bin/env bash
# Do not disturb for the bottom bar: pauses dunst. Notifications that arrive while paused
# are held back and shown when it is switched off again.
#   (no argument)   print the icon: crossed-out bell when on, dimmed bell when off
#   --toggle        flip it and refresh the module

I_ON=$'\U000F009B' I_OFF=$'\U000F009A'      # bell-off / bell
DIM="#7C7C84"
SIGNAL=10                                    # waybar "signal" of custom/dnd

if [ "$1" = "--toggle" ]; then
    dunstctl set-paused toggle
    pkill -RTMIN+"$SIGNAL" -x waybar
    exit 0
fi

if [ "$(dunstctl is-paused 2>/dev/null)" = "true" ]; then
    echo "$I_ON"
else
    echo "<span color='$DIM'>$I_OFF</span>"
fi
