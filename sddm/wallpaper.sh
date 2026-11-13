#!/bin/sh
# Fetches a fresh photo for the login screen and the lock screen (both read the same file).
# Run by the login-wallpaper systemd user timer; run it by hand to change the picture now.
#
# Source: Unsplash if an API access key is saved in ~/.config/login-wallpaper/unsplash-key
#         (free at unsplash.com/developers; a random landscape photo from the "wallpapers"
#         topic each run), otherwise Bing's photo of the day, which needs no key.
# The download is checked to be a real image and re-encoded to 1920x1080 before it replaces
# the current one; if anything fails the old picture stays.

DEST="/usr/share/sddm/themes/glass/backgrounds"       # made writable for this user by sddm/install.sh
KEYFILE="${XDG_CONFIG_HOME:-$HOME/.config}/login-wallpaper/unsplash-key"
TMP="$(mktemp -d)" || exit 1
trap 'rm -rf "$TMP"' EXIT

[ -d "$DEST" ] && [ -w "$DEST" ] || { echo "login-wallpaper: $DEST missing or not writable (run sddm/install.sh)" >&2; exit 1; }

if [ -s "$KEYFILE" ]; then
    url=$(curl -fsSL --max-time 20 -H "Authorization: Client-ID $(tr -d '[:space:]' < "$KEYFILE")" \
        "https://api.unsplash.com/photos/random?topics=wallpapers&orientation=landscape" |
        jq -r '.urls.raw // empty')
    [ -n "$url" ] && url="$url&w=1920&h=1080&fit=crop&q=85&fm=jpg"
    source="unsplash"
else
    path=$(curl -fsSL --max-time 20 "https://www.bing.com/HPImageArchive.aspx?format=js&idx=0&n=1&mkt=en-US" |
        jq -r '.images[0].url // empty')
    [ -n "$path" ] && url="https://www.bing.com$path"
    source="bing"
fi
[ -n "$url" ] || { echo "login-wallpaper: no image address from $source" >&2; exit 1; }

curl -fsSL --max-time 60 -o "$TMP/download" "$url" || { echo "login-wallpaper: download failed" >&2; exit 1; }
# untrusted file: accept it only if ImageMagick reads it as a JPEG, PNG or WebP picture
format=$(magick identify -format '%m' "$TMP/download[0]" 2>/dev/null)
case "$format" in JPEG|PNG|WEBP) ;; *) echo "login-wallpaper: not an image ($format)" >&2; exit 1 ;; esac

magick "$TMP/download[0]" -auto-orient -resize 1920x1080^ -gravity center -extent 1920x1080 \
    -strip -quality 90 "$TMP/new.jpg" || exit 1
cp "$TMP/new.jpg" "$DEST/.new.jpg" && mv -f "$DEST/.new.jpg" "$DEST/current.jpg"
chmod 644 "$DEST/current.jpg"
echo "login-wallpaper: updated from $source"
