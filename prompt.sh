# Please set the following colors before sourcing this file:
#   $__bash_mk5_color_normal
#   $__bash_mk5_color_status_ok
#   $__bash_mk5_color_status_bad

function __bash_mk5_git_dirty {
  local dirtymark='\xc2\xb1\x0a'
  if [[ "$(git status -s --ignore-submodules=dirty 2>/dev/null)" ]]; then
    printf " $dirtymark"
  fi
}

function __bash_mk5_git_branch {
  local branch="$(git rev-parse --abbrev-ref HEAD 2>/dev/null)"
  if [[ $branch ]]; then
    printf "($branch$(__bash_mk5_git_dirty)) "
  fi
}

function __bash_mk5_git_pwd {
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
function __bash_mk5_chevron {
  local prompt_char='\xe2\x9d\xb1\x0a'
  local prompt
  local color

  if [[ $1 == 0 ]]; then
    color="$__bash_mk5_color_status_ok"
  else
    color="$__bash_mk5_color_status_bad"
  fi

  if [[ $USER == 'root' ]]; then
    prompt="$prompt_char$prompt_char$prompt_char"
  else
    prompt="$prompt_char"
  fi

  printf "$color$prompt$__bash_mk5_color_normal"
}

function __bash_mk5_set_prompt {
  local last_status=$?
  export PS1='$(__bash_mk5_git_branch)\
$(__bash_mk5_git_pwd) \
$(__bash_mk5_chevron last_status) '
}

__bash_mk5_set_prompt
