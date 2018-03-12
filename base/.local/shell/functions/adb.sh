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
      echo "Attempting install..."
      local PATTERN='.*\[INSTALL_FAILED_ALREADY_EXISTS: Attempt to re-install \([^\s]*\) without first uninstalling.\].*'
      local out="$(command adb install "$@" 2>&1)"
      local pkg="$(sed -n "s/$PATTERN/\1/p" <<< "$out")"
      if [ "$pkg" ]; then
        echo "Package detected: $pkg"
        echo "Uninstalling..."
        command adb uninstall "$pkg"
        echo "Reinstalling..."
        command adb install "$@"
      else
        echo "$out"
      fi
      ;;
    *)
      command adb "$cmd" "$@"
      ;;
  esac
}
