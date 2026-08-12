#!/usr/bin/env bash

# ==========================================
# EDITABLE VALUES (Change your icons here!)
# ==========================================
ICON_ON="󰂱"
ICON_OFF="󰂲"
ICON_DISCONNECTED="󰂯"
# ==========================================

# ------------------------------------------
# MODE 1: THE POLLER (Runs every second)
# ------------------------------------------
if [[ "$1" == "--status" ]]; then
    
    if ! bluetoothctl show | grep -q "Powered: yes"; then
        echo "$ICON_OFF"
    elif bluetoothctl devices Connected | grep -q "Device"; then
        echo "$ICON_ON"
    else
        echo "$ICON_DISCONNECTED"
    fi
    
    exit 0 # Exits immediately. Protects your CPU!
fi

# ------------------------------------------
# MODE 2: THE EXECUTOR (Runs only on click)
# ------------------------------------------
if [[ "$1" == "--menu" ]]; then
    
    # 1. Gather Current State
    power_state=$(bluetoothctl show | grep "Powered: yes" | wc -c)

    # 2. Build the Menu
    if [ $power_state -gt 0 ]; then
        toggle="󰂲 Power: Turn OFF"
        scan="󰂰 Scan for New Devices"

        connected=$(bluetoothctl devices Connected | sed 's/^Device \S* /󰂱 /' | sed 's/$/ (Connected)/')
        paired=$(bluetoothctl devices | grep -v -f <(bluetoothctl devices Connected | awk '{print $2}') | sed 's/^Device \S* /󰂯 /')

        # Start with the base options
        MENU_CONTENT="${toggle}\n${scan}"

        # Only draw the separator and devices IF there are devices to show
        if [ -n "$connected" ] || [ -n "$paired" ]; then
            MENU_CONTENT="${MENU_CONTENT}\n──────────────────────────────"
            [ -n "$connected" ] && MENU_CONTENT="${MENU_CONTENT}\n${connected}"
            [ -n "$paired" ] && MENU_CONTENT="${MENU_CONTENT}\n${paired}"
        fi
    else
        # If power is off, the only option is to turn it on
        MENU_CONTENT="󰂯 Power: Turn ON"
    fi

    # 3. Hand off to the Engine (Inheritance)
    source ~/.config/waybar/scripts/_rofi_engine.sh

    # 4. Execute the Action based on what was clicked
    if [[ "$ROFI_CHOICE" == *"Power: Turn OFF"* ]]; then
        bluetoothctl power off
    elif [[ "$ROFI_CHOICE" == *"Power: Turn ON"* ]]; then
        bluetoothctl power on
    elif [[ "$ROFI_CHOICE" == *"Scan for New Devices"* ]]; then
        # Pops open Alacritty for a live scan
        ghostty -e bash -c "echo 'Scanning for 15 seconds...'; bluetoothctl --timeout 15 scan on; echo 'Done. Check Rofi menu.'; sleep 2"
    elif [[ "$ROFI_CHOICE" == *"󰂱"* ]]; then
        # Disconnect a connected device
        name=$(echo "$ROFI_CHOICE" | sed 's/󰂱 //;s/ (Connected)//')
        mac=$(bluetoothctl devices | grep "$name" | awk '{print $2}')
        bluetoothctl disconnect "$mac"
    elif [[ "$ROFI_CHOICE" == *"󰂯"* ]]; then
        # Connect to an available device
        name=$(echo "$ROFI_CHOICE" | sed 's/󰂯 //')
        mac=$(bluetoothctl devices | grep "$name" | awk '{print $2}')
        bluetoothctl connect "$mac"
    fi
    
    exit 0
fi
