#!/usr/bin/env bash

# 1. Try playerctl first (Catches Browsers, Spotify, etc.)
if command -v playerctl &> /dev/null && playerctl status &> /dev/null; then
    status=$(playerctl status 2>/dev/null)
    if [[ "$status" == "Playing" ]] || [[ "$status" == "Paused" ]]; then
        song=$(playerctl metadata --format "{{artist}} - {{title}}" 2>/dev/null)
        # Clean up the string in case a track has no artist
        echo "󰌳  ${song# - }"
        exit 0
    fi
fi

# 2. Fallback directly to mpd/mpc (For local ncmpcpp tracks)
if command -v mpc &> /dev/null && mpc status | grep -q "playing\|paused"; then
    song=$(mpc current -f "%artist% - %title%")
    echo "󰎆 ${song# - }"
    exit 0
fi

# 3. If nothing is playing, stay completely invisible
echo ""
