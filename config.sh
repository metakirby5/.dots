# Environment variables
export VISUAL=vim
export EDITOR=$VISUAL
export CLASSPATH='*':'.'

# Functions

function flatten-dir {
  find . -mindepth 2 -type f -exec mv -t . -i '{}' +
}

## Git

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

## Program-specific

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

