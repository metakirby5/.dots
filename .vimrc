" ~/.vimrc
" Angie Nguyen, Minji Yoon
" Last modified: 11 January 2014
" Sources: http://vim.wikia.com/
"
" If you have any questions, email me at ann045@ucsd.edu

" **************************************
" * VARIABLES
" **************************************
" Comment out the ones you don't like by putting a " before the line

set nocompatible		" get rid of strict vi compatibility
set nu				" line numbering on
set autoindent			" turns autoindent on
set smartindent			" turns smartindent on
set noerrorbells		" turns off annoying bell sounds for errors
"set visualbell			" screen flashes instead of error bell
set ignorecase			" search without regards to case
set backspace=2			" backspace over everything
"set confirm			" Shows dialog when exiting without saving
"set nowrap			" turns off word wrapping
set fileformats=unix,dos,mac	" open files from mac/dos
set exrc			" open local config files
set nojoinspaces		" don't add white space when I don't tell you to
set showmatch			" show match when inserting {}, [], or ()
"set incsearch			" incremental
set noswapfile			" no intermediate files used when saving
set ruler			" always show position in file

set wildmenu			" show autocomplete for commands
set autowrite			" write before make
set mouse-=a			" disallow mouse usage
set hlsearch			" highlights all search hits
set smartcase			" smart search casing

" **************************************
" * Macros
" **************************************
" Python
autocmd BufRead *.py inoremap # X#

" **************************************
" * OVER 80 CHARS!
" **************************************
" When going over 80 chars, will start highlighting red
let w:m2=matchadd('ErrorMsg', '\%>80v.\+', -1)

" Removes any trailing whitespace in the file upon closing
autocmd BufRead,BufWrite * if ! &bin | silent! %s/\s\+$//ge | endif

" automate the formatted insertion of a new line in multi-line comments
:set formatoptions+=r

" **************************************
" * TABBING:set formatoptions+=r
" :set formatoptions+=r
"
" **************************************
" Check out shortcut section for auto-retabbing shortcut

" expandtab: Expand tabs in the following file extensions to spaces so that
"            they are spaces instead of tabs
" tabstop: When tab is pressed, inserts 4 spaces instead
" shiftwidth: (with auto-indentation) when indent happens, inserts 4 spaces
"             instead

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

" **************************************
" * AESTHETICS
" **************************************

" There are lots of colorschemes you can use! My personal favorite is
" desert. You can see all the colors by opening a file and doing
" :colorscheme <CTRL> + <D> and then picking an option.
"
:colorscheme default

" if no colorschemes installed, can use the following.
" light: makes font change as if background was light
" dark: makes font change as if background was dark
"
" set bg=light


" syntax off: will turn off syntax highlighting/coloring
"         on: will turn on syntax highlighting/coloring
syntax on

if has('gui_running')
	set guifont=Consolas:h12:cANSI
endif

" **************************************
" * QUICK SHORTCUTS
" **************************************

" You can add shortcuts of your own similarly.

" hit F10 while not in insert mode to do a quick write and quit
map <F10> <Esc>:wq<CR>
" hit F11 while not in insert mode to quickly retab everything
map <F11> <Esc>gg=G<ESC>:retab<CR>

