# cd with smart ... handling.
cd() {
  local first="${1%%/*}"
  local num
  local rest

  # Only consider if first is all dots
  if [ ! "$(tr -d . <<< "$first")" ]; then
    num="$(wc -c <<< "$first")"
    rest="${1#$first}"
  else
    num=0
  fi

  if [ $num -gt 3 ]; then
    command cd "..$(printf '%0.s/..' $(seq 1 $(($num - 3))))$rest"
  else
    command cd "$@"
  fi
}

# Touch with script shebang.
touchx() {
  [ ! "$1" ] && return 1
  cat <<< "#!/usr/bin/env ${2:-bash}" > "$1"
  chmod +x "$1"
}

# Shortcut to awk a field.
field() {
  [ ! "$1" ] && return 1
  awk "{ print \$$1 }"
}

# Perform a countdown.
countdown() {
  [ ! "$1" ] && return 1
  for i in $(seq $1); do echo $(($1 - $i + 1)); sleep 1; done
}

# Urgent bell when task finishes.
remind() {
  eval "$@"
  echo -en "\a"
}

# Urgent bell + say when task finishes.
remind-say() {
  remind "$@"
  say -- "Finished $@."
}

# Port tunnel to a remove server.
portup() {
  ssh -NTCR "${2:-3000}:localhost:${1:-3000}" "${3:-"$PORTUP_HOST"}"
}
