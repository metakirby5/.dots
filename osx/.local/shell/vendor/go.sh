if which go &>/dev/null; then
  export GOROOT=/usr/local/opt/go
  export GOPATH="$WORKSPACE/go"
  export PATH="$PATH:$GOROOT/bin:$GOPATH/bin"
fi
