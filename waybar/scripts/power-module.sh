#!/usr/bin/env bash

# ==========================================
# THE MENU EXECUTOR 
# ==========================================

# 1. Build the Menu
MENU_CONTENT="󰐥 Shutdown\n󰜉 Reboot\n󰤄 Suspend\n󰌾 Lock\n󰍃 Logout"

# 2. Hand off to the Engine
source ~/.config/waybar/scripts/_rofi_engine.sh

# 3. Handle the choice
case "$ROFI_CHOICE" in
    *"Shutdown"*) systemctl poweroff ;;
    *"Reboot"*) systemctl reboot ;;
    *"Suspend"*) systemctl suspend ;;
    *"Lock"*) ~/.config/sway/lock.sh ;;
    *"Logout"*) swaymsg exit ;;
esac

exit 0
