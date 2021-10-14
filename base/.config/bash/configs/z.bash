z_path=/usr/local/etc/profile.d/z.sh
if [ -f "$z_path" ]; then
  source "$z_path"
fi
unset z_path
