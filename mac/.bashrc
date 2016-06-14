# Path
export PATH=$PATH:\
$HOME/.local/bin:\
$HOME/code/bash-scripts

# Configs
for rc in ~/.local/config.sh ~/.creds.sh; do
  [ "$rc" ] && source "$rc"
done

# Completions
for f in \
    $(brew --prefix)/etc/bash_completion.d/* \
    ~/.bash_completion.d/*; do
  source "$f"
done

# fasd
eval "$(fasd --init auto)"
alias v='f -e vim'       # quick opening files with vim
alias o='a -e open'      # quick opening files with open
_fasd_bash_hook_cmd_complete v o

# hub
alias git='hub'

# virtualenvwrapper
export PROJECT_HOME=~/code
source /usr/local/bin/virtualenvwrapper_lazy.sh
