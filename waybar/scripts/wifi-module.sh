#!/usr/bin/env bash

# ==========================================
# EDITABLE VALUES (Change your icons here!)
# ==========================================
ICON_WIFI_ON="󰤨"
ICON_WIFI_OFF="󰤭"
ICON_DISCONNECTED="󰤯"
# ==========================================

# ------------------------------------------
# MODE 1: THE POLLER (Runs every second)
# ------------------------------------------
if [[ "$1" == "--status" ]]; then
    wifi_state=$(nmcli radio wifi)
    
    if [[ "$wifi_state" == "disabled" ]]; then
        echo "$ICON_WIFI_OFF"
    else
        # Check if actually connected to a network
        if nmcli -t -f active dev wifi | grep -q "^yes"; then
            echo "$ICON_WIFI_ON"
        else
            echo "$ICON_DISCONNECTED"
        fi
    fi
    exit 0
fi

# ------------------------------------------
# MODE 2: THE EXECUTOR (Runs only on click)
# ------------------------------------------
if [[ "$1" == "--menu" ]]; then
    wifi_state=$(nmcli radio wifi)

    if [[ "$wifi_state" == "enabled" ]]; then
        toggle="󰤭 Wi-Fi: Turn OFF"
        
        # Get connected network (if any)
        connected=$(nmcli -t -f active,ssid dev wifi | grep '^yes' | cut -d':' -f2)
        
        # Get available networks (unique, removing the connected one and empty SSIDs)
        paired=$(nmcli -t -f active,ssid dev wifi | grep '^no' | cut -d':' -f2 | grep -v '^$' | sort -u)

        MENU_CONTENT="${toggle}"
        
        # Only draw the separator if there are networks around
        if [ -n "$connected" ] || [ -n "$paired" ]; then
            MENU_CONTENT="${MENU_CONTENT}\n──────────────────────────────"
            
            if [ -n "$connected" ]; then
                MENU_CONTENT="${MENU_CONTENT}\n󰤨 ${connected} (Connected)"
            fi
            
            # Format available networks with the disconnected icon
            if [ -n "$paired" ]; then
                paired_formatted=$(echo "$paired" | sed 's/^/󰤯 /')
                MENU_CONTENT="${MENU_CONTENT}\n${paired_formatted}"
            fi
        fi
    else
        MENU_CONTENT="󰤨 Wi-Fi: Turn ON"
    fi

    # 3. Hand off to the Engine (Inheritance!)
    source ~/.config/waybar/scripts/_rofi_engine.sh

    # 4. Handle the click
    if [[ "$ROFI_CHOICE" == *"Wi-Fi: Turn OFF"* ]]; then
        nmcli radio wifi off
    elif [[ "$ROFI_CHOICE" == *"Wi-Fi: Turn ON"* ]]; then
        nmcli radio wifi on
    elif [[ "$ROFI_CHOICE" == *"󰤨"* && "$ROFI_CHOICE" == *"(Connected)"* ]]; then
        # Clicked the currently connected network - disconnect it
        ssid=$(echo "$ROFI_CHOICE" | sed 's/󰤨 //;s/ (Connected)//')
        nmcli con down id "$ssid"
    elif [[ "$ROFI_CHOICE" == *"󰤯"* ]]; then
        # Clicked an available network
        ssid=$(echo "$ROFI_CHOICE" | sed 's/󰤯 //')
        
        # Check if it's a known connection (saved password)
        if nmcli con show | grep -q "$ssid"; then
            nmcli con up id "$ssid"
        else
            # New network: Open Alacritty with nmtui to handle the password securely
            ghostty -e nmtui-connect "$ssid"
        fi
    fi

    exit 0
fi
