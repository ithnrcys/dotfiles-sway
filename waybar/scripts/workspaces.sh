#!/usr/bin/env bash
# Workspaces for the top bar: each workspace has one constant icon (workspace-icons.txt),
# drawn with its "focused" glyph when focused and with the dimmed "unfocused" glyph otherwise.
# The focused workspace sits at the visual centre in [ brackets ]. A workspace without an icon shows its name.
# The brackets never move: each side of the focused icon is padded with invisible copies of
# the icons on the other side, so both sides are exactly as wide and the centre stays put.
#
# The icons are SF Symbols characters and need the SF Pro font in ~/.local/share/fonts
# (Apple-licensed, deliberately not in this repo).

FONT="SF Pro"
ICON_SIZE="9pt"
DIM="#7C7C84"         # unfocused icon without a colour of its own
DIM_ALPHA="55%"       # unfocused icon with a colour: same colour, this opaque
GAP="      "          # between workspaces

declare -A ICON_OFF ICON_ON ICON_COLOR
while read -r ws off on color; do
    [[ "$ws" == \#* || -z "$ws" ]] && continue
    ICON_OFF[$ws]=$off; ICON_ON[$ws]=$on; ICON_COLOR[$ws]=$color
done < "${0%/*}/workspace-icons.txt"

# $1 glyph, $2 optional colour (from the icons file), $3 "dim" for an unfocused workspace,
# "ghost" for an invisible copy that only takes up space.
# A coloured icon keeps its colour when unfocused, just fainter; an uncoloured one goes grey.
icon_span() {
    local attrs=""
    if [ "$3" = ghost ]; then
        attrs=" fgalpha='1'"
    elif [ -n "$2" ]; then
        attrs=" color='$2'"; [ "$3" = dim ] && attrs+=" fgalpha='$DIM_ALPHA'"
    elif [ "$3" = dim ]; then
        attrs=" color='$DIM'"
    fi
    echo "<span font_family='$FONT' size='$ICON_SIZE'$attrs>$1</span>"
}

print_ws() {
    local name focused text ghost i
    local left="" right="" centre="" seen=0
    local -a lghost=() rghost=()

    while IFS=$'\t' read -r name focused; do
        if [ -n "${ICON_OFF[$name]}" ]; then
            if [ "$focused" = true ]; then text=$(icon_span "${ICON_ON[$name]}" "${ICON_COLOR[$name]}")
            else                           text=$(icon_span "${ICON_OFF[$name]}" "${ICON_COLOR[$name]}" dim); fi
            ghost=$(icon_span "${ICON_OFF[$name]}" "" ghost)
        else
            text="$name"; ghost="<span fgalpha='1'>$name</span>"
            [ "$focused" = true ] || text="<span color='$DIM'>$text</span>"
        fi

        if [ "$focused" = true ]; then
            centre="[ $text ]"; seen=1
        elif (( seen )); then
            right+="$GAP$text"; rghost+=("$ghost")
        else
            left+="$text$GAP";  lghost+=("$ghost")
        fi
    done < <(swaymsg -t get_workspaces | jq -r '.[] | "\(.name)\t\(.focused)"')

    # mirror each side invisibly onto the other: left and right end up the same width
    for (( i = ${#rghost[@]} - 1; i >= 0; i-- )); do left="${rghost[i]}$GAP$left"; done
    for (( i = ${#lghost[@]} - 1; i >= 0; i-- )); do right+="$GAP${lghost[i]}"; done
    echo "$left$centre$right"
}

print_ws
swaymsg -t subscribe -m '["workspace"]' | while read -r _; do print_ws; done
