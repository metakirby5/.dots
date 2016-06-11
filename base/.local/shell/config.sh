# Environment variables
export VISUAL=vim
export EDITOR=$VISUAL
export CLASSPATH='*':'.'

# Don't give literal * unless we ask for it
shopt -s nullglob

# Functions

up2ixio() {
  command curl -sfF 'f:1=<-' ix.io | xargs echo -n
}

transfer() {
  if [ $# -eq 0 ]; then
    echo "No arguments specified. Usage:
    transfer [file]
    cat [file] | transfer [url]"
    return 1
  fi

  tmpfile="$(mktemp -t transferXXX)"

  if tty -s; then
    basefile="$(basename "$1" | sed -e 's/[^a-zA-Z0-9._-]/-/g')"
    curl --progress-bar --upload-file "$1" "https://transfer.sh/$basefile" >> $tmpfile
  else
    curl --progress-bar --upload-file "-" "https://transfer.sh/$1" >> $tmpfile
  fi

  cat $tmpfile
  rm -f $tmpfile
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

