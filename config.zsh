#### DOWNLOAD THESE PLUGINS:
# cd ~/.oh-my-zsh/custom/plugins
# git clone git://github.com/zsh-users/zsh-syntax-highlighting.git
#### END

#### PUT THE FOLLOWING IN ~/.zshrc:

### TOP

## The following lines were added by compinstall
# zstyle :compinstall filename '~/.zshrc'
#
# autoload -Uz compinit
# compinit
## End of lines added by compinstall

## Path to your oh-my-zsh installation.
# export ZSH=~/.oh-my-zsh
##

# source location/of/config.zsh

### END TOP

### BOTTOM
# source $ZSH/oh-my-zsh.sh
### END BOTTOM

#### END

HISTFILE=~/.zhistory
HISTSIZE=1000
SAVEHIST=1000
setopt appendhistory beep extendedglob nomatch
unsetopt autocd notify

# http://askubuntu.com/questions/1577/moving-from-bash-to-zsh
autoload -U compinit
compinit

setopt completeinword

zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*:killall:*' command 'ps -u $USER -o cmd'

autoload select-word-style
select-word-style shell

if [[ -x "`whence -p dircolors`" ]]; then
  eval `dircolors`
  alias ls='ls -F --color=auto'
else
  alias ls='ls -F'
fi

alias ll='ls -l'
alias la='ls -a'

setopt sharehistory extendedhistory

setopt extendedglob
unsetopt caseglob

REPORTTIME=10

ZSH_THEME="nicoulaj"
ENABLE_CORRECTION="true"
COMPLETION_WAITING_DOTS="true"
plugins=(gitfast sudo wd yum zsh-syntax-highlighting)

