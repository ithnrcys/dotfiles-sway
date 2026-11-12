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
DIM="#7C7C84"
GAP="    "            # between workspaces

declare -A ICON_OFF ICON_ON
while read -r ws off on; do
    [[ "$ws" == \#* || -z "$ws" ]] && continue
    ICON_OFF[$ws]=$off; ICON_ON[$ws]=$on
done < "${0%/*}/workspace-icons.txt"

icon_span() { echo "<span font_family='$FONT' size='$ICON_SIZE'>$1</span>"; }

print_ws() {
    local name focused text cells
    local left="" right="" centre="" lcells=0 rcells=0 seen=0

    while IFS=$'\t' read -r name focused; do
        if [ -n "${ICON_OFF[$name]}" ]; then
            cells=$ICON_CELLS
            if [ "$focused" = true ]; then text=$(icon_span "${ICON_ON[$name]}")
            else                           text=$(icon_span "${ICON_OFF[$name]}"); fi
        else
            text="$name"; cells=${#name}
        fi

        if [ "$focused" = true ]; then
            centre="$text"; seen=1
        elif (( seen )); then
            right+="$GAP<span color='$DIM'>$text</span>"; rcells=$(( rcells + ${#GAP} + cells ))
        else
            left+="<span color='$DIM'>$text</span>$GAP";  lcells=$(( lcells + ${#GAP} + cells ))
        fi
    done < <(swaymsg -t get_workspaces | jq -r '.[] | "\(.name)\t\(.focused)"')

    # pad the shorter side so the focused workspace sits at the visual centre
    while (( lcells < rcells )); do left=" $left";   lcells=$(( lcells + 1 )); done
    while (( rcells < lcells )); do right="$right "; rcells=$(( rcells + 1 )); done
    echo "$left$centre$right"
}

print_ws
swaymsg -t subscribe -m '["workspace"]' | while read -r _; do print_ws; done
