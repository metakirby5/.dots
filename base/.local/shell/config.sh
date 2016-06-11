# Environment variables
export VISUAL=vim
export EDITOR=$VISUAL
export CLASSPATH='*':'.'
export LS_COLORS='di=01;34:'

# Don't give literal * unless we ask for it
shopt -s nullglob

# http://stackoverflow.com/a/246128
dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
for f in $dir/{aliases,functions}/* $dir/prompt.sh; do
  source "$f"
done
