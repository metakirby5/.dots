fasd_path="$(command -v fasd)"
if [ "$fasd_path" ]; then
  fasd_cache="$HOME/.fasd-init"
  [ "$fasd_path" -nt "$fasd_cache" -o ! -s "$fasd_cache" ] &&
    fasd --init posix-alias bash-hook >| "$fasd_cache"
  source "$fasd_cache"
  unset fasd_cache

  alias \
    v='f -e vim' \
    o='a -e open'
fi
unset fasd_path
