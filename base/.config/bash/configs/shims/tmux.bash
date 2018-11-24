tmux() {
  cmd="$1"; shift
  case "$cmd" in
    l)
      command tmux list-sessions "$@"
      ;;

    s)
      command tmux switch-client -t "$@"
      ;;

    k)
      command tmux kill-session -t "$@"
      ;;

    *)
      command tmux "$cmd" "$@"
      ;;
  esac
}
