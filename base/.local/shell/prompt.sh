# Line colors
__mk5_normal="\[\e[0m\]"
__mk5_red="\[\e[0;31m\]"
__mk5_green="\[\e[0;32m\]"
__mk5_yellow="\[\e[0;33m\]"
__mk5_blue="\[\e[0;34m\]"
__mk5_purple="\[\e[0;35m\]"
__mk5_cyan="\[\e[0;36m\]"
__mk5_white="\[\e[0;37m\]"
__mk5_b_red="\[\e[1;31m\]"
__mk5_b_green="\[\e[1;32m\]"
__mk5_b_yellow="\[\e[1;33m\]"
__mk5_b_blue="\[\e[1;34m\]"
__mk5_b_purple="\[\e[1;35m\]"
__mk5_b_cyan="\[\e[1;36m\]"
__mk5_b_white="\[\e[1;37m\]"

# Special characters
__mk5_char_usr='>'
__mk5_char_root='#'
__mk5_char_unt='-'
__mk5_char_mod='*'
__mk5_char_add='+'
__mk5_char_stash='\$'
__mk5_char_behind='v'
__mk5_char_ahead='^'

__mk5_hostname="${HOSTNAME%%.*}"
__mk5_home="$(readlink -f "$HOME" 2>/dev/null)"

__mk5_set_prompt() {
  # Grab status code first
  local last_status="$?"

  # Status color
  local pcharcolor
  if [ "$last_status" == 0 ]; then
    pcharcolor="$__mk5_b_green"
  else
    pcharcolor="$__mk5_b_red"
  fi

  # Use $ or # for prompt
  local pchar
  if [ "$EUID" == 0 ]; then
    pchar="$__mk5_char_root"
  else
    pchar="$__mk5_char_usr"
  fi

  # Display hostname if ssh'd
  local hostname
  [ "$SSH_TTY" ] && hostname="$__mk5_b_cyan@$__mk5_cyan$__mk5_hostname"

  # Git stuff
  local git_info="$(git symbolic-ref --quiet --short HEAD 2>/dev/null ||\
    git rev-parse --short HEAD 2>/dev/null)"

  if [ "$git_info" ]; then
    local git_st="$(git status --porcelain)"
    local git_rev="$(git rev-list --left-right --count ...@{u} 2>/dev/null)"

    # Untracked
    local git_unt="$(grep '^??' <<< "$git_st" | wc -l)"
    if [ "$git_unt" != 0 ]; then
      git_info+=" $__mk5_b_red$__mk5_char_unt$git_unt"
    fi

    # Modified
    local git_mod="$(grep '^.[^ ?]' <<< "$git_st" | wc -l)"
    if [ "$git_mod" != 0 ]; then
      git_info+=" $__mk5_b_yellow$__mk5_char_mod$git_mod"
    fi

    # Staged
    local git_add="$(grep '^[^ ?].' <<< "$git_st" | wc -l)"
    if [ "$git_add" != 0 ]; then
      git_info+=" $__mk5_b_green$__mk5_char_add$git_add"
    fi

    # Stashed
    local git_stash="$(git stash list | wc -l)"
    if [ "$git_stash" != 0 ]; then
      git_info+=" $__mk5_b_cyan$__mk5_char_stash$git_stash"
    fi

    # Commits behind upstream
    local git_behind="$(awk '{ print $2 }' <<< "$git_rev")"
    if [ "$git_behind" != 0 ]; then
      git_info+=" $__mk5_b_red$__mk5_char_behind$git_behind"
    fi

    # Commits ahead of upstream
    local git_ahead="$(awk '{ print $1 }' <<< "$git_rev")"
    if [ "$git_ahead" != 0 ]; then
      git_info+=" $__mk5_b_blue$__mk5_char_ahead$git_ahead"
    fi

    git_info="$__mk5_purple$git_info$__mk5_b_purple, "
  fi

  # pwd stuff
  local mypwd="$(pwd)"

  # Replace git path
  local gitpath="$(git rev-parse --show-toplevel 2>/dev/null)"
  local gitbase
  if [ "$gitpath" ]; then
    gitbase="$(basename "$gitpath")"
    mypwd="$gitbase$(sed "s|^$gitpath||i" <<< "$(pwd -P)")"
  fi

  # Colorize
  local suffix
  local pwdcolor="$__mk5_green"

  # Virtualenv = blue
  local virtualenv_info
  if [ "$VIRTUAL_ENV" ]; then
    local envpath="$(cat $VIRTUAL_ENV/$VIRTUALENVWRAPPER_PROJECT_FILENAME \
      2>/dev/null)"

    if [ ! "$envpath" ]; then
      virtualenv_info="$__mk5_blue${VIRTUAL_ENV##*/}$__mk5_b_blue, "
    else
      [ "$gitpath" ] && envpath="$gitbase${envpath##$gitpath}"
      case "$mypwd" in
        "$envpath"*)
          suffix="${mypwd##$envpath}"
          pwdcolor="$__mk5_blue"
          ;;
        *)
          virtualenv_info="$__mk5_blue${VIRTUAL_ENV##*/}$__mk5_b_blue, "
          ;;
      esac
    fi
  fi

  # Shorten $HOME
  mypwd="$(echo "$mypwd" | sed "s|^$__mk5_home|~|")"

  # Apply color
  mypwd="$pwdcolor${mypwd%%$suffix}$__mk5_green$suffix"

  PS1=""                   # Clear PS1
  PS1+="$__mk5_blue$USER"  # User
  PS1+="$hostname"         # (Hostname)
  PS1+="$__mk5_b_blue, "   # Separator
  PS1+="$virtualenv_info"  # (Virtualenv)
  PS1+="$git_info"         # (Git)
  PS1+="$mypwd"            # Abbreviated PWD
  PS1+="\n"                # Newline
  PS1+="$pcharcolor$pchar" # Prompt
  PS1+="$__mk5_normal "    # Clear colors

  PS2=""                   # Clear PS2
  PS2+="$__mk5_yellow$pchar" # Blue continuation line
  PS2+="$__mk5_normal "    # Clear colors
}

PROMPT_COMMAND=__mk5_set_prompt
