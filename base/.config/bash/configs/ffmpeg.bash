to-mp3() {
  local f
  for f in "$@"; do
    ffmpeg -i "$f" -qscale:a 0 "${f%.*}.mp3"
  done
}

to-mp4() {
  extsub "$1" mp4 ffmpeg -i
}

to-mp4-all() {
  for f in *.mov; do
    extsub "$f" mp4 ffmpeg -i
    rm "$f"
  done
}
