# Environment variables.
export \
  VISUAL=vim \
  EDITOR=$VISUAL \
  LS_COLORS='di=01;34:' \
  LESS_TERMCAP_md="$(echo -ne '\033[1;33m')" \
  \
  DOTS=~/.dots \
  LOCAL=~/.local \
  WORKSPACE=~/code \
  \
  normal="$(tput sgr0)" \
  bold="$(tput bold)" \
  underline="$(tput smul)" \
  reverse="$(tput rev)" \
  black="$(tput setaf 0)" \
  red="$(tput setaf 1)" \
  green="$(tput setaf 2)" \
  yellow="$(tput setaf 3)" \
  blue="$(tput setaf 4)" \
  purple="$(tput setaf 5)" \
  cyan="$(tput setaf 6)" \
  white="$(tput setaf 7)" \
  \
  HISTCONTROL=ignoreboth:erasedups \
  HISTTIMEFORMAT="%d/%m/%y %T " \
  HISTSIZE=1000000 \
  HISTFILESIZE=1000000

export MY_SCRIPTS="$WORKSPACE/scripts"

export PATH="\
$LOCAL/bin:\
$MY_SCRIPTS:\
$PATH:\
/usr/local/bin:\
/usr/local/sbin
"

# Shell options.
shopt -qs cdspell histappend globstar 2>/dev/null

# Keybindings.
set -o vi

# Save and reload the history after each command finishes
history_cmd='history -a; history -c; history -r'
[[ $PROMPT_COMMAND == *"$history_cmd"*  ]] ||
  export PROMPT_COMMAND="$history_cmd; $PROMPT_COMMAND"
unset history_cmd
