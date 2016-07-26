#!/usr/bin/env bash

# Line colors
__mk5_normal="\[\e[0m\]"
__mk5_black="\[\e[0;30m\]"
__mk5_red="\[\e[0;31m\]"
__mk5_green="\[\e[0;32m\]"
__mk5_yellow="\[\e[0;33m\]"
__mk5_blue="\[\e[0;34m\]"
__mk5_purple="\[\e[0;35m\]"
__mk5_cyan="\[\e[0;36m\]"
__mk5_white="\[\e[0;37m\]"
__mk5_b_black="\[\e[1;30m\]"
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
__mk5_char_no_up='!'

__mk5_hostname="${HOSTNAME%%.*}"
__mk5_home="$(readlink -f "$HOME" 2>/dev/null || echo "$HOME")"

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

  # Git stuff (mostly in bash for speed)
  local git_info
  local git_path="$PWD"
  until [ -d "$git_path/.git" -o "$git_path" == '' ]; do
    git_path="${git_path%/*}"
  done

  if [ "$git_path" ]; then
    git_info="$(cat "$git_path/.git/HEAD")"

    if [[ "$git_info" == ref:* ]]; then
      git_info="${git_info##*/}" # ref name
    else
      git_info="${git_info::7}"  # short hash
    fi

    local git_st="$(git status --porcelain)"
    local git_rev="$(git rev-list --left-right --count ...@{u} 2>/dev/null)"

    # Branch name
    git_info="$__mk5_purple$git_info"

    # Untracked
    local git_unt="$(grep '^??' <<< "$git_st" | wc -l | awk '{print$1}')"
    if [ "$git_unt" != 0 ]; then
      git_info+=" $__mk5_b_red$__mk5_char_unt$git_unt"
    fi

    # Modified
    local git_mod="$(grep '^.[^ ?]' <<< "$git_st" | wc -l | awk '{print$1}')"
    if [ "$git_mod" != 0 ]; then
      git_info+=" $__mk5_b_yellow$__mk5_char_mod$git_mod"
    fi

    # Staged
    local git_add="$(grep '^[^ ?].' <<< "$git_st" | wc -l | awk '{print$1}')"
    if [ "$git_add" != 0 ]; then
      git_info+=" $__mk5_b_green$__mk5_char_add$git_add"
    fi

    # Stashed
    local git_stash="$(wc -l "$git_path/.git/logs/refs/stash" 2>/dev/null |\
      awk '{print$1}')"
    if [ "$git_stash" ]; then
      git_info+=" $__mk5_b_cyan$__mk5_char_stash$git_stash"
    fi

    # Upstream?
    if [ "$git_rev" ]; then
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
    else
      # Mark the branch
      git_info="$__mk5_b_black$__mk5_char_no_up$git_info"
    fi

    git_info+="$__mk5_b_purple, "
  fi

  # Replace git path
  local mypwd
  local gitbase
  if [ "$git_path" ]; then
    gitbase="$(basename "$git_path")"
    mypwd="$gitbase$(perl -pe "s|^$git_path||i" <<< "$(pwd -P)")"
  else
    mypwd="$PWD"
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
      [ "$git_path" ] && envpath="$gitbase${envpath##$git_path}"
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
  mypwd="$(perl -pe "s|^$__mk5_home|~|" <<< "$mypwd")"

  # Apply color
  mypwd="$pwdcolor${mypwd%%$suffix}$__mk5_green$suffix"

  PS1=""                     # Clear PS1
  PS1+="$__mk5_blue$USER"    # User
  PS1+="$hostname"           # (Hostname)
  PS1+="$__mk5_b_blue, "     # Separator
  PS1+="$virtualenv_info"    # (Virtualenv)
  PS1+="$git_info"           # (Git)
  PS1+="$mypwd"              # Abbreviated PWD
  PS1+="\n"                  # Newline
  PS1+="$pcharcolor$pchar"   # Prompt
  PS1+="$__mk5_normal "      # Clear colors

  PS2=""                     # Clear PS2
  PS2+="$__mk5_yellow$pchar" # Blue continuation line
  PS2+="$__mk5_normal "      # Clear colors
}

if ! [[ $PROMPT_COMMAND == *"__mk5_set_prompt"*  ]]; then
  export PROMPT_COMMAND="__mk5_set_prompt; $PROMPT_COMMAND"
fi
