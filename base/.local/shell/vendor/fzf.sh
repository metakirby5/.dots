if which fzf &>/dev/null; then
  # Show hidden files
  export FZF_DEFAULT_COMMAND='(\
    git ls-tree -r --name-only HEAD ||\
    ag --hidden -l ||\
    find -L . ! -type d | cut -c3- | tail -n+2\
    ) 2>/dev/null'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

  # Color scheme and file preview
  FZF_PREVIEWER='((x={}; x="${x/#\~/$HOME}"; pygmentize "$x" || less "$x") 2>/dev/null)'
  export FZF_DEFAULT_OPTS="\
    --color 'fg:7,bg:-1,hl:3,fg+:7,bg+:-1,hl+:3,info:2,prompt:4,pointer:3,marker:2,spinner:0,header:5' \
    --preview '$FZF_PREVIEWER' --preview-window right:hidden \
    --bind 'ctrl-l:toggle-preview,ctrl-s:toggle-sort,ctrl-o:execute[$FZF_PREVIEWER | less -R >&2]'"
  export FZF_CTRL_T_OPTS="$FZF_DEFAULT_OPTS"
  export FZF_CTRL_R_OPTS="$FZF_DEFAULT_OPTS --preview="
  export FZF_ALT_C_OPTS="$FZF_DEFAULT_OPTS --preview="

  # Brew-install settings
  if [ "$(uname)" == "Darwin" ]; then
    fzf_opt="$(brew --prefix)/opt/fzf"

    # Auto-completion
    [[ $- == *i* ]] && source "$fzf_opt/shell/completion.bash" 2>/dev/null

    # Key bindings
    set -o vi
    source "$fzf_opt/shell/key-bindings.bash"
  fi
fi
