__mk5_color_normal='\[\e[0m\]'
__mk5_color_branch='\[\e[0;37m\]'
__mk5_color_dirty='\[\e[1;33m\]'
__mk5_color_pwd='\[\e[0;32m\]'
__mk5_color_status_ok='\[\e[1;32m\]'
__mk5_color_status_bad='\[\e[1;31m\]'

function __mk5_git_dirty {
  local dirtymark=$(echo -e '\xc2\xb1\x0a')
  if [[ "$(git status -s --ignore-submodules=dirty 2>/dev/null)" ]]; then
    echo " $__mk5_color_dirty$dirtymark$__mk5_color_normal"
  fi
}

function __mk5_git_branch {
  local branch="$(git rev-parse --abbrev-ref HEAD 2>/dev/null)"
  if [[ $branch ]]; then
    echo "$__mk5_color_branch\
($branch$(__mk5_git_dirty)\
$__mk5_color_branch)$__mk5_color_normal "
  fi
}

function __mk5_git_pwd {
  # Get git base directory
  local gitbase=$(git rev-parse --show-toplevel 2>/dev/null)
  local gitpwd

  if [[ $gitbase ]]; then
    gitpwd="$(basename $gitbase)${PWD##$gitbase}"
  else
    local homesed=$(echo $HOME | sed 's/\//\\\//g')
    gitpwd=$(echo $PWD | sed "s/^$homesed/~/")
  fi

  echo "$__mk5_color_pwd$gitpwd$__mk5_color_normal"
}

# arg 1 is last status code
function __mk5_chevron {
  local prompt_char=$(echo -e '\xe2\x9d\xb1\x0a')
  local prompt
  local color

  if [[ $1 == 0 ]]; then
    color="$__mk5_color_status_ok"
  else
    color="$__mk5_color_status_bad"
  fi

  if [[ $USER == 'root' ]]; then
    prompt="$prompt_char$prompt_char$prompt_char"
  else
    prompt="$prompt_char"
  fi

  echo "$color$prompt$__mk5_color_normal"
}

function __mk5_set_prompt {
  local last_status=$?
  PS1="$(__mk5_git_branch)\
$(__mk5_git_pwd) \
$(__mk5_chevron $last_status) "
}

PROMPT_COMMAND=__mk5_set_prompt
