#!/usr/bin/env bash
# Audio mixer for the bottom bar: a dropup listing the output devices and every application
# that is playing sound, each with its own level.
#   Enter / click on a device        make it the default output (playing apps move to it)
#   Enter / click on an application  pick a level from a list (or mute it)
#   Left / Right on any row          volume -5% / +5%
#   Escape, or clicking the volume slider again, closes it
#   --rows  print the menu rows and exit (for checking)

STEP=5
LABEL=26          # characters of device / application name
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

# fills ROWS (text) and ACTS ("sink|name|vol|mute" or "app|index|vol|mute"), same order
build() {
    local kind id vol mute name default
    ROWS=() ACTS=()
    default=$(pactl get-default-sink 2>/dev/null)

    while IFS=$'\t' read -r id vol mute name; do
        [ -n "$id" ] || continue
        if [ "$id" = "$default" ]; then kind="●"; else kind="○"; fi
        ROWS+=("$kind  $(label "$name")  $(level "$vol" "$mute")")
        ACTS+=("sink|$id|$vol|$mute")
    done < <(pactl -f json list sinks 2>/dev/null | jq -r '.[] |
        [.name, ([.volume[].value_percent | rtrimstr("%") | tonumber] | max), .mute, .description] | @tsv')

    while IFS=$'\t' read -r id vol mute name; do
        [ -n "$id" ] || continue
        ROWS+=("$I_APP  $(label "$name")  $(level "$vol" "$mute")")
        ACTS+=("app|$id|$vol|$mute")
    done < <(pactl -f json list sink-inputs 2>/dev/null | jq -r '.[] |
        (.properties["application.name"] // .properties["application.process.binary"] // "unknown") as $app |
        (.properties["media.name"] // "") as $media |
        [.index, ([.volume[].value_percent | rtrimstr("%") | tonumber] | max), .mute,
         (if $media == "" or $media == $app then $app else "\($app) · \($media)" end)] | @tsv')

    (( ${#ROWS[@]} )) || { ROWS=("no audio devices"); ACTS=("none"); }
}

set_volume() {      # kind, id, percent (clamped to 0..100)
    local v=$3
    (( v < 0 )) && v=0; (( v > 100 )) && v=100
    if [ "$1" = sink ]; then pactl set-sink-volume "$2" "$v%"; else pactl set-sink-input-volume "$2" "$v%"; fi
}

set_default() {     # sink name: new default, and move what is playing onto it
    local input
    pactl set-default-sink "$1"
    for input in $(pactl -f json list sink-inputs | jq -r '.[].index'); do
        pactl move-sink-input "$input" "$1" 2>/dev/null
    done
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
        *%)          set_volume app "$1" "${pick//[ %]/}" ;;
    esac
}

if [ "$1" = "--rows" ]; then build; printf '%s\n' "${ROWS[@]}"; exit 0; fi

row=0
while true; do
    build
    MENU_ROWS=("${ROWS[@]}")
    menu "$row"
    [[ "$ROFI_CHOICE" =~ ^[0-9]+$ ]] || break          # closed
    row=$ROFI_CHOICE
    IFS='|' read -r kind id vol mute <<< "${ACTS[$row]}"
    case "$ROFI_EXIT" in
        0)  case "$kind" in
                sink) set_default "$id" ;;
                app)  app_levels "$id" "$vol" "$mute" ;;
                *)    break ;;
            esac ;;
        10) [ "$kind" != none ] && set_volume "$kind" "$id" $(( vol - STEP )) ;;
        11) [ "$kind" != none ] && set_volume "$kind" "$id" $(( vol + STEP )) ;;
        *)  break ;;
    esac
done
exit 0
