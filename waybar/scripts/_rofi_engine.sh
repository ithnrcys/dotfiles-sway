#!/usr/bin/env bash

# The Engine: Takes $MENU_CONTENT, feeds it to Rofi, and outputs $ROFI_CHOICE
ROFI_CHOICE=$(echo -e "$MENU_CONTENT" | rofi -dmenu -i -config ~/.config/rofi/dropdown.rasi)
