#!/usr/bin/env bash
# Pomodoro for the quick access panel and the top bar.
#   toggle      start (25 min focus) / stop
#   status      "true" while running, else "false" (swaync toggle state)
#   --bar       time left for the bar, e.g. "󱎫 18:42" (focus) or "󰅶 03:10" (break); empty when stopped
# Focus 25 min → break 5 min, every 4th break 15 min, round and round until stopped.
# A notification marks each change. State lives in $XDG_RUNTIME_DIR, so a reboot stops it.

FOCUS=25 BREAK=5 LONG=15 ROUNDS=4
STATE="${XDG_RUNTIME_DIR:-/tmp}/pomodoro"     # "<pid> <phase> <end epoch> <focus count>"
SIGNAL=12                                     # waybar signal of custom/quick

I_FOCUS="󱎫" I_BREAK="󰅶"

refresh() { pkill -RTMIN+"$SIGNAL" -x waybar; }
notify()  { notify-send -a pomodoro "Pomodoro" "$1"; }

read_state() { [ -f "$STATE" ] && read -r PID PHASE END COUNT < "$STATE" && kill -0 "$PID" 2>/dev/null; }

run() {    # the timer itself, in the background
    local count=0 phase=focus mins end
    trap 'rm -f "$STATE"; exit 0' TERM INT
    while :; do
        case "$phase" in
            focus) mins=$FOCUS ;;
            break) mins=$BREAK ;;
            long)  mins=$LONG ;;
        esac
        end=$(( $(date +%s) + mins * 60 ))
        echo "$$ $phase $end $count" > "$STATE"
        refresh
        while [ "$(date +%s)" -lt "$end" ]; do sleep 1; done
        if [ "$phase" = focus ]; then
            count=$((count + 1))
            if (( count % ROUNDS == 0 )); then phase=long; notify "Focus done — long break, ${LONG} min"
            else phase=break; notify "Focus done — break, ${BREAK} min"; fi
        else
            phase=focus; notify "Break over — focus, ${FOCUS} min"
        fi
    done
}

case "$1" in
    toggle)
        if read_state; then
            kill "$PID"; rm -f "$STATE"; notify "Stopped"; refresh
        else
            notify "Focus, ${FOCUS} min"
            setsid "$0" --run >/dev/null 2>&1 < /dev/null &
        fi ;;
    --run)
        run ;;
    status)
        read_state && echo true || echo false ;;
    --bar)
        read_state || exit 0
        left=$(( END - $(date +%s) )); (( left < 0 )) && left=0
        icon=$I_FOCUS; [ "$PHASE" != focus ] && icon=$I_BREAK
        printf '%s %02d:%02d' "$icon" $((left / 60)) $((left % 60)) ;;
esac
