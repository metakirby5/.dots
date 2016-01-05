__mk5_normal="\[\e[0m\]"

# Line colors
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

__mk5_hostname=${HOSTNAME%%.*}
__mk5_home="$(readlink "$HOME")"

function __mk5_git_pwd {
  # Get git path
  local thePWD=$(pwd -P)
  local gitpath="$(git rev-parse --show-toplevel 2>/dev/null)"

  if [[ "$gitpath" ]]; then
    # Strip git path
    echo "${gitpath##*/}${thePWD##$gitpath}"
  else
    # Replace home with ~
    pwd | sed "s|^$__mk5_home|~|"
  fi
}

function __mk5_git_branch {
  echo $(git symbolic-ref HEAD 2>/dev/null || \
         git rev-parse --short HEAD 2>/dev/null) \
       | sed "s|^refs/heads/||"
}

function __mk5_git_dirty {
  echo "$(git status -s --ignore-submodules=dirty 2>/dev/null | wc -l | awk '{print $1}')"
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
  local branch_exists=$(git branch -r 2>/dev/null \
    | grep "^\s*origin/$(__mk5_git_branch)\$")
  if [[ ! $branch_exists ]]; then
    echo '!'

  # Otherwise, compare wih remote branch; echo # commits ahead
  else
    echo "$(git log origin/$(__mk5_git_branch).. 2>/dev/null \
      | grep '^commit' | wc -l | awk '{print $1}')"
  fi
}

function __mk5_set_prompt {
  # Grab status code first
  local last_status=$?

  # Status color
  local pcharcolor
  if [[ $last_status == 0 ]]; then
    pcharcolor="$__mk5_b_green"
  else
    pcharcolor="$__mk5_b_red"
  fi

  # Use $ or # for prompt
  local pchar
  if [[ $EUID -eq 0 ]]; then
    pchar="$__mk5_root_pchar"
  else
    pchar="$__mk5_usr_pchar"
  fi

  # Git stuff
  local git_info
  local git_branch=$(__mk5_git_branch)
  if [[ "$git_branch" ]]; then
    git_info=$git_branch

    local git_dirty=$(__mk5_git_dirty)
    if [[ "$git_dirty" != 0 ]]; then
      git_info="$git_info \
$__mk5_b_yellow$__mk5_dirty_char$git_dirty"
    fi

    local git_incoming=$(__mk5_git_incoming)
    if [[ "$git_incoming" != 0 ]]; then
      git_info="$git_info \
$__mk5_b_red$__mk5_incoming_char$git_incoming"
    fi

    local git_behindmaster=$(__mk5_git_behindmaster)
    if [[ "$git_behindmaster" != 0 ]]; then
      git_info="$git_info \
$__mk5_b_green$__mk5_behindmaster_char$git_behindmaster"
    fi

    local git_outgoing=$(__mk5_git_outgoing)
    if [[ "$git_outgoing" != 0 ]]; then
      git_info="$git_info \
$__mk5_b_blue$__mk5_outgoing_char$git_outgoing"
    fi

    git_info="$__mk5_purple$git_info$__mk5_b_purple, "
  fi

  # Virtualenv stuff
  local colorpwd="$__mk5_green$(__mk5_git_pwd) "
  local virtualenv_info
  if [[ "$VIRTUAL_ENV" ]]; then
    local thePWD=$(pwd -P)
    local gitpath="$(git rev-parse --show-toplevel 2>/dev/null)"
    local envpath="$(cat $VIRTUAL_ENV/.project 2>/dev/null)"

    # If we're in a git repo and the directory matches the current env
    # project path, make it blue
    if [[ "$envpath" && "$gitpath" == "$envpath" ]]; then
      colorpwd="$__mk5_blue${gitpath##*/}$__mk5_green${thePWD##$gitpath} "

    # Otherwise, just print out the virtualenv info separately
    else
      virtualenv_info="$__mk5_blue${VIRTUAL_ENV##*/}$__mk5_b_blue, "
    fi
  fi

  PS1="\
$__mk5_b_blue$__mk5_top_connector\
$__mk5_cyan$USER$__mk5_b_cyan in \
$virtualenv_info\
$git_info\
$colorpwd\
\n\
$__mk5_b_blue$__mk5_bot_connector\
$pcharcolor$pchar \
$__mk5_normal"
}

PROMPT_COMMAND=__mk5_set_prompt
