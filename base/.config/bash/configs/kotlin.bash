# Compile a kotlin file to executable jar.
kotlinj() {
  [ ! "$1" ] && return 1
  local f="$1"; shift
  kotlinc "$f" -include-runtime -d "${f%.*}.jar" "$@"
}
