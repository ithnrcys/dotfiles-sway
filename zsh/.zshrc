#fastfetch

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

# completion
autoload -Uz compinit && compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

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
