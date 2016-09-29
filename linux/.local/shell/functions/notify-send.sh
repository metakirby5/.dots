remind-notify() {
  eval "$@"
  echo -en "\a"
  notify-send -a "Finished task" "$(tr -d \" <<< "$@")"
}
