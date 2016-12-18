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

__mk5_hostname="${HOSTNAME%%.*}"
__mk5_home="$HOME"

__mk5_set_prompt() {
  # Grab status code first
  local last_status="$?"

  # Status color
  local pchar_color=
  if [ "$last_status" == 0 ]; then
    pchar_color="$__mk5_b_green"
  else
    pchar_color="$__mk5_b_red"
  fi

  # Use $ or # for prompt
  local pchar=
  if [ "$EUID" == 0 ]; then
    pchar="#"
  else
    pchar=">"
  fi

  # Display hostname if ssh'd
  local hostname=
  [ "$SSH_TTY" ] && hostname="$__mk5_cyan$__mk5_hostname$__mk5_b_cyan, "

  # Display job count
  local jobs_info="$(jobs | awk '
  m == 1 { m = 0; }

  m == 0 && /^.{6}S/ { stopped++; m = 1; }
  m == 0 && /^.{6}R/ { running++; m = 1; }

  END {
    if (stopped) printf " \033[31m%%%d\033[0m", stopped;
    if (running) printf " \033[33m&%d\033[0m", running;
  }')"

  [ "$jobs_info" ] && jobs_info="${jobs_info:1}$__mk5_b_yellow, "

  # Git stuff (mostly in bash for speed)
  local mypwd="$PWD"
  local git_info=
  local git_base=
  local git_path="$PWD"
  until [ -d "$git_path/.git" -o "$git_path" == '' ]; do
    git_path="${git_path%/*}"
  done

  if [ "$git_path" ]; then
    # Replace git path
    git_base="$(basename "$git_path")"
    mypwd="$git_base$(perl -pe "s|^$git_path||i" <<< "$mypwd")"

    # Branch
    read git_head < "$git_path/.git/HEAD"
    if [[ "$git_head" == ref:* ]]; then
      git_info="${git_head:16}"  # ref name
    else
      git_info="${git_head::7}"  # short hash
    fi

    # Stashed
    local git_stash="$(wc -l "$git_path/.git/logs/refs/stash" 2>/dev/null |\
      awk '{print$1}')"
    if [ "$git_stash" ]; then
      git_info+=" $__mk5_b_cyan"'\$'"$git_stash"
    fi

    # https://www.reddit.com/r/commandline/comments/5iueei/tiny_awk_script_for_git_prompt/
    git_info+="$(git status --porcelain -b | awk '
    m == 1 { m = 0; }

    /^## / {
      if ($0 ~ /[[ ]ahead /) {
        ahead = $0;
        sub(/.*[[ ]ahead /,  "", ahead);
        sub(/[,\]].*/, "", ahead);
      }
      if ($0 ~ /[[ ]behind /) {
        behind = $0;
        sub(/.*[[ ]behind /, "", behind);
        sub(/[,\]].*/, "", behind);
      }
      m = 1;
    }

    m == 0 && /^\?\?/  { untracked++; m = 1; }
    m == 0 && /^.[^ ]/ { changed++;          }
    m == 0 && /^[^ ]./ { staged++;           }

    END {
      if (untracked) printf " \033[1;31m-%d\033[0m", untracked;
      if (changed  ) printf " \033[1;33m*%d\033[0m", changed  ;
      if (staged   ) printf " \033[1;32m+%d\033[0m", staged   ;
      if (behind   ) printf " \033[1;31mv%d\033[0m", behind   ;
      if (ahead    ) printf " \033[1;34m^%d\033[0m", ahead    ;
    }')"

    git_info="$__mk5_purple$git_info$__mk5_b_purple, "
  fi

  # Colorize
  local suffix=
  local pwd_color="$__mk5_green"

  # Virtualenv = blue
  local virtualenv_info=
  if [ "$VIRTUAL_ENV" ]; then
    local project_filename="$VIRTUAL_ENV/$VIRTUALENVWRAPPER_PROJECT_FILENAME"
    local env_path=
    [ -f "$project_filename" ] && read env_path < "$project_filename"

    if [ ! "$env_path" ]; then
      virtualenv_info="$__mk5_blue${VIRTUAL_ENV##*/}$__mk5_b_blue, "
    else
      [ "$git_path" ] && env_path="$git_base${env_path##$git_path}"
      case "$mypwd" in
        "$env_path"*)
          suffix="${mypwd##$env_path}"
          pwd_color="$__mk5_blue"
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
  mypwd="$pwd_color${mypwd%%$suffix}$__mk5_green$suffix"

  PS1=""                     # Clear PS1
  PS1+="$hostname"           # (Hostname)
  PS1+="$jobs_info"          # (Jobs)
  PS1+="$virtualenv_info"    # (Virtualenv)
  PS1+="$git_info"           # (Git)
  PS1+="$mypwd"              # Abbreviated PWD

  # If only one character, single-line
  local stripped="$(sed 's/\\\[[^]]*\]//g' <<< "$PS1")"
  if [ $(wc -c <<< "$stripped") == 2 ]; then
    PS1="$pchar_color$stripped"
  else
    PS1+="\n"                  # Newline
    PS1+="$pchar_color$pchar"  # Prompt
  fi
  PS1+="$__mk5_normal "      # Clear colors

  PS2=""                     # Clear PS2
  PS2+="$__mk5_yellow$pchar" # Yellow continuation line
  PS2+="$__mk5_normal "      # Clear colors
}

if ! [[ $PROMPT_COMMAND == *"__mk5_set_prompt"*  ]]; then
  export PROMPT_COMMAND="__mk5_set_prompt; $PROMPT_COMMAND"
fi
