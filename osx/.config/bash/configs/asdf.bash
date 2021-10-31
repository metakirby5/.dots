ASDF_ROOT="$(brew --prefix asdf)"
[ -d "$ASDF_ROOT" ] && source "$ASDF_ROOT/asdf.sh"
unset ASDF_ROOT
