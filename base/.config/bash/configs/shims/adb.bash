adb() {
  local cmd="$1"; shift
  case "$cmd" in
    file)
      command adbf "$@"
      ;;
    reinstall)
      command adb install -r -d "$@"
      ;;
    '')
      command adb
      ;;
    *)
      command adb "$cmd" "$@"
      ;;
  esac
}
