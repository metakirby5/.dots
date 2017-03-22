if which gpg-agent &>/dev/null; then
  GPG_AGENT_INFO_FILE=~/.gnupg/agent-info
  mkdir -p "${GPG_AGENT_INFO_FILE%/*}"
  [ -f "$GPG_AGENT_INFO_FILE" ] && source "$GPG_AGENT_INFO_FILE"
  if [ -S "${GPG_AGENT_INFO%%:*}" ]; then
    export GPG_AGENT_INFO
  else
    eval $(gpg-agent --daemon --write-env-file "$GPG_AGENT_INFO_FILE")
  fi
fi
