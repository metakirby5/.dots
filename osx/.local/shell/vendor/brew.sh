if which brew &>/dev/null; then
  for f in "$(brew --prefix)"/bash_completion.d/*; do
    source "$f"
  done
fi
