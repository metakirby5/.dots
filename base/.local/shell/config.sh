# Environment variables
export VISUAL=vim                                   # vim > emacs
export EDITOR=$VISUAL                               # part 2
export LS_COLORS='di=01;34:'                        # Folders are blue
export LESS_TERMCAP_md="$(echo -ne '\033[1;33m')"   # Yellow headers in less

# Keybindings
set -o vi  # vim > emacs part 2

# Completion
shopt -s cdspell              # autocorrect cd
shopt -s globstar 2>/dev/null # Super-complete **

# History
export HISTCONTROL=ignoreboth:erasedups  # no duplicate entries or leading spaces
export HISTSIZE=100000                   # big big history
export HISTFILESIZE=100000               # big big history
shopt -s histappend                      # append to history, don't overwrite it

# Save and reload the history after each command finishes
__mk5_hist_cmd='history -a; history -c; history -r'
if ! [[ $PROMPT_COMMAND == *"$__mk5_hist_cmd"*  ]]; then
  export PROMPT_COMMAND="$__mk5_hist_cmd; $PROMPT_COMMAND"
fi

# http://stackoverflow.com/a/246128
dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Directories
for d in "$dir"/{vendor,functions,aliases}; do
  [ -d "$d" ] && for f in "$d"/*; do
    source "$f"
  done
done

# Files
for f in "$dir"/prompt.sh; do
  [ -f "$f" ] && source "$f"
done
