if command -v go &>/dev/null; then
  GOROOT=/usr/local/opt/go/libexec
  export \
    GOROOT \
    GOPATH="$WORKSPACE/lang/go" \
    PATH="$PATH:$GOROOT/bin:$GOPATH/bin"
fi
