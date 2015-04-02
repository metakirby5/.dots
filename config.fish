function fish_greeting
  # greeting here
end

# Environment variables
set VISUAL vim
set EDITOR $VISUAL
set CLASSPATH '*':'.'

# BASH workarounds
function sudo
  if test "$argv" = !!
    eval command sudo $history[1]
  else
    command sudo $argv
  end
end

# Grep hotfix
alias grep "/usr/bin/grep $GREP_OPTIONS"
set -e GREP_OPTIONS

# Aliases
alias flatten-dir "find . -mindepth 2 -type f -exec mv -t . -i '{}' +"

alias vty "variety >/dev/null"

# Helper
function variety-mv
  mv (variety --get | grep '/') $argv[1]
  and variety --next
end

function variety
  if [ (count $argv) = 0 ]
    command variety
  end
  switch $argv[1]
    case nsfw
      variety-mv ~/Pictures/Wallpapers/Desktop/NSFW/
    case mv
      if [ (count $argv) = 2 ]
        variety-mv $argv[2]
      else
        echo "Please provide a destination."
      end
    case '*'
      command variety $argv
  end
end

# Functions
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

