export PATH="$HOMEBREW_PREFIX/opt/ruby/bin:$PATH"
command -v gem &>/dev/null &&
  export PATH="$(gem environment gemdir)/bin:$PATH"
