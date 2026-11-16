#!/bin/sh
# Builds "windows" (window overview for Wayland, https://github.com/RadioNoiseE/windows —
# the successor to exposway) from source into ~/.local/bin; it has no openSUSE package.
# Its Makefile is not used, so make is not needed. mouse.patch (next to this script) is
# applied on top: upstream is keyboard-only.
# Needs: a C compiler, wayland-devel, wayland-protocols-devel, cairo-devel,
# libxkbcommon-devel; jq at run time (bin/expose).
set -e
SRC="$HOME/.local/src/windows"
BIN="$HOME/.local/bin"

[ -d "$SRC/.git" ] || git clone --depth 1 https://github.com/RadioNoiseE/windows "$SRC"
cd "$SRC"
git checkout -q -- .                 # drop an earlier copy of the patch before updating
git pull --ff-only || true
git apply "$HOME/.dotfiles/expose/mouse.patch"

# client code for the Wayland protocols it speaks
WP="$(pkg-config --variable=pkgdatadir wayland-protocols)"
for xml in stable/viewporter/viewporter.xml \
           stable/xdg-shell/xdg-shell.xml \
           staging/ext-foreign-toplevel-list/ext-foreign-toplevel-list-v1.xml \
           staging/ext-image-capture-source/ext-image-capture-source-v1.xml \
           staging/ext-image-copy-capture/ext-image-copy-capture-v1.xml \
           staging/fractional-scale/fractional-scale-v1.xml; do
    name=$(basename "$xml" .xml)
    wayland-scanner client-header "$WP/$xml" "$name-protocol.h"
    wayland-scanner private-code  "$WP/$xml" "$name-protocol.c"
done

cc -O2 -o windows *.c $(pkg-config --cflags --libs wayland-client xkbcommon cairo) -lm

mkdir -p "$BIN"
install -m 755 windows "$BIN/windows"
ln -sf "$HOME/.dotfiles/bin/expose" "$BIN/expose"
echo "installed: $BIN/windows, $BIN/expose"
