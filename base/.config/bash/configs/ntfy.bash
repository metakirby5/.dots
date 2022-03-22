# Urgent bell + push when task finishes.
remind-ns() {
  remind "$@"
  ntfy send "$*"
}

monitor-job() {
  if [ "$#" -lt 2 ]; then
    echo 'monitor-job URL MESSAGE...'
    return 1
  fi

  local id="${1##*/}"
  shift
  echo "$id"
  gitlab-job-monitor "$id"; ntfy send "$*"
}
