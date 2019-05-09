asdf() {
  [ "$ASDF_BIN" ] || source "$(brew --prefix asdf)/asdf.sh"
  command asdf "$@"
}
