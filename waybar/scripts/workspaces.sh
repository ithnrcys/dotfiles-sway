#!/usr/bin/env bash
# Workspaces for the top bar: each workspace has one constant icon (workspace-icons.txt),
# drawn with its "focused" glyph when focused and with the dimmed "unfocused" glyph otherwise.
# The focused workspace sits at the visual centre in [ brackets ]. A workspace without an icon shows its name.
# On a workspace switch the row slides to its new position over a few frames.
#
# The icons are SF Symbols characters and need the SF Pro font in ~/.local/share/fonts
# (Apple-licensed, deliberately not in this repo).

FONT="SF Pro"
ICON_SIZE="10pt"
ICON_CELLS=3          # advance of one icon measured in bar-font characters, for centring
DIM="#7C7C84"         # unfocused icon without a colour of its own
DIM_ALPHA="55%"       # unfocused icon with a colour: same colour, this opaque
GAP="      "          # between workspaces
FRAMES=8              # slide animation: number of steps (0 = jump straight there)
FRAME_TIME=0.016      # seconds per step

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

# Builds the row for the current state: ROW is the markup, SHIFT how far it must be pushed
# so the focused workspace is centred (> 0: that many spaces on the left, < 0: on the right).
build_row() {
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
            centre="[ $text ]"; seen=1
        elif (( seen )); then
            right+="$GAP$text"; rcells=$(( rcells + ${#GAP} + cells ))
        else
            left+="$text$GAP"; lcells=$(( lcells + ${#GAP} + cells ))
        fi
    done < <(swaymsg -t get_workspaces | jq -r '.[] | "\(.name)\t\(.focused)"')

    ROW="$left$centre$right"
    SHIFT=$(( rcells - lcells ))
}

# prints ROW pushed by $1 cells
frame() {
    local pad
    if (( $1 >= 0 )); then printf -v pad '%*s' "$1" '';        echo "$pad$ROW"
    else                   printf -v pad '%*s' "$(( -$1 ))" ''; echo "$ROW$pad"; fi
}

# $1 = "slide": move from the previous position to the new one, fast at first, easing out
SHOWN=""
update() {
    local i from
    build_row
    if [ "$1" = slide ] && [ -n "$SHOWN" ] && (( FRAMES > 0 && SHOWN != SHIFT )); then
        from=$SHOWN
        for (( i = 1; i < FRAMES; i++ )); do
            frame $(( from + (SHIFT - from) * (FRAMES * FRAMES - (FRAMES - i) * (FRAMES - i)) / (FRAMES * FRAMES) ))
            sleep "$FRAME_TIME"
        done
    fi
    frame "$SHIFT"
    SHOWN=$SHIFT
}

update
swaymsg -t subscribe -m '["workspace"]' | while read -r _; do
    # several switches in quick succession: skip ahead and animate only to the latest state
    while read -r -t 0.005 _; do :; done
    update slide
done
