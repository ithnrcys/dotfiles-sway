#!/usr/bin/env bash
# Music controls for the bottom bar, next to nowplaying.sh.
#   --icon prev|toggle|next   print the button glyph (nothing when no player is active, so it hides)
#   --do   prev|toggle|next   run the action and refresh the buttons
#   (no argument)             dropup with the cover art, track details and the same controls

I_PREV=$'\U000F04AE' I_NEXT=$'\U000F04AD' I_PLAY=$'\U000F040A' I_PAUSE=$'\U000F03E4'
SIGNAL=9          # waybar "signal" of the three button modules

# Playing / Paused, or empty when there is nothing to control. playerctl first, then mpd.
player_status() {
    local s
    s=$(playerctl status 2>/dev/null)
    if [[ "$s" == "Playing" || "$s" == "Paused" ]]; then echo "$s"; return; fi
    command -v mpc &>/dev/null || return
    case "$(mpc status 2>/dev/null)" in
        *"[playing]"*) echo "Playing" ;;
        *"[paused]"*)  echo "Paused" ;;
    esac
}

uses_playerctl() { [[ "$(playerctl status 2>/dev/null)" =~ ^(Playing|Paused)$ ]]; }

act() {
    if uses_playerctl; then
        case "$1" in prev) playerctl previous ;; toggle) playerctl play-pause ;; next) playerctl next ;; esac
    else
        case "$1" in prev) mpc -q prev ;; toggle) mpc -q toggle ;; next) mpc -q next ;; esac
    fi
    sleep 0.15                                   # let the player report its new state
    pkill -RTMIN+"$SIGNAL" -x waybar
}

# Prints the path of the current cover image, or nothing. Remote art is cached per URL.
cover_file() {
    local url cache file
    url=$(playerctl metadata mpris:artUrl 2>/dev/null)
    [ -n "$url" ] || return
    if [[ "$url" == file://* ]]; then
        file="${url#file://}"
        file=$(printf '%b' "${file//%/\\x}")     # undo %20 and friends
    else
        cache="${XDG_CACHE_HOME:-$HOME/.cache}/nowplaying"
        mkdir -p "$cache"
        file="$cache/$(printf '%s' "$url" | md5sum | cut -d' ' -f1)"
        [ -s "$file" ] || curl -fsL --max-time 4 -o "$file" "$url" || { rm -f "$file"; return; }
    fi
    [ -s "$file" ] && echo "$file"
}

case "$1" in
    --icon)
        status=$(player_status)
        [ -n "$status" ] || exit 0
        case "$2" in
            prev)   echo "$I_PREV" ;;
            next)   echo "$I_NEXT" ;;
            toggle) [ "$status" = "Playing" ] && echo "$I_PAUSE" || echo "$I_PLAY" ;;
        esac
        exit 0 ;;
    --do)
        act "$2"
        exit 0 ;;
esac

# ---- cover art dropup ----
status=$(player_status)
[ -n "$status" ] || exit 0

if uses_playerctl; then
    title=$(playerctl metadata xesam:title 2>/dev/null)
    artist=$(playerctl metadata xesam:artist 2>/dev/null)
    album=$(playerctl metadata xesam:album 2>/dev/null)
else
    title=$(mpc current -f '%title%'); artist=$(mpc current -f '%artist%'); album=$(mpc current -f '%album%')
fi
info="$title"
[ -n "$artist" ] && info+=$'\n'"$artist"
[ -n "$album" ]  && info+=$'\n'"$album"

cover=$(cover_file)
if [ -n "$cover" ]; then
    ROFI_ARGS=(-theme-str "icon-cover { filename: \"$cover\"; }")
else
    ROFI_ARGS=(-theme-str "mainbox { children: [ message, listview ]; }")
fi
ROFI_ARGS+=(-mesg "$info")

if [ "$status" = "Playing" ]; then toggle_row="$I_PAUSE Pause"; else toggle_row="$I_PLAY Play"; fi
MENU_CONTENT="$I_PREV Previous\n$toggle_row\n$I_NEXT Next"
ROFI_THEME=music.rasi
source ~/.config/waybar/scripts/_rofi_engine.sh

case "$ROFI_CHOICE" in
    *"Previous"*)        act prev ;;
    *"Pause"*|*"Play"*)  act toggle ;;
    *"Next"*)            act next ;;
esac
exit 0
