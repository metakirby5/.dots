# https://gist.github.com/dbtek/fb2ddccb18f0cf63a654ea2cc94c8f19
# include following in .bashrc / .bash_profile / .zshrc
# usage
# $ mkvenv myvirtualenv # creates venv under ~/.venv/
# $ venv myvirtualenv   # activates venv
# $ deactivate          # deactivates venv
# $ rmvenv myvirtualenv # removes venv

export VENV_HOME="$HOME/.venv"
[ -d "$VENV_HOME" ] || mkdir "$VENV_HOME"

venv() {
  cmd="$1"
  shift

  case "$cmd" in
    list)
      ls -1 "$VENV_HOME"
      ;;
    current)
      echo "${VIRTUAL_ENV##*/}"
      ;;
    use)
      source "${VENV_HOME:?}/${1:?}/bin/activate"
      ;;
    create)
      python3 -m venv "${VENV_HOME:?}/${1:?}"
      ;;
    remove)
      rm -r "${VENV_HOME:?}/${1:?}"
      ;;
    *)
      echo "list / use [name] / create [name] / remove [name]"
      ;;
  esac
}
