#!/usr/bin/env bash
# GTK and Qt theming in the waybar palette. Run once on a new machine; run again to refresh.
# Needs (sudo zypper install): kvantum-qt5 kvantum-qt6 qt5ct qt6ct papirus-icon-theme
#
#   GTK 3        adw-gtk3-dark (downloaded here) + theme/gtk.css
#   GTK 4        libadwaita / adw-gtk3-dark      + theme/gtk4.css (imports gtk.css)
#   Qt 5, Qt 6   Kvantum theme "Mizu" (kvantum/), chosen through qt5ct / qt6ct; QT_QPA_PLATFORMTHEME in environment.d/qt.conf
#   KDE programs theme/Mizu.colors, copied into ~/.config/kdeglobals (view backgrounds, icon colours)
#   icons        Papirus-Mizu = Papirus-Dark with grey folders (built here, in ~/.local/share/icons)
#   fonts        SF Pro Text for interfaces, JetBrainsMono Nerd Font for code

REPO="$(cd "${0%/*}/.." && pwd)"
DATA="${XDG_DATA_HOME:-$HOME/.local/share}"
CONF="${XDG_CONFIG_HOME:-$HOME/.config}"
ADW_GTK3="v6.5"

# link $1 (in the repo) to $2; a real file already there is kept as $2.bak
link() {
    mkdir -p "${2%/*}"
    [ -e "$2" ] && [ ! -L "$2" ] && mv "$2" "$2.bak"
    ln -sfn "$REPO/$1" "$2"
}

# --- adw-gtk3: the GTK 3 theme that looks like libadwaita and takes the same colour names
if [ ! -d "$DATA/themes/adw-gtk3-dark" ] || [ "$1" = --update ]; then
    echo "installing adw-gtk3 $ADW_GTK3"
    mkdir -p "$DATA/themes"
    curl -fsSL "https://github.com/lassekongo83/adw-gtk3/releases/download/$ADW_GTK3/adw-gtk3$ADW_GTK3.tar.xz" \
        | tar -xJ -C "$DATA/themes" || { echo "adw-gtk3 download failed" >&2; exit 1; }
fi

# --- Papirus-Mizu: inherits Papirus-Dark, with every folder icon pointed at its grey variant
SRC=/usr/share/icons/Papirus-Dark
if [ -d "$SRC" ]; then
    DST="$DATA/icons/Papirus-Mizu"
    rm -rf "$DST"; mkdir -p "$DST"
    dirs=()
    for places in "$SRC"/*/places; do
        size="${places%/places}"; size="${size##*/}"
        [[ "$size" == *@* ]] && continue
        ls "$places" | grep -q -- '-grey' || continue
        mkdir -p "$DST/$size/places"
        for icon in "$places"/folder-blue*.svg "$places"/user-blue*.svg; do
            [ -e "$icon" ] || continue
            name="${icon##*/}"
            grey="$places/${name/-blue/-grey}"
            [ -e "$grey" ] && ln -s "$(readlink -f "$grey")" "$DST/$size/places/${name/-blue/}"
        done
        # file managers ask for the folder by its mime-type name (Dolphin's file view), not "folder"
        [ -e "$DST/$size/places/folder.svg" ] && ln -s folder.svg "$DST/$size/places/inode-directory.svg"
        dirs+=("$size/places")
    done
    {
        printf '[Icon Theme]\nName=Papirus-Mizu\nComment=Papirus-Dark with grey folders\nInherits=Papirus-Dark,hicolor\n'
        printf 'Directories=%s\n' "$(IFS=,; echo "${dirs[*]}")"
        for d in "${dirs[@]}"; do
            printf '\n[%s]\nContext=Places\nSize=%s\nType=Fixed\n' "$d" "${d%%x*}"
        done
    } > "$DST/index.theme"
    ICONS=Papirus-Mizu
else
    echo "papirus-icon-theme is not installed — keeping Adwaita icons" >&2
    ICONS=Adwaita
fi

# --- config links
link theme/gtk.css       "$CONF/gtk-3.0/gtk.css"
link theme/settings.ini  "$CONF/gtk-3.0/settings.ini"
link theme/gtk4.css      "$CONF/gtk-4.0/gtk.css"
link theme/gtk.css       "$CONF/gtk-4.0/gtk-shared.css"
link theme/settings.ini  "$CONF/gtk-4.0/settings.ini"
link kvantum             "$CONF/Kvantum"
link qt5ct/qt5ct.conf    "$CONF/qt5ct/qt5ct.conf"
link qt6ct/qt6ct.conf    "$CONF/qt6ct/qt6ct.conf"
link environment.d/qt.conf "$CONF/environment.d/qt.conf"
link theme/Mizu.colors   "$DATA/color-schemes/Mizu.colors"

# --- KDE programs (Gwenview, Konsole, KDE Connect) read their colours from kdeglobals, not from the Qt style:
#     drop any colour groups already in it and append the ones from Mizu.colors; other settings in the file are kept
KG="$CONF/kdeglobals"
touch "$KG"
awk '/^\[/ { skip = ($0 ~ /^\[(Colors:|ColorEffects:|WM\])/) } !skip' "$KG" > "$KG.new"
awk '/^\[/ { keep = ($0 ~ /^\[(Colors:|ColorEffects:|WM\])/) } keep' "$REPO/theme/Mizu.colors" >> "$KG.new"
mv "$KG.new" "$KG"
if command -v kwriteconfig6 >/dev/null; then
    kwriteconfig6 --file kdeglobals --group General --key ColorScheme Mizu
    kwriteconfig6 --file kdeglobals --group Icons   --key Theme "$ICONS"
    # KDE derives its "mid" grey (Gwenview's location bar) from the window colour; the default contrast of 7 gives #6B6B72 on black, 0 gives #202024
    kwriteconfig6 --file kdeglobals --group KDE     --key contrast 0
fi

# --- what GTK programs read on Wayland
g() { gsettings set org.gnome.desktop.interface "$@"; }
g gtk-theme           adw-gtk3-dark
g color-scheme        prefer-dark
g icon-theme          "$ICONS"
g font-name           'SF Pro Text 11'
g document-font-name  'SF Pro Text 11'
g monospace-font-name 'JetBrainsMono Nerd Font 11'

# --- flatpak programs may read the theme files (they are links into this repo, so it is shared too)
if command -v flatpak >/dev/null; then
    flatpak override --user \
        --filesystem=xdg-config/gtk-3.0:ro --filesystem=xdg-config/gtk-4.0:ro \
        --filesystem=xdg-data/themes:ro --filesystem=xdg-data/icons:ro \
        --filesystem="$REPO/theme:ro"
fi

echo "done — already running programs pick up colours on restart; Qt programs after the next login"
