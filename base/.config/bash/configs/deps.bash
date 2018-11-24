# TODO: mpx refactor

DEPS_DIR=~/.local/deps

# Try to dump all dependencies to their respective files
dump-leaves() {
  for dest in "$DEPS_DIR"/*; do
    local m="$(basename "$dest")"

    if which "$m" &>/dev/null; then
      echo "Dumping $m leaves to $dest..."
      local leaves="$(${m}-leaves 2>/dev/null)"
      [ $? -eq 0 ] && echo "$leaves" > "$dest" ||
        echo "    ${m}-leaves FAILED!"
    else
      echo "$m not found, skipping..."
    fi
  done
}

# Try to install all dependencies to their respective files
install-leaves() {
  local NORM="\033[0m"
  local RED="\033[0;31m"
  local GREEN="\033[0;32m"
  local YELLOW="\033[0;33m"

  declare -A INSTALLERS
  local INSTALLERS=(
    [brew]="brew bundle --file=-"
    [pip]="xargs pip install"
    [npm]="xargs npm install -g"
    [gem]="xargs gem install"
    [luarocks]="xargs luarocks install"
    [code]="xargs -L1 code --install-extension"
  )

  for src in "$DEPS_DIR"/*; do
    echo
    local m="$(basename "$src")"
    local reqs="$(comm -23 "$src" <(${m}-leaves 2>/dev/null) |
      sed 's/^/    /')"

    if which "$m" &>/dev/null ||
        [ "$m" == "AppStore" -a "$(uname)" == "Darwin" ]; then
      if [ "$reqs" ]; then
        echo -e "${GREEN}Installing $m leaves with \`${INSTALLERS[$m]}\`...$NORM"
        echo "$reqs" | ${INSTALLERS[$m]}
      else
        echo -e "${GREEN}$m up to date!$NORM"
      fi
    else
      echo -e "${YELLOW}$m not found, skipping...$NORM"
    fi
  done

  # Handle these separately
  declare -A NODEP_INSTALLERS
  local NODEP_INSTALLERS=(
    [yarn]="yarn global add"
  )
  for m in "${!NODEP_INSTALLERS[@]}"; do
    if which "$m" &>/dev/null; then
      echo -e "${GREEN}Installing $m leaves with \`${NODEP_INSTALLERS[$m]}\`...$NORM"
      ${NODEP_INSTALLERS[$m]}
    else
      echo -e "${YELLOW}$m not found, skipping...$NORM"
    fi
  done

  echo
}
