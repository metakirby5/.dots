# Enable sudo aliases
alias sudo='sudo '

# Tools
alias flatten-dir='find . -mindepth 2 -type f -exec mv -t . -i "{}" +'
alias ip-public="dig +short myip.opendns.com @resolver1.opendns.com"
alias ip-local="ipconfig getifaddr en0"
alias serve="python -m SimpleHTTPServer"
for method in GET POST PUT DELETE; do
  alias "$method"="curl -X $method"
done

# Shortcuts
alias resource='source ~/.bashrc 2>/dev/null || source ~/.bash_profile'
alias update-conf='pullc && restow-dots && resource && zenbu -e'
alias unstow='stow -D'
alias restow='stow -R'
alias tetris='bastet'
alias findr='find -L . ! -type d -regex'
alias HEAD='git rev-parse --abbrev-ref HEAD'
alias aniget='anistrm --program="wget -c"'
alias pbp='pb push -d 0'
alias pypush='python setup.py sdist bdist_wheel upload -r'
alias pypush3='python3 setup.py sdist bdist_wheel upload -r'
alias all="tr '\n' '\0' | xargs -0"
alias map="all -n 1"
alias fst="awk '{print\$1}'"
alias snd="awk '{print\$2}'"
alias cl='clear'
alias c='cd'
alias l='ls'
alias ll='ls -l'
alias la='ls -la'
alias g='git'
alias h='history'
alias q='fzf --multi | map'
alias u='pushd'
alias p='popd'
alias s='dirs -v'
alias k='kubectl'
alias gc='gcloud'

# Prefs
alias less='less -R'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias emacs='TERM=xterm-16color emacsclient -t'
alias feh='feh -.'
alias ocaml='rlwrap ocaml'
