# Protections
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# Prompt
PROMPT=~echan/.local/shell/prompt.sh
[ -f "$PROMPT" ] && source "$PROMPT"
