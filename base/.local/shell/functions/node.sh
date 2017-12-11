# Bundles up only leaf npm dependencies.
npm-leaves() {
  read -rd '' SCRIPT << EOF
    NF >= 2 {
      github = match(\$3, /(github:.*)/)
      if (github) {
        # 7 to take out github:, -42 to take out hash
        github_len = 7
        dep = substr(\$3, RSTART + github_len, RLENGTH - github_len - 42)
      } else {
        sub(/@.*$/, "", \$2)
        dep = \$2
      }
      print dep
    }
EOF

  npm list -g --depth 0 | awk "$SCRIPT" | sort
}
