if which brew &>/dev/null; then
  __brew_prefix="$(brew --prefix)"
  for f in \
    "$__brew_prefix"/etc/bash_completion \
    "$__brew_prefix"/bash_completion.d/*; do
    [ -f "$f" ] && source "$f"
  done
fi
