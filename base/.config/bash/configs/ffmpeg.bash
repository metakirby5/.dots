to-mp3() {
  local f
  for f in "$@"; do
    ffmpeg -i "$f" -qscale:a 0 "${f%.*}.mp3"
  done
}

to-mp4() {
  local f
  for f in "$@"; do
    extsub "$f" mp4 ffmpeg -i
  done
}

to-mp4-all() {
  to-mp4 *.mov
  rm *.mov
}

to-gif() {
  local f
  for f in "$@"; do
    ffmpeg -i "$f" -r 15 -vf scale=512:-1 "${f%.*}.gif"
  done
}

to-gif-all() {
  to-gif *.mp4
  rm *.mp4
}
