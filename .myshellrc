# Environment variables
export VISUAL=vim
export EDITOR=$VISUAL
export CLASSPATH='*':'.'

# Aliases
alias flatten-dir="find . -mindepth 2 -type f -exec mv -t . -i '{}' +"
## Git
alias ghp-publish='git checkout master && git pull && git checkout gh-pages && git pull && sleep 3 && git merge master --no-edit && git push && git checkout master'
alias clean-branches='git checkout master && git branch --merged master | grep -v "\* master$" | xargs -n 1 git branch -d'
## Program-specific
alias clean-chrome='killall chrome && rm ~/.config/google-chrome/Default/Web\ Data'

# Functions
## Compile and run Java program
function javar {
    if [[ ! $1 ]]; then
        echo 'Usage: javar <class name>'
        echo 'Example for a file named "Test.java":'
        echo '    $ javar Test'
        return
    fi
    javac $1.java
    java $1
}

