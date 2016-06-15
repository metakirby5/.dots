# Path
for p in \
    ~/.local/bin \
    ~/code/bash-scripts; do
  [ -d "$p" ] && PATH="$PATH:$p"
done
export PATH

# Configs
for rc in \
    ~/.local/shell/config.sh \
    ~/.creds.sh; do
  [ "$rc" ] && source "$rc"
done

# Completions
for f in \
    $(brew --prefix)/etc/bash_completion.d/* \
    ~/.bash_completion.d/*; do
  source "$f"
done

# fasd
if which fasd &>/dev/null; then
  eval "$(fasd --init auto)"
  alias v='f -e vim'       # quick opening files with vim
  alias o='a -e open'      # quick opening files with open
  _fasd_bash_hook_cmd_complete v o
fi

# hub
if which hub &>/dev/null; then
  alias git='hub'
fi

# virtualenvwrapper
VIRTUALENVWRAPPER_SH=/usr/local/bin/virtualenvwrapper_lazy.sh
if [ -f "$VIRTUALENVWRAPPER_SH" ]; then
  export PROJECT_HOME=~/code
  source "$VIRTUALENVWRAPPER_SH"
fi
