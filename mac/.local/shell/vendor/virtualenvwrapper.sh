VIRTUALENVWRAPPER_SH=/usr/local/bin/virtualenvwrapper_lazy.sh
if [ -f "$VIRTUALENVWRAPPER_SH" ]; then
  export PROJECT_HOME=~/code
  source "$VIRTUALENVWRAPPER_SH"
fi
