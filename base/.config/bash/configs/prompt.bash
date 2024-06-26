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
case $SSH_TTY in
  '') ;;
  *) __mk5_hostname="$__mk5_cyan${HOSTNAME%%.*}$__mk5_b_cyan, ";;
esac

__mk5_map_tool() {
  case "$1" in
    nodejs) echo 'node';;
    *) echo "$1";;
  esac
}

__mk5_set_prompt() {
  # Local variables.
  local \
    last_status="$?" \
    ifs="$IFS" \
    pchar_color="$__mk5_b_red" \
    pchar="$__mk5_pchar" \
    pprefix='' \
    mypwd="$PWD" \
    read_result='' \
    jobs_info='' \
    git_info='' \
    git_path="$PWD" \
    git_stash_path='' \
    git_stash='' \
    asdf_path="$PWD" \
    asdf_info='' \
    venv_info=''

  # Set IFS for prompt use.
  IFS=$'\n'

  # Status color.
  case $last_status in
    0) pchar_color="$__mk5_b_green";;
  esac

  # Display job count.
  jobs_info="$(jobs | awk '
  m == 1 { m = 0; }

  m == 0 && /^.{6}S/ { stopped++; m = 1; }
  m == 0 && /^.{6}R/ { running++; m = 1; }

  END {
    if (stopped) printf " \033[31m%%%d\033[0m", stopped;
    if (running) printf " \033[33m&%d\033[0m", running;
  }')"

  case $jobs_info in
    '') ;;
    *) jobs_info="${jobs_info:1}$__mk5_b_yellow, ";;
  esac

  # Git stuff (mostly in bash for speed).
  until [ -e "$git_path/.git" -o "$git_path" == '' ]; do
    git_path="${git_path%/*}"
  done

  case $git_path in
    '') ;;
    *)
      # Replace git path.
      mypwd="${git_path##*/}${PWD#$git_path}"

      # If it's a file, follow the link.
      [ -f "$git_path/.git" ] && read read_result < "$git_path/.git"
      case $read_result in
        gitdir:*) git_path="${read_result:8}";;
        *)        git_path="$git_path/.git"
      esac

      # Get branch identifier.
      read read_result < "$git_path/HEAD"
      case $read_result in
        ref:*) git_info="${read_result:16}";; # Ref name.
        *)     git_info="${read_result::7}";; # Short hash.
      esac

      # Stash count.
      git_stash_path="$git_path/logs/refs/stash"
      [ -f "$git_stash_path" ] && git_stash=($(<"$git_stash_path"))
      case $git_stash in
        '') ;;
        *) git_info+=" $__mk5_b_cyan"'\$'"${#git_stash[@]}";;
      esac

      # https://www.reddit.com/r/commandline/comments/5iueei/tiny_awk_script_for_git_prompt/
      git_info+="$(git status --porcelain -b | awk '
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
        next;
      }

      /^\?\?/  { untracked++; next; }
      /^.[^ ]/ { changed++; }
      /^[^ ]./ { staged++; }

      END {
        if (untracked) printf " \033[1;31m-%d\033[0m", untracked;
        if (changed  ) printf " \033[1;33m*%d\033[0m", changed  ;
        if (staged   ) printf " \033[1;32m+%d\033[0m", staged   ;
        if (behind   ) printf " \033[1;31mv%d\033[0m", behind   ;
        if (ahead    ) printf " \033[1;34m^%d\033[0m", ahead    ;
      }')"

      git_info="$__mk5_purple$git_info$__mk5_b_purple, "
    ;;
  esac

  # asdf version manager.
  until [ -f "$asdf_path/.tool-versions" -o "$asdf_path" == '' ]; do
    asdf_path="${asdf_path%/*}"
  done
  asdf_path="$asdf_path/.tool-versions"

  if [ -f "$asdf_path" -a "$asdf_path" != "$HOME/.tool-versions" ]; then
    if command -v asdf &> /dev/null; then
      asdf_info=($(
        while IFS=' ' read -r tool version; do
          if command -v "$(__mk5_map_tool "$tool")" &> /dev/null; then
            echo "$tool" "$version"
          fi
        done < "$asdf_path"
      ))
      IFS='|' asdf_info="$__mk5_red${asdf_info[*]:-asdf}$__mk5_b_red, "
    else
      IFS='|' asdf_info="${__mk5_red}asdf${__mk5_b_red}, "
    fi
  fi

  # Python venv.
  if [ "$VIRTUAL_ENV" ]; then
    venv_info="$__mk5_blue${VIRTUAL_ENV##*/}$__mk5_b_blue, "
  fi

  # Shorten $HOME.
  mypwd="$__mk5_green${mypwd/#$HOME/$'~'}"

  PS1="$asdf_info$venv_info$__mk5_hostname$jobs_info$git_info$mypwd"

  # Root user prompt prefix.
  case $EUID in
    0) pprefix="$__mk5_b_red[#] ";;
  esac

  # Use single-line prompt for one character, otherwise two-line.
  local stripped="$(sed 's/\\\[[^]]*\]//g' <<< "$PS1")"
  case ${#stripped} in
    1) PS1="$pprefix$pchar_color$stripped";;
    *) PS1+="\n$pprefix$pchar_color$pchar";;
  esac
  PS1+="$__mk5_normal "

  # Restore IFS.
  IFS="$ifs"
}

case $PROMPT_COMMAND in
  *__mk5_set_prompt*) ;;
  *) export PROMPT_COMMAND="__mk5_set_prompt; $PROMPT_COMMAND";;
esac
