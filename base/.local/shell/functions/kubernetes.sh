kubectl() {
  local cmd="$1"
  shift

  case "$cmd" in
    # Switch contexts with fzf.
    ctx)
      local chosen="$(
        command kubectl config get-contexts |
          rev | awk '{$1 = ""; $2 = ""} NR > 1' | rev |
          awk 'NF == 1 {print "\t" $1} NF == 2 {print $1 "\t" $2}' |
          fzf | awk '{print $NF}'
      )"

      [ "$chosen" ] && 
        command kubectl config set current-context "$chosen" ||
        true
      ;;

    # List pods.
    pods)
      command kubectl get pods "$@"
      ;;

    # Get full pod name.
    pod)
      [ -z "$1" ] &&
        command kubectl get pods "$@" | fzf --header-lines=1 | awk '{print $1}' ||
        command kubectl get pods | awk "/^$1-[a-z0-9]{5}/ {print \$1}"
      ;;

    # Describe pod.
    desc)
      command kubectl describe pod "$(kubectl pod "$1")"
      ;;

    # Get pod logs.
    logs)
      command kubectl logs -f "$(kubectl pod "$1")"
      ;;

    # Get node name of a pod.
    node)
      command kubectl describe pod "$(kubectl pod "$1")" |
        awk '/^Node:/ {print $2}' |
        cut -d/ -f1
      ;;

    # exec on a pod.
    pod-do)
      local pod="$(kubectl pod "$1")"
      shift

      command kubectl exec "$pod" -- "$@"
      ;;

    # Thread dump a pod.
    threads)
      kubectl pod-do "$1" jstack 1
      ;;

    # Get class histogram of a pod.
    classes)
      kubectl pod-do "$1" jcmd 1 GC.class_histogram
      ;;

    # Heap dump a pod.
    heap)
      kubectl pod-do "$1" jmap -dump:live,format=b,file=heap.bin 1
      kubectl pod-do "$1" jhat heap.bin
      ;;

    *)
      command kubectl "$cmd" "$@"
      ;;
  esac
}
