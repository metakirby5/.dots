up2ixio() {
  command curl -sfF 'f:1=<-' ix.io | xargs echo -n
}

transfer() {
  if [ "$#" -eq 0 ]; then
    echo "No arguments specified. Usage:
    transfer [file]
    cat [file] | transfer [url]"
    return 1
  fi

  tmpfile="$(mktemp -t transferXXX)"

  if tty -s; then
    basefile="$(basename "$1" | sed -e 's/[^a-zA-Z0-9._-]/-/g')"
    curl --progress-bar --upload-file "$1" "https://transfer.sh/$basefile" >> $tmpfile
  else
    curl --progress-bar --upload-file "-" "https://transfer.sh/$1" >> $tmpfile
  fi

  cat $tmpfile
  rm -f $tmpfile
}
