# Environment variables
export VISUAL=vim
export EDITOR=$VISUAL
export CLASSPATH='*':'.'

# Aliases
alias flatten-dir="find . -mindepth 2 -type f -exec mv -t . -i '{}' +"
alias vty="variety >/dev/null"

# Functions
function variety-mv {
  mv "$(variety --get | grep '/')" "$1" && variety --next
}

function variety {
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

function ghp-publish {
  local cur_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
  git checkout master && \
    git pull && \
    git checkout gh-pages && \
    git pull && \
    git merge master --no-edit && \
    git push && \
    git checkout $cur_branch
}

function clean-branches {
  git checkout master && \
    git branch --merged master | \
    grep -v "\* master$" | \
    xargs -n 1 git branch -d
}

function clean-chrome {
  killall chrome && \
    rm ~/.config/google-chrome/Default/Web\ Data
}

function javar {
    if [[ ! $1 ]]; then
        echo 'Usage: javar <class name>'
        echo 'Example for a file named "Test.java":'
        echo '    $ javar Test'
        return
    fi
    javac $1.java && \
    java $1
}

