kubectl() {
  local cmd="$1"
  shift

  case "$cmd" in
    desc)
      commmand kubectl describe pod "$@"
      ;;

    pod)
      [ -z "$1" ] && echo 'Arg required.' && return 1
      command kubectl get pod | awk "/^$1-[a-z0-9]{5}/ {print \$1}"
      ;;

    node)
      [ -z "$1" ] && echo 'Arg required.' && return 1
      command kubectl describe pod "$(kubectl pod "$1")" |
        awk '/^Node:/ {print $2}' |
        cut -d/ -f1
      ;;

    pod-do)
      [ -z "$1" ] && echo 'Arg required.' && return 1
      local pod="$(kubectl pod "$1")"
      shift

      command kubectl exec "$pod" -- "$@"
      ;;

    threads)
      [ -z "$1" ] && echo 'Arg required.' && return 1
      kubectl pod-do "$1" jstack 1
      ;;

    classes)
      [ -z "$1" ] && echo 'Arg required.' && return 1
      kubectl pod-do "$1" jcmd 1 GC.class_histogram
      ;;

    *)
      command kubectl "$cmd" "$@"
      ;;
  esac
}
