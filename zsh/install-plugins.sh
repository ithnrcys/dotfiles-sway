#!/usr/bin/env bash
# Fetches the zsh plugins .zshrc loads (openSUSE does not package them) into
# ~/.local/share/zsh/plugins. Run once on a new machine; run again to update them.

DIR="${XDG_DATA_HOME:-$HOME/.local/share}/zsh/plugins"
mkdir -p "$DIR"

for repo in zsh-users/zsh-autosuggestions \
            zsh-users/zsh-syntax-highlighting \
            zsh-users/zsh-history-substring-search \
            Aloxaf/fzf-tab; do
    name="${repo#*/}"
    if [ -d "$DIR/$name/.git" ]; then
        echo "updating $name"; git -C "$DIR/$name" pull -q --ff-only
    else
        echo "installing $name"; git clone -q --depth 1 "https://github.com/$repo.git" "$DIR/$name"
    fi
done
