brew() {
  local cmd="$1"
  shift

  case "$cmd" in
    # https://github.com/Homebrew/legacy-homebrew/issues/16639#issuecomment-42813448
    aliasapps)
      # Convert links to aliases
      find /Applications -maxdepth 1 -type l | while read f; do
        local src="$(stat -c%N "$f" | cut -d\' -f4)"
        rm "$f"
        osascript -e \
          "tell app \"Finder\" to make new alias file at \
          POSIX file \"/Applications\" to POSIX file \"$src\"
          set name of result to \"$(basename "$f")\""
      done
      ;;

    # A script to prune the leaves of your brew packages.
    # Requires beeftornado/homebrew-rmtree
    trim)
      for formula in $(mpx brew:leaves); do
        read -p "Keep $(brew desc "$formula")? [Y/n] " keep
        case $keep in
          [Nn])
            echo "    Uninstalling ${formula}..."
            brew rmtree "$formula"
            ;;
          *)
            echo "    Keeping ${formula}..."
            ;;
        esac
      done
      ;;

    relink)
      command brew unlink "$@"
      command brew link "$@"
      ;;
    up)
      if [[ "$@" ]]; then
        command brew upgrade "$@"
        return
      fi

      command brew update
      command brew upgrade
      command brew cleanup
      ;;
    l)
      command brew list "$@"
      ;;
    /)
      command brew search "$@"
      ;;
    o)
      command brew info "$@"
      ;;
    e)
      command brew edit "$@"
      ;;
    s)
      command brew services "$@"
      ;;
    i)
      command brew install "$@"
      ;;
    ri)
      command brew reinstall "$@"
      ;;
    ui)
      command brew uninstall "$@"
      ;;
    z)
      command brew rmtree "$@"
      ;;
    c)
      local cmd="$1"
      shift
      brew "$cmd" --cask "$@"
      ;;
    *)
      command brew "$cmd" "$@"
      ;;
  esac
}
