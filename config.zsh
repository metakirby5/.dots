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

# source location/of/.myzshrc.zsh

### END TOP

### BOTTOM
# source $ZSH/oh-my-zsh.sh
### END BOTTOM

#### END

HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
setopt appendhistory beep extendedglob nomatch
unsetopt autocd notify

ZSH_THEME="nicoulaj"
ENABLE_CORRECTION="true"
COMPLETION_WAITING_DOTS="true"
plugins=(gitfast sudo wd yum)

