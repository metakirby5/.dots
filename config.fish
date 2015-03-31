function fish_greeting
  # greeting here
end

# Environment variables
set -e VISUAL vim
set -e EDITOR $VISUAL
set -e CLASSPATH '*':'.'

# Functions

function flatten-dir
  find . -mindepth 2 -type f -exec mv -t . -i '{}' +
end

## Git

function ghp-publish
  set -l cur_branch (git rev-parse --abbrev-ref HEAD ^/dev/null)
  git checkout master
  and git pull
  and git checkout gh-pages
  and git pull
  and git merge master --no-edit
  and git push
  and git checkout $cur_branch
end

function clean-branches
  git checkout master
  and git branch --merged master | \
  grep -v '\* master$' | \
  xargs -n 1 git branch -d
end

## Program-specific

function clean-chrome
  killall chrome
  and rm ~/.config/google-chrome/Default/Web\ Data
end

function javar
    if [ ! $argv[1] ]
        echo 'Usage: javar <class name>'
        echo 'Example for a file named "Test.java":'
        echo '    $ javar Test'
        return
    end
    javac $argv[1].java
    and java $argv[1]
end

