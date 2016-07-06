if which brew &>/dev/null; then
  for f in $(brew --prefix)/etc/bash_completion.d/*; do
    source "$f"
  done
fi
