# Urgent bell + push when task finishes.
remind-ns() {
  remind "$@"
  ntfy send "$*"
}
