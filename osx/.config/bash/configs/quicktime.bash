# Start a screencast.
qt-cast() {
  osascript << EOF
  tell application "QuickTime Player"
     activate
     new screen recording
  end tell

  return
EOF
}
