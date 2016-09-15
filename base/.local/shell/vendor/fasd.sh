if which fasd &>/dev/null; then
  eval "$(fasd --init auto)"
  alias v='f -e vim'                      # quick opening files with vim
  alias e='TERM=xterm-16color f -e "emacsclient -t"' # quick opening files with emacs
  alias o='a -e open'                     # quick opening files with open
  _fasd_bash_hook_cmd_complete v e o
fi
