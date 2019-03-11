if which fasd &>/dev/null; then
  eval "$(fasd --init posix-alias posix-hook)"
  alias \
    v='f -e vim' \
    o='a -e open'
fi
