git() {
  local cmd="$1"; shift
  case "$cmd" in
    cd)
      cd "$(git rev-parse --show-toplevel)" "$@"
      ;;

    open)
      git-open "$@"
      ;;

    # Get rid of .orig files from merge conflicts.
    clean-orig)
      command git status -su | awk '/\.orig$/ {print $2}' | xargs rm -r
      ;;

    # Update the .gitignore with all currently untracked files
    update-gitignore)
      touch .gitignore
      command git status --porcelain | grep '^??' | cut -c4- >> .gitignore
      ;;

    *)
      command "$(basename "$0")" "$cmd" "$@"
      ;;
  esac
}
