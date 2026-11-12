#!/bin/sh
# SwayFX 0.6 workaround, run from fx.conf at session start and after every config reload:
# a reload leaves the left and right window borders undrawn (top and bottom stay). Setting
# the border colours to something else and straight back makes SwayFX redraw all four sides.
# The colours are read from the client.* lines of the sway config, so nothing is duplicated.

CONFIG="$HOME/.config/sway/config"
sleep "${1:-1.5}"          # let the reload (or the first window at login) settle first

set_colors() {            # $1 = "nudge": a throwaway colour; anything else: the real ones
    grep -E '^client\.(focused|focused_inactive|unfocused|urgent|placeholder)[[:space:]]' "$CONFIG" |
    while read -r class border bg text indicator child; do
        if [ "$1" = nudge ]; then
            swaymsg -q "$class #7f7f7f #7f7f7f $text #7f7f7f #7f7f7f"
        else
            swaymsg -q "$class $border $bg $text $indicator $child"
        fi
    done
}
set_colors nudge
set_colors real
