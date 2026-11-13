#!/usr/bin/env bash
# Lock the screen. Used by $mod+l, the power menu's Lock entry and swayidle.
# Uses hyprlock (config: hyprlock/hyprlock.conf, the same look as the login screen) and
# returns as soon as the screen is locked, so swayidle can let the machine go to sleep.
# Falls back to plain swaylock (config: swaylock/config) if hyprlock is not installed.

pgrep -x hyprlock >/dev/null && exit 0   # already locked
pgrep -x swaylock >/dev/null && exit 0

if command -v hyprlock >/dev/null; then
    setsid -f hyprlock >/dev/null 2>&1
    # wait (up to 2 s) until hyprlock is up before reporting "locked"
    for _ in $(seq 20); do pgrep -x hyprlock >/dev/null && break; sleep 0.1; done
    sleep 0.3
    exit 0
fi

exec swaylock    # daemonizes itself; colours and ring come from swaylock/config
