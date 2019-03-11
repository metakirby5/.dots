VIRTUALENVWRAPPER_SH=/usr/local/bin/virtualenvwrapper_lazy.sh
if [ -f "$VIRTUALENVWRAPPER_SH" ]; then
  export \
    VIRTUALENVWRAPPER_PYTHON="$(which python3)" \
    PROJECT_HOME="$WORKSPACE"
  source "$VIRTUALENVWRAPPER_SH"
fi
