#!/bin/sh
# Builds exposway (window overview for sway, https://github.com/radionoisee/exposway) from
# source into ~/.local/bin — it has no openSUSE package. Its makefile is not used, so make
# is not needed. Needs: clang, wayland-devel, wayland-protocols-devel, cairo-devel,
# pango-devel, libxkbcommon-devel, libjson-c-devel; grim at run time.
set -e
SRC="$HOME/.local/src/exposway"
BIN="$HOME/.local/bin"

[ -d "$SRC/.git" ] || git clone --depth 1 https://github.com/radionoisee/exposway "$SRC"
cd "$SRC"
git pull --ff-only || true

XDG_SHELL="$(pkg-config --variable=pkgdatadir wayland-protocols)/stable/xdg-shell/xdg-shell.xml"
wayland-scanner client-header "$XDG_SHELL" xdg-shell-client-protocol.h
wayland-scanner private-code  "$XDG_SHELL" xdg-shell-protocol.c

# the overview itself
clang -O3 -Wno-unused-result -o exposway expose.c xdg-shell-protocol.c \
    $(pkg-config --cflags --libs wayland-client pangocairo xkbcommon) -lm
# the daemon that keeps a snapshot of every window
clang -O3 -Wno-unused-result -o exposwayd exposed.c $(pkg-config --cflags --libs json-c)

mkdir -p "$BIN"
install -m 755 exposway exposwayd "$BIN/"
ln -sf "$HOME/.dotfiles/bin/expose" "$BIN/expose"
echo "installed: $BIN/exposway, $BIN/exposwayd, $BIN/expose"
