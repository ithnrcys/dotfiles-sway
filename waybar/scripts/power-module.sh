#!/usr/bin/env bash

# Power menu for the bottom bar. The button itself is the current phase of the moon.
#   --icon          print the moon-phase glyph for right now (waybar polls this hourly)
#   (no argument)   open the power menu
#
# The glyphs are SF Symbols "moonphase" characters (font: SF Pro, not in this repo), the
# inverse set: lit part drawn solid, which reads correctly on a dark bar.
if [ "$1" = "--icon" ]; then
    MOONS=($'\U00101409' $'\U0010140A' $'\U0010140B' $'\U0010140C'    # new, waxing crescent, first quarter, waxing gibbous
           $'\U0010140D' $'\U0010140E' $'\U0010140F' $'\U00101410')   # full, waning gibbous, last quarter, waning crescent
    # age of the moon from a known new moon (2000-01-06 18:14 UTC) and the mean lunar month
    # of 29.530588853 days; good to about half a day, plenty for eight phases
    month=2551443                                    # seconds
    age=$(( ($(date +%s) - 947182440) % month ))
    phase=$(( (age * 8 + month / 2) / month % 8 ))
    echo "<span font_family='SF Pro'>${MOONS[$phase]}</span>"
    exit 0
fi

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
