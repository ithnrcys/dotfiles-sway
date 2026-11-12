#!/usr/bin/env bash
# External drives for the bottom bar (USB sticks, disks, card readers with a card in).
#   --status        print the icon: filled when a drive is connected, dimmed empty one when not
#   (no argument)   dropup: eject a drive (unmounts its partitions and powers it down),
#                   or mount a partition that is not mounted yet
# Icons are SF Symbols characters (font: SF Pro, not in this repo).

I_ON=$'\U00100A25' I_OFF=$'\U00100A24'      # connected / disconnected
DIM="#7C7C84"
SIGNAL=13                                    # waybar "signal" of custom/drive

# One line per external disk and per partition on it:
#   D <dev> <size> <model>                 P <dev> <size> <mountpoint or -> <label or ->
# "external" = on USB or hot-pluggable, and actually holding media (size not 0)
drives() {
    lsblk -J -b -o NAME,TYPE,TRAN,HOTPLUG,SIZE,LABEL,MODEL,MOUNTPOINT,FSTYPE 2>/dev/null | jq -r '
        def human: if . >= 1e12 then "\(. / 1e11 | round / 10)T" elif . >= 1e9 then "\(. / 1e8 | round / 10)G"
                   else "\(. / 1e6 | round)M" end;
        .blockdevices[] | select(.type == "disk" and (.tran == "usb" or .hotplug == true) and .size > 0) |
        "D\t\(.name)\t\(.size | human)\t\((.model // "drive") | gsub("^ +| +$"; ""))",
        ((if (.children // []) | length > 0 then .children[] else . end) | select(.fstype != null) |
         "P\t\(.name)\t\(.size | human)\t\(.mountpoint // "-")\t\(.label // "-")")'
}

notify() { command -v notify-send >/dev/null && notify-send -a drives "External drive" "$1"; }

if [ "$1" = "--status" ]; then
    if drives | grep -q '^D'; then
        echo "<span font_family='SF Pro'>$I_ON</span>"
    else
        echo "<span font_family='SF Pro' color='$DIM'>$I_OFF</span>"
    fi
    exit 0
fi

# ---- menu ----
ROWS=() ACTS=()          # row text, and "eject|disk|part part ..." or "mount|part"
disk="" model="" mounted=() pending=()
flush() {                # close the disk being collected: one Eject row for it
    [ -n "$disk" ] || return
    ROWS+=("⏏  Eject   $model"); ACTS+=("eject|$disk|${mounted[*]}")
}
while IFS=$'\t' read -r kind dev size a b; do
    if [ "$kind" = D ]; then
        flush
        disk=$dev model="$a  $size" mounted=()
    elif [ "$a" != "-" ]; then
        mounted+=("$dev")
    else
        name=$b; [ "$name" = "-" ] && name=$dev
        pending+=("+  Mount   $name  $size|mount|$dev")
    fi
done < <(drives)
flush
for p in "${pending[@]}"; do ROWS+=("${p%%|*}"); ACTS+=("${p#*|}"); done
(( ${#ROWS[@]} )) || { ROWS=("no external drives connected"); ACTS=("none"); }

IFS=$'\n'; MENU_CONTENT="${ROWS[*]}"; unset IFS
ROFI_THEME=dropup-right.rasi
ROFI_ARGS=(-format i)
source ~/.config/waybar/scripts/_rofi_engine.sh
[[ "$ROFI_CHOICE" =~ ^[0-9]+$ ]] || exit 0

IFS='|' read -r action target parts <<< "${ACTS[$ROFI_CHOICE]}"
case "$action" in
    eject)
        for part in $parts; do
            if ! err=$(udisksctl unmount -b "/dev/$part" 2>&1); then
                notify "Could not unmount $part — still in use?"$'\n'"$err"; exit 1
            fi
        done
        if err=$(udisksctl power-off -b "/dev/$target" 2>&1); then notify "Safe to remove."
        else notify "Unmounted, but could not power off $target."$'\n'"$err"; fi ;;
    mount)
        if out=$(udisksctl mount -b "/dev/$target" 2>&1); then notify "$out"
        else notify "Could not mount $target."$'\n'"$out"; fi ;;
esac
pkill -RTMIN+"$SIGNAL" -x waybar
exit 0
