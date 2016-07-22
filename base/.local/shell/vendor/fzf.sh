if which fzf &>/dev/null; then
  # Show hidden files
  export FZF_DEFAULT_COMMAND='(\
    git ls-tree -r --name-only HEAD ||\
    ag --hidden -l ||\
    find -L . | cut -c3-\
    ) 2>/dev/null'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

  # Color scheme and file preview
  FZF_PREVIEWER='((x={}; x="${x/#\~/$HOME}"; pygmentize "$x" || cat "$x") 2>/dev/null)'
  export FZF_DEFAULT_OPTS="\
    --color 'fg:7,bg:-1,hl:3,fg+:7,bg+:-1,hl+:3,info:2,prompt:4,pointer:3,marker:2,spinner:0,header:5'\
    --preview '$FZF_PREVIEWER'\
    --bind 'ctrl-l:toggle-preview,ctrl-s:toggle-sort,ctrl-o:execute[$FZF_PREVIEWER | less -R >&2]'"
  export FZF_CTRL_T_OPTS="$FZF_DEFAULT_OPTS"
  export FZF_CTRL_R_OPTS="$FZF_DEFAULT_OPTS --preview="
  export FZF_ALT_C_OPTS="$FZF_DEFAULT_OPTS --preview="

  # Auto-completion
  [[ $- == *i* ]] && source "/usr/local/opt/fzf/shell/completion.bash" 2>/dev/null

  # Key bindings
  set -o vi
  source "/usr/local/opt/fzf/shell/key-bindings.bash"
fi
