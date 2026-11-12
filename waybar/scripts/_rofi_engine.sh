#!/usr/bin/env bash

# The Engine: Takes $MENU_CONTENT, feeds it to Rofi, and outputs $ROFI_CHOICE (and $ROFI_EXIT)
# ROFI_THEME picks the menu position: dropdown.rasi (top bar, default) or dropup.rasi (bottom bar)
ROFI_THEME_FILE="$HOME/.config/rofi/${ROFI_THEME:-dropdown.rasi}"

# Toggle: clicking a module while its menu is open closes it. Clicking a different module
# closes the open menu and opens the new one. The open menu's name is kept in a state file.
ROFI_MENU_ID="${0##*/}"
ROFI_STATE="${XDG_RUNTIME_DIR:-/tmp}/rofi-bar-menu"
ROFI_PREV=$(cat "$ROFI_STATE" 2>/dev/null)
# claim the state before killing, so the menu being replaced sees it is no longer the owner
echo "$ROFI_MENU_ID $$" > "$ROFI_STATE"
if pkill -x rofi; then
    if [ "${ROFI_PREV% *}" = "$ROFI_MENU_ID" ]; then
        rm -f "$ROFI_STATE"
        exit 0
    fi
    # wait for the old rofi to go away, it holds a lock that blocks a second instance
    for _ in 1 2 3 4 5 6 7 8 9 10; do pgrep -x rofi >/dev/null || break; sleep 0.02; done
fi

# -sync: read every row before drawing. Without it the menu (which has no inputbar) starts
# at zero height and rofi-wayland segfaults on the empty buffer.
# ROFI_LINES (optional) raises the row limit for long menus.
# ROFI_ARGS (optional array) is passed straight to rofi, e.g. -mesg or extra -theme-str.
ROFI_CHOICE=$(echo -e "$MENU_CONTENT" | rofi -dmenu -i -sync -config "$ROFI_THEME_FILE" \
              ${ROFI_LINES:+-theme-str "listview { lines: ${ROFI_LINES}; }"} "${ROFI_ARGS[@]}")
ROFI_EXIT=$?      # 0 = row chosen, 1 = closed, 10+ = custom key (-kb-custom-N)

# menu closed normally: clear the state, but only if this instance still owns it
[ "$(cat "$ROFI_STATE" 2>/dev/null)" = "$ROFI_MENU_ID $$" ] && rm -f "$ROFI_STATE"
