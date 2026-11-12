#!/bin/sh
# Makes every unfocused window see-through and the focused one solid. Started once per
# session from fx.conf (SwayFX only: there is blur behind the see-through windows).
# Usage: inactive-opacity.sh [opacity of unfocused windows, default 0.80]

INACTIVE="${1:-0.80}"

apply() {
    # all windows (Wayland and XWayland) to the unfocused level, then the focused one to solid
    swaymsg -q "[app_id=\".*\"] opacity $INACTIVE; [class=\".*\"] opacity $INACTIVE; opacity 1" 2>/dev/null
}

apply
swaymsg -t subscribe -m '["window"]' |
    jq --unbuffered -r 'select(.change == "focus" or .change == "new" or .change == "move") | .change' |
    while read -r _; do apply; done
