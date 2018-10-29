tmux() {
  case "$1" in
    l)
      shift
      command tmux list-sessions "$@"
      ;;

    s)
      shift
      command tmux switch-client -t "$@"
      ;;

    k)
      shift
      command tmux kill-session -t "$@"
      ;;

    *)
      command tmux "$@"
      ;;
  esac
}
