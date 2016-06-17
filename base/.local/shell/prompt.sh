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
#__mk5_top_connector='┌ '
#__mk5_bot_connector='└ '
__mk5_usr_pchar='>'
__mk5_root_pchar='#'
__mk5_dirty_char='*'
__mk5_incoming_char='v'
__mk5_behindmaster_char='>'
__mk5_outgoing_char='^'

__mk5_hostname="${HOSTNAME%%.*}"
__mk5_home="$(readlink -f "$HOME" 2>/dev/null)"

function __mk5_git_branch {
  echo $(git symbolic-ref HEAD 2>/dev/null || \
         git rev-parse --short HEAD 2>/dev/null) \
       | sed "s|^refs/heads/||"
}

function __mk5_git_dirty {
  echo "$(git status -s --ignore-submodules=dirty 2>/dev/null | wc -l |\
    awk '{print $1}')"
}

function __mk5_git_incoming {
  echo "$(git log ..origin/$(__mk5_git_branch) 2>/dev/null \
    | grep '^commit' | wc -l | awk '{print $1}')"
}

function __mk5_git_behindmaster {
  echo "$(git log ..master 2>/dev/null \
    | grep '^commit' | wc -l | awk '{print $1}')"
}

function __mk5_git_outgoing {
  # Check if branch exists on remote; if so, echo !
  local branch_exists="$(git branch -r 2>/dev/null \
    | grep "^ *origin/$(__mk5_git_branch)\$")"
  if [ ! "$branch_exists" ]; then
    echo '!'

  # Otherwise, compare wih remote branch; echo # commits ahead
  else
    echo "$(git log origin/$(__mk5_git_branch).. 2>/dev/null \
      | grep '^commit' | wc -l | awk '{print $1}')"
  fi
}

function __mk5_set_prompt {
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
    pchar="$__mk5_root_pchar"
  else
    pchar="$__mk5_usr_pchar"
  fi

  # Display hostname if ssh'd
  local hostname
  [ "$SSH_TTY" ] && hostname="$__mk5_b_blue@$__mk5_blue$__mk5_hostname"

  # Git stuff
  local git_info
  local git_branch="$(__mk5_git_branch)"
  if [ "$git_branch" ]; then
    git_info="$git_branch"

    local git_dirty="$(__mk5_git_dirty)"
    if [ "$git_dirty" != 0 ]; then
      git_info="$git_info \
$__mk5_b_yellow$__mk5_dirty_char$git_dirty"
    fi

    git_info="$__mk5_purple$git_info$__mk5_b_purple, "
  fi

  # pwd stuff
  local mypwd="$(pwd -P)"

  # Replace git path
  local gitpath="$(git rev-parse --show-toplevel 2>/dev/null)"
  local gitbase
  if [ "$gitpath" ]; then
    gitbase="$(basename "$gitpath")"
    mypwd="$gitbase${mypwd##$gitpath}"
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

  PS1="\
$__mk5_b_blue$__mk5_top_connector\
$__mk5_cyan$USER$hostname$__mk5_b_cyan in \
$virtualenv_info\
$git_info\
$mypwd\
\n\
$__mk5_b_blue$__mk5_bot_connector\
$pcharcolor$pchar \
$__mk5_normal"
}

PROMPT_COMMAND=__mk5_set_prompt
