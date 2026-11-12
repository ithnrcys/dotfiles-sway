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

# --- Polkit agent (GUI auth prompts) ---
pgrep -f polkit-gnome-authentication || /usr/lib/polkit-gnome-authentication-agent-1 &
