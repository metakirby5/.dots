if which kotlinc &>/dev/null; then
  kotlinj() {
    filename="$1"
    shift
    kotlinc "$filename" -include-runtime -d "${filename%.*}.jar" "$@"
  }
fi
