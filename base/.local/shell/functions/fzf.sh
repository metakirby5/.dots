# fzf + ag
zag() {
  local c="ag --color -C 5 $@ {}"
  ag -l "$@" | fzf --multi \
    --preview "$c" \
    --bind "ctrl-o:execute-multi[$c | less -R >&2]"
}
