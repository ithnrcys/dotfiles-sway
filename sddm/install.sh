#!/bin/sh
# Builds and installs the "glass" SDDM login theme from this folder.
#   - blurs the desktop wallpaper into the theme's background (the greeter cannot blur live)
#   - copies three SF Pro Display weights from ~/.local/share/fonts if they are there
#     (Apple-licensed, so they are not kept in this repo; without them Cantarell is used)
#   - installs to /usr/share/sddm/themes/glass and selects it in /etc/sddm.conf.d/10-theme.conf
# Needs sudo for the last step. Re-run after changing the wallpaper or the theme.
set -e
HERE="$(cd "$(dirname "$0")" && pwd)"
BUILD="${XDG_CACHE_HOME:-$HOME/.cache}/sddm-glass"
WALL="$HOME/.dotfiles/wallpapers/wallpaper.jpg"
FONTS="$HOME/.local/share/fonts/SF-Pro"

rm -rf "$BUILD" && mkdir -p "$BUILD/fonts"
cp "$HERE/theme/Main.qml" "$HERE/theme/metadata.desktop" "$HERE/theme/theme.conf" "$BUILD/"
magick "$WALL" -resize 1920x1080^ -gravity center -extent 1920x1080 -blur 0x28 -quality 88 "$BUILD/background.jpg"
for w in Regular Semibold Bold; do
    [ -f "$FONTS/SF-Pro-Display-$w.otf" ] && cp "$FONTS/SF-Pro-Display-$w.otf" "$BUILD/fonts/"
done

if [ "$1" = "--build-only" ]; then echo "built in $BUILD"; exit 0; fi

sudo ${SUDO_ASKPASS:+-A} sh -c "
    rm -rf /usr/share/sddm/themes/glass &&
    cp -r '$BUILD' /usr/share/sddm/themes/glass &&
    chmod -R a+rX /usr/share/sddm/themes/glass &&
    mkdir -p /etc/sddm.conf.d &&
    printf '[Theme]\nCurrent=glass\n' > /etc/sddm.conf.d/10-theme.conf"
echo "installed: /usr/share/sddm/themes/glass (shown at the next logout)"
