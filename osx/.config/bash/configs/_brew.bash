BREW="/opt/homebrew/bin/brew"
[ -f "$BREW" ] && eval "$("$BREW" shellenv)"
unset BREW
