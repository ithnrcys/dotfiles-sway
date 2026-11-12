#!/usr/bin/env bash
# CPU details menu for the top bar (click on the cpu module).
#
#   --snapshot   run by waybar every second (hidden custom/cpusnap module): keeps the two most
#                recent copies of /proc/stat in $XDG_RUNTIME_DIR, prints nothing
#   (no args)    builds the menu from the older copy vs. now, so it opens with no sampling delay

SNAP="${XDG_RUNTIME_DIR:-/tmp}/cpu-stat"

if [[ "$1" == "--snapshot" ]]; then
    mv -f "$SNAP.1" "$SNAP.2" 2>/dev/null
    grep '^cpu' /proc/stat > "$SNAP.1"
    exit 0
fi

SEP="──────────────────────────────────────"

# bar <percent> <width> — heavy line for the used part, light line for the rest
bar() {
    local filled=$(( ($1 * $2 + 50) / 100 )) out="" i
    for (( i = 0; i < $2; i++ )); do
        [ "$i" -lt "$filled" ] && out+="━" || out+="─"
    done
    echo "$out"
}

# previous sample: 1-2 s old from the snapshot module; only sample by hand if it is missing
if [ -s "$SNAP.2" ]; then
    a=$(cat "$SNAP.2")
else
    a=$(grep '^cpu' /proc/stat); sleep 0.3
fi
b=$(grep '^cpu' /proc/stat)

# usage per line: 100 * (1 - idle_delta / total_delta); idle = idle + iowait
mapfile -t usage < <(paste <(echo "$a") <(echo "$b") | awk '{
    n = NF / 2; t1 = 0; t2 = 0
    for (i = 2; i <= n; i++)        t1 += $i
    for (i = n + 2; i <= NF; i++)   t2 += $i
    i1 = $5 + $6; i2 = $(n + 5) + $(n + 6)
    d = t2 - t1
    printf "%d\n", (d > 0) ? 100 * (1 - (i2 - i1) / d) + 0.5 : 0
}')
total=${usage[0]}
cores=("${usage[@]:1}")

freq=$(awk -F': ' '/^cpu MHz/{s += $2; n++} END{printf "%.2f GHz", s / n / 1000}' /proc/cpuinfo)
load=$(cut -d' ' -f1-3 /proc/loadavg)

# CPU temperature: find the k10temp sensor by name, hwmon numbers shift between boots
temp="--"
for h in /sys/class/hwmon/hwmon*; do
    if [ "$(cat "$h/name" 2>/dev/null)" = "k10temp" ]; then
        temp="$(( $(cat "$h/temp1_input") / 1000 ))°C"
        break
    fi
done

MENU_CONTENT="$(printf 'usage   %3d%%   %s' "$total" "$(bar "$total" 24)")"
MENU_CONTENT+="\n$(printf 'temp    %-8s freq   %s' "$temp" "$freq")"
MENU_CONTENT+="\n$(printf 'load    %s' "$load")"
MENU_CONTENT+="\n${SEP}"

# cores two per row
rows=4
for (( i = 0; i < ${#cores[@]}; i += 2 )); do
    line=$(printf '%2d %s %3d%%' "$i" "$(bar "${cores[i]}" 9)" "${cores[i]}")
    if [ -n "${cores[i+1]}" ]; then
        line+=$(printf '    %2d %s %3d%%' "$((i+1))" "$(bar "${cores[i+1]}" 9)" "${cores[i+1]}")
    fi
    MENU_CONTENT+="\n${line}"
    rows=$(( rows + 1 ))
done

ROFI_LINES=$rows
ROFI_THEME=dropdown-left.rasi
source ~/.config/waybar/scripts/_rofi_engine.sh
exit 0
