" **************************************
" ~/.vimrc
" Ethan Chan
" Sources: Angie Nguyen, Minji Yoon
"          http://amix.dk/vim/vimrc.txt
"          http://vim.wikia.com/
" **************************************

" **************************************
" * Setup
" **************************************

" get rid of strict vi compatibility
set nocompatible

" Enable more shortcuts with <space> key (denoted as , in shortcuts)
let mapleader = " "
let g:mapleader = " "

" Preserve legacy mapping
noremap <leader><space> <space>

" Set up w:created au to run later
au VimEnter * au WinEnter * let w:created = 1

" Vundle
filetype off
set rtp+=~/.vim/bundle/Vundle.vim

if isdirectory($HOME.'/.vim/bundle/Vundle.vim')
  call vundle#begin()

  " General
  Plugin 'gmarik/Vundle.vim'                " Bundle manager
  Plugin 'tpope/vim-repeat'                 " Make repeat work with plugins
  Plugin 'tomtom/tcomment_vim'              " Toggle comments
  Plugin 'tpope/vim-surround'               " Surround with...
  Plugin 'tpope/vim-sleuth'                 " Autodetect indentation
  Plugin 'nathanaelkane/vim-indent-guides'  " Indent guides
  Plugin 'kana/vim-textobj-user'            " User-defined text objects
  Plugin 'kana/vim-textobj-indent'          " Indentation levels
  Plugin 'sheerun/vim-polyglot'             " Language packs
  Plugin 'Shougo/neocomplete'               " Autocomplete
  Plugin 'ludovicchabant/vim-gutentags'     " Auto-generate ctags
  Plugin 'majutsushi/tagbar'                " Nice tag browser
  Plugin 'Shougo/neosnippet'                " Snippets engine
  Plugin 'Shougo/neosnippet-snippets'       " Snippets
  Plugin 'justinmk/vim-sneak'               " Two-character f and t
  Plugin 'jiangmiao/auto-pairs'             " Automatically add delimiters
  Plugin 'osyo-manga/vim-over'              " Better :%s/.../.../
  Plugin 'haya14busa/incsearch.vim'         " Highlight all as searching
  Plugin 'terryma/vim-multiple-cursors'     " Multiple cursors
  Plugin 'Konfekt/FastFold'                 " Faster folder
  Plugin 'airblade/vim-gitgutter'           " Git gutter
  Plugin 'tpope/vim-fugitive'               " Git functions
  Plugin 'pbrisbin/vim-mkdir'               " Automatically mkdir
  Plugin 'Shougo/unite.vim'                 " Fuzzy searcher
  " Plugin 'scrooloose/syntastic'             " Syntax checker

  " Language-specific
  Plugin 'mattn/emmet-vim'                  " Emmet

  call vundle#end()

  " Indent guides
  let g:indent_guides_enable_on_vim_startup = 1
  let g:indent_guides_start_level = 2
  let g:indent_guides_guide_size = 1
  let g:indent_guides_auto_colors = 0
  au VimEnter,Colorscheme *
        \ :hi IndentGuidesOdd
        \ ctermbg=black guibg=black
  au VimEnter,Colorscheme *
        \ :hi IndentGuidesEven
        \ ctermbg=black guibg=black
  nmap <silent> <Leader>i <Plug>IndentGuidesToggle

  " Syntastic
  let g:syntastic_always_populate_loc_list = 1
  let g:syntastic_auto_loc_list = 1
  let g:syntastic_check_on_open = 0
  let g:syntastic_check_on_wq = 0
  let g:syntastic_error_symbol = 'x'
  let g:syntastic_warning_symbol = '!'
  let g:syntastic_style_error_symbol = 'S'
  let g:syntastic_style_warning_symbol = 's'

  " Neocomplete
  let g:neocomplete#enable_at_startup = 1
  let g:neocomplete#enable_smart_case = 1
  set completeopt-=preview
  imap <expr><tab>    pumvisible() ?
        \               "\<c-n>" :
        \               neosnippet#jumpable() ?
        \                 "\<Plug>(neosnippet_jump)" :
        \                 "\<tab>"
  imap <expr><cr>     pumvisible() ?
        \               neosnippet#expandable() ?
        \                 "\<Plug>(neosnippet_expand)" :
        \                 "\<c-y>" :
        \               "\<cr>"
  imap <expr><bs>     neocomplete#smart_close_popup() . "\<bs>"
  imap <expr><s-tab>  pumvisible() ? "\<c-p>" : "\<tab>"

  " Sneak
  let g:sneak#streak = 1
  let g:sneak#s_next = 1
  let g:sneak#use_ic_scs = 1

  " Over
  nnoremap <silent> % :OverCommandLine<cr>%s/
  vnoremap <silent> % :OverCommandLine<cr>s/

  " Incsearch
  set hlsearch
  let g:incsearch#auto_nohlsearch = 1
  let g:incsearch#is_stay = 1
  map /  <Plug>(incsearch-forward)
  map ?  <Plug>(incsearch-backward)
  map n  <Plug>(incsearch-nohl-n)
  map N  <Plug>(incsearch-nohl-N)
  map *  <Plug>(incsearch-nohl-*)
  map #  <Plug>(incsearch-nohl-#)
  map g* <Plug>(incsearch-nohl-g*)
  map g# <Plug>(incsearch-nohl-g#)

  " Multiple cursors
  let g:multi_cursor_use_default_mapping=0
  let g:multi_cursor_next_key='<C-c>'
  let g:multi_cursor_prev_key='<C-u>'
  let g:multi_cursor_skip_key='<C-x>'
  let g:multi_cursor_quit_key='<Esc>'
  " Fix for autocomplete
  function! Multiple_cursors_before()
    if exists(':NeoCompleteLock') == 2
      NeoCompleteLock
    endif
  endfunction
  function! Multiple_cursors_after()
    if exists(':NeoCompleteUnlock') == 2
      NeoCompleteUnlock
    endif
  endfunction

  " Unite
  let g:unite_data_directory = '~/.vim/cache/unite'
  let g:unite_winheight = 100
  let g:unite_split_rule = 'botright'
  let g:unite_enable_start_insert = 1
  call unite#filters#matcher_default#use(['matcher_fuzzy'])
  call unite#filters#sorter_default#use(['sorter_rank'])
  noremap <silent> <leader>r :Unite -auto-resize -buffer-name=register register<cr>
  noremap <silent> <leader>x :Unite -auto-resize -buffer-name=files    buffer file<cr>

  " Git Gutter
  let g:gitgutter_map_keys = 0
  nmap <leader>gn <Plug>GitGutterNextHunk
  nmap <leader>gp <Plug>GitGutterPrevHunk
  nmap <leader>ga <Plug>GitGutterStageHunk
  nmap <leader>gu <Plug>GitGutterRevertHunk
  nmap <leader>gv <Plug>GitGutterPreviewHunk
  omap ih <Plug>GitGutterTextObjectInnerPending
  omap ah <Plug>GitGutterTextObjectOuterPending
  xmap ih <Plug>GitGutterTextObjectInnerVisual
  xmap ah <Plug>GitGutterTextObjectOuterVisual

  " Emmet
  let g:user_emmet_leader_key='<c-e>'
  let g:user_emmet_install_global = 0
  autocmd FileType html,css EmmetInstall

