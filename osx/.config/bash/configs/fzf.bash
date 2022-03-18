# Add fzf to path if installed locally.
fzf_bin=~/.fzf/bin
[ -d "$fzf_bin" ] && export PATH="$PATH:$fzf_bin"
unset fzf_bin

if command -v fzf &>/dev/null; then
  export \
    FZF_DEFAULT_COMMAND='(\
    rg --hidden -l . ||\
    ag --hidden -l . ||\
    find -L . ! -type d | cut -c3- | tail -n+2\
    ) 2>/dev/null' \
    FZF_DEFAULT_OPTS="\
      --color 'fg:7,bg:-1,hl:3,fg+:7,bg+:-1,hl+:3,info:2,prompt:4,pointer:3,marker:2,spinner:0,header:5' \
      --preview '(highlight -q --force -O ansi {} || cat {}) 2>/dev/null' --preview-window right:hidden \
      --bind 'ctrl-l:toggle-preview,ctrl-s:toggle-sort'"

  export \
    FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND" \
    FZF_CTRL_T_OPTS="$FZF_DEFAULT_OPTS" \
    FZF_CTRL_R_OPTS="$FZF_DEFAULT_OPTS --preview=" \
    FZF_ALT_C_OPTS="$FZF_DEFAULT_OPTS --preview="

  # Get location of fzf install.
  fzf_opt=~/.fzf
  [ -d "$fzf_opt" ] || fzf_opt="$HOMEBREW_PREFIX/opt/fzf"

  if [ -d "$fzf_opt" ]; then
    # Install key bindings.
    source "$fzf_opt/shell/key-bindings.bash"
  fi

  unset fzf_opt
fi
