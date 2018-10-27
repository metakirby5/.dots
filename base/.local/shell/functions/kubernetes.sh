kubectl() {
  local cmd="$1"
  shift

  case "$cmd" in
    desc)
      commmand kubectl describe pod "$@"
      ;;

    pod)
      command kubectl get pod | awk "/^$1-[a-z0-9]{5}/ {print \$1}"
      ;;

    node)
      command kubectl describe pod "$(kubectl pod "$1")" |
        awk '/^Node:/ {print $2}' |
        cut -d/ -f1
      ;;

    pod-do)
      local pod="$(kubectl pod "$1")"
      shift

      command kubectl exec "$pod" -- "$@"
      ;;

    threads)
      kubectl pod-do "$1" jstack 1
      ;;

    classes)
      kubectl pod-do "$1" jcmd 1 GC.class_histogram
      ;;

    *)
      command kubectl "$cmd" "$@"
      ;;
  esac
}
