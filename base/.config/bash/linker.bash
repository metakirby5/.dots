# Get the current directory.
# http://stackoverflow.com/a/246128
dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source configs.
for f in $(find -L "$dir/configs/" -type f | sort); do
  source "$f"
done

unset dir f

# Reset the exit code.
true
