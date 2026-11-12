#!/usr/bin/env bash
# Audio mixer for the bottom bar: a dropup listing every application that is playing sound
# (browser, music player, games ...), each with its own level. Output devices are not listed.
#   Enter / click on an application  pick a level from a list (or mute it)
#   Left / Right on an application   volume -5% / +5%
#   Escape, or clicking the volume slider again, closes it
#   --rows  print the menu rows and exit (for checking)

STEP=5
LABEL=30          # characters of application name
SLIDER=10         # characters of the level slider
I_APP=$'\U000F0386'

# name cut to LABEL characters and padded, so the sliders line up
label() {
    local t="$1"
    (( ${#t} > LABEL )) && t="${t:0:LABEL-1}…"
    printf "%-${LABEL}s" "$t"
}

# "──────◈ 64%", or "muted"
level() {
    local v=$1 bar="" i
    [ "$2" = true ] && { printf '%-*s  off' $(( SLIDER + 1 )) "muted"; return; }
    (( v > 100 )) && v=100
    for (( i = 0; i < v * SLIDER / 100; i++ )); do bar+="─"; done
    bar+="◈"
    for (( i = ${#bar}; i <= SLIDER; i++ )); do bar+=" "; done
    printf '%s %3d%%' "$bar" "$1"
}

# fills ROWS (text) and ACTS ("app|index|vol|mute"), same order
build() {
    local id vol mute name
    ROWS=() ACTS=()
    while IFS=$'\t' read -r id vol mute name; do
        [ -n "$id" ] || continue
        ROWS+=("$I_APP  $(label "$name")  $(level "$vol" "$mute")")
        ACTS+=("app|$id|$vol|$mute")
    done < <(pactl -f json list sink-inputs 2>/dev/null | jq -r '.[] |
        (.properties["application.name"] // .properties["application.process.binary"] // "unknown") as $app |
        (.properties["media.name"] // "") as $media |
        [.index, ([.volume[].value_percent | rtrimstr("%") | tonumber] | max), .mute,
         (if $media == "" or $media == $app then $app else "\($app) · \($media)" end)] | @tsv')

    (( ${#ROWS[@]} )) || { ROWS=("nothing is playing"); ACTS=("none"); }
}

set_volume() {      # stream index, percent (clamped to 0..100)
    local v=$2
    (( v < 0 )) && v=0; (( v > 100 )) && v=100
    pactl set-sink-input-volume "$1" "$v%"
}

# menu through the shared engine; sets ROFI_CHOICE (row number) and ROFI_EXIT
menu() {            # shows MENU_ROWS with row $1 preselected
    local IFS=$'\n'
    MENU_CONTENT="${MENU_ROWS[*]}"
    ROFI_THEME=dropup-right.rasi
    ROFI_LINES=12
    ROFI_ARGS=(-format i -selected-row "${1:-0}"
               -kb-move-char-back "" -kb-move-char-forward ""
               -kb-custom-1 Left -kb-custom-2 Right)
    source ~/.config/waybar/scripts/_rofi_engine.sh
}

# level list for one application; returns to the main menu afterwards
app_levels() {      # index, current volume, muted
    local levels=() pct pick
    if [ "$3" = true ]; then levels+=("unmute"); else levels+=("mute"); fi
    for (( pct = 100; pct >= 0; pct -= 10 )); do levels+=("$(printf '%3d%%' "$pct")"); done
    levels+=("← back")
    MENU_ROWS=("${levels[@]}")
    menu $(( 1 + (100 - $2 + 5) / 10 ))
    pick="${levels[$ROFI_CHOICE]}"
    [ "$ROFI_EXIT" = 0 ] || return
    case "$pick" in
        mute|unmute) pactl set-sink-input-mute "$1" toggle ;;
        *%)          set_volume "$1" "${pick//[ %]/}" ;;
    esac
}

if [ "$1" = "--rows" ]; then build; printf '%s\n' "${ROWS[@]}"; exit 0; fi

# flag for the volume icon (volume-bar.sh draws it filled while the mixer is open)
OPEN="${XDG_RUNTIME_DIR:-/tmp}/mixer-open"
refresh_icon() { pkill -RTMIN+12 -x waybar; }
trap 'rm -f "$OPEN"; refresh_icon' EXIT
touch "$OPEN"; refresh_icon

row=0
while true; do
    build
    MENU_ROWS=("${ROWS[@]}")
    menu "$row"
    [[ "$ROFI_CHOICE" =~ ^[0-9]+$ ]] || break          # closed
    row=$ROFI_CHOICE
    IFS='|' read -r kind id vol mute <<< "${ACTS[$row]}"
    case "$ROFI_EXIT" in
        0)  [ "$kind" = app ] || break
            app_levels "$id" "$vol" "$mute" ;;
        10) [ "$kind" = app ] && set_volume "$id" $(( vol - STEP )) ;;
        11) [ "$kind" = app ] && set_volume "$id" $(( vol + STEP )) ;;
        *)  break ;;
    esac
done
exit 0
