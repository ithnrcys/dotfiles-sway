# Prompt colours, sourced by .zshrc after ~/.p10k.zsh so they win over it.
# Hex values match the terminal palette in ghostty/colors.
typeset -g POWERLEVEL9K_DIR_FOREGROUND='#8FA8C8'                            # blue: directory
typeset -g POWERLEVEL9K_VCS_FOREGROUND='#9DBF8E'                            # green: git branch
typeset -g POWERLEVEL9K_VCS_CLEAN_FOREGROUND='#9DBF8E'
typeset -g POWERLEVEL9K_VCS_MODIFIED_FOREGROUND='#D9C58A'                   # yellow: uncommitted changes
typeset -g POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND='#D9C58A'
typeset -g POWERLEVEL9K_VCS_{INCOMING,OUTGOING}_CHANGESFORMAT_FOREGROUND='#8EC4C4'   # cyan: ahead / behind
typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_{VIINS,VICMD,VIVIS}_FOREGROUND='#B4A0D0'      # magenta: last command ok
typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_{VIINS,VICMD,VIVIS}_FOREGROUND='#D98C8C'   # red: last command failed
typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FOREGROUND='#D9C58A'         # yellow: how long it took
typeset -g POWERLEVEL9K_TIME_FOREGROUND='#5C5C68'                           # dim: clock
