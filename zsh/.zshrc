# system summary at the top of every new terminal — has to run before the p10k instant
# prompt below, which does not allow output once it has started
[[ -o interactive ]] && command -v fastfetch >/dev/null && fastfetch

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
source /usr/share/zsh/site-functions/zsh-autosuggestions.zsh 2>/dev/null
source /usr/share/zsh/site-functions/zsh-syntax-highlighting.zsh 2>/dev/null

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
