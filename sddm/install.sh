#!/bin/sh
# Builds and installs the "glass" SDDM login theme from this folder.
#   - copies three SF Pro Display weights from ~/.local/share/fonts if they are there
#     (Apple-licensed, so they are not kept in this repo; without them Cantarell is used)
#   - cuts the profile picture into a circle (the greeter cannot mask images itself)
#   - installs to /usr/share/sddm/themes/glass and selects it in /etc/sddm.conf.d/10-theme.conf
#   - makes the theme's backgrounds/ folder writable for you, so sddm/wallpaper.sh can swap the
#     photo without root; the first picture is the desktop wallpaper, unblurred
# Needs sudo for the install step. Re-run after changing the theme or the profile picture.
set -e
HERE="$(cd "$(dirname "$0")" && pwd)"
BUILD="${XDG_CACHE_HOME:-$HOME/.cache}/sddm-glass"
WALL="$HOME/.dotfiles/wallpapers/wallpaper.jpg"
AVATAR="$HOME/Pictures/pfp.png"
FONTS="$HOME/.local/share/fonts/SF-Pro"
THEME=/usr/share/sddm/themes/glass

rm -rf "$BUILD" && mkdir -p "$BUILD/fonts" "$BUILD/backgrounds"
cp "$HERE/theme/Main.qml" "$HERE/theme/metadata.desktop" "$HERE/theme/theme.conf" "$BUILD/"
for w in Regular Semibold Bold; do
    [ -f "$FONTS/SF-Pro-Display-$w.otf" ] && cp "$FONTS/SF-Pro-Display-$w.otf" "$BUILD/fonts/"
done
# round avatar, 192px (shown at 96): centre-crop to a square, then keep only a circle
if [ -f "$AVATAR" ]; then
    magick "$AVATAR[0]" -auto-orient -resize 192x192^ -gravity center -extent 192x192 \
        \( -size 192x192 xc:none -fill white -draw 'circle 96,96 96,0' \) \
        -alpha set -compose DstIn -composite -strip "$BUILD/avatar.png"
fi
# starting picture, used until wallpaper.sh has fetched one (kept if one is already installed)
if [ -s "$THEME/backgrounds/current.jpg" ]; then
    cp "$THEME/backgrounds/current.jpg" "$BUILD/backgrounds/current.jpg"
    cp "$THEME/backgrounds/caption.txt" "$BUILD/backgrounds/caption.txt" 2>/dev/null || true
else
    magick "$WALL" -resize 1920x1080^ -gravity center -extent 1920x1080 -strip -quality 90 "$BUILD/backgrounds/current.jpg"
fi

if [ "$1" = "--build-only" ]; then echo "built in $BUILD"; exit 0; fi

sudo ${SUDO_ASKPASS:+-A} sh -c "
    rm -rf '$THEME' &&
    cp -r '$BUILD' '$THEME' &&
    chmod -R a+rX '$THEME' &&
    chown -R '$(id -un):$(id -gn)' '$THEME/backgrounds' &&
    mkdir -p /etc/sddm.conf.d &&
    printf '[Theme]\nCurrent=glass\n' > /etc/sddm.conf.d/10-theme.conf"
echo "installed: $THEME (shown at the next logout)"
