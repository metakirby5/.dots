if which brew &>/dev/null; then
  BREW_COMPL="$(brew --prefix)/etc/bash_completion.d"
  [ -d "$BREW_COMPL" ] && for f in "$BREW_COMPL"/*; do
    source "$f"
  done
fi
