alias \
  sudo='sudo ' \
  xargs='xargs ' \
  \
  flatten-dir='find . -mindepth 2 -type f -exec mv -t . -i "{}" +' \
  ip-public='dig +short myip.opendns.com @resolver1.opendns.com' \
  ip-local="ipconfig getifaddr en0" \
  simple-serve='python -m SimpleHTTPServer' \
  jpop='clear; ffplay -nodisp -autoexit -hide_banner https://listen.moe/stream' \
  kpop='clear; ffplay -nodisp -autoexit -hide_banner https://listen.moe/kpop/stream' \
  \
  resource='source ~/.bashrc 2>/dev/null || source ~/.bash_profile' \
  unstow='stow -D' \
  restow='stow -R' \
  tetris='bastet' \
  findr='find -L . ! -type d -regex' \
  HEAD='git rev-parse --abbrev-ref HEAD' \
  aniget='anistrm --program="wget -c"' \
  pbp='pb push -d 0' \
  pypush='python setup.py sdist bdist_wheel upload -r' \
  pypush3='python3 setup.py sdist bdist_wheel upload -r' \
  all='parallel -X --tty' \
  map='all -n 1' \
  fst="awk '{print\$1}'" \
  snd="awk '{print\$2}'" \
  cl='clear' \
  c='cd' \
  l='ls' \
  ll='ls -l' \
  la='ls -la' \
  g='git' \
  h='history' \
  q='fzf --multi | all' \
  qq='fzf --multi | map' \
  u='pushd' \
  p='popd' \
  s='dirs -v' \
  t='tmux' \
  k='kubectl' \
  gc='gcloud' \
  \
  less='less -R' \
  grep='grep --color=auto' \
  fgrep='fgrep --color=auto' \
  egrep='egrep --color=auto' \
  emacs='TERM=xterm-16color emacsclient -t' \
  feh='feh -.' \
  ocaml='rlwrap ocaml'
