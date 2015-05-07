# Environment variables
export VISUAL=vim
export EDITOR=$VISUAL
export CLASSPATH='*':'.'

# Aliases
alias flatten-dir="find . -mindepth 2 -type f -exec mv -t . -i '{}' +"
alias vty="variety >/dev/null"

# Functions

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
git-clean-branches() {
  git checkout master && \
    git pull && \
    git branch --merged master | \
    grep -v "\* master$" | \
    xargs -n 1 git branch -d && \
    git pull --prune
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

