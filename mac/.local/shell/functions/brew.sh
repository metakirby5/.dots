# Bundles up only leaf brew dependencies.
# Requires Homebrew/homebrew-bundle.
brew-leaves() {
  brew bundle dump --file=- |\
    grep -Ff <(cat <(brew leaves) <(echo 'tap'; echo 'cask'))
}
