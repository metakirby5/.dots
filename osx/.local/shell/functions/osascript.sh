# Sends a notification: $1 = title, $2 = description
notify() {
  osascript -e "display notification \"$2\" with title \"$1\""
}

# Reminds with a notification
remind-notify() {
  eval "$@"
  echo -en "\a"
  notify "Finished task" "$(tr -d \" <<< "$@")"
}
