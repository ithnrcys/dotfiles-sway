#!/usr/bin/env bash
v=$(pamixer --get-volume)
if [ "$(pamixer --get-mute)" = "true" ]; then echo " Mute"; exit 0; fi
w=15; f=$(( v * w / 100 )); e=$(( w - f - 1 ))
bar=""
for ((i=0;i<f;i++)); do bar="${bar}━"; done
bar="${bar}┫"
for ((i=0;i<e;i++)); do bar="${bar}╍"; done
if   [ "$v" -lt 34 ]; then ic=" "
elif [ "$v" -lt 67 ]; then ic=" "
else ic=" "; fi
echo "$ic $bar"
