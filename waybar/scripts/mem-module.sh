#!/usr/bin/env bash
# Memory menu for the top bar (click on the memory module): RAM and swap at a glance.

# bar <percent> <width> — heavy line for the used part, light line for the rest
bar() {
    local filled=$(( ($1 * $2 + 50) / 100 )) out="" i
    for (( i = 0; i < $2; i++ )); do
        [ "$i" -lt "$filled" ] && out+="━" || out+="─"
    done
    echo "$out"
}

# values from /proc/meminfo are in kB; used = total - available, same as the bar module
read -r total avail cache swap_total swap_free < <(awk '
    /^MemTotal:/     {t = $2}
    /^MemAvailable:/ {a = $2}
    /^Buffers:/      {c += $2}
    /^Cached:/       {c += $2}
    /^SwapTotal:/    {st = $2}
    /^SwapFree:/     {sf = $2}
    END {print t, a, c, st, sf}' /proc/meminfo)

gb() { awk -v k="$1" 'BEGIN{printf "%.1f", k / 1048576}'; }

used=$(( total - avail ))
swap_used=$(( swap_total - swap_free ))
ram_pct=$(( used * 100 / total ))
swap_pct=0
[ "$swap_total" -gt 0 ] && swap_pct=$(( swap_used * 100 / swap_total ))

MENU_CONTENT="$(printf 'ram   %5sG / %4sG  %s' "$(gb $used)" "$(gb $total)" "$(bar $ram_pct 16)")"
MENU_CONTENT+="\n$(printf 'free  %5sG   cache %4sG' "$(gb $avail)" "$(gb $cache)")"
MENU_CONTENT+="\n$(printf 'swap  %5sG / %4sG  %s' "$(gb $swap_used)" "$(gb $swap_total)" "$(bar $swap_pct 16)")"

ROFI_THEME=dropdown-left.rasi
source ~/.config/waybar/scripts/_rofi_engine.sh
exit 0
