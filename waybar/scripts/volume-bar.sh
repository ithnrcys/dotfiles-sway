#!/usr/bin/env bash
v=$(pamixer --get-volume)
if [ "$(pamixer --get-mute)" = "true" ]; then echo " Mute"; exit 0; fi
w=15; f=$(( v * w / 100 )); e=$(( w - f - 1 ))
bar=""
for ((i=0;i<f;i++)); do bar="${bar}─"; done
bar="${bar}◈"
ic="󰝚"
echo "$ic $bar"
