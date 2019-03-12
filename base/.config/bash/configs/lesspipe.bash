lesspipe_path="$(command -v lesspipe.sh)"
if [ "$lesspipe_path" ]; then
  lesspipe_cache="$HOME/.lesspipe-init"
  [ "$lesspipe_path" -nt "$lesspipe_cache" -o ! -s "$lesspipe_cache" ] &&
    lesspipe.sh >| "$lesspipe_cache"
  source "$lesspipe_cache"
  unset lesspipe_cache
fi
unset lesspipe_path
