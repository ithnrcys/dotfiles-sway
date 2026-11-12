#!/usr/bin/env bash

# The Engine: Takes $MENU_CONTENT, feeds it to Rofi, and outputs $ROFI_CHOICE
# ROFI_THEME picks the menu position: dropdown.rasi (top bar, default) or dropup.rasi (bottom bar)
ROFI_THEME_FILE="$HOME/.config/rofi/${ROFI_THEME:-dropdown.rasi}"
# -sync: read every row before drawing. Without it the menu (which has no inputbar) starts
# at zero height and rofi-wayland segfaults on the empty buffer.
ROFI_CHOICE=$(echo -e "$MENU_CONTENT" | rofi -dmenu -i -sync -config "$ROFI_THEME_FILE")
