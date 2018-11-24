# Extract a url from a vox redirect link
voxlink() {
  open "$(urldecode "$(sed 's/.*=\(.*\)&.*/\1/' <<< "$1")")"
}
