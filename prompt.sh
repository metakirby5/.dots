__mk5_hostname=$(hostname|cut -d . -f 1)

function __mk5_git_pwd {
  # Get git base directory
  local gitbase=$(git rev-parse --show-toplevel 2>/dev/null)

  if [[ $gitbase ]]; then
    # Strip git base directory
    echo "$(basename $gitbase)${PWD##$gitbase}"
  else
    # Replace home with ~
    echo $PWD | sed "s|^$HOME|~|"
  fi
}

function __mk5_git_branch {
  echo $(git symbolic-ref HEAD 2>/dev/null || \
         git rev-parse --short HEAD 2>/dev/null) \
       | sed "s|^refs/heads/||"
}

function __mk5_git_dirty {
  echo "$(git status -s --ignore-submodules=dirty 2>/dev/null | wc -l)"
}

function __mk5_git_outgoing {
  echo "$(git log @{u}.. 2>/dev/null | grep '^commit' | wc -l)"
}

function __mk5_git_incoming {
  echo "$(git log ..@{u} 2>/dev/null | grep '^commit' | wc -l)"
}

function __mk5_set_prompt {
  # Grab status code first
  local last_status=$?

  local normal='\[\e[0m\]'
  local white='\[\e[0;37m\]'
  local cyan='\[\e[0;36m\]'
  local green='\[\e[0;32m\]'
  local b_cyan='\[\e[1;36m\]'
  local b_green='\[\e[1;32m\]'
  local b_yellow='\[\e[1;33m\]'
  local b_red='\[\e[1;31m\]'
  local b_blue='\[\e[1;34m\]'

  local dirty_char=$(echo -e '\xc2\xb1\x0a')
  local incoming_char=$(echo -e '\xe2\xac\x87\x0a')
  local outgoing_char=$(echo -e '\xe2\xac\x86\x0a')
  local chev_char=$(echo -e '\xe2\x9d\xaf\x0a')

  local chevcolor
  if [[ $last_status == 0 ]]; then
    chevcolor=$b_green
  else
    chevcolor=$b_red
  fi

  local chev
  if [[ $USER == 'root' ]]; then
    chev="$chev_char$chev_char$chev_char"
  else
    chev="$chev_char"
  fi

  local git_info
  if [[ $(__mk5_git_branch) ]]; then
    git_info="$white($(__mk5_git_branch)"

    if [[ $(__mk5_git_dirty) != 0 ]]; then
      git_info="$git_info $b_yellow$dirty_char$(__mk5_git_dirty)"
    fi

    if [[ $(__mk5_git_incoming) != 0 ]]; then
      git_info="$git_info $b_red$incoming_char$(__mk5_git_incoming)"
    fi

    if [[ $(__mk5_git_outgoing) != 0 ]]; then
      git_info="$git_info $b_blue$outgoing_char$(__mk5_git_outgoing)"
    fi

    git_info="$git_info$white) "
  fi

  PS1="$cyan$USER@$__mk5_hostname$b_cyan $chev \
$git_info$green$(__mk5_git_pwd) $chevcolor$chev$normal "
}

PROMPT_COMMAND=__mk5_set_prompt
