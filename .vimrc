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

" Enable more shortcuts with <Space> key
let mapleader = " "
let g:mapleader = " "

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
nnoremap <leader>w :w<cr>

" ,q - Quit
noremap <leader>q :q<CR>

" ,p - Toggle paste mode
noremap <leader>p :setlocal paste!<cr>

" ,<cr> - Disable highlight
noremap <silent> <leader><cr> :noh<cr>

" ,= - Quick retab of everything
noremap <leader>= <Esc>gg=G<ESC>:retab<CR>

" ,c - Toggle over 80 char highlighting
function! Toggle80Char ()
	if exists('w:m2')
		call matchdelete(w:m2)
		unlet w:m2
	else
		let w:m2 = matchadd('ErrorMsg', '\%>80v.\+', -1)
	endif
endfunction

noremap <silent> <leader>c :call Toggle80Char()<CR>

" ,[jk] - Move line of text
nnoremap <leader>j mz:m+<cr>`z
nnoremap <leader>k mz:m-2<cr>`z
vnoremap <leader>j :m'>+<cr>`<my`>mzgv`yo`z
vnoremap <leader>k :m'<-2<cr>`>my`<mzgv`yo`z

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
noremap <leader>ss :setlocal spell!<cr>

" Shortcuts using <leader>
noremap <leader>sn ]s
noremap <leader>sp [s
noremap <leader>sa zg
noremap <leader>s? z=

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
noremap j gj
noremap k gk

" 0 - First non-blank character
noremap 0 ^
" ,0 - Legacy behavior
noremap <leader>0 0

" ,[hv] - Horizontal/vertical split
noremap <leader>h <C-w>s
noremap <leader>v <C-w>v

" ctrl-[hjkl] - Switch to split
noremap <C-j> <C-W>j
noremap <C-k> <C-W>k
noremap <C-h> <C-W>h
noremap <C-l> <C-W>l

" Close the current buffer
noremap <leader>bd :bd<cr>

" Close all the buffers
noremap <leader>ba :1,1000 bd!<cr>

" Useful mappings for managing tabs
noremap <C-t> :tabnew<cr>
noremap <leader>to :tabonly<cr>
noremap <leader>tc :tabclose<cr>
noremap <leader>tm :tabmove<Space>

" Opens a new tab with the current buffer's path
" Super useful when editing files in the same directory
noremap <leader>te :tabedit <c-r>=expand("%:p:h")<cr>/

" ctrl-[leftarrow | rightarrow] - Switch tabs
noremap <silent> <C-Right> :tabnext<CR>
noremap <silent> <C-Left> :tabprevious<CR>

" ctrl-shift-[leftarrow | rightarrow] - Move tabs
noremap <silent> <C-S-Right> :tabmove +1<CR>
noremap <silent> <C-S-Left> :tabmove -1<CR>

" Switch CWD to the directory of the open buffer
noremap <leader>d :cd %:p:h<cr>:pwd<cr>

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
