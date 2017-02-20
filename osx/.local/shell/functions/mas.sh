mas-leaves() {
  mas list | awk '{print $1}' | sort
}
