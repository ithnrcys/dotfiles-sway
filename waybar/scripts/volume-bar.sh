#!/usr/bin/env bash
# Volume slider for the bottom bar. Icons are SF Symbols (font: SF Pro, not in this repo):
# filled while sound is on, the empty variant when muted.
I_ON=$'\U0010343A' I_OFF=$'\U00103439'
ICON_SIZE="8pt"
icon() { echo "<span font_family='SF Pro' size='$ICON_SIZE'>$1</span>"; }

v=$(pamixer --get-volume)
if [ "$(pamixer --get-mute)" = "true" ]; then echo "$(icon "$I_OFF")  Mute"; exit 0; fi
w=15; f=$(( v * w / 100 )); e=$(( w - f - 1 ))
bar=""
for ((i=0;i<f;i++)); do bar="${bar}─"; done
bar="${bar}◈"
echo "$(icon "$I_ON") $bar"
