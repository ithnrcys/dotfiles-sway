#!/bin/sh
# Fetches the photo for the login screen and the lock screen (both read the same files).
# Run by the login-wallpaper systemd user timer; run it by hand to refresh now.
#
# Source: Wikimedia Commons "Picture of the day", with its English caption saved next to it.
#         If that fails (no network, or the day's pick is a video), Bing's photo of the day.
# The download is checked to be a real image and re-encoded to 1920x1080 before it replaces
# the current one; if everything fails the old picture and caption stay.

DEST="/usr/share/sddm/themes/glass/backgrounds"       # made writable for this user by sddm/install.sh
UA="login-wallpaper-script/1.0 (personal desktop script)"   # Wikimedia asks scripts to identify themselves
API="https://commons.wikimedia.org/w/api.php"
TMP="$(mktemp -d)" || exit 1
trap 'rm -rf "$TMP"' EXIT

[ -d "$DEST" ] && [ -w "$DEST" ] || { echo "login-wallpaper: $DEST missing or not writable (run sddm/install.sh)" >&2; exit 1; }

# wiki template -> its expanded text
expand() {
    curl -fsSL --max-time 20 -A "$UA" -G "$API" --data-urlencode "action=expandtemplates" \
        --data-urlencode "format=json" --data-urlencode "prop=wikitext" --data-urlencode "text=$1" |
        jq -r '.expandtemplates.wikitext // empty'
}

# wiki markup -> one line of plain text, at most 220 characters
plain() {
    python3 -I -c '
import re, sys, html
t = sys.stdin.read()
t = re.sub(r"\{\{[^{}]*\}\}", "", t)                          # templates
t = re.sub(r"\[\[(?:[^\]|]*\|)?([^\]]*)\]\]", r"\1", t)       # [[target|text]] and [[text]]
t = re.sub(r"\[https?://\S+\s+([^\]]*)\]", r"\1", t)          # [url text]
t = re.sub(r"<[^>]+>", "", t)                                 # html tags
t = html.unescape(t.replace("\x27\x27\x27", "").replace("\x27\x27", ""))
t = re.sub(r"\s+", " ", t).strip()
t = re.sub(r"\(\s+", "(", t)
if len(t) > 220: t = t[:217].rsplit(" ", 1)[0] + "…"
print(t)'
}

url="" caption="" source=""

# --- Wikimedia Commons picture of the day (the day changes at 00:00 UTC) ---
day=$(date -u +%F)
file=$(expand "{{Potd/$day}}")
if [ -n "$file" ]; then
    info=$(curl -fsSL --max-time 20 -A "$UA" -G "$API" --data-urlencode "action=query" \
        --data-urlencode "format=json" --data-urlencode "titles=File:$file" \
        --data-urlencode "prop=imageinfo" --data-urlencode "iiprop=url|mime" --data-urlencode "iiurlwidth=2560" |
        jq -r '.query.pages[] | .imageinfo[0] | "\(.mime)\t\(.thumburl // .url)"' | head -1)
    case "$info" in
        image/jpeg*|image/png*|image/tiff*|image/webp*)
            url=${info#*	}
            caption=$(expand "{{Potd/$day (en)}}" | plain)
            source="wikimedia" ;;
    esac
fi

# --- fallback: Bing photo of the day ---
if [ -z "$url" ]; then
    json=$(curl -fsSL --max-time 20 "https://www.bing.com/HPImageArchive.aspx?format=js&idx=0&n=1&mkt=en-US")
    path=$(printf '%s' "$json" | jq -r '.images[0].url // empty')
    [ -n "$path" ] && url="https://www.bing.com$path" && source="bing" &&
        caption=$(printf '%s' "$json" | jq -r '.images[0].copyright // empty' | plain)
fi
[ -n "$url" ] || { echo "login-wallpaper: no image address found" >&2; exit 1; }

curl -fsSL --max-time 90 -A "$UA" -o "$TMP/download" "$url" || { echo "login-wallpaper: download failed" >&2; exit 1; }
# untrusted file: accept it only if ImageMagick reads it as a picture
format=$(magick identify -format '%m' "$TMP/download[0]" 2>/dev/null)
case "$format" in JPEG|PNG|WEBP|TIFF) ;; *) echo "login-wallpaper: not an image ($format)" >&2; exit 1 ;; esac

magick "$TMP/download[0]" -auto-orient -resize 1920x1080^ -gravity center -extent 1920x1080 \
    -strip -quality 90 "$TMP/new.jpg" || exit 1
cp "$TMP/new.jpg" "$DEST/.new.jpg" && mv -f "$DEST/.new.jpg" "$DEST/current.jpg"
printf '%s\n' "$caption" > "$DEST/caption.txt"
chmod 644 "$DEST/current.jpg" "$DEST/caption.txt"
echo "login-wallpaper: updated from $source — $caption"
