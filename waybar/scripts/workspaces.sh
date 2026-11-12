#!/usr/bin/env bash
# Workspaces for the top bar: each workspace has one constant icon (workspace-icons.txt),
# drawn with its "focused" glyph when focused and with the dimmed "unfocused" glyph otherwise.
# The focused workspace sits at the visual centre. A workspace without an icon shows its name.
#
# The icons are SF Symbols characters and need the SF Pro font in ~/.local/share/fonts
# (Apple-licensed, deliberately not in this repo).

FONT="SF Pro"
ICON_SIZE="10pt"
ICON_CELLS=3          # advance of one icon measured in bar-font characters, for centring
DIM="#7C7C84"         # unfocused icon without a colour of its own
DIM_ALPHA="55%"       # unfocused icon with a colour: same colour, this opaque
GAP="    "            # between workspaces

declare -A ICON_OFF ICON_ON ICON_COLOR
while read -r ws off on color; do
    [[ "$ws" == \#* || -z "$ws" ]] && continue
    ICON_OFF[$ws]=$off; ICON_ON[$ws]=$on; ICON_COLOR[$ws]=$color
done < "${0%/*}/workspace-icons.txt"

# $1 glyph, $2 optional colour (from the icons file), $3 "dim" for an unfocused workspace.
# A coloured icon keeps its colour when unfocused, just fainter; an uncoloured one goes grey.
icon_span() {
    local attrs=""
    if [ -n "$2" ]; then
        attrs=" color='$2'"; [ "$3" = dim ] && attrs+=" fgalpha='$DIM_ALPHA'"
    elif [ "$3" = dim ]; then
        attrs=" color='$DIM'"
    fi
    echo "<span font_family='$FONT' size='$ICON_SIZE'$attrs>$1</span>"
}

print_ws() {
    local name focused text cells
    local left="" right="" centre="" lcells=0 rcells=0 seen=0

    while IFS=$'\t' read -r name focused; do
        if [ -n "${ICON_OFF[$name]}" ]; then
            cells=$ICON_CELLS
            if [ "$focused" = true ]; then text=$(icon_span "${ICON_ON[$name]}" "${ICON_COLOR[$name]}")
            else                           text=$(icon_span "${ICON_OFF[$name]}" "${ICON_COLOR[$name]}" dim); fi
        else
            text="$name"; cells=${#name}
            [ "$focused" = true ] || text="<span color='$DIM'>$text</span>"
        fi

        if [ "$focused" = true ]; then
            centre="$text"; seen=1
        elif (( seen )); then
            right+="$GAP$text"; rcells=$(( rcells + ${#GAP} + cells ))
        else
            left+="$text$GAP"; lcells=$(( lcells + ${#GAP} + cells ))
        fi
    done < <(swaymsg -t get_workspaces | jq -r '.[] | "\(.name)\t\(.focused)"')

    # pad the shorter side so the focused workspace sits at the visual centre
    while (( lcells < rcells )); do left=" $left";   lcells=$(( lcells + 1 )); done
    while (( rcells < lcells )); do right="$right "; rcells=$(( rcells + 1 )); done
    echo "$left$centre$right"
}

print_ws
swaymsg -t subscribe -m '["workspace"]' | while read -r _; do print_ws; done
