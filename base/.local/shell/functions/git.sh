# Custom git commands
__mk5_git() {
  local prog="$1"
  shift
  local cmd="$1"
  shift

  case "$cmd" in
    cd)
      cd "$(git rev-parse --show-toplevel)" "$@"
      ;;
    open)
      git-open "$@"
      ;;
    clean-orig)
      git-clean-orig "$@"
      ;;
    update-gitignore)
      git-update-gitignore "$@"
      ;;
    *)
      command "$prog" "$cmd" "$@"
      ;;
  esac
}
git() {
  __mk5_git git "$@"
}
hub() {
  __mk5_git hub "$@"
}

# Get rid of .orig files from merge conflicts
git-clean-orig() {
  git status -su | grep -e"\.orig$" | cut -f2 -d" " | xargs rm -r
}

# Update the .gitignore with all currently untracked files
git-update-gitignore() {
  touch .gitignore
  git status --porcelain | grep '^??' | cut -c4- >> .gitignore
}
