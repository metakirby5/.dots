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

" Enable more shortcuts with , key
let mapleader = ","
let g:mapleader = ","

" **************************************
" * Theme
" **************************************

colorscheme default

" If no color schemes installed, light bg
set background=light

" Syntax highlighting
syntax on

" Extra options for GUI mode
if has('gui_running')
	set guifont=Consolas:h12:cANSI
endif

" **************************************
" * UI
" **************************************

" Alawys show status line
set ls=2

" example: .vimrc [sh] [+]        PASTE MODE | 5 - 71/94 - 42%
set statusline=%f\ %y\ %m%=%{HasPaste()}%c\ -\ %l/%L\ -\ %P

" Returns true if paste mode is enabled
function! HasPaste()
    if &paste
        return 'PASTE MODE | '
    en
    return ''
endfunction

" **************************************
" * Variables
" **************************************

set nocompatible		" get rid of strict vi compatibility
set nu				" line numbering on
set autoindent			" turns autoindent on
set smartindent			" turns smartindent on
set noerrorbells		" turns off annoying bell sounds for errors
set backspace=2			" backspace over everything
set fileformats=unix,dos,mac	" open files from mac/dos
set exrc			" open local config files
set nojoinspaces		" don't add white space when I don't tell you to
set showmatch			" show match when inserting {}, [], or ()
set noswapfile			" no intermediate files used when saving
set ruler			" always show position in file
set wildmenu			" show autocomplete for commands
set autowrite			" write before make
set mouse-=a			" disallow mouse usage
set hlsearch			" highlights all search hits
set smartcase			" smart search casing

" Set these to your preference
"set incsearch			" incremental search
"set visualbell			" screen flashes instead of error bell
"set ignorecase			" search without regards to case
"set confirm			" Shows dialog when exiting without saving
"set nowrap			" turns off word wrapping

" **************************************
" * Shortcuts
" **************************************

" ,w - Save
nmap <leader>w :w<cr>

" ,p - Toggle paste mode
map <leader>p :setlocal paste!<cr>

" ,c - Toggle over 80 char highlighting
function! Toggle80Char ()
	if exists('w:m2')
		call matchdelete(w:m2)
		unlet w:m2
	else
		let w:m2 = matchadd('ErrorMsg', '\%>80v.\+', -1)
	endif
endfunction

map <silent> <leader>c :call Toggle80Char()<CR>

" ,<cr> - Disable highlight
map <silent> <leader><cr> :noh<cr>

" ,= - Quick retab of everything
map <leader>= <Esc>gg=G<ESC>:retab<CR>

" **************************************
" * Style
" **************************************

" When going over 80 chars, will start highlighting red
let w:m2=matchadd('ErrorMsg', '\%>80v.\+', -1)

" Removes any trailing whitespace in the file upon closing
autocmd BufRead,BufWrite * if ! &bin | silent! %s/\s\+$//ge | endif

" Automate the formatted insertion of a new line in multi-line comments
:set formatoptions+=r

" ,m - Remove Windows' ^M
noremap <Leader>m mmHmt:%s/<C-V><cr>//ge<cr>'tzt'm

" ,ss - Toggle spellcheck
map <leader>ss :setlocal spell!<cr>

" Shortcuts using <leader>
map <leader>sn ]s
map <leader>sp [s
map <leader>sa zg
map <leader>s? z=

" **************************************
" * Indentation
" **************************************
" expandtab: Expand tabs in the following file extensions to spaces so that
"            they are spaces instead of tabs
" tabstop: When tab is pressed, inserts 4 spaces instead
" shiftwidth: (with auto-indentation) when indent happens, inserts 4 spaces
"             instead

" Remove tabs intelligently
set smarttab

" Defaults
set tabstop=4
set shiftwidth=4

au BufRead,BufNewFile *.{c,h,cpp,hpp,java,ml} set expandtab
au BufRead,BufNewFile *.{c,h,cpp,hpp,java,ml,py} set tabstop=4
au BufRead,BufNewFile *.{c,h,cpp,hpp,java,ml,py} set shiftwidth=4

" For assembly files, will do special tabbing.  Make them 8 chars wide.
" The following is for assembly file indentation
au BufRead,BufNewFile *.s set noexpandtab
au BufRead,BufNewFile *.s set tabstop=8
au BufRead,BufNewFile *.s set shiftwidth=8

" For python, one-line comments indent weird. This fixes it.
autocmd BufRead *.py inoremap # X#

" **************************************
" * Navigation
" **************************************

" Treat long lines as break lines (useful when moving around in them)
map j gj
map k gk

" 0 - First non-blank character
map 0 ^

" ctrl-[hjkl] - Switch to split
map <C-j> <C-W>j
map <C-k> <C-W>k
map <C-h> <C-W>h
map <C-l> <C-W>l

" ,[jk] - Move line of text
nmap <leader>j mz:m+<cr>`z
nmap <leader>k mz:m-2<cr>`z
vmap <leader>j :m'>+<cr>`<my`>mzgv`yo`z
vmap <leader>k :m'<-2<cr>`>my`<mzgv`yo`z

" Close the current buffer
map <leader>bd :bd<cr>

" Close all the buffers
map <leader>ba :1,1000 bd!<cr>

" Useful mappings for managing tabs
map <leader>tn :tabnew<cr>
map <leader>to :tabonly<cr>
map <leader>tc :tabclose<cr>
map <leader>tm :tabmove

" Opens a new tab with the current buffer's path
" Super useful when editing files in the same directory
map <leader>te :tabedit <c-r>=expand("%:p:h")<cr>/

" Switch CWD to the directory of the open buffer
map <leader>d :cd %:p:h<cr>:pwd<cr>

" Specify the behavior when switching between buffers
try
  set switchbuf=useopen,usetab,newtab
  set stal=2
catch
endtry

" Return to last edit position when opening files (You want this!)
autocmd BufReadPost *
     \ if line("'\"") > 0 && line("'\"") <= line("$") |
     \   exe "normal! g`\"" |
     \ endif
" Remember info about open buffers on close
set viminfo^=%
