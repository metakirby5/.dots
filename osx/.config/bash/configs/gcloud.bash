export CLOUDSDK_PYTHON="$HOMEBREW_PREFIX/opt/python/libexec/bin/python"
CLOUD_SDK="$HOMEBREW_PREFIX/Caskroom/google-cloud-sdk/latest/google-cloud-sdk"
if [ -d "$CLOUD_SDK" ]; then
  for f in "$CLOUD_SDK"/*.bash.inc; do
    source "$f"
  done
fi
unset CLOUD_SDK
