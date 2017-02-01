#!/usr/bin/env bash

# Custom brew commands
brew() {
  local cmd="$1"
  shift

  case "$cmd" in
    aliasapps)
      brew-aliasapps
      ;;
    trim)
      brew-trim
      ;;
    up)
      command brew update
      command brew upgrade
      command brew prune
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

      case "$cmd" in
        l)
          command brew cask list "$@"
          ;;
        /)
          command brew cask search "$@"
          ;;
        o)
          command brew cask info "$@"
          ;;
        e)
          command brew cask edit "$@"
          ;;
        i)
          command brew cask install "$@"
          ;;
        ri)
          command brew cask reinstall "$@"
          ;;
        ui)
          command brew cask uninstall "$@"
          ;;
        z)
          command brew cask zap "$@"
          ;;
        *)
          command brew cask "$cmd" "$@"
          ;;
      esac
      ;;
    *)
      command brew "$cmd" "$@"
      ;;
  esac
}

# Bundles up only leaf brew dependencies.
# Requires Homebrew/homebrew-bundle.
brew-leaves() {
  (
    bundle="$(brew bundle dump --file=-)"
    grep -f <(
      brew leaves | tr '\n' '\0' | xargs -0 printf "^brew '%s'\n"
    ) <<< "$bundle"
    grep -v '^brew' <<< "$bundle"
  ) | sort
}

# https://github.com/Homebrew/legacy-homebrew/issues/16639#issuecomment-42813448
brew-aliasapps() {
  # Remove old links/aliases
  brew linkapps 2>&1 |
    perl -ne '/^Error: ([^.]*\.app)/ && print "$1\0"' |
    xargs -0 -n1 rm

  # Link apps
  brew linkapps

  # Convert links to aliases
  find /Applications -maxdepth 1 -type l | while read f; do
    local src="$(stat -c%N "$f" | cut -d\' -f4)"
    rm "$f"
    osascript -e \
      "tell app \"Finder\" to make new alias file at \
      POSIX file \"/Applications\" to POSIX file \"$src\"
      set name of result to \"$(basename "$f")\""
  done
}

# A script to prune the leaves of your brew packages.
# Requires beeftornado/homebrew-rmtree
brew-trim() {
  for formula in $(brew leaves); do
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
}
