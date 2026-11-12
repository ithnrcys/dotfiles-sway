#!/usr/bin/env bash

# ==========================================
# EDITABLE VALUES (Change your icons here!)
# ==========================================
ICON_WIFI_ON="󰀂"
ICON_WIFI_OFF="󰤭"
ICON_DISCONNECTED="󰤯"
# ==========================================

# ------------------------------------------
# MODE 0: icon in front of the waybar network module (custom/netstate)
#   wired / wifi glyph while the internet is reachable; the "no internet" glyph otherwise —
#   not connected at all, or connected to a router that has no way out (NetworkManager's
#   connectivity check: anything but "full")
# ------------------------------------------
if [[ "$1" == "--icon" ]]; then
    ICON_NO_INTERNET="<span font_family='SF Pro' size='10pt'>"$'\U00100665'"</span>"
    if [[ "$(nmcli -t -f CONNECTIVITY general 2>/dev/null)" != "full" ]]; then
        echo "$ICON_NO_INTERNET"
    elif nmcli -t -f TYPE,STATE dev 2>/dev/null | grep -q '^ethernet:connected'; then
        echo "󰈀"
    else
        echo "$ICON_WIFI_ON"
    fi
    exit 0
fi

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
notify() { command -v dunstify >/dev/null && dunstify -a wifi "Wi-Fi" "$1"; }

strength_icon() {
    if   [ "$1" -ge 75 ]; then echo "󰤨"
    elif [ "$1" -ge 50 ]; then echo "󰤥"
    elif [ "$1" -ge 25 ]; then echo "󰤢"
    else echo "󰤟"; fi
}

if [[ "$1" == "--menu" ]]; then
    declare -A SECURITY   # ssid -> security string ("" or "--" = open)
    connected=""

    if [[ "$(nmcli radio wifi)" == "enabled" ]]; then
        MENU_CONTENT="󰤭 Wi-Fi: Turn OFF\n󰑐 Rescan"
        rows=""

        # IN-USE:SIGNAL:SECURITY:SSID, strongest first; SSID is last so colons in it survive
        while IFS=: read -r inuse signal sec ssid; do
            [ -z "$ssid" ] && continue                 # hidden networks
            [ -n "${SECURITY[$ssid]+x}" ] && continue  # one row per SSID (strongest AP)
            SECURITY[$ssid]="$sec"
            if [ "$inuse" = "*" ]; then
                connected="$ssid"
                rows="$(strength_icon "$signal") ${ssid} (Connected)\n${rows}"
            else
                rows="${rows}$(strength_icon "$signal") ${ssid}\n"
            fi
        done < <(nmcli -t -e no -f IN-USE,SIGNAL,SECURITY,SSID dev wifi list --rescan no | sort -t: -k2,2 -nr)

        # --rescan no: show NetworkManager's cached list at once (a forced scan blocks ~5 s).
        # Kick off a scan in the background instead, so the cache is fresh for the next open.
        ( nmcli dev wifi rescan >/dev/null 2>&1 & )

        if [ -n "$rows" ]; then
            MENU_CONTENT="${MENU_CONTENT}\n──────────────────────────────\n${rows%\\n}"
        fi
    else
        MENU_CONTENT="󰤨 Wi-Fi: Turn ON"
    fi

    # Hand off to the Engine
    source ~/.config/waybar/scripts/_rofi_engine.sh
    [ -z "$ROFI_CHOICE" ] && exit 0

    case "$ROFI_CHOICE" in
        *"Wi-Fi: Turn OFF"*) nmcli radio wifi off; exit 0 ;;
        *"Wi-Fi: Turn ON"*)  nmcli radio wifi on;  exit 0 ;;
        *"Rescan"*)
            # explicit rescan: this one does wait for the scan to finish
            nmcli -t dev wifi list --rescan yes >/dev/null 2>&1
            exec "$0" --menu ;;
        ──*) exit 0 ;;
    esac

    # A network row: strip the icon, and the (Connected) tag if present
    ssid="${ROFI_CHOICE#* }"
    if [[ "$ssid" == *" (Connected)" ]]; then
        nmcli dev disconnect "$(nmcli -t -f DEVICE,TYPE dev | awk -F: '$2=="wifi"{print $1; exit}')"
        exit 0
    fi
    [ -z "${SECURITY[$ssid]+x}" ] && exit 0

    sec="${SECURITY[$ssid]}"
    known=false
    nmcli -g NAME con show | grep -Fxq -- "$ssid" && known=true

    if $known || [ -z "$sec" ] || [ "$sec" = "--" ]; then
        # saved profile or open network: no password needed
        out=$(nmcli dev wifi connect "$ssid" 2>&1)
    else
        # new secured network: ask for the password in the same menu spot
        pass=$(rofi -dmenu -password -p "󰌾 ${ssid}" -config "$ROFI_THEME_FILE" \
               -theme-str 'mainbox { children: [ inputbar ]; }' < /dev/null)
        [ -z "$pass" ] && exit 0
        out=$(nmcli dev wifi connect "$ssid" password "$pass" 2>&1)
    fi

    if [ $? -eq 0 ]; then
        notify "Connected to ${ssid}"
    else
        # a failed first attempt can leave a broken profile behind; drop it so the next try re-asks
        $known || nmcli con delete id "$ssid" >/dev/null 2>&1
        notify "Could not connect to ${ssid}: ${out##*: }"
    fi
    exit 0
fi
