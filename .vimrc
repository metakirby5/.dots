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

" Enable more shortcuts with <space> key (denoted as , in shortcuts)
let mapleader = " "
let g:mapleader = " "

" Preserve legacy mapping
noremap <leader><space> <space>

" **************************************
" * Variables
" **************************************

set nocompatible        " get rid of strict vi compatibility
set nu                  " line numbering on
set noerrorbells        " turns off annoying bell sounds for errors
set backspace=2         " backspace over everything
set fileformats=unix,dos,mac    " open files from mac/dos
set hidden              " hide abandoned buffers
set exrc                " open local config files
set nojoinspaces        " don't add white space when I don't tell you to
set noswapfile          " no intermediate files used when saving
set autowrite           " write before make
set mouse-=a            " disallow mouse usage
set hlsearch            " highlights all search hits
set ignorecase          " search without regards to case
set smartcase           " search with smart casing
filetype on             " filetype stuff
filetype plugin on      " filetype stuff
filetype plugin indent on   " filetype stuff

" Autocomplete menus
if has("wildmenu")
    set wildignore+=*.a,*.o
    set wildignore+=*.bmp,*.gif,*.ico,*.jpg,*.png
    set wildignore+=.DS_Store,.git,.hg,.svn
    set wildignore+=*~,*.swp,*.tmp
    set wildmenu
    set wildignorecase
    set wildmode=full
    set wildcharm=<C-i>
endif

" Autocomplete text
set omnifunc=syntaxcomplete#Complete

" Persistent undo
try
    set undodir=~/.vimUndo/ " set undo directory
    set undofile            " use an undo file
catch
endtry

" Set these to your preference
"set incsearch          " incremental search
"set visualbell         " screen flashes instead of error bell
"set confirm            " shows dialog when exiting without saving
"set nowrap             " turns off word wrapping

" **************************************
" * Theme
" **************************************

" Set color scheme
colorscheme desert

" Syntax highlighting
syntax on
set showmatch           " show match when inserting {}, [], or ()

" Extra options for GUI mode
if has('gui_running')
    set guifont=Consolas:h12:cANSI
endif

" **************************************
" * UI
" **************************************

set shortmess+=I              " no splash screen

set scrolloff=5               " keep at least 5 lines above/below
set sidescrolloff=5           " keep at least 5 lines left/right

" Alawys show status line
set ls=2

" Statusline
" example: 1 | .vimrc [vim] [+]        s/tcroq1 | *80 |  52 - 099/523 - 17%
set statusline=                   " initialize
set statusline+=\ %2n             " buffer number
set statusline+=\ \|\             " separator
set statusline+=%f                " relative path
set statusline+=\ %y              " filetype
set statusline+=\ %m              " modified flag
set statusline+=%=                " left/right separator
set statusline+=%{FDMShort()}     " fold method
set statusline+=/%{&fo}           " format options
set statusline+=\ \|\             " separator
set statusline+=%{Has80Char()}    " 80 char highlighting
set statusline+=%2{TextWidth()}   " text width/paste mode
set statusline+=\ \|\             " separator

" char# - curline/totline - file%
set statusline+=%20(\ %2c\ -\ %3l/%3L\ -\ %P\ %)

" Returns '*' if > 80 char highlighting enabled
function! Has80Char()
    return (exists('w:m2')) ? '*' : ''
endfunction

" Returns &tw if paste mode is disabled
" Otherwise, return 'P'
function! TextWidth()
    return (!&paste) ? &tw : 'P'
endfunction

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

"set ruler          " default ruler

" **************************************
" * Shortcuts
" **************************************

" Swap ; and :
" noremap ; :
" noremap : ;

" Search mappings: These will make it so that going to the next one in a
" search will center on the line it's found in.
noremap N Nzz
noremap n nzz

" // ?? - Quick case insensitive search
noremap // /\c
noremap ?? ?\c

" shift-<tab> - Omni complete (not really useful in C)
" inoremap <S-tab> <C-x><C-o>

" ^\ - Save
noremap <C-\> :w<cr>
inoremap <C-\> <esc>:w<cr>

" ,q - Quit
noremap <leader>q :q<cr>

" ,p - Toggle paste mode
noremap <leader>p :setlocal paste!<cr>

" ,<cr> - Disable highlight
noremap <silent> <leader><cr> :noh<cr>

" ,= - Quick retab of everything
noremap <silent> <leader>= mzgg=G<esc>:retab<cr>'z

" ,[jk] - Move line of text
nnoremap <leader>j mz:m+<cr>`z
nnoremap <leader>k mz:m-2<cr>`z
vnoremap <leader>j :m'>+<cr>`<my`>mzgv`yo`z
vnoremap <leader>k :m'<-2<cr>`>my`<mzgv`yo`z

" ,[oO] - Create newlines in normal mode
nnoremap <silent> <leader>o o<esc>
nnoremap <silent> <leader>O O<esc>

" ,n - Splits a line at the cursor, then moves to column 81
nnoremap <silent> <leader>n i<cr><esc>80l

