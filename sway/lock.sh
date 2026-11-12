#!/usr/bin/env bash
# Lock the screen. Used by $mod+l and the power menu's Lock entry.
# Look and behaviour live in ~/.config/swaylock/config.
pgrep -x swaylock >/dev/null && exit 0   # already locked
exec swaylock
