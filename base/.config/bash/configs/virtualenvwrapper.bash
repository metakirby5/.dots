virtualenvwrapper=/usr/local/bin/virtualenvwrapper_lazy.sh
if [ -f "$virtualenvwrapper" ]; then
  export \
    VIRTUALENVWRAPPER_PYTHON="$(command -v python3)" \
    PROJECT_HOME="$WORKSPACE"
  source "$virtualenvwrapper"
fi
unset virtualenvwrapper
