#!/bin/sh
# Login-session launcher for SwayFX (built from source into ~/.local/swayfx, see README).
# Same environment setup as openSUSE's sway-run.sh, then SwayFX with swayfx.config.
# Falls back to plain sway if the SwayFX binary is missing or cannot start, e.g. after
# a Tumbleweed update that replaced the wlroots version it was built against.

export XDG_SESSION_TYPE=wayland
export XDG_SESSION_DESKTOP=sway
export XDG_CURRENT_DESKTOP=sway

set -a
[ -r /etc/sway/env ] && . /etc/sway/env
gen=/usr/lib/systemd/user-environment-generators/30-systemd-environment-d-generator
[ -x "$gen" ] && eval "$($gen)"
set +a

FX="$HOME/.local/swayfx/bin/sway"
# ghostty reads this optional file (see ghostty/config): see-through background only
# under SwayFX, where there is blur behind it
FXTERM="${XDG_CACHE_HOME:-$HOME/.cache}/ghostty-fx.conf"

systemctl --user start sway-session.target

if [ -x "$FX" ] && "$FX" --version >/dev/null 2>&1; then
    export SWAYFX=1
    echo "background-opacity = 0.82" > "$FXTERM"
    exec systemd-cat --identifier=swayfx "$FX" -c "$HOME/.config/sway/swayfx.config"
fi
rm -f "$FXTERM"
exec systemd-cat --identifier=sway sway
