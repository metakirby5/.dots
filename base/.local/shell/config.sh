# Environment variables
export VISUAL=vim                                   # vim > emacs
export EDITOR=$VISUAL                               # part 2
export LS_COLORS='di=01;34:'                        # Folders are blue
export LESS_TERMCAP_md="$(tput bold; tput setaf 3)" # Yellow headers in less

# Don't give literal * unless we ask for it
shopt -s nullglob

# Big history
export HISTCONTROL=ignoredups:erasedups  # no duplicate entries
export HISTSIZE=100000                   # big big history
export HISTFILESIZE=100000               # big big history
shopt -s histappend                      # append to history, don't overwrite it

# Save and reload the history after each command finishes
export PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"

# http://stackoverflow.com/a/246128
dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
for f in $dir/{aliases,functions,vendor}/* $dir/prompt.sh; do
  source "$f"
done