else

  " Fallbacks...

  " Fix for hash comments
  " inoremap # X#

  " tcomment
  au BufNewFile,BufFilePre,BufRead * if !exists ('b:comment_leader') |
                                   \   let b:comment_leader = '# ' |
                                   \ endif

  au FileType c,cpp,java,scala          let b:comment_leader = '// '
  au FileType javascript                let b:comment_leader = '// '
  au FileType zsh,sh,ruby,python        let b:comment_leader = '# '
  au FileType conf,fstab                let b:comment_leader = '# '
  au FileType tex                       let b:comment_leader = '% '
  au FileType mail                      let b:comment_leader = '> '
  au FileType vim                       let b:comment_leader = '" '

  noremap <silent> g> :call StoreSearch()<cr>:<C-B>silent <C-E>s/^/<C-R>=escape(b:comment_leader,'\/')<cr>/<cr>:noh<cr>:call RestoreSearch()<cr>
  noremap <silent> g< :call StoreSearch()<cr>:<C-B>silent <C-E>s/^\V<C-R>=escape(b:comment_leader,'\/')<cr>//e<cr>:noh<cr>:call RestoreSearch()<cr>
  vnoremap <silent> g> :call StoreSearch()<cr>gv:<C-B>silent <C-E>s/^/<C-R>=escape(b:comment_leader,'\/')<cr>/<cr>:noh<cr>:call RestoreSearch()<cr>gv
  vnoremap <silent> g< :call StoreSearch()<cr>gv:<C-B>silent <C-E>s/^\V<C-R>=escape(b:comment_leader,'\/')<cr>//e<cr>:noh<cr>:call RestoreSearch()<cr>gv

  " Autocomplete
  set omnifunc=syntaxcomplete#Complete
  inoremap <S-tab> <C-x><C-o>

  " Search
  noremap N Nzz
  noremap n nzz
  noremap // /\c
  noremap ?? ?\c

  " Auto-insert matching curly brace
  inoremap {<cr> {<cr>}<C-o>O

endif

" **************************************
" * Variables
" **************************************

set nu                        " line numbering on
set noerrorbells              " turns off annoying bell sounds for errors
set visualbell                " disable bell part 1
set t_vb=                     " disable bell part 2
set backspace=2               " backspace over everything
set fileformats=unix,dos,mac  " open files from mac/dos
set hidden                    " hide abandoned buffers
set exrc                      " open local config files
set nojoinspaces              " don't add white space when I don't tell you to
set autowrite                 " write before make
set mouse=a                   " allow mouse usage
set ttymouse=xterm2           " urxvt scrolling
set hlsearch                  " highlights all search hits
set ignorecase                " search without regards to case
set smartcase                 " search with smart casing
set gdefault                  " default global sub
set timeoutlen=1000 ttimeoutlen=0   " No escape key delay

" Persistent undo
if exists('&undodir')
  if !isdirectory($HOME . '/.vimUndo/')
    silent call mkdir($HOME . '/.vimUndo/', 'p')
  endif
  set undodir=~/.vimUndo/ " set undo directory
  set undofile            " use an undo file
endif

" Autocomplete menus
if has("wildmenu")
  set wildignore+=*.a,*.o
  set wildignore+=*.bmp,*.gif,*.ico,*.jpg,*.png
  set wildignore+=.DS_Store,.git,.hg,.svn
  set wildignore+=*~,*.swp,*.tmp
  set wildmenu
  if has("wildignorecase")
    set wildignorecase
  endif
  set wildmode=longest:full,full
  set wildcharm=<tab>
endif

" Set these to your preference
"set ve=all             " place cursor anywhere in any mode
"set incsearch          " highlight as you search
"set confirm            " shows dialog when exiting without saving
"set nowrap             " turns off word wrapping
"set noswapfile         " no intermediate files used when saving
"set autoread           " automatically read ext. file changes

" **************************************
" * UI
" **************************************

" Set color scheme
silent! colorscheme peachpuff

" Syntax highlighting
syntax on
set showmatch                 " show match when inserting {}, [], or ()

" Highlights/colors
set cursorline                " highlight current line

hi Normal   guifg=white guibg=black
hi Visual   ctermbg=black guibg=black
hi Search   ctermfg=black guifg=black
hi NonText  ctermfg=black guifg=black

hi CursorLine   term=bold cterm=bold gui=bold ctermbg=black guibg=black
hi LineNr       ctermfg=darkgrey ctermbg=NONE guifg=darkgrey guibg=NONE
hi CursorLineNr term=bold cterm=bold gui=bold ctermfg=grey ctermbg=black guifg=grey guibg=black

hi Todo  cterm=reverse gui=reverse ctermfg=Yellow ctermbg=Black guifg=Yellow guibg=Black
hi Error cterm=reverse gui=reverse ctermfg=Red    ctermbg=Black guifg=Red    guibg=Black

hi ColorColumn  ctermbg=black guibg=black
hi Folded       ctermbg=black guibg=black

hi TabLine      term=NONE cterm=NONE gui=NONE ctermfg=white ctermbg=black guifg=white guibg=black
hi TabLineSel   term=bold cterm=bold gui=bold ctermfg=white ctermbg=NONE guifg=white guibg=NONE
hi TabLineFill  term=NONE cterm=NONE gui=NONE ctermfg=white ctermbg=black guifg=white guibg=black

hi StatusLine   term=bold cterm=bold gui=bold ctermfg=white ctermbg=black guifg=white guibg=black
hi StatusLineNC term=bold cterm=bold gui=bold ctermfg=darkgrey ctermbg=black guifg=darkgrey guibg=black

hi VertSplit term=NONE cterm=NONE gui=NONE ctermfg=white ctermbg=black guifg=white guibg=black

set shortmess+=I              " no splash screen

set scrolloff=5               " keep at least 5 lines above/below
set sidescrolloff=5           " keep at least 5 lines left/right

" Title
set title
set titlestring=%f

" Alawys show status line
set ls=2

" Statusline
" 1   .vimrc                                    ve   vim   0   12 - 193/689 - 25%
set statusline=\                                " initialize w/ space
set statusline+=%n                              " buffer number
set statusline+=\ %#Normal#%<\ %*               " separator
set statusline+=\ %f                            " relative path
set statusline+=%(\ [%{ExtModified()}%M%R]%)    " flags
set statusline+=\ %#Normal#                     " no highlight
set statusline+=%=                              " left/right separator
set statusline+=%*                              " statusline highlight
set statusline+=%(\ %{GetVe()}\ %)%#Normal#\ %* " virtualedit
set statusline+=\ %{GetSyntax()}                " syntax
set statusline+=\ %#Normal#\ %*                 " separator
set statusline+=\ %{TextWrapOn()}               " text wrap
set statusline+=%{TextWidth()}                  " text width/paste mode
set statusline+=\ %#Normal#\ %*                 " separator
set statusline+=\ %2c\ -\ %3l/%L\ -\ %P         " char# - curline/totline - file%
set statusline+=%{gutentags#statusline('\ \|\ TAGS')}
set statusline+=\                               " end w/ space

" Returns '!' if file externally modified since last read/write
" :e to get rid of this warning
function! ExtModified()
  return (exists('b:modified')) ? '!' : ''
endfunction

au FileChangedShellPost * let b:modified = 1
au BufRead,BufWrite * if exists('b:modified') |
                    \   unlet b:modified |
                    \ endif

" Returns a shortened form of &fdm
function! FDMShort()
  if &fdm == 'manual'
    return 'm'
  elseif &fdm == 'syntax'
    return 's'
  elseif &fdm == 'indent'
    return 'i'
  else
    return &fdm
  endif
endfunction

" Returns 've' if virtualedit is not off
function! GetVe()
  return (&ve == '') ? '' : 've'
endfunction

function! GetSyntax()
  return (&syntax != '') ? &syntax : 'plaintext'
endfunction

" Returns '*' if text wrap on
function! TextWrapOn()
  return  (!empty(matchstr(&fo, '.*t.*'))) ? '*' : ''
endfunction

" Returns &tw if paste mode is disabled
" Otherwise, return 'P'
function! TextWidth()
    return (!&paste) ? &tw : 'P'
endfunction

" Toggle minimal UI
let g:minimal = 0
function! ToggleMinimalUI()
  if !g:minimal
    let g:minimal = 1
    set noshowmode
    set noruler
    set showtabline=1
    set nonu
    set ls=0
  else
    let g:minimal = 0
    set showmode
    set ruler
    set showtabline=2
    set nu
    set ls=2
  endif
endfunction

command Minimal call ToggleMinimalUI()

" **************************************
" * Navigation
" **************************************

" Treat long lines as break lines (useful when moving around in them)
noremap <silent> j gj
noremap <silent> k gk
noremap <silent> <down> gj
noremap <silent> <up> gk
inoremap <silent> <down> <esc>gja
inoremap <silent> <up> <esc>gka

" Toggle relative line numbers
function! NumberToggle()
  if(&rnu == 1)
    set nornu
    set nu
  else
    set nonu
    set rnu
  endif
endfunction

noremap <silent> <leader>n :call NumberToggle()<cr>

" Toggle virtualedit
noremap <silent> <leader>e :let &virtualedit=&virtualedit=="" ? "all" : ""<cr>

" Preserve selection when (de)indenting in visual mode
vnoremap > >gv
vnoremap < <gv

" Swap 0 and ^
noremap 0 ^
noremap ^ 0

" === Buffers

" ,b[p/n] - Switch to next/prev buffer
noremap <leader>bn :bn<cr>
noremap <leader>bp :bN<cr>

" ,bl - List all buffers
noremap <leader>bl :buffers<cr>

" ,bs - Switch to buffer by name
noremap <leader>bs :buffers<cr>:buffer<space>

" ,bd - Close the current buffer
noremap <leader>bd :bd<cr>

" ,ba - Close all the buffers
noremap <leader>ba :1,1000 bd!<cr>

" Close all empty buffers
function! DeleteEmptyBuffers()
  let [i, n; empty] = [1, bufnr('$')]
  while i <= n
    if bufloaded(i) && bufname(i) == '' && getbufline(i, 1, 2) == ['']
      call add(empty, i)
    endif
    let i += 1
  endwhile
  if len(empty) > 0
    exe 'bdelete' join(empty)
  endif
endfunction

" ,be - Close all empty buffers
noremap <leader>be :exe DeleteEmptyBuffers()<cr>

" ,bt - Open all buffers as tabs
noremap <leader>bt :tab ball<cr>

" ,bcd - Switch CWD to the directory of the open buffer
noremap <leader>bcd :cd %:p:h<cr>:pwd<cr>

" Specify the behavior when switching between buffers
if exists('&switchbuf')
  set switchbuf=useopen,usetab,newtab
  set stal=2
endif

" === Splits

" Get rid of vertical split pipe
set fillchars+=vert:\ 

" Open new split panes to the right and bottom, instead of left and top
set splitbelow
set splitright

" ,[sv] - Horizontal/vertical split
noremap <leader>s <C-w>s
noremap <leader>v <C-w>v

" ,e - Equalize splits
noremap <leader>= <C-w>=

" ,[hjkl] - Switch to split
noremap <leader>j <C-W>j
noremap <leader>k <C-W>k
noremap <leader>h <C-W>h
noremap <leader>l <C-W>l

" ,[HJKL] - Move split
noremap <leader>J <C-W>J
noremap <leader>K <C-W>K
noremap <leader>H <C-W>H
noremap <leader>L <C-W>L

" ^[hjkl] - Resize split
noremap <silent> <c-j> :resize +1<cr>
noremap <silent> <c-k> :resize -1<cr>
noremap <silent> <c-l> :vertical resize +1<cr>
noremap <silent> <c-h> :vertical resize -1<cr>

" === Tabs

" Change maximum number of tabs
set tabpagemax=100

" Useful mappings for managing tabs
noremap <leader>tn :tabnew<cr>
noremap <leader>to :tabonly<cr>
noremap <leader>tw :tabclose<cr>
noremap <leader>tm :tabmove<Space>
noremap <leader>tb :tab ball<cr>
noremap <leader>tl :tabs<cr>

" Opens a new tab with a file
noremap <leader>te :tabedit <tab>

" ,[1-9] - Switch to tab #
noremap <leader>1 1gt
noremap <leader>2 2gt
noremap <leader>3 3gt
noremap <leader>4 4gt
noremap <leader>5 5gt
noremap <leader>6 6gt
noremap <leader>7 7gt
noremap <leader>8 8gt
noremap <leader>9 9gt

" ^[p / n] or ^[left / right] - Switch tabs
noremap <silent> <C-p> :tabprevious<cr>
noremap <silent> <C-n> :tabnext<cr>
inoremap <silent> <C-p> <esc>:tabprevious<cr>
inoremap <silent> <C-n> <esc>:tabnext<cr>
noremap <silent> <C-Left> :tabprevious<cr>
noremap <silent> <C-Right> :tabnext<cr>
inoremap <silent> <C-Left> <esc>:tabprevious<cr>
inoremap <silent> <C-Right> <esc>:tabnext<cr>

" m[T / t] / ^shift[left / right] - Move tabs
noremap <silent> mT :tabmove -1<cr>
noremap <silent> mt :tabmove +1<cr>
noremap <silent> <C-S-Left> :tabmove -1<cr>
noremap <silent> <C-S-Right> :tabmove +1<cr>
inoremap <silent> <C-S-Left> <esc>:tabmove -1<cr>
inoremap <silent> <C-S-Right> <esc>:tabmove +1<cr>

" === Folds

" Enable folds
if exists("+foldenable")
  set foldenable

  " Enable fold column
  " set foldcolumn=1
  hi FoldColumn ctermbg=NONE guibg=NONE

  " zz - toggle folds
  noremap zz za

  " The mode settings below all start with folds open

  " ,zm - Manual mode
  noremap <leader>zm :set foldmethod=manual<cr>zR

  " ,zi - Indent mode
  noremap <leader>zi :set foldmethod=indent<cr>zR

  " ,zs - Syntax mode
  noremap <leader>zs :set foldmethod=syntax<cr>zR

  " Use syntax mode by default
  set foldmethod=syntax

  " Unfold everything at start
  set foldlevel=99
endif

" === On exit

" Return to last edit position when opening files (You want this!)
au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") |
               \   exe "normal! g`\"" |
               \ endif

" **************************************
" * Style
" **************************************

" Format options:
"   t - Wrap text using textwidth
"   cro - Auto-insert comment leader when newlining
"   q - Enable formatting with 'gq'
"   w - End lines unless there is whitespace at the end
"   1 - Break lines before one-letter words
au BufNewFile,BufRead * setlocal fo=tcroqw1

" Line break only at breaking characters
set linebreak

" Default textwidth: 78
set tw=78

" Colorcolumn when textwidth on
au BufNewFile,BufRead * if !empty(matchstr(&fo, '.*t.*')) |
                      \   setlocal cc=+1 |
                      \ endif

" ,\ - Toggle text wrap & color column
function! ToggleTextWrap()
  if empty(matchstr(&fo, '.*t.*'))
    setlocal fo+=t
    setlocal cc=+1
  else
    setlocal fo-=t
    setlocal cc=0
  endif
endfunction

noremap <silent> <leader>\ :call ToggleTextWrap()<cr>

" ,f (normal mode) - Reformat all
noremap <silent> <leader>f mzgggqG`z

" ,f (visual mode) - Reflow selection
vnoremap <silent> <leader>f Jgqq

" Spellcheck
if v:version >= 700
  " ,/ss - Toggle spellcheck
  noremap <leader>cc :setlocal spell!<cr>

  " More spellcheck shortcuts
  noremap <leader>cn ]s
  noremap <leader>cp [s
  noremap <leader>ca zg
  noremap <leader>cw z=

  " Enable spell check for text files
  " au BufNewFile,BufRead *.txt setlocal spell spelllang=en
endif

" **************************************
" * Indentation / Syntax
" **************************************
"  expandtab: Expand tabs into spaces.
"    tabstop: The width of a tab.
" shiftwidth: The width of an auto-inserted tab.

filetype plugin indent on
set smarttab            " remove spaces grouped as tabs
set autoindent          " copy indent from previous line

" Defaults
set expandtab
set tabstop=2
set shiftwidth=2

" Define tab settings for filetypes via:
" au Syntax c,cpp,asm,java,py,othertypes setlocal whatever=#

" Markdown - 4 char wide tabs
au BufNewFile,BufFilePre,BufRead *.md set filetype=markdown
au Syntax markdown setlocal tabstop=4
au Syntax markdown setlocal shiftwidth=4

" Assembly - 8 char wide tabs, no expansion
au Syntax asm setlocal noexpandtab
au Syntax asm setlocal tabstop=8
au Syntax asm setlocal shiftwidth=8

" **************************************
" * Misc
" **************************************

" Check if file modified periodically
" set updatetime=1000
" au CursorHold * checktime

" Use DiffOrig to see file differences
command DiffOrig vert new | set bt=nofile | r ++edit # | 0d_
            \ | diffthis | wincmd p | diffthis

" ,r - Run using filetype
xnoremap <expr> <leader>r
      \ "\<Esc>:'<,'>:w !" . getbufvar('%', 'run_command', &filetype) . "\<cr>"

" No backups for crontab
autocmd filetype crontab setlocal nobackup nowritebackup

" Recursive tag search
set tags=./tags;

" === Make

" ,m - Make and go to first error
noremap <leader>m :silent make\|redraw!\|cc<cr>

" Set error formats for lint
set efm+=\ (%l)\ error:\ %m

" **************************************
" * Shortcuts
" **************************************

" === Required functions

function! StoreSearch()
  let g:ps = getreg('/', 1)
  let g:ps_t = getregtype('/')
endfunction

function! RestoreSearch()
  if !(exists('g:ps') && exists('g:ps_t'))
    return
  endif

  call setreg('/', g:ps, g:ps_t)
endfunction

" jj to esc
inoremap jj <esc>

" Swap ; and :
noremap ; :
noremap : ;

" Swap ' and `
noremap ' `
noremap ` '

" Better tag jumping
noremap <c-]> g<c-]>
noremap <c-w><c-]> <c-w>g<c-]>
noremap <c-w><c-}> <c-w>g<c-}>
noremap <leader>tt :tab split<CR>:exec("tag ".expand("<cword>"))<CR>

" <f5> - Reload file
noremap <f5> :e<cr>:echo "File Reloaded"<cr>

" ,y - Yank to clipboard
noremap <leader>y "+y

" ,p - Toggle paste mode
noremap <leader>p :setlocal paste!<cr>

" ,/ - Disable highlight
noremap <silent> <leader>/ :noh<cr>

" K - split line
noremap <silent> K i<cr><esc>

" ,[oO] - Create newlines in normal mode
noremap <silent> <leader>o o<esc>cc<esc>
noremap <silent> <leader>O O<esc>cc<esc>

" ,dd - Delete current line contents
noremap <silent> <leader>dd cc<esc>
vnoremap <silent> <leader>dd :mz<cr>:call StoreSearch()<cr>`<v`>:s/.*//<cr>:noh<cr>:call RestoreSearch()<cr>

" **************************************
" * Macros
" **************************************

" == ORD STUFF ==
" " File header function
" function FileHeader()
"     let s:line=line(".")
"     call setline(s:line, "/*******************************************************************************")
"     call append(s:line,  " * Filename: ".expand("%:t"))
"     call append(s:line+1," * Author: Ethan Chan")
"     call append(s:line+2," * Userid: cs30xhy")
"     call append(s:line+3," * Date: ".strftime("%D"))
"     call append(s:line+4," * Sources of Help: CSE 30 Website, handouts")
"     call append(s:line+5," *")
"     call append(s:line+6," * Description: ")
"     call append(s:line+7," *      ")
"     call append(s:line+8," * ****************************************************************************/")
"     unlet s:line
" endfunction
"
" " ,ih - Insert file header
" noremap <silent> <leader>ih mz:exe FileHeader()<cr>`z8<cr>A
"
" " Method header function
" function MethodHeader()
"     let s:line=line(".")
"     call setline(s:line,  "/*******************************************************************************")
"     call append(s:line,   " * Function name: ")
"     call append(s:line+1, " * Function prototype: TODO")
"     call append(s:line+2, " *")
"     call append(s:line+3, " * Description:")
"     call append(s:line+4, " *      TODO")
"     call append(s:line+5, " *")
"     call append(s:line+6, " * Parameters:")
"     call append(s:line+7, " *      arg 1: _name -- _desc TODO")
"     call append(s:line+8, " * Side effects:")
"     call append(s:line+9, " *      TODO")
"     call append(s:line+10," * Error conditions:")
"     call append(s:line+11," *      _errcond TODO")
"     call append(s:line+12," *          Action: _action TODO")
"     call append(s:line+13," * Return value: _type TODO")
"     call append(s:line+14," *      _val -- _meaning TODO")
"     call append(s:line+15," *")
"     call append(s:line+16," * Registers used:")
"     call append(s:line+17," *      %i0: _name -- _desc TODO")
"     call append(s:line+18," *")
"     call append(s:line+19," *      %l0: _name -- _desc TODO")
"     call append(s:line+20," *")
"     call append(s:line+21," *      %o0: _name -- _desc TODO")
"     call append(s:line+22," * ****************************************************************************/")
"     unlet s:line
" endfunction
"
" " ,im - Insert method header
" noremap <silent> <leader>im mz:exe MethodHeader()<cr>`z<cr>A

" ===Automatic actions on file open

" == ORD STUFF ==
" Automatically insert file header in *.{c,cpp,h,s}
" au BufNewFile *.{c,cpp,h,s} exe "normal mz:exe FileHeader()\<cr>zR`z8\<cr>A"
