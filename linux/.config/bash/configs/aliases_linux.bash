# Shortcuts
alias reload-xresources='xrdb ~/.Xresources'
alias mpc-path='echo "${XDG_MUSIC_DIR%%/}/$(mpc current --format %file%)"'

# Prefs
alias ls='ls -xh --color=auto'
alias clip='xclip -sel c'
alias dump='xclip -sel c -o'
alias open='xdg-open'
