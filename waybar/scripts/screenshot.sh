#!/usr/bin/env bash
# Screenshot from the quick access panel: drag a region (Esc cancels), or click once for the
# whole screen under the pointer. Saved to ~/Pictures/Screenshots and copied to the clipboard.

DIR="$HOME/Pictures/Screenshots"
mkdir -p "$DIR"
FILE="$DIR/$(date +%Y-%m-%d_%H-%M-%S).png"

swaync-client -cp >/dev/null 2>&1
sleep 0.25                                  # let the panel slide away before the capture

# -o: a plain click selects the whole output
GEOM=$(slurp -o -d -b '#07070888' -c '#BABAC6' -s '#00000000' -w 1) || exit 0
grim -g "$GEOM" "$FILE" || { notify-send -a screenshot "Screenshot" "Capture failed"; exit 1; }
wl-copy --type image/png < "$FILE"
notify-send -a screenshot -i "$FILE" "Screenshot" "Saved and copied — ${FILE/#$HOME/\~}"
