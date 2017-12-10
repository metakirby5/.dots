[ -d ~/.rbenv ] && export PATH="$HOME/.rbenv/bin:$PATH"

if which rbenv &>/dev/null; then
  eval "$(rbenv init -)"
  alias gemset='rbenv gemset'
fi
