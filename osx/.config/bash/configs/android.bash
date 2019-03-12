ANDROID_SDK_ROOT="/usr/local/share/android-sdk"
[ -d "$ANDROID_SDK_ROOT" ] &&
  export ANDROID_SDK_ROOT ||
  unset ANDROID_SDK_ROOT
