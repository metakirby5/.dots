# Bundles up only leaf brew dependencies.
# Requires Homebrew/homebrew-bundle.
brew-leaves() {
  brew bundle dump --file=- |\
    command grep -f <( \
    brew leaves | tr '\n' '\0' | xargs -0 printf "^brew '%s'\n"; \
    echo "^cask"; \
    ) | sort
}

# https://github.com/Homebrew/legacy-homebrew/issues/16639#issuecomment-42813448
brew-aliasapps() {
  brew linkapps
  find /Applications -maxdepth 1 -type l | while read f; do
    osascript -e \
      "tell app \"Finder\" to make new alias file at \
      POSIX file \"/Applications\" to POSIX file \
      \"$(stat -c%N "$f" | cut -d\' -f4)\"
      set name of result to \"$f\""
  done
}

# A script to prune the leaves of your brew packages.
# Requires beeftornado/homebrew-rmtree
brew-prune() {
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
