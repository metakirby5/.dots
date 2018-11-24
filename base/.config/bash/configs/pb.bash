# Urgent bell + push when task finishes.
remind-pb() {
  remind "$@"
  pb push "$*"
}
