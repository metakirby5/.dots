to-mp3() {
  local f
  for f in "$@"; do
    ffmpeg -i "$f" -qscale:a 0 "${f%.*}.mp3"
  done
}
