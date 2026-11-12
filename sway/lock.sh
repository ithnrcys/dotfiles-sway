#!/usr/bin/env bash
# Lock the screen. Used by $mod+l and the power menu's Lock entry.
# Ring colours and behaviour live in ~/.config/swaylock/config; this script supplies the
# background: the wallpaper, blurred and darkened, with "λ user" set under the ring.
# The image is cached and only rebuilt when the wallpaper (or this script) changes.

pgrep -x swaylock >/dev/null && exit 0   # already locked

WALLPAPER="$HOME/.dotfiles/wallpapers/wallpaper.jpg"
CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/swaylock"
BG="$CACHE/bg.jpg"

build_bg() {
    mkdir -p "$CACHE"
    # size of the focused output, falling back to 1080p
    local size font
    size=$(swaymsg -t get_outputs 2>/dev/null | jq -r '.[] | select(.focused) | "\(.current_mode.width)x\(.current_mode.height)"' | head -1)
    [[ "$size" =~ ^[0-9]+x[0-9]+$ ]] || size="1920x1080"
    font=$(fc-match -f '%{file}' 'JetBrainsMono Nerd Font:bold')

    # frosted glass: shrink to a quarter, blur, scale back up; then mute the colour and darken
    local w=${size%x*} h=${size#*x}
    magick "$WALLPAPER" -resize "$((w / 4))x$((h / 4))^" -gravity center -extent "$((w / 4))x$((h / 4))" \
        -blur 0x3 -resize "${size}!" -modulate 100,60 -fill '#070708' -colorize 50% \
        -font "$font" -pointsize 26 -fill '#e3e2e9' -gravity center -annotate +0+165 "λ  ${USER}" \
        -quality 92 "$BG.tmp.jpg" && mv -f "$BG.tmp.jpg" "$BG"
}

if [[ "$1" == "--rebuild" ]]; then build_bg; exit; fi

if [ ! -s "$BG" ] || [ "$WALLPAPER" -nt "$BG" ] || [ "$0" -nt "$BG" ]; then
    build_bg
fi

if [ -s "$BG" ]; then
    exec swaylock --image "$BG"
else
    exec swaylock      # image could not be built: plain colour from the config
fi
