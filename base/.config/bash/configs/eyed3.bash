add-art() {
  if [ "$#" -lt 2 ]; then
    echo "Usage: add-art [image] [files...]"
    return 1
  fi

  local image="$1"; shift
  eyed3 --add-image "$image:FRONT_COVER" "$@"
}
