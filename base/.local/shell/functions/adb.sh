#!/usr/bin/env bash

# Custom adb commands

adb() {
  local cmd="$1"
  shift

  case "$cmd" in
    file)
      command adbf "$@"
      ;;
    reinstall)
      command adb install -r -d "$@"
      ;;
    *)
      command adb "$cmd" "$@"
      ;;
  esac
}
