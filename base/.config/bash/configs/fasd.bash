if which fasd &>/dev/null; then
  fasd_cache="$HOME/.fasd-init"
  [ "$(command -v fasd)" -nt "$fasd_cache" -o ! -s "$fasd_cache" ] &&
    fasd --init posix-alias posix-hook >| "$fasd_cache"
  source "$fasd_cache"
  unset fasd_cache

  alias \
    v='f -e vim' \
    o='a -e open'
fi
