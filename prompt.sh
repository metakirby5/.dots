# Please set the following variables before sourcing this file:
#   $__mk5_color_normal
#   $__mk5_color_branch
#   $__mk5_color_dirty
#   $__mk5_color_status_ok
#   $__mk5_color_status_bad

function __mk5_git_dirty {
  local dirtymark='\xc2\xb1\x0a'
  if [[ "$(git status -s --ignore-submodules=dirty 2>/dev/null)" ]]; then
    printf " $__mk5_color_dirty$dirtymark$__mk5_color_normal"
  fi
}

function __mk5_git_branch {
  local branch="$(git rev-parse --abbrev-ref HEAD 2>/dev/null)"
  if [[ $branch ]]; then
    printf "$__mk5_color_branch\
($branch$(__mk5_git_dirty)\
$__mk5_color_branch)$__mk5_color_normal "
  fi
}

function __mk5_git_pwd {
  # Get git base directory
  local gitbase=$(git rev-parse --show-toplevel 2>/dev/null)
  if [[ $gitbase ]]; then
    printf "$(basename $gitbase)${PWD##$gitbase}"
  else
    local homesed
    if [[ $USER == 'root' ]]; then
      homesed="s/^\/root/~/"
    else
      homesed="s/^\/home\/$USER/~/"
    fi
    printf "$PWD" | sed "$homesed"
  fi
}

# arg 1 is last status code
function __mk5_chevron {
  local prompt_char='\xe2\x9d\xb1\x0a'
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

  printf "$color$prompt$__mk5_color_normal"
}

function __mk5_set_prompt {
  local last_status=$?
  export PS1='$(__mk5_git_branch)\
$(__mk5_git_pwd) \
$(__mk5_chevron last_status) '
}

__mk5_set_prompt
