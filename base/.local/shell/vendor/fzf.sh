if which fzf &>/dev/null; then
  export FZF_DEFAULT_COMMAND='ag --hidden -l 2>/dev/null || find -L .'
fi
