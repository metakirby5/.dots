# Bundles up only leaf npm dependencies.
npm-leaves() {
  read -r -d '' SCRIPT << EOF
    NF >= 2 {
      github = match(\$3, /github\.com\/.*\/.*\.git/)
      if (github) {
        # 11 to take out github, 15 to take out github + .git
        dep = substr(\$3, RSTART + 11, RLENGTH - 15)
      } else {
        sub(/@.*$/, "", \$2)
        dep = \$2
      }
      print dep
    }
EOF

  npm list -g --depth 0 | awk "$SCRIPT"
}
