# Tools
alias flatten-dir="find . -mindepth 2 -type f -exec mv -t . -i '{}' +"
alias mpc-path='echo "${XDG_MUSIC_DIR%%/}/$(mpc current --format %file%)"'

# Shortcuts
alias resource='source ~/.bashrc 2>/dev/null || source ~/.bash_profile'
alias enw='emacs -nw'
alias unstow='stow -D'
alias restow='stow -R'
alias tetris='bastet'

# Prefs
alias less='less -R'
alias mpv='mpv --autofit-larger=90%x90%'
alias feh='feh -.'
alias ocaml='rlwrap ocaml'
