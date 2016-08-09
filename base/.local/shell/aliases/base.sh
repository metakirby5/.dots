# Enable sudo aliases
alias sudo='sudo '

# Tools
alias flatten-dir='find . -mindepth 2 -type f -exec mv -t . -i "{}" +'
alias urlencode='python -c "import sys, urllib as ul; print ul.quote_plus(sys.argv[1])"'
alias urldecode='python -c "import sys, urllib as ul; print ul.unquote_plus(sys.argv[1])"'
alias ip-public="dig +short myip.opendns.com @resolver1.opendns.com"
alias ip-local="ipconfig getifaddr en0"
alias codi="vim codi.py -c 'setlocal buftype=nofile | Codi'"
for method in GET POST PUT DELETE; do
	alias "$method"="curl -X $method"
done

# Shortcuts
alias resource='source ~/.bashrc 2>/dev/null || source ~/.bash_profile'
alias update-conf='pullc && restow-dots && resource && whizkers -e'
alias unstow='stow -D'
alias restow='stow -R'
alias tetris='bastet'
alias ll='ls -l'
alias la='ls -la'
alias findr='find -L . ! -type d -regex'
alias HEAD='git rev-parse --abbrev-ref HEAD'
alias aniget='anistrm --program="wget -c"'
alias all="tr '\n' '\0' | xargs -0"
alias map="all -n 1"
alias g='git'
alias h='history'
alias zh='eval $(tac "$HISTFILE" | fzf --no-sort --preview= | tee -a "$HISTFILE")'
alias q='fzf --multi | map'
alias l='locate / | fzf --multi | map'

# Prefs
which nvim &>/dev/null && alias vim='nvim'
alias less='less -R'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias emacs='emacs -nw'
alias feh='feh -.'
alias ocaml='rlwrap ocaml'
