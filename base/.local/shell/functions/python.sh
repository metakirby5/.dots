# Bundles up only leaf pip dependencies.
# Requires pipdeptree.
pip-leaves() {
  pipdeptree --freeze -w silence | command grep -o '^[^ =]\+' | sort
}

# Cleans all *.pyc files recursively in the current directory
clean-pyc() {
  find . -name '*.pyc' -delete
}

# Check differences between current packages and requirements.txt
pip-diff() {
  local reqs='requirements.txt'

  if [ ! -f "$reqs" ]; then
    echo "ERROR: $reqs not found."
    return
  fi

  diff <(pip freeze) $reqs
}

# Makes pip packages match requirements.txt
pip-sync() {
  local reqs='requirements.txt'

  if [ ! -f "$reqs" ]; then
    echo "ERROR: $reqs not found."
    return
  fi

  pip freeze | grep -v -f $reqs - | xargs pip uninstall -y 2>/dev/null
  pip install -r $reqs
}
