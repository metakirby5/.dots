gcloud() {
  local cmd="$1"
  shift

  case "$cmd" in
    p)
      if [ -z "$1" ]; then
        command gcloud config get-value project
      else
        command gcloud config set project "$1"
      fi
      ;;

    ssh)
      command gcloud compute ssh "$@"
      ;;

    creds)
      command gcloud container clusters get-credentials "$@"
      ;;

    *)
      command gcloud "$cmd" "$@"
      ;;
  esac
}
