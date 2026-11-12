#!/usr/bin/env bash
# Workspaces for the top bar: every window is drawn as its app icon, grouped per workspace,
# with the focused workspace in [brackets] at the visual centre and the others dimmed.
# An empty workspace shows its number instead.
#
# Icons come from sketchybar-app-font (fonts/sketchybar-app-font.ttf): the text ":firefox:"
# set in that font renders as one glyph. app-icons.txt lists the names the font knows.

FONT="sketchybar-app-font"
ICON_SIZE="13pt"
ICON_CELLS=3          # advance of one icon measured in bar-font characters, for centring
ICON_RISE="-1500"     # pango units: nudges the icons down onto the text centre line
DIM="#7C7C84"
GAP="     "           # between workspaces

declare -A KNOWN
while read -r name; do KNOWN[$name]=1; done < "${0%/*}/app-icons.txt"

# app_id / X11 class -> icon name
icon_for() {
    local id="${1,,}" part
    case "$id" in
        steam*)                              echo steam; return ;;
        code|code-oss|code-url-handler|vscodium|codium) echo code; return ;;
        google-chrome*|chromium*)            echo google_chrome; return ;;
        zen|zen-*|app.zen_browser.zen)       echo zen_browser; return ;;
        org.telegram.desktop)                echo telegram; return ;;
        thunar|org.gnome.nautilus|nemo|pcmanfm|org.kde.dolphin) echo finder; return ;;
        foot|kitty|alacritty|org.wezfurlong.wezterm) echo terminal; return ;;
    esac
    # whole id, then each dot-separated part from the right: org.mozilla.firefox -> firefox
    part="${id//[^a-z0-9.]/_}"
    [ -n "${KNOWN[$part]}" ] && { echo "$part"; return; }
    while [[ "$part" == *.* ]]; do
        [ -n "${KNOWN[${part##*.}]}" ] && { echo "${part##*.}"; return; }
        part="${part%.*}"
    done
    [ -n "${KNOWN[$part]}" ] && { echo "$part"; return; }
    echo default
}

print_ws() {
    local focused name apps app text cells icons
    local left="" right="" centre="" lcells=0 rcells=0 seen=0
    focused=$(swaymsg -t get_workspaces | jq -r '.[] | select(.focused) | .name')

    while IFS=$'\t' read -r name apps; do
        text="" cells=0
        for app in $apps; do
            [ -n "$text" ] && { text+=" "; cells=$(( cells + 1 )); }
            text+=":$(icon_for "$app"):"
            cells=$(( cells + ICON_CELLS ))
        done
        if [ -n "$text" ]; then
            text="<span font_family='$FONT' size='$ICON_SIZE' rise='$ICON_RISE'>$text</span>"; icons=1
        else
            text="$name"; cells=${#name}; icons=0
        fi

        if [ "$name" = "$focused" ]; then
            # the glyphs carry their own space on the right, so no space before the closing bracket
            if (( icons )); then centre="[ $text]"; else centre="[ $text ]"; fi
            seen=1
        elif (( seen )); then
            right+="$GAP<span color='$DIM'>$text</span>"; rcells=$(( rcells + ${#GAP} + cells ))
        else
            left+="<span color='$DIM'>$text</span>$GAP";  lcells=$(( lcells + ${#GAP} + cells ))
        fi
    done < <(swaymsg -t get_tree | jq -r '
        [.. | objects | select(.type == "workspace" and .name != "__i3_scratch")] | sort_by(.num) | .[] |
        "\(.name)\t\([.. | objects | select(.pid != null) | (.app_id // .window_properties.class // "unknown")] | join(" "))"')

    # pad the shorter side so [focused] sits at the visual centre
    while (( lcells < rcells )); do left=" $left";   lcells=$(( lcells + 1 )); done
    while (( rcells < lcells )); do right="$right "; rcells=$(( rcells + 1 )); done
    echo "$left$centre$right"
}

print_ws
# window title changes fire constantly and never change the icons: skip them
swaymsg -t subscribe -m '["workspace","window"]' | jq --unbuffered -r '.change' |
    while read -r change; do [ "$change" = "title" ] || print_ws; done
