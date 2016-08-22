# fzf cache
FZF_CACHE=~/.cache/fzf

FZF_CACHE_DIR="$(dirname "$FZF_CACHE")"
[ ! -d "$FZF_CACHE_DIR" ] && mkdir -p "$FZF_CACHE_DIR"

fzf() {
  exec 3>&1 1> >(tee "$FZF_CACHE")
  command fzf "$@"
  exec 1>&3 3>&-
}

fzc() {
  cat "$FZF_CACHE"
}

# fzf + ag
zag() {
  local c="ag --color -C 5 $* {}"
  ag -l "$@" | fzf --multi \
    --preview "$c" \
    --bind "ctrl-o:execute-multi[$c | less -R >&2]"
}
