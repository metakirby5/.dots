BREW="/opt/homebrew/bin/brew"
[ ! -f "$BREW" ] && BREW="/usr/local/bin/brew"
[ -f "$BREW" ] && eval "$("$BREW" shellenv)"
unset BREW