" **************************************
" * Macros
" **************************************

" Insert matching curly brace
inoremap {<cr> {<cr>}<C-o>O

" File header function
function FileHeader()
    let s:line=line(".")
    call setline(s:line, "/*******************************************************************************")
    call append(s:line,  " * Filename: ".expand("%:t"))
    call append(s:line+1," * Author: Ethan Chan")
    call append(s:line+2," * Userid: cs30xhy")
    call append(s:line+3," * Date: ".strftime("%D"))
    call append(s:line+4," * Sources of Help: CSE 30 Website, handouts")
    call append(s:line+5," *")
    call append(s:line+6," * Description: ")
    call append(s:line+7," *      ")
    call append(s:line+8," * ****************************************************************************/")
    unlet s:line
endfunction

" ,mh - Insert file header
nnoremap <silent> <leader>mh mz:exec FileHeader()<cr>'z8jA<backspace>

" Automatically do this in .{c,s} files
autocmd BufNewFile *.{c,cpp,s} normal mz
autocmd BufNewFile *.{c,cpp,s} exec FileHeader()
autocmd BufNewFile *.{c,cpp,s} normal 'z8jA

" Method header function
function MethodHeader()
    let s:line=line(".")
    call setline(s:line,  "/*******************************************************************************")
    call append(s:line,   " * Function name: ")
    call append(s:line+1, " * Function prototype: TODO")
    call append(s:line+2, " *")
    call append(s:line+3, " * Description:")
    call append(s:line+4, " *     TODO")
    call append(s:line+5, " *")
    call append(s:line+6, " * Parameters:")
    call append(s:line+7, " *     arg 1: $name -- $desc TODO")
    call append(s:line+8, " * Side effects:")
    call append(s:line+9, " *     TODO")
    call append(s:line+10," * Error conditions:")
    call append(s:line+11," *     $errcond TODO")
    call append(s:line+12," *         Action: $action TODO")
    call append(s:line+13," * Return value: $type TODO")
    call append(s:line+14," *     $val -- $meaning TODO")
    call append(s:line+15," *")
    call append(s:line+16," * Registers used:")
    call append(s:line+17," *     %i0: $name -- $desc TODO")
    call append(s:line+18," *")
    call append(s:line+19," *     %l0: $name -- $desc TODO")
    call append(s:line+20," *")
    call append(s:line+21," *     %o0: $name -- $desc TODO")
    call append(s:line+22," * ****************************************************************************/")
    unlet s:line
endfunction

" ,mm - Insert method header
nnoremap <silent> <leader>mm mz:exec MethodHeader()<cr>'zjA

" **************************************
" * Style
" **************************************

" Format options:
"   t - Wrap text using textwidth
"   cro - Auto-insert comment leader when newlining
"   q - Enable formatting with 'gq'
"   w - End lines unless there is whitespace at the end
"   1 - Break lines before one-letter words
autocmd BufNewFile,BufRead * setlocal formatoptions=tcroqw1

" When typing over 80 chars, line break
set textwidth=80
set linebreak

" Reformat all
function! FmtTW()
    normal mz
    normal gggqG
    normal 'z
endfunction

" ,f - Reformat all
noremap <silent> <leader>f mzgggqG'z

" ,\ - Toggle textwidth and reformat if needed
noremap <silent> <leader>\ :let &tw = (&tw ? 0 : 80)<cr>:call FmtTW()<cr>

" Highlight anything after virtual column 80 red
let w:m2=matchadd('ErrorMsg', '\%>80v.\+', -1)

" ,c - Toggle over 80 char highlighting
function! Toggle80Char()
    if exists('w:m2')
        call matchdelete(w:m2)
        unlet w:m2
    else
        let w:m2 = matchadd('ErrorMsg', '\%>80v.\+', -1)
    endif
endfunction

noremap <silent> <leader>c :call Toggle80Char()<cr>

" Removes any trailing whitespace in the file upon closing
autocmd BufRead,BufWrite * if ! &bin | silent! %s/\s\+$//ge | endif

" ,/m - Remove Windows' ^M
noremap <leader>/m mmHmt:%s/<C-V><cr>//ge<cr>'tzt'm

" Spellcheck
if v:version >= 700
    " ,/ss - Toggle spellcheck
    noremap <leader>/ss :setlocal spell!<cr>

    " More spellcheck shortcuts
    noremap <leader>/sn ]s
    noremap <leader>/sp [s
    noremap <leader>/sa zg
    noremap <leader>/s? z=

    " Enable spell check for text files
    " autocmd BufNewFile,BufRead *.txt setlocal spell spelllang=en
endif

" **************************************
" * Indentation
" **************************************
"  expandtab: Expand tabs into spaces.
"    tabstop: The width of a tab.
" shiftwidth: The width of an auto-inserted tab.

" set smarttab          " remove spaces grouped as tabs
set autoindent          " copy indent from previous line
set smartindent         " adjust indentation for curly braces, etc.

" Defaults
set expandtab
set tabstop=4
set shiftwidth=4

" Define tab settings for filetypes via:
" au BufRead,BufNewFile *.{c,h,cpp,hpp,java,ml,py,othertypes} set whatever=#

" For assembly files, 8 char wide tabs, no expansion
au BufRead,BufNewFile *.s set noexpandtab
au BufRead,BufNewFile *.s set tabstop=8
au BufRead,BufNewFile *.s set shiftwidth=8

" For python, one-line comments indent weird. This fixes it.
au BufRead,BufNewFile *.py inoremap # X#

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

" Preserve selection when (de)indenting in visual mode
vnoremap > ><CR>gv
vnoremap < <<CR>gv

" 0 - First non-blank character
noremap 0 ^
" ,0 - Legacy behavior
noremap <leader>0 0

" === Buffers

" ^[up / down] - Switch to prev/next buffer
noremap <C-down> :next<CR>
noremap <C-up> :previous<CR>
inoremap <silent> <C-down> <esc>:next<cr>
inoremap <silent> <C-up> <esc>:previous<cr>

" ,bl - List all buffers
noremap <leader>bl :buffers<CR>

" ,bs - Switch to buffer by name
noremap <leader>bs :buffers<CR>:buffer<space>

" ,bd - Close the current buffer
noremap <leader>bd :bd<cr>

" ,ba - Close all the buffers
noremap <leader>ba :1,1000 bd!<cr>

" ,bt - Open all buffers as tabs
noremap <leader>bt :tab ball<cr>

" ,d - Switch CWD to the directory of the open buffer
noremap <leader>d :cd %:p:h<cr>:pwd<cr>

" Specify the behavior when switching between buffers
try
    set switchbuf=useopen,usetab,newtab
    set stal=2
catch
endtry

" === Splits

" ,[sv] - Horizontal/vertical split
noremap <leader>s <C-w>s
noremap <leader>v <C-w>v

" ^[hjkl] - Switch to split
noremap <C-j> <C-W>j
noremap <C-k> <C-W>k
noremap <C-h> <C-W>h
noremap <C-l> <C-W>l
inoremap <C-j> <esc><C-W>j
inoremap <C-k> <esc><C-W>k
inoremap <C-h> <esc><C-W>h
inoremap <C-l> <esc><C-W>l

" ,[jk] - Resize height
noremap <silent> <leader><up> :resize +5<cr>
noremap <silent> <leader><down> :resize -5<cr>

" ,[hl] - Resize width
noremap <silent> <leader><right> :vertical resize +5<cr>
noremap <silent> <leader><left> :vertical resize -5<cr>

" === Tabs

" Useful mappings for managing tabs
noremap <C-t> :tabnew<cr>
inoremap <C-t> <esc>:tabnew<cr>
noremap <leader>to :tabonly<cr>
noremap <leader>tw :tabclose<cr>
noremap <leader>tm :tabmove<Space>
noremap <leader>tb :tab ball<cr>
noremap <leader>tl :tabs<cr>

" Opens a new tab with a file
noremap <leader>te :tabedit <tab><S-tab>

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

" ^[left / right] - Switch tabs
noremap <silent> <C-Right> :tabnext<cr>
noremap <silent> <C-Left> :tabprevious<cr>
inoremap <silent> <C-Right> <esc>:tabnext<cr>
inoremap <silent> <C-Left> <esc>:tabprevious<cr>

" ^shift[left / right] - Move tabs
noremap <silent> <C-S-Right> :tabmove +1<cr>
noremap <silent> <C-S-Left> :tabmove -1<cr>
inoremap <silent> <C-S-Right> <esc>:tabmove +1<cr>
inoremap <silent> <C-S-Left> <esc>:tabmove -1<cr>

" === Folds

" Enable folds
set foldenable

"" ,ft - Toggle foldenable
"noremap <leader>ft zi

" Enable fold column
set foldcolumn=1

"" ,ff - Toggle folds in normal mode, make folds in visual mode
"nnoremap <leader>ff za
"vnoremap <leader>ff zf
"
"" ,fF - Toggle folds recursively
"nnoremap <leader>fF zA
"
"" ,fa - Unfold all
"noremap <leader>fa zR
"
"" ,fA - Fold all
"noremap <leader>fA zM
"
"" ,fd - Delete fold
"noremap <leader>fd zd
"
"" ,fD - Delete folds recursively
"noremap <leader>fD zD
"
"" ,fE - Delete all folds
"noremap <leader>fE zE
"
"" ,f[jk] - Open/close folds by one level
"noremap <leader>fj zr
"noremap <leader>fk zm

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
au BufRead,BufNewFile * normal zR

" === On exit

" Return to last edit position when opening files (You want this!)
autocmd BufReadPost *
    \ if line("'\"") > 0 && line("'\"") <= line("$") |
    \   exe "normal! g`\"" |
    \ endif

" Remember info about open buffers on close
set viminfo^=%
