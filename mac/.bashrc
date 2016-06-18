# Path
for p in \
    ~/.local/bin \
    ~/code/bash-scripts; do
  [ -d "$p" ] && PATH="$PATH:$p"
done
export PATH

# Configs
for rc in \
    ~/.local/shell/config.sh \
    ~/.local/shell/local.sh \
    ~/.creds.sh; do
  [ -f "$rc" ] && source "$rc"
done

# Completions
for f in ~/.bash_completion.d/*; do
  source "$f"
done
