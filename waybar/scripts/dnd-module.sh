#!/usr/bin/env bash
# Do not disturb for the bottom bar: swaync DND. Popups are held back while it is on;
# notifications still land in the panel (swaync-client -t).
#   (no argument)   print the icon: filled when on, dimmed empty variant when off
# Icons are SF Symbols characters (font: SF Pro, not in this repo).
#   --toggle        flip it and refresh the module

I_ON=$'\U001002E0' I_OFF=$'\U001002DB'    # filled / empty
FONT="SF Pro"
DIM="#7C7C84"
SIGNAL=10                                    # waybar "signal" of custom/dnd

if [ "$1" = "--toggle" ]; then
    swaync-client -sw -d >/dev/null
    pkill -RTMIN+"$SIGNAL" -x waybar
    exit 0
fi

if [ "$(swaync-client -sw -D 2>/dev/null)" = "true" ]; then
    echo "<span font_family='$FONT'>$I_ON</span>"
else
    echo "<span font_family='$FONT' color='$DIM'>$I_OFF</span>"
fi
