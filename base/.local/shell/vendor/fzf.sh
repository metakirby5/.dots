if which fzf &>/dev/null; then
  export FZF_DEFAULT_COMMAND='\
    ag --hidden -l 2>/dev/null || find -L . 2>/dev/null | cut -c3-'
  export FZF_DEFAULT_OPTS="\
    --color=fg:7,bg:-1,hl:3,fg+:7,bg+:-1,hl+:3,info:2,prompt:4,pointer:3,marker:2,spinner:1,header:5\
    --preview='(x={}; x=\"\${x/#\~/$HOME}\"; pygmentize \"\$x\" || cat \"\$x\") 2>/dev/null'"
fi
