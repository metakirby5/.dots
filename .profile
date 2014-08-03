# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
	. "$HOME/.bashrc"
    fi
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

# Colors
export CLICOLOR=1
export LSCOLORS=ExFxCxDxBxegedabagacad
XTITLE="\[\e]0;\u@\h (\w)\a\]"
CYAN="\[\033[0;36m\]"
GREEN="\[\033[0;32m\]"
NO_COLOR="\[\033[0m\]"

# Aliases
alias clean-branches="git checkout master; git pull; git branch --merged | grep -v \"\\*\" | xargs -n 1 git branch -d"
alias clean-pyc="find . -name \*.pyc -delete"
alias resource="source ~/.profile"

# Git things
function parse_git_branch {
    git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1) /'
}
export PS1="$XTITLE$CYAN\h$NO_COLOR:$GREEN\$(parse_git_branch)$NO_COLOR\W \u\$ "

# virtualenvwrapper
export WORKON_HOME=$HOME/.virtualenvs
export PROJECT_HOME=$HOME/code
source /usr/local/bin/virtualenvwrapper.sh

# Easy SSH tunnels
function forward() {
    # port forwarding shortcut
    # usage: proxy cu-p2 443 to 888
	if [[ $# -lt 4 ]]; then
		echo "Usage: forward p1 443 to 888"
		echo "This will forward port 443 to 888 of your local box."
		return
	fi
    echo "Forwarding $1 port $2 to localhost port $4"
    echo "http://127.0.0.1:$4"
    echo "https://127.0.0.1:$4"
    echo "Press ctrl-C to stop this connection."
    ssh -NL $4:127.0.0.1:$2 $1
}
