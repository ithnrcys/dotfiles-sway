#!/usr/bin/env bash
# Volume slider for the bottom bar. Icons are SF Symbols (font: SF Pro, not in this repo):
# the empty variant normally, the filled one while the mixer dropup (audio-module.sh) is open.
I_ON=$'\U0010343A' I_OFF=$'\U00103439'
ICON_SIZE="9pt"
icon() { echo "<span font_family='SF Pro' size='$ICON_SIZE'>$1</span>"; }

if [ -e "${XDG_RUNTIME_DIR:-/tmp}/mixer-open" ]; then ic=$(icon "$I_ON"); else ic=$(icon "$I_OFF"); fi

v=$(pamixer --get-volume)
if [ "$(pamixer --get-mute)" = "true" ]; then echo "$ic  Mute"; exit 0; fi
w=15; f=$(( v * w / 100 )); e=$(( w - f - 1 ))
bar=""
for ((i=0;i<f;i++)); do bar="${bar}─"; done
bar="${bar}◈"
echo "$ic $bar"
