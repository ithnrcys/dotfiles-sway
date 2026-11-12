#!/usr/bin/env bash
# CPU details menu for the top bar (click on the cpu module).
# Samples /proc/stat twice to get live per-core usage, then shows it through the rofi engine.

SEP="──────────────────────────────────────"

# bar <percent> <width> — heavy line for the used part, light line for the rest
bar() {
    local filled=$(( ($1 * $2 + 50) / 100 )) out="" i
    for (( i = 0; i < $2; i++ )); do
        [ "$i" -lt "$filled" ] && out+="━" || out+="─"
    done
    echo "$out"
}

snapshot() { grep '^cpu' /proc/stat; }

a=$(snapshot)
# top needs its own interval for real per-process numbers; run it during the sample window
top_out=$(top -b -n 2 -d 0.4 -o %CPU -w 200 2>/dev/null | awk '/^top - /{n++} n==2' | awk '/^ *PID/{f=1; next} f && NF {print $1 "|" $9}' | head -3)
b=$(snapshot)

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

model=$(awk -F': ' '/^model name/{print $2; exit}' /proc/cpuinfo | sed -E 's/\(R\)|\(TM\)//g; s/ [0-9]+-Core Processor//; s/  +/ /g')
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

MENU_CONTENT="${model}\n${SEP}"
MENU_CONTENT+="\n$(printf 'usage   %3d%%   %s' "$total" "$(bar "$total" 24)")"
MENU_CONTENT+="\n$(printf 'temp    %-8s freq   %s' "$temp" "$freq")"
MENU_CONTENT+="\n$(printf 'load    %s' "$load")"
MENU_CONTENT+="\n${SEP}"

# cores two per row
rows=2
for (( i = 0; i < ${#cores[@]}; i += 2 )); do
    line=$(printf '%2d %s %3d%%' "$i" "$(bar "${cores[i]}" 9)" "${cores[i]}")
    if [ -n "${cores[i+1]}" ]; then
        line+=$(printf '    %2d %s %3d%%' "$((i+1))" "$(bar "${cores[i+1]}" 9)" "${cores[i+1]}")
    fi
    MENU_CONTENT+="\n${line}"
    rows=$(( rows + 1 ))
done

MENU_CONTENT+="\n${SEP}"
while IFS='|' read -r pid pct; do
    [ -z "$pid" ] && continue
    name=$(ps -o comm= -p "$pid" 2>/dev/null)
    MENU_CONTENT+="\n$(printf '%-30s %5.1f%%' "${name:-pid $pid}" "$pct")"
    rows=$(( rows + 1 ))
done <<< "$top_out"
MENU_CONTENT+="\n${SEP}\n󰀻 Open btop"

# header(2) + stats(3) + sep + cores + sep + procs + sep + btop
ROFI_LINES=$(( rows + 8 ))
ROFI_THEME=dropdown-left.rasi
source ~/.config/waybar/scripts/_rofi_engine.sh

[[ "$ROFI_CHOICE" == *"Open btop"* ]] && exec ghostty -e btop
exit 0
