#!/usr/bin/env bash
# Notepad for the quick access panel: a rofi dropdown listing the notes in ~/Documents/notes,
# newest first. Pick one to open it, or type a name that is not in the list and press Enter
# to start a new note (".md" is added when the name has no extension).
# The note opens in nvim in a floating Ghostty window (app_id quick.notepad, see sway/config).

DIR="$HOME/Documents/notes"
NEW="󰎔  new note"
mkdir -p "$DIR"

open_note() {
    exec ghostty --class=quick.notepad --title="notes" \
        --working-directory="$DIR" -e nvim "$1"
}

swaync-client -cp >/dev/null 2>&1

# newest first; names only
mapfile -t NOTES < <(cd "$DIR" && ls -t -- * 2>/dev/null)

MENU_CONTENT="$NEW"
for n in "${NOTES[@]}"; do MENU_CONTENT+="\n󰈙  $n"; done

# the dropdown theme hides the input bar; this one needs it for typing a new name
ROFI_ARGS=(-p "note" -theme-str 'mainbox { children: [ inputbar, listview ]; }'
           -theme-str 'inputbar { children: [ prompt, entry ]; padding: 6px 10px; }'
           -theme-str 'entry { placeholder: "type a name for a new note"; }')
ROFI_LINES=10
source ~/.config/waybar/scripts/_rofi_engine.sh
[ "$ROFI_EXIT" -ne 0 ] || [ -z "$ROFI_CHOICE" ] && exit 0

case "$ROFI_CHOICE" in
    "$NEW")
        open_note "$DIR/$(date +%Y-%m-%d_%H%M).md" ;;
    "󰈙  "*)
        open_note "$DIR/${ROFI_CHOICE#󰈙  }" ;;
    *)
        name="${ROFI_CHOICE//\//-}"                    # typed name: no folders
        [[ "$name" == *.* ]] || name+=".md"
        open_note "$DIR/$name" ;;
esac
