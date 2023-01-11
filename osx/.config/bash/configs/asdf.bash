ASDF_ROOT="$(brew --prefix asdf)"
for script in asdf.sh libexec/asdf.sh; do
  [ -f "$ASDF_ROOT/$script" ] && source "$ASDF_ROOT/$script"
done
unset ASDF_ROOT
