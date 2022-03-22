if command -v go &>/dev/null; then
  GOROOT="$HOMEBREW_PREFIX/opt/go/libexec"
  export \
    GOROOT \
    GOPATH="$WORKSPACE/lang/go"
  export PATH="$PATH:$GOROOT/bin:$GOPATH/bin"
fi
