adb() {
  local cmd="$1"; shift
  case "$cmd" in
    file)
      command adbf "$@"
      ;;
    reinstall)
      command adb install -rd "$@"
      ;;
    '')
      command adb
      ;;
    *)
      command adb "$cmd" "$@"
      ;;
  esac
}
