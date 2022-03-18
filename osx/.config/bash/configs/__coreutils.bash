coreutils="$HOMEBREW_PREFIX/opt/coreutils/libexec"
[ -d "$coreutils" ] && export \
  PATH="$coreutils/gnubin:$PATH" \
  MANPATH="$coreutils/gnuman:$MANPATH"
unset coreutils
