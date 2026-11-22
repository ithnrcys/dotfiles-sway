#!/usr/bin/env bash

# --- Notifications ---
pgrep -x swaync || swaync &

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

# --- Clipboard: the last copy (text, formatting, pictures) survives closing the window it came from
# one item, in memory, no history; entries a password manager marks as sensitive are left alone
pgrep -x wl-clip-persist || "$HOME/.local/bin/wl-clip-persist" --clipboard regular \
    --all-mime-type-regex '^(?!x-kde-passwordManagerHint).+' &

# --- Polkit agent (GUI auth prompts) ---
pgrep -f polkit-gnome-authentication || /usr/libexec/polkit-gnome-authentication-agent-1 &

# --- Steam: start in the tray, no main window ---
pgrep -x steam || steam -silent &
