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
      command apk-reinstall "$@"
      ;;
    *)
      command adb "$cmd" "$@"
      ;;
  esac
}
