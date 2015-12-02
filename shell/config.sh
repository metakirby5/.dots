# Environment variables
export VISUAL=vim
export EDITOR=$VISUAL
export CLASSPATH='*':'.'

# Aliases
## Tools
alias up2ixio="curl -sfF 'f:1=<-' ix.io"
alias flatten-dir="find . -mindepth 2 -type f -exec mv -t . -i '{}' +"
alias mpc-path='echo \
  "${XDG_MUSIC_DIR%%/}/$(mpc current --format "%file%")"'

## Shortcuts
alias resource='source ~/.bashrc 2>/dev/null || source ~/.bash_profile'
alias reload-xresources='xrdb ~/.Xresources'
alias vty="variety >/dev/null"
alias xopen="xdg-open"
alias clip="xclip -sel c"
alias enw='emacs -nw'

## Prefs
alias less='less -R'
alias ls='ls -h --color=auto'
alias mpv='mpv --autofit-larger=90%x90%'
alias feh='feh -.'

# Functions

# Detect filetype and extract
extract () {
  if [ -f "$1" ] ; then
    case "$1" in
      *.tar.bz2) tar xvjf "$1" ;;
      *.tar.gz) tar xvzf "$1" ;;
      *.bz2) bunzip2 "$1" ;;
      *.rar) unrar x "$1" ;;
      *.gz) gunzip "$1" ;;
      *.tar) tar xvf "$1" ;;
      *.tbz2) tar xvjf "$1" ;;
      *.tgz) tar xvzf "$1" ;;
      *.zip) unzip "$1" ;;
      *.Z) uncompress "$1" ;;
      *.7z) 7z x "$1" ;;
      *) echo "don't know how to extract \"$1\"..." ;;
    esac
  else
    echo "\"$1\" is not a valid file!"
  fi
}

# Moves the current wallpaper to $1
variety-mv() {
  mv "$(variety --get | grep '/')" "$1" && variety --next
}

# Add aliases for mv and nsfw
variety() {
  if [[ "$#" -eq 0 ]]; then
    command variety
  else
    case "$1" in
      nsfw)
        variety-mv "/home/echan/Pictures/Wallpapers/Desktop/NSFW/"
        ;;
      mv)
        if [[ $# -eq 2 ]]; then
          variety-mv "$2"
        else
          echo "Please provide a destination."
        fi
        ;;
      *)
        command variety "$@"
        ;;
    esac
  fi
}

# Publish to github-pages
ghp-publish() {
  local cur_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
  git checkout master && \
    git pull && \
    git checkout gh-pages && \
    git pull && \
    git merge master --no-edit && \
    git push && \
    git checkout $cur_branch
}

# Get rid of already-merged branches
# http://stackoverflow.com/questions/17983068/git-delete-local-branches-after-deleting-them-on-remote
git-clean-branches() {
    git branch --merged | \
    grep -v "\*" | \
    grep -v "master" | \
    grep -v "develop" | \
    xargs -n 1 git branch -d
}

# Get rid of .orig files from merge conflicts
git-clean-orig() {
    git status -su | grep -e"\.orig$" | cut -f2 -d" " | xargs rm -r
}

# Fix chrome profile loading bugs
clean-chrome() {
  killall chrome && \
    rm ~/.config/google-chrome/Default/Web\ Data
}

# Cleans all *.pyc files recursively in the current directory
clean-pyc() {
  find . -name '*.pyc' -delete
}

# Check differences between current packages and requirements.txt
pip-diff() {
  local reqs='requirements.txt'

  if [[ ! -f $reqs ]]; then
      echo "ERROR: $reqs not found."
      return
  fi

  diff <(pip freeze) $reqs
}

# Makes pip packages match requirements.txt
pip-sync() {
  local reqs='requirements.txt'

  if [[ ! -f $reqs ]]; then
      echo "ERROR: $reqs not found."
      return
  fi

  pip freeze | grep -v -f $reqs - | xargs pip uninstall -y 2>/dev/null
  pip install -r $reqs
}

# Compile and run a Java class
javar() {
    if [[ ! $1 ]]; then
        echo 'Usage: javar [class name]'
        echo 'Example for a file named "Test.java":'
        echo '    $ javar Test'
        return
    fi
    javac $1.java && \
    java $1
}

# Urgent bell when task finishes
remind() {
    eval "${@}"
    echo -e "\a"
}

