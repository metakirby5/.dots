# Environment variables
export VISUAL=vim
export EDITOR=$VISUAL
export CLASSPATH='*':'.'

# Aliases
alias flatten-dir="find . -mindepth 2 -type f -exec mv -t . -i '{}' +"
alias vty="variety >/dev/null"

# Functions
variety-mv() {
  mv "$(variety --get | grep '/')" "$1" && variety --next
}

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

git-clean-branches() {
  git checkout master && \
    git pull --prune && \
    git branch --merged master | \
    grep -v "\* master$" | \
    xargs -n 1 git branch -d
}

git-clean-orig() {
    git status -su | grep -e"\.orig$" | cut -f2 -d" " | xargs rm -ri
}

clean-chrome() {
  killall chrome && \
    rm ~/.config/google-chrome/Default/Web\ Data
}

pip-update() {
  if [[ ! $1 ]]; then
      echo 'Usage: pip-update [requirements.txt]'
      return
  fi
  pip freeze | grep -v -f $1 - | xargs pip uninstall && \
    pip install -r $1
}

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

