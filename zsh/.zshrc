# system summary at the top of every new terminal — has to run before the p10k instant
# prompt below, which does not allow output once it has started.
# It is only shown while the window is big enough to hold it: if a fresh terminal (nothing
# run yet) is resized too small, the screen is cleared instead of leaving a re-wrapped,
# broken logo, and the summary comes back when the window is big enough again. After the
# first command it is ordinary scrollback and is left alone.
if [[ -o interactive ]] && (( $+commands[fastfetch] )); then
  _ff_out=$(fastfetch --pipe false)
  () {  # size of the summary: widest line (escape codes do not count) and number of lines
    emulate -L zsh; setopt extendedglob
    local line; local -a match mbegin mend
    typeset -gi _ff_cols=0 _ff_rows=0
    for line in "${(@f)_ff_out}"; do
      local -i pad=0
      # "ESC[<n>G" jumps to column n: whatever is before it only counts up to there
      if [[ $line == (#b)*$'\e['(<->)G(*) ]]; then pad=$(( match[1] - 1 )); line=$match[2]; fi
      line=${line//$'\e'\[[0-9;]#[a-zA-Z]/}
      (( pad + ${(m)#line} > _ff_cols )) && _ff_cols=$(( pad + ${(m)#line} ))
      (( ++_ff_rows ))
    done
  }
  # room for the summary, the empty line under it and the two-line prompt
  _ff_fits() { (( COLUMNS >= _ff_cols && LINES >= _ff_rows + 3 )) }
  # the empty line after it keeps the first prompt off the logo
  _ff_fits && { print -r -- $_ff_out; print; typeset -gi _ff_shown=1 } || typeset -gi _ff_shown=0

  TRAPWINCH() {
    _ff_fits; local -i fits=$(( ! $? ))
    (( fits == _ff_shown )) && return
    _ff_shown=$fits
    zle && zle -I                       # the prompt is redrawn after this output
    print -n -- '\e[H\e[2J\e[3J'        # clear the screen and the scrollback
    (( fits )) && print -r -- $_ff_out   # no empty line here: the redrawn prompt brings its own
    return 0
  }
  # once a command has run the summary is history: stop watching the window size
  _ff_done() { unfunction TRAPWINCH 2>/dev/null; add-zsh-hook -d preexec _ff_done; unset _ff_out }
  autoload -Uz add-zsh-hook && add-zsh-hook preexec _ff_done
fi

# p10k instant prompt — must stay at the top
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# history
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
setopt SHARE_HISTORY HIST_IGNORE_ALL_DUPS HIST_IGNORE_SPACE
setopt INC_APPEND_HISTORY EXTENDED_HISTORY

setopt AUTO_CD               # a directory name on its own is a cd
setopt INTERACTIVE_COMMENTS  # allow # comments at the prompt

# colours for tools that follow the terminal palette (ghostty/colors)
export BAT_THEME=ansi
export FZF_DEFAULT_OPTS="--height 40% --layout reverse --border rounded --info inline \
  --color fg:7,bg:-1,hl:4,fg+:15,bg+:0,hl+:12,info:8,prompt:5,pointer:5,marker:2,spinner:6,header:8,border:8"

# completion
autoload -Uz compinit && compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'                    # case-insensitive
zstyle ':completion:*' list-colors 'di=34' 'ln=36' 'ex=32' 'ma=30;44'       # coloured file lists
zstyle ':completion:*:descriptions' format '%F{5}── %d ──%f'                 # group headings
zstyle ':completion:*' group-name ''

bindkey -e

# editor: nvim for anything that asks for one (git commit, sudoedit, crontab -e, less v ...)
export EDITOR=nvim VISUAL=nvim

# aliases
alias ls='eza --icons --group-directories-first'
alias ll='eza -l --icons --git'
alias la='eza -la --icons --git'
alias tree='eza --tree --icons'
alias cat='bat -p'
alias v='nvim'
alias g='git'

# tools
eval "$(zoxide init zsh)"
source <(fzf --zsh)

# plugins — fetched by zsh/install-plugins.sh into ~/.local/share/zsh/plugins; each one is
# skipped quietly if it is not there. The order matters: fzf-tab right after compinit,
# syntax highlighting after everything that adds widgets, history search last.
ZPLUGINS="${XDG_DATA_HOME:-$HOME/.local/share}/zsh/plugins"

# fzf-tab: Tab opens the completions in an fzf popup (type to filter, Tab/arrows to move)
if [[ -r $ZPLUGINS/fzf-tab/fzf-tab.plugin.zsh ]]; then
  source $ZPLUGINS/fzf-tab/fzf-tab.plugin.zsh
  zstyle ':completion:*' menu no                       # fzf-tab draws the menu itself
  zstyle ':fzf-tab:*' use-fzf-default-opts yes
  zstyle ':fzf-tab:*' switch-group '<' '>'
  zstyle ':fzf-tab:complete:(cd|z|ls|eza):*' fzf-preview 'eza -1 --icons --color=always $realpath'
fi

# autosuggestions: grey ghost text from history, then from completion; Right arrow / End accepts
if [[ -r $ZPLUGINS/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
  ZSH_AUTOSUGGEST_STRATEGY=(history completion)
  ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'
  source $ZPLUGINS/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

# syntax highlighting: commands, strings, paths and mistakes coloured as you type
if [[ -r $ZPLUGINS/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
  ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)
  source $ZPLUGINS/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

# history search: Up / Down walk through history entries containing what is already typed
if [[ -r $ZPLUGINS/zsh-history-substring-search/zsh-history-substring-search.zsh ]]; then
  source $ZPLUGINS/zsh-history-substring-search/zsh-history-substring-search.zsh
  bindkey '^[[A' history-substring-search-up   '^[OA' history-substring-search-up
  bindkey '^[[B' history-substring-search-down '^[OB' history-substring-search-down
  HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND='fg=0,bg=4'
  HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_NOT_FOUND='fg=0,bg=1'
fi

# ssh agent — one per login, no prompt at shell start
export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"
ssh-add -l >/dev/null 2>&1
if [ $? -eq 2 ]; then
  rm -f "$SSH_AUTH_SOCK"
  eval "$(ssh-agent -t 12h -a "$SSH_AUTH_SOCK")" >/dev/null
fi

# prompt
source ~/.dotfiles/p10k/powerlevel10k.zsh-theme
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh
[[ -f ~/.dotfiles/zsh/p10k-colors.zsh ]] && source ~/.dotfiles/zsh/p10k-colors.zsh

# graphical password prompts (zenity) for sudo -A and for ssh key passphrases when there is no terminal
export SUDO_ASKPASS="$HOME/.local/bin/zenity-askpass"
export SSH_ASKPASS="$HOME/.local/bin/zenity-askpass"
