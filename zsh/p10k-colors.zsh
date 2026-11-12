# Prompt look, sourced by .zshrc after ~/.p10k.zsh so everything here wins over it.
# Style: powerline blocks — coloured background segments with slanted separators.
#   left:   folder | git branch with counts          right:  status | duration | clock
#   second line: just the prompt character
# Colours are taken from the terminal theme (Belafonte Night, see ghostty/colors);
# change the hex values here when the theme changes.

() {
  emulate -L zsh
  local bg_dark='#20111b' light='#d5ccba' blue='#426a79' olive='#858162' amber='#eaa549'
  local rust='#97522c' red='#be100e' dim='#5e5252' plum='#45373c'

  typeset -g POWERLEVEL9K_MODE=nerdfont-v3
  typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir vcs newline prompt_char)
  typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status command_execution_time virtualenv context time newline)

  # --- block shapes ---
  unset POWERLEVEL9K_VISUAL_IDENTIFIER_EXPANSION                       # segment icons back on
  typeset -g POWERLEVEL9K_{LEFT,RIGHT}_{LEFT,RIGHT}_WHITESPACE=' '      # padding inside a block
  typeset -g POWERLEVEL9K_LEFT_SEGMENT_SEPARATOR=''               # slanted joins
  typeset -g POWERLEVEL9K_RIGHT_SEGMENT_SEPARATOR=''
  typeset -g POWERLEVEL9K_LEFT_SUBSEGMENT_SEPARATOR=''
  typeset -g POWERLEVEL9K_RIGHT_SUBSEGMENT_SEPARATOR=''
  typeset -g POWERLEVEL9K_LEFT_PROMPT_LAST_SEGMENT_END_SYMBOL=''
  typeset -g POWERLEVEL9K_RIGHT_PROMPT_FIRST_SEGMENT_START_SYMBOL=''
  typeset -g POWERLEVEL9K_PROMPT_ADD_NEWLINE=true                       # empty line between commands
  typeset -g POWERLEVEL9K_SHOW_RULER=false

  # --- prompt character: no block around it ---
  typeset -g POWERLEVEL9K_PROMPT_CHAR_BACKGROUND=
  typeset -g POWERLEVEL9K_PROMPT_CHAR_LEFT_{LEFT,RIGHT}_WHITESPACE=
  typeset -g POWERLEVEL9K_PROMPT_CHAR_LEFT_PROMPT_LAST_SEGMENT_END_SYMBOL=
  typeset -g POWERLEVEL9K_PROMPT_CHAR_LEFT_PROMPT_FIRST_SEGMENT_START_SYMBOL=
  typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_{VIINS,VICMD,VIVIS}_FOREGROUND=$rust
  typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_{VIINS,VICMD,VIVIS}_FOREGROUND=$red

  # --- folder: blue block ---
  typeset -g POWERLEVEL9K_DIR_BACKGROUND=$blue
  typeset -g POWERLEVEL9K_DIR_FOREGROUND=$light

  # --- git: olive when clean, amber when there are changes ---
  typeset -g POWERLEVEL9K_VCS_BRANCH_ICON=' '
  typeset -g POWERLEVEL9K_VCS_VISUAL_IDENTIFIER_EXPANSION=              # branch icon only, no second git icon
  typeset -g POWERLEVEL9K_VCS_{CLEAN,LOADING}_BACKGROUND=$olive
  typeset -g POWERLEVEL9K_VCS_{MODIFIED,UNTRACKED,CONFLICTED}_BACKGROUND=$amber
  typeset -g POWERLEVEL9K_VCS_{CLEAN,LOADING,MODIFIED,UNTRACKED,CONFLICTED}_FOREGROUND=$bg_dark
  typeset -g POWERLEVEL9K_VCS_FOREGROUND=$bg_dark
  # branch, then counts:  ⇣ behind  ⇡ ahead  + staged  ! modified  ? untracked
  function my_git_formatter() {
    emulate -L zsh
    if [[ -n $P9K_CONTENT ]]; then typeset -g my_git_format=$P9K_CONTENT; return; fi
    local res="${POWERLEVEL9K_VCS_BRANCH_ICON}${${VCS_STATUS_LOCAL_BRANCH:-@${VCS_STATUS_COMMIT[1,8]}}//\%/%%}"
    (( VCS_STATUS_COMMITS_BEHIND )) && res+=" ⇣${VCS_STATUS_COMMITS_BEHIND}"
    (( VCS_STATUS_COMMITS_AHEAD ))  && res+=" ⇡${VCS_STATUS_COMMITS_AHEAD}"
    (( VCS_STATUS_NUM_STAGED ))     && res+=" +${VCS_STATUS_NUM_STAGED}"
    (( VCS_STATUS_NUM_UNSTAGED ))   && res+=" !${VCS_STATUS_NUM_UNSTAGED}"
    (( VCS_STATUS_NUM_UNTRACKED ))  && res+=" ?${VCS_STATUS_NUM_UNTRACKED}"
    typeset -g my_git_format=$res
  }
  functions -M my_git_formatter 2>/dev/null
  typeset -g POWERLEVEL9K_VCS_DISABLE_GITSTATUS_FORMATTING=true
  typeset -g POWERLEVEL9K_VCS_CONTENT_EXPANSION='${$((my_git_formatter(1)))+${my_git_format}}'
  typeset -g POWERLEVEL9K_VCS_LOADING_CONTENT_EXPANSION='${$((my_git_formatter(0)))+${my_git_format}}'
  typeset -g POWERLEVEL9K_VCS_{STAGED,UNSTAGED,UNTRACKED,COMMITS_AHEAD,COMMITS_BEHIND}_MAX_NUM=-1
  typeset -g POWERLEVEL9K_VCS_MAX_SYNC_LATENCY_SECONDS=0.05

  # --- status: ✔ on plum, ✘ and exit code on red ---
  typeset -g POWERLEVEL9K_STATUS_EXTENDED_STATES=false
  typeset -g POWERLEVEL9K_STATUS_OK=true
  typeset -g POWERLEVEL9K_STATUS_OK_VISUAL_IDENTIFIER_EXPANSION='✔'
  typeset -g POWERLEVEL9K_STATUS_OK_FOREGROUND=$olive
  typeset -g POWERLEVEL9K_STATUS_OK_BACKGROUND=$plum
  typeset -g POWERLEVEL9K_STATUS_ERROR=true
  typeset -g POWERLEVEL9K_STATUS_ERROR_VISUAL_IDENTIFIER_EXPANSION='✘'
  typeset -g POWERLEVEL9K_STATUS_ERROR_FOREGROUND=$light
  typeset -g POWERLEVEL9K_STATUS_ERROR_BACKGROUND=$red

  # --- duration (commands over 5 s): rust; clock: dim ---
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FOREGROUND=$light
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_BACKGROUND=$rust
  typeset -g POWERLEVEL9K_TIME_FOREGROUND=$light
  typeset -g POWERLEVEL9K_TIME_BACKGROUND=$dim
  typeset -g POWERLEVEL9K_VIRTUALENV_FOREGROUND=$bg_dark
  typeset -g POWERLEVEL9K_VIRTUALENV_BACKGROUND=$olive
  typeset -g POWERLEVEL9K_CONTEXT_BACKGROUND=$plum
}
