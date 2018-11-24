if which brew &>/dev/null; then
  BREW_COMPL="$(brew --prefix)/etc/bash_completion.d"
  [ -d "$BREW_COMPL" ] && for f in "$BREW_COMPL"/*; do
    source "$f"
  done

  # Bundles up only leaf brew dependencies.
  # Requires Homebrew/homebrew-bundle.
  # TODO: mpx refactor
  brew-leaves() {
    (
      # This little file dance is necessary since --file=- doesn't work anymore.
      out="$(mktemp)"
      rm "$out"
      brew bundle dump --file="$out"
      bundle="$(<"$out")"
      rm "$out"

      grep -f <(
        brew leaves | tr '\n' '\0' | xargs -0 printf "^brew \"%s\"\n"
      ) <<< "$bundle"
      grep -v '^brew' <<< "$bundle"
    ) | sort
  }
fi
