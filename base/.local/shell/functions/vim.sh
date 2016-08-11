# Codi
# Usage: codi [filetype] [filename]
codi() {
  vim $2 -c \
    "let g:startify_disable_at_vimenter = 1 |\
    set buftype=nofile laststatus=0 nonu nornu |\
    hi ColorColumn ctermbg=NONE |\
    hi VertSplit ctermbg=NONE |\
    hi NonText ctermfg=0 |\
    Codi ${1:-python}"
}
