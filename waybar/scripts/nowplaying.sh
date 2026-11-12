#!/usr/bin/env bash
# Now playing for the bottom bar. Runs continuously (no waybar interval) and prints a line
# whenever the text changes.
#
# Titles longer than WIDTH scroll as a marquee, in bursts rather than nonstop:
#   hold the start -> slide to the end one character at a time -> hold the end -> back to start

WIDTH=40          # visible characters of "artist - title"
TICK=0.25         # seconds per scroll step
HOLD_START=12     # ticks to rest at the start (3 s)
HOLD_END=8        # ticks to rest at the end (2 s)
POLL=8            # ticks between player queries (2 s)

# prints "icon|text", or nothing when no player is active
current_track() {
    local status song
    # 1. playerctl first (browsers, Spotify, Cider, ...)
    if command -v playerctl &>/dev/null; then
        status=$(playerctl status 2>/dev/null)
        if [[ "$status" == "Playing" || "$status" == "Paused" ]]; then
            song=$(playerctl metadata --format "{{artist}} - {{title}}" 2>/dev/null)
            echo "󰌳|${song# - }"
            return
        fi
    fi
    # 2. fall back to mpd (ncmpcpp)
    if command -v mpc &>/dev/null && mpc status 2>/dev/null | grep -q "playing\|paused"; then
        song=$(mpc current -f "%artist% - %title%")
        echo "󰎆|${song# - }"
    fi
}

icon="" text="" offset=0 hold=$HOLD_START tick=0 last="-"

while true; do
    if (( tick % POLL == 0 )); then
        IFS='|' read -r new_icon new_text <<< "$(current_track)"
        if [[ "$new_text" != "$text" ]]; then      # track changed: start over
            offset=0; hold=$HOLD_START
        fi
        icon="$new_icon"; text="$new_text"
    fi
    tick=$(( tick + 1 ))

    if [ -z "$text" ]; then
        out=""                                      # nothing playing: module stays hidden
    elif (( ${#text} <= WIDTH )); then
        out="$icon  $text"
    else
        out="$icon  ${text:offset:WIDTH}"
        max=$(( ${#text} - WIDTH ))
        if (( hold > 0 )); then
            hold=$(( hold - 1 ))
        elif (( offset < max )); then
            offset=$(( offset + 1 ))
            (( offset == max )) && hold=$HOLD_END   # reached the end: rest there
        else
            offset=0; hold=$HOLD_START              # rested at the end: jump back
        fi
    fi

    if [[ "$out" != "$last" ]]; then
        echo "$out"
        last="$out"
    fi
    sleep "$TICK"
done
