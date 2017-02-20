luarocks-leaves() {
  luarocks list --porcelain 2>/dev/null | awk '{print $1}' | sort
}
