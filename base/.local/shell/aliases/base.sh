# Tools
alias flatten-dir="find . -mindepth 2 -type f -exec mv -t . -i '{}' +"

# Shortcuts
alias resource='source ~/.bashrc 2>/dev/null || source ~/.bash_profile'
alias update-conf='pullc && restow-dots && resource'
alias unstow='stow -D'
alias restow='stow -R'
alias tetris='bastet'
alias ll='ls -l'
alias la='ls -la'
alias aniget='anistrm --program="wget -qbc"'

# Prefs
alias less='less -R'
alias emacs='emacs -nw'
alias feh='feh -.'
alias ocaml='rlwrap ocaml'
