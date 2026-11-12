#!/usr/bin/env bash
# Bluetooth for the top bar.
#   --status   icon for the bar (polled)
#   --menu     rofi dropdown: power, scan, connect / disconnect / pair devices

ICON_ON="󰂱"            # a device is connected
ICON_OFF="󰂲"           # adapter off, or no bluetooth stack
ICON_DISCONNECTED="󰂯"  # on, nothing connected
ICON_SCAN="󰂰"

SEP="──────────────────────────────"

# every bluetoothctl call is time-boxed: it waits forever if bluetoothd is not answering
bt() { timeout 5 bluetoothctl "$@" 2>/dev/null; }
have_bt() { command -v bluetoothctl >/dev/null; }
powered() { bt show | grep -q "Powered: yes"; }
notify() { command -v dunstify >/dev/null && dunstify -a bluetooth "Bluetooth" "$1"; }

# ------------------------------------------
# MODE 1: status icon
# ------------------------------------------
if [[ "$1" == "--status" ]]; then
    if ! have_bt || ! powered; then
        echo "$ICON_OFF"
    elif bt devices Connected | grep -q "^Device"; then
        echo "$ICON_ON"
    else
        echo "$ICON_DISCONNECTED"
    fi
    exit 0
fi

# ------------------------------------------
# MODE 2: menu (runs only on click)
# ------------------------------------------
if [[ "$1" == "--menu" ]]; then
    declare -A MAC   # device name -> address

    if ! have_bt; then
        MENU_CONTENT="${ICON_OFF} bluez is not installed"
    elif ! powered; then
        MENU_CONTENT="${ICON_DISCONNECTED} Bluetooth: Turn ON"
    else
        MENU_CONTENT="${ICON_OFF} Bluetooth: Turn OFF\n${ICON_SCAN} Scan for devices"

        connected_macs=$(bt devices Connected | awk '{print $2}')
        paired_macs=$(bt devices Paired | awk '{print $2}')
        rows_connected="" rows_paired="" rows_new=""

        # "Device AA:BB:CC:DD:EE:FF Some Name" — everything known to the adapter, scan results included
        while read -r _ mac name; do
            [ -z "$name" ] && continue
            # devices that never sent a name show up as their address with dashes; skip them
            [[ "$name" =~ ^([0-9A-F]{2}-){5}[0-9A-F]{2}$ ]] && continue
            MAC[$name]="$mac"
            if grep -Fxq "$mac" <<< "$connected_macs"; then
                rows_connected+="\n${ICON_ON} ${name} (Connected)"
            elif grep -Fxq "$mac" <<< "$paired_macs"; then
                rows_paired+="\n${ICON_DISCONNECTED} ${name}"
            else
                rows_new+="\n${ICON_SCAN} ${name} (New)"
            fi
        done < <(bt devices)

        rows="${rows_connected}${rows_paired}${rows_new}"
        [ -n "$rows" ] && MENU_CONTENT+="\n${SEP}${rows}"
    fi

    # Hand off to the Engine
    source ~/.config/waybar/scripts/_rofi_engine.sh
    [ -z "$ROFI_CHOICE" ] && exit 0

    case "$ROFI_CHOICE" in
        *"Bluetooth: Turn OFF"*) bt power off >/dev/null; exit 0 ;;
        *"Bluetooth: Turn ON"*)  bt power on  >/dev/null; exit 0 ;;
        *"Scan for devices"*)
            notify "Scanning for 6 seconds…"
            timeout 8 bluetoothctl --timeout 6 scan on >/dev/null 2>&1
            exec "$0" --menu ;;
        *"not installed"*|──*) exit 0 ;;
    esac

    # A device row: strip the icon and the state tag, look the address up by name
    name="${ROFI_CHOICE#* }"
    state=""
    case "$name" in
        *" (Connected)") state="connected"; name="${name% (Connected)}" ;;
        *" (New)")       state="new";       name="${name% (New)}" ;;
    esac
    mac="${MAC[$name]}"
    [ -z "$mac" ] && exit 0

    case "$state" in
        connected)
            bt disconnect "$mac" >/dev/null && notify "Disconnected ${name}" ;;
        new)
            # first time: pair, trust (so it reconnects by itself later), then connect
            notify "Pairing ${name}…"
            if timeout 20 bluetoothctl pair "$mac" >/dev/null 2>&1; then
                bt trust "$mac" >/dev/null
                timeout 15 bluetoothctl connect "$mac" >/dev/null 2>&1 \
                    && notify "Connected ${name}" || notify "Paired ${name}, but could not connect"
            else
                notify "Could not pair ${name}"
            fi ;;
        *)
            timeout 15 bluetoothctl connect "$mac" >/dev/null 2>&1 \
                && notify "Connected ${name}" || notify "Could not connect ${name}" ;;
    esac
    exit 0
fi
