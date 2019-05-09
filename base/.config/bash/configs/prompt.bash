# Variables.
__mk5_pchar="┄"

# Line colors.
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

# Set PS2 once.
PS2="$__mk5_yellow$__mk5_pchar$__mk5_normal "

# Detect SSH once upon loading prompt.
[ "$SSH_TTY" ] && __mk5_hostname="$__mk5_cyan${HOSTNAME%%.*}$__mk5_b_cyan, "

__mk5_set_prompt() {
  # Local variables.
  local \
    last_status="$?" \
    ifs="$IFS" \
    pchar_color="$__mk5_b_green" \
    pchar="$__mk5_pchar" \
    mypwd="$PWD" \
    jobs_info= \
    git_info= \
    git_path="$PWD" \
    git_head= \
    git_stash_path= \
    git_stash= \
    asdf_path="$PWD" \
    asdf_info=

  # Set IFS for prompt use.
  IFS=$'\n'

  # Status color.
  [ "$last_status" != 0 ] && pchar_color="$__mk5_b_red"

  # Root user prompt character.
  [ "$EUID" == 0 ] && pchar="#"

  # Display job count.
  jobs_info="$(jobs | awk '
  m == 1 { m = 0; }

  m == 0 && /^.{6}S/ { stopped++; m = 1; }
  m == 0 && /^.{6}R/ { running++; m = 1; }

  END {
    if (stopped) printf " \033[31m%%%d\033[0m", stopped;
    if (running) printf " \033[33m&%d\033[0m", running;
  }')"

  [ "$jobs_info" ] && jobs_info="${jobs_info:1}$__mk5_b_yellow, "

  # Git stuff (mostly in bash for speed).
  until [ -d "$git_path/.git" -o "$git_path" == '' ]; do
    git_path="${git_path%/*}"
  done

  if [ "$git_path" ]; then
    # Replace git path.
    mypwd="${git_path##*/}${PWD#$git_path}"

    # Get branch identifier.
    read git_head < "$git_path/.git/HEAD"
    [[ "$git_head" == ref:* ]] &&
      git_info="${git_head:16}" || # Ref name.
      git_info="${git_head::7}"    # Short hash.

    # Stash count.
    git_stash_path="$git_path/.git/logs/refs/stash"
    [ -f "$git_stash_path" ] && git_stash=($(<"$git_stash_path"))
    [ "$git_stash" ] && git_info+=" $__mk5_b_cyan"'\$'"${#git_stash[@]}"

    # https://www.reddit.com/r/commandline/comments/5iueei/tiny_awk_script_for_git_prompt/
    git_info+="$(git status --porcelain -b | awk '
    { m = 0; }

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

  # asdf version manager.
  if [ "$ASDF_BIN" ]; then
    until [ -f "$asdf_path/.tool-versions" -o "$asdf_path" == '' ]; do
      asdf_path="${asdf_path%/*}"
    done
    asdf_path="$asdf_path/.tool-versions"

    if [ -f "$asdf_path" ]; then
      asdf_info=($(<"$asdf_path"))
      IFS='/'
      asdf_info="$__mk5_red${asdf_info[*]}$__mk5_b_red, "
    fi
  fi

  # Shorten $HOME.
  mypwd="$__mk5_green${mypwd/#$HOME/\~}"

  PS1="$asdf_info$__mk5_hostname$jobs_info$git_info$mypwd"

  # Use single-line prompt for one character, otherwise two-line.
  local stripped="$(sed 's/\\\[[^]]*\]//g' <<< "$PS1")"
  [ ${#stripped} == 1 ] &&
    PS1="$pchar_color$stripped" ||
    PS1+="\n$pchar_color$pchar"
  PS1+="$__mk5_normal "

  # Restore IFS.
  IFS="$ifs"
}

[[ $PROMPT_COMMAND == *"__mk5_set_prompt"*  ]] ||
  export PROMPT_COMMAND="__mk5_set_prompt; $PROMPT_COMMAND"
