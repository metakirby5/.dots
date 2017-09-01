# Add fzf to path if installed locally
[ -d ~/.fzf/bin ] && export PATH="$PATH:$HOME/.fzf/bin"

if which fzf &>/dev/null; then
  # Show hidden files
  export FZF_DEFAULT_COMMAND='(\
    rg --hidden -l . ||\
    ag --hidden -l . ||\
    find -L . ! -type d | cut -c3- | tail -n+2\
    ) 2>/dev/null'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

  # Color scheme and file preview
  FZF_PREVIEWER='(highlight -q --force -O ansi {} || cat {}) 2>/dev/null'
  export FZF_DEFAULT_OPTS="\
    --color 'fg:7,bg:-1,hl:3,fg+:7,bg+:-1,hl+:3,info:2,prompt:4,pointer:3,marker:2,spinner:0,header:5' \
    --preview '$FZF_PREVIEWER' --preview-window right:hidden \
    --bind 'ctrl-l:toggle-preview,ctrl-s:toggle-sort'"
  export FZF_CTRL_T_OPTS="$FZF_DEFAULT_OPTS"
  export FZF_CTRL_R_OPTS="$FZF_DEFAULT_OPTS --preview="
  export FZF_ALT_C_OPTS="$FZF_DEFAULT_OPTS --preview="

  # Get location of fzf install
  if [ "$(uname)" == "Darwin" ]; then
    fzf_opt="$(brew --prefix)/opt/fzf"
  else
    fzf_opt=~/.fzf
  fi

  if [ -d "$fzf_opt" ]; then
    # Auto-completion
    [[ $- == *i* ]] && source "$fzf_opt/shell/completion.bash" 2>/dev/null

    # Key bindings
    source "$fzf_opt/shell/key-bindings.bash"
  fi
fi
