#!/usr/bin/env bash
# Workspaces for the top bar: a fixed row of icons, one constant icon per workspace
# (workspace-icons.txt). The row never shifts; only the styling changes:
#   focused   -> "focused" glyph, full brightness
#   open      -> "unfocused" glyph, accent grey      (has windows, not focused)
#   not open  -> "unfocused" glyph, faint            (workspace does not exist yet)
# Open workspaces that have no icon are appended by name.
#
# The icons are SF Symbols characters and need the SF Pro font in ~/.local/share/fonts
# (Apple-licensed, deliberately not in this repo).

FONT="${WS_FONT:-SF Pro}"
ICON_SIZE="${WS_SIZE:-11pt}"
ICON_WEIGHT="${WS_WEIGHT:-light}"   # pango weight: thin, light, normal, medium, semibold, bold ...
C_FOCUS="#e3e2e9"
C_OPEN="#BABAC6"
C_NONE="#4D4D5A"
GAP="${WS_GAP:-   }"                 # between workspaces

ORDER=()
declare -A ICON_OFF ICON_ON
while read -r ws off on; do
    [[ "$ws" == \#* || -z "$ws" ]] && continue
    ORDER+=("$ws"); ICON_OFF[$ws]=$off; ICON_ON[$ws]=$on
done < "${0%/*}/workspace-icons.txt"

icon() { echo "<span font_family='$FONT' size='$ICON_SIZE' weight='$ICON_WEIGHT' color='$1'>$2</span>"; }

print_ws() {
    local name focused ws out="" extra=""
    local -A state=()
    while IFS=$'\t' read -r name focused; do
        state[$name]=$focused
        [ -z "${ICON_OFF[$name]}" ] && {
            if [ "$focused" = true ]; then extra+="$GAP<span color='$C_FOCUS'>$name</span>"
            else                           extra+="$GAP<span color='$C_OPEN'>$name</span>"; fi
        }
    done < <(swaymsg -t get_workspaces | jq -r '.[] | "\(.name)\t\(.focused)"')

    for ws in "${ORDER[@]}"; do
        [ -n "$out" ] && out+="$GAP"
        case "${state[$ws]}" in
            true)  out+=$(icon "$C_FOCUS" "${ICON_ON[$ws]}") ;;
            false) out+=$(icon "$C_OPEN"  "${ICON_OFF[$ws]}") ;;
            *)     out+=$(icon "$C_NONE"  "${ICON_OFF[$ws]}") ;;
        esac
    done
    echo "$out$extra"
}

print_ws
swaymsg -t subscribe -m '["workspace"]' | while read -r _; do print_ws; done
