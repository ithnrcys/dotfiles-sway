#!/usr/bin/env bash

# --- Notifications ---
pgrep -x dunst || dunst &

# --- Tiling & device management ---
pgrep -f autotiling-rs || autotiling-rs &
pgrep -x udiskie || udiskie &

# --- Colour temperature (redshift → gammastep on Wayland) ---
pgrep -x gammastep || gammastep -l 18.52:73.85 &

# --- Audio ---
pgrep -x mpd || mpd &

# --- Idle: lock after 10 min, screen off a minute later, lock before suspend ---
# -w waits for the lock to be up before the machine goes to sleep
# the two timeouts are skipped while caffeine is on (bottom-bar toggle, caffeine-module.sh)
CAFFEINE="$HOME/.config/waybar/scripts/caffeine-module.sh"
pgrep -x swayidle || swayidle -w \
    timeout 600 "$CAFFEINE --idle-ok && $HOME/.config/sway/lock.sh" \
    timeout 660 "$CAFFEINE --idle-ok && swaymsg 'output * power off'" \
         resume 'swaymsg "output * power on"' \
    before-sleep "$HOME/.config/sway/lock.sh" &

# --- Polkit agent (GUI auth prompts) ---
pgrep -f polkit-gnome-authentication || /usr/lib/polkit-gnome-authentication-agent-1 &

# --- Steam: start in the tray, no main window ---
pgrep -x steam || steam -silent &
