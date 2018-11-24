# Get the current directory.
# http://stackoverflow.com/a/246128
dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source configs.
for f in \
  $(find -L "$dir/configs/" -type f | sort)\
  ~/.bash_completion.d/*\
  ; do
  [ -f "$f" ] && source "$f"
done

# Reset the exit code.
true
