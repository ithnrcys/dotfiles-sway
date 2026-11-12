#!/usr/bin/env bash
# Caffeine for the bottom bar: while on, the idle lock and screen-off are skipped.
# State is the file $XDG_RUNTIME_DIR/caffeine, so it is off again after a reboot; the
# swayidle timeouts in sway/autostart.sh run this script with --idle-ok before acting.
# Locking before suspend is not affected.
#   (no argument)   print the icon: filled when on, dimmed empty variant when off
#                   (SF Symbols characters; font: SF Pro, not in this repo)
#   --toggle        flip it and refresh the module
#   --idle-ok       exit 0 when idle actions may run (caffeine off), 1 when they may not

I_ON=$'\U00100E19' I_OFF=$'\U00100E18'    # filled / empty
FONT="SF Pro"
DIM="#7C7C84"
SIGNAL=11                                    # waybar "signal" of custom/caffeine
STATE="${XDG_RUNTIME_DIR:-/tmp}/caffeine"

case "$1" in
    --toggle)
        if [ -e "$STATE" ]; then rm -f "$STATE"; else touch "$STATE"; fi
        pkill -RTMIN+"$SIGNAL" -x waybar
        exit 0 ;;
    --idle-ok)
        [ ! -e "$STATE" ]; exit ;;
esac

if [ -e "$STATE" ]; then
    echo "<span font_family='$FONT'>$I_ON</span>"
else
    echo "<span font_family='$FONT' color='$DIM'>$I_OFF</span>"
fi
