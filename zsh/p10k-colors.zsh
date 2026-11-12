# Prompt colours, sourced by .zshrc after ~/.p10k.zsh so they win over it.
# Hex values are taken from the terminal theme (Belafonte Night, see ghostty/colors);
# change them here when the theme changes.
typeset -g POWERLEVEL9K_DIR_FOREGROUND='#426a79'                            # blue: directory
typeset -g POWERLEVEL9K_VCS_FOREGROUND='#858162'                            # olive green: git branch
typeset -g POWERLEVEL9K_VCS_CLEAN_FOREGROUND='#858162'
typeset -g POWERLEVEL9K_VCS_MODIFIED_FOREGROUND='#eaa549'                   # amber: uncommitted changes
typeset -g POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND='#eaa549'
typeset -g POWERLEVEL9K_VCS_{INCOMING,OUTGOING}_CHANGESFORMAT_FOREGROUND='#989a9c'   # grey: ahead / behind
typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_{VIINS,VICMD,VIVIS}_FOREGROUND='#97522c'      # rust: last command ok
typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_{VIINS,VICMD,VIVIS}_FOREGROUND='#be100e'   # red: last command failed
typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FOREGROUND='#eaa549'         # amber: how long it took
typeset -g POWERLEVEL9K_TIME_FOREGROUND='#5e5252'                           # dim: clock

# A thin dim rule across the terminal above every prompt, separating one command's output
# from the next. It takes the place of the empty line p10k otherwise adds.
typeset -g POWERLEVEL9K_SHOW_RULER=true
typeset -g POWERLEVEL9K_RULER_CHAR='─'
typeset -g POWERLEVEL9K_RULER_FOREGROUND='#5e5252'
typeset -g POWERLEVEL9K_PROMPT_ADD_NEWLINE=false
