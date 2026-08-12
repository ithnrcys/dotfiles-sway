#!/usr/bin/env bash

# ==========================================
# THE ICON ENGINE (Reusable Function)
# ==========================================
get_icon() {
    local condition=$(echo "$1" | tr '[:upper:]' '[:lower:]')
    local time="$2" # day or night
    case "$condition" in
        *sunny*|*clear*) [ "$time" = "day" ] && echo "󰖙" || echo "󰖔" ;;
        *partly*cloudy*) [ "$time" = "day" ] && echo "󰖕" || echo "󰼱" ;;
        *cloud*|*overcast*) echo "󰖐" ;;
        *rain*|*drizzle*|*shower*) echo "󰖖" ;;
        *snow*|*ice*) echo "󰖘" ;;
        *storm*|*thunder*) echo "󰖓" ;;
        *fog*|*mist*) echo "󰖑" ;;
        *) echo "󰖐" ;;
    esac
}

# ------------------------------------------
# MODE 1: THE POLLER (Runs every 15 mins)
# ------------------------------------------
if [[ "$1" == "--status" ]]; then
    # --max-time prevents Polybar from hanging if your internet drops
    weather=$(curl -sf --max-time 5 'wttr.in/?format=%C|%t' 2>/dev/null)
    
    if [ -z "$weather" ]; then
        echo "󰖐 --°C"
        exit 0
    fi

    condition=$(echo "$weather" | awk -F '|' '{print $1}')
    temp=$(echo "$weather" | awk -F '|' '{print $2}' | sed 's/+//')

    hour=$(date +%H)
    if [ "$hour" -ge 6 ] && [ "$hour" -lt 20 ]; then
        time="day"
    else
        time="night"
    fi

    icon=$(get_icon "$condition" "$time")
    echo "$icon $temp"
    exit 0
fi

# ------------------------------------------
# MODE 2: THE EXECUTOR (Runs only on click)
# ------------------------------------------
if [[ "$1" == "--menu" ]]; then
    # Fetch detailed JSON data from wttr.in
    json=$(curl -sf --max-time 5 'wttr.in/?format=j1' 2>/dev/null)
    
    if [ -z "$json" ]; then
        MENU_CONTENT="󰖐 Weather API Unreachable"
        source ~/.config/waybar/scripts/_rofi_engine.sh
        exit 0
    fi

    MENU_CONTENT="󰖐 3-Day Forecast\n──────────────────────────────"

    # Loop through Today, Tomorrow, and Next Day
    for i in 0 1 2; do
        raw_date=$(echo "$json" | jq -r ".weather[$i].date")
        day_name=$(date -d "$raw_date" +%a)

        # Morning (09:00 -> JSON index 3)
        m_cond=$(echo "$json" | jq -r ".weather[$i].hourly[3].weatherDesc[0].value")
        m_temp=$(echo "$json" | jq -r ".weather[$i].hourly[3].tempC")
        m_icon=$(get_icon "$m_cond" "day")

        # Afternoon (15:00 -> JSON index 5)
        a_cond=$(echo "$json" | jq -r ".weather[$i].hourly[5].weatherDesc[0].value")
        a_temp=$(echo "$json" | jq -r ".weather[$i].hourly[5].tempC")
        a_icon=$(get_icon "$a_cond" "day")

        # Night (21:00 -> JSON index 7)
        n_cond=$(echo "$json" | jq -r ".weather[$i].hourly[7].weatherDesc[0].value")
        n_temp=$(echo "$json" | jq -r ".weather[$i].hourly[7].tempC")
        n_icon=$(get_icon "$n_cond" "night")

        # Build the row to align cleanly in Rofi's monospace font
        row="${day_name}:    ${m_icon} ${m_temp}°C    ${a_icon} ${a_temp}°C    ${n_icon} ${n_temp}°C"
        MENU_CONTENT="${MENU_CONTENT}\n${row}"
    done

    # Hand off to our Shared Library
    source ~/.config/waybar/scripts/_rofi_engine.sh
    exit 0
fi
