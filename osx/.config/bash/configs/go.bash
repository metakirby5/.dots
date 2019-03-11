if command -v go &>/dev/null; then
  export \
    GOROOT=/usr/local/opt/go/libexec \
    GOPATH="$WORKSPACE/lang/go" \
    PATH="$PATH:$GOROOT/bin:$GOPATH/bin"
fi
