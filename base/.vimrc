" vimrc / init.vim
" Author: Ethan Chan

" Best viewed with vim: syntax=vim foldmethod=marker foldlevel=0
" Use za to toggle the folds.

" Setup {{{
  let s:configdir = $HOME . (has('nvim') ? '/.config/nvim' : '/.vim')

  " Source any local configuration
  let s:localrc = s:configdir . '/local.vim'
  if !empty(glob(s:localrc))
    exe 'source '.s:localrc
  endif

  " Leader
  let mapleader = "\<Space>"
  let g:mapleader = mapleader
  noremap <leader><space> <space>
" }}}
" Plugins {{{
  " Native: Extended matching for %
  runtime macros/matchit.vim

  if empty(glob(s:configdir . '/autoload/plug.vim'))
    let s:plugfile = s:configdir . '/autoload/plug.vim'
    exe 'silent !curl -fLo ' . s:plugfile . ' --create-dirs
          \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
    exe 'source ' . s:plugfile
    au VimEnter * PlugInstall
  endif

  command! PU PlugUpdate | PlugUpgrade  " Update and upgrade
  command! PI PlugInstall               " Install

  call plug#begin(s:configdir . '/plugins')
  " Interface {{{
    " Start screen
    Plug 'mhinz/vim-startify'
    let g:startify_list_order = [
          \ ['   Bookmarks'], 'bookmarks',
          \ ['   Sessions'], 'sessions',
          \ ['   Files'], 'files',
          \ ['   Directory'], 'dir',
          \ ['   Commands'], 'commands']
    let g:startify_relative_path = 1
    let g:startify_session_autoload = 1
    let g:startify_session_persistence = 1
    let g:startify_session_delete_buffers = 1
    let g:startify_session_sort = 1
    let g:startify_custom_header = ''

    " Indent guides
    Plug 'Yggdroot/indentLine'
    let g:indentLine_color_term = 8
    let g:indentLine_char = '│'

    " Git gutter
    Plug 'airblade/vim-gitgutter'
    let g:gitgutter_map_keys = 0
    nmap [g <Plug>(GitGutterPrevHunk)
    nmap ]g <Plug>(GitGutterNextHunk)
    nmap <leader>ga <Plug>(GitGutterStageHunk)
    nmap <leader>gu <Plug>(GitGutterUndoHunk)
    nmap <leader>go <Plug>(GitGutterPreviewHunk)
    omap ig <Plug>(GitGutterTextObjectInnerPending)
    omap ag <Plug>(GGitGutterTextObjectOuterPending)
    xmap ig <Plug>(GGitGutterTextObjectInnerVisual)
    xmap ag <Plug>(GGitGutterTextObjectOuterVisual)

    " Register preview
    Plug 'junegunn/vim-peekaboo'
    let g:peekaboo_delay = 100
  " }}}
  " Text objects {{{
    Plug 'kana/vim-textobj-user'
    Plug 'kana/vim-textobj-entire'
    Plug 'kana/vim-textobj-line'
    Plug 'kana/vim-textobj-indent'
    Plug 'glts/vim-textobj-comment'
    Plug 'wellle/targets.vim'
  " }}}
  " Operators {{{
    " User operators
    Plug 'kana/vim-operator-user'

    " Make repeat work with plugins
    Plug 'tpope/vim-repeat'

    " Surround with...
    Plug 'tpope/vim-surround'
    nmap s <Plug>Ysurround
    nmap S <Plug>YSurround
    nmap ss <Plug>Yssurround
    nmap Ss <Plug>YSsurround
    nmap SS <Plug>YSsurround
    xmap s <Plug>VSurround
    xmap S <Plug>VgSurround

    " Exchange text
    Plug 'tommcdo/vim-exchange'

    " Toggle comments
    Plug 'tpope/vim-commentary'

    " Replace with register
    Plug 'vim-scripts/ReplaceWithRegister'

    " Align with ga
    Plug 'junegunn/vim-easy-align'
          \, { 'on': '<Plug>(EasyAlign)' }
    xmap ga <Plug>(EasyAlign)
    nmap ga <Plug>(EasyAlign)

    " Ablolish, Subvert, and Coerce
    Plug 'tpope/vim-abolish'
  " }}}
  " Utility {{{
    " Pop-up completion
    Plug 'vim-scripts/AutoComplPop'
    Plug 'skywind3000/vim-dict'

    " Syntax checker
    let g:ale_completion_enabled = 1
    Plug 'dense-analysis/ale'

    " Fuzzy find engine
    Plug 'junegunn/fzf'
          \, { 'do': './install --bin' }
          \| Plug 'junegunn/fzf.vim'
            \, { 'on': [
            \ 'Files', 'GFiles', 'Buffers', 'Colors', 'Ag', 'Lines',
            \ 'Blines', 'Tags', 'BTags', 'Marks', 'Windows', 'Locate',
            \ 'History', 'Snippets', 'Commits', 'BCommits', 'Commands',
            \ 'Maps', 'Helptags', 'Filetypes' ] }

    let g:fzf_files_options =
          \ '--preview "highlight -q --force -O ansi {} || cat {}"'
    let g:fzf_buffers_jump = 1
    nnoremap <silent> <leader>x  <esc>:History<cr>
    nnoremap <silent> <leader>z  <esc>:Files<cr>
    nnoremap          <leader>a  <esc>:Ag<space>
    nnoremap <silent> <leader>A  <esc>:exe('Ag '.expand('<cword>'))<cr>
    nnoremap <silent> <leader>bg <esc>:Lines<cr>
    nnoremap <silent> <leader>:  <esc>:History:<cr>
    nnoremap <silent> <leader>;  <esc>:Commands<cr>
    nnoremap <silent> <leader>]  <esc>:exe('Tags ^'.expand('<cword>').' ')<cr>
    nnoremap <silent> <leader>?  <esc>:Helptags<cr>
    nnoremap <silent> <leader>gz <esc>:GFiles<cr>
    nnoremap <silent> <leader>gs <esc>:GFiles?<cr>
    nnoremap          <leader>gg <esc>:GGrep<space>
    nnoremap <silent> <leader>GG <esc>:exe('GGrep '.expand('<cword>'))<cr>

    function! s:git_grep_handler(line)
      let parts = split(a:line, ':')
      let [f, l] = parts[0 : 1]
      exe 'e +' . l . ' `git rev-parse --show-toplevel`/'
            \. substitute(f, ' ', '\\ ', 'g')
    endfunction

    command! -nargs=+ GGrep call fzf#run({
          \ 'source':
          \ '(cd "$(git rev-parse --show-toplevel)" && git grep --color=always -niI --untracked "<args>")',
          \ 'sink': function('<sid>git_grep_handler'),
          \ 'options': '--ansi --multi',
          \ })

    " Multiple cursors
    Plug 'terryma/vim-multiple-cursors'

    " Undo tree browser
    Plug 'mbbill/undotree'
          \, { 'on': 'UndotreeToggle' }
    nnoremap <silent> <leader>u <esc>:UndotreeToggle<cr>
    let g:undotree_SetFocusWhenToggle = 1
    let g:undotree_ShortIndicators = 1

    " Paired keybindings
    Plug 'tpope/vim-unimpaired'

    " Numi-esque code interpreter
    Plug 'metakirby5/codi.vim'
          \, { 'on': 'Codi' }
    let g:codi#interpreters = {
        \     'python': {
        \         'bin': 'python3',
        \     },
        \     'purescript': {
        \         'bin': ['pulp', 'psci'],
        \         'prompt': '^> ',
        \     },
        \ }

  " }}}
  " Automation {{{
    " Autodetect indentation
    Plug 'tpope/vim-sleuth'

    " Automatically set paste
    Plug 'ConradIrwin/vim-bracketed-paste'

    " Context-aware paste
    Plug 'sickill/vim-pasta'

    " Automatically return to last edit position
    Plug 'dietsche/vim-lastplace'

    " Automatically add delimiters
    Plug 'jiangmiao/auto-pairs'
    let g:AutoPairsShortcutToggle = ''
    let g:AutoPairsShortcutFastWrap = '<c-l>'
    let g:AutoPairsShortcutJump = ''
    let g:AutoPairsCenterLine = 0
    let g:AutoPairsMapSpace = 0
    let g:AutoPairsMultilineClose = 0

    " Automatically mkdir
    Plug 'pbrisbin/vim-mkdir'

    " Automatically add endif, etc.
    Plug 'tpope/vim-endwise'
  " }}}
  " Languages {{{
    Plug 'sheerun/vim-polyglot'
    let g:polyglot_disabled = ['csv']
  " }}}
  call plug#end()
" }}}
" General {{{
  set vb t_vb=                      " disable bell
  set backspace=2                   " backspace over everything
  set virtualedit=block             " arbitrary cursor position in visual block
  set fileformats=unix,dos,mac      " open files from mac/dos
  set hidden                        " don't bug me about abandoning buffers
  set nojoinspaces                  " don't add white space on join line
  set autowrite                     " write before make
  set mouse=a                       " allow mouse usage
  set hlsearch                      " highlights all search hits
  set ignorecase                    " search without regards to case
  set smartcase                     " search with smart casing
  set infercase                     " smart casing for keyword completion
  set gdefault                      " default global sub
  set tags=./tags;                  " recursive tag search
  set efm+=\ (%l)\ error:\ %m       " lint error format
  set timeoutlen=1000 ttimeoutlen=0 " no escape key delay
  set ttyfast                       " assume speedy connection
  set undolevels=10000              " allow lots of undos
  set updatetime=500                " fire hold events every half-second
  set showcmd                       " show keystrokes as they are typed

  " Save vim information in config dir, accounting for nvim
  exe "set viminfo='100,h,n".s:configdir.'/'.(has('nvim') ? 'nv_' : '').'info'

  " Make gx select whole WORDs
  let g:netrw_gx="<cWORD>"
" }}}
" Interface {{{
  " General {{{
    " Set color scheme
    colorscheme habamax

    set guioptions-=r              " no gui scrollbar
    set shortmess+=I               " no splash screen
    set showmatch                  " show match when inserting {}, [], or ()
    set scrolloff=5                " keep at least 5 lines above/below
    set sidescrolloff=5            " keep at least 5 lines left/right
    set title                      " allow titles
    set titlestring=%f             " title is the filename
    set ls=2                       " always show status line
    set lcs=tab:│\ ,trail:·,extends:>,precedes:<,nbsp:_ " whitespace characters
    set fillchars=stl:\ ,stlnc:\ ,vert:\ ,fold:\ ,diff:\  " line characters
    set list                       " enable whitespace characters

    silent! set signcolumn=yes     " always show sign column (e.g. GitGutter)
  " }}}
  " Highlights / Colors {{{
    function! s:apply_highlights()
      " Normal text
      hi clear Normal | hi Normal
            \
            \
            \ ctermbg=NONE

      " Empty lines, etc.
      hi clear NonText | hi NonText
            \
            \ ctermfg=darkgrey guifg=darkgrey
            \ ctermbg=NONE

      " End of buffer tildes
      hi clear EndOfBuffer | hi EndOfBuffer
            \
            \ ctermfg=black guifg=black
            \

      " Keep colors in visual
      hi clear Visual | hi Visual
            \ term=reverse cterm=reverse gui=reverse
            \
            \

      " Matching delimiter color
      hi clear MatchParen | hi MatchParen
            \
            \
            \ ctermbg=darkgrey guibg=darkgrey

      " Terms
      hi clear Search | hi Search
            \
            \ ctermfg=black  guifg=black
            \ ctermbg=yellow guibg=yellow
      hi clear Todo | hi Todo
            \ cterm=reverse  gui=reverse
            \ ctermfg=yellow guifg=yellow
            \ ctermbg=black  guibg=black
      hi clear Error | hi Error
            \ cterm=reverse gui=reverse
            \ ctermfg=red   guifg=red
            \ ctermbg=black guibg=black
      hi clear SpellBad | hi SpellBad
            \ term=underline cterm=underline gui=underline
            \ ctermfg=red    guifg=red
            \
      hi clear SpellOkay | hi SpellOkay
            \ term=underline cterm=underline gui=underline
            \
            \
      hi clear SpellCap | hi link SpellCap SpellOkay
      hi clear SpellLocal | hi link SpellLocal SpellOkay
      hi clear SpellRare | hi link SpellRare SpellOkay

      " Cursor line
      hi clear LineNr | hi LineNr
            \
            \ ctermfg=black guifg=black
            \
      hi clear SignColumn | hi link SignColumn LineNr
      hi clear CursorLine | hi CursorLine
            \ term=bold     cterm=bold  gui=bold
            \
            \ ctermbg=black guibg=black
      hi clear CursorLineNr | hi CursorLineNr
            \ term=bold     cterm=bold  gui=bold
            \ ctermfg=grey  guifg=grey
            \ ctermbg=black guibg=black

      " Vertial lines
      hi clear Column | hi Column
            \
            \
            \ ctermbg=black guibg=black
      hi clear CursorColumn | hi link CursorColumn Column
      hi clear ColorColumn | hi link ColorColumn Column
      hi clear VertSplit | hi VertSplit
            \
            \ ctermfg=white guifg=white
            \ ctermbg=black guibg=black

      " Tabs
      hi clear TabSel | hi TabLineSel
            \ term=bold     cterm=bold  gui=bold
            \ ctermfg=gray guifg=gray
            \ ctermbg=NONE guibg=NONE
      hi clear TabLine | hi TabLine
            \ term=bold     cterm=bold  gui=bold
            \ ctermfg=black guifg=black
            \ ctermbg=NONE guibg=NONE
      hi clear TabLineFill | hi link TabLineFill TabLine

      " Status line
      hi clear StatusLine | hi StatusLine
            \ term=bold     cterm=bold  gui=bold
            \ ctermfg=grey guifg=grey
            \ ctermbg=NONE guibg=NONE
      hi clear StatusLineNC | hi StatusLineNC
            \ term=bold        cterm=bold     gui=bold
            \ ctermfg=darkgrey guifg=darkgrey
            \ ctermbg=NONE    guibg=NONE

      " Folds
      hi clear Folded | hi Folded
            \
            \ ctermfg=blue guifg=blue
            \
      hi clear FoldColumn | hi FoldColumn
            \
            \ ctermbg=NONE guibg=NONE
            \

      " Diffs
      hi clear DiffAdd | hi DiffAdd
            \
            \ ctermfg=green guifg=green
            \
      hi clear DiffChange | hi DiffChange
            \
            \ ctermfg=yellow guifg=yellow
            \
      hi clear DiffDelete | hi DiffDelete
            \
            \ ctermfg=red guifg=red
            \

      " Completion menu
      hi clear Pmenu | hi Pmenu
            \
            \ ctermfg=white guifg=black
            \ ctermbg=black guibg=blue
      hi clear PmenuSel | hi PmenuSel
            \ term=bold     cterm=bold  gui=bold
            \ ctermfg=white guifg=white
            \ ctermbg=blue  guibg=blue
      hi clear PmenuSbar | hi PmenuSbar
            \
            \
            \ ctermbg=white guibg=white
      hi clear PmenuThumb | hi PmenuThumb
            \
            \
            \ ctermbg=blue guibg=blue

      " -- INSERT --
      hi clear ModeMsg | hi ModeMsg
            \ term=bold        cterm=bold     gui=bold
            \ ctermfg=darkgrey guifg=darkgrey
            \ ctermbg=NONE    guibg=NONE

      " ALE
      hi clear ALEErrorSign | hi ALEErrorSign
            \
            \ ctermfg=red guifg=red
            \
      hi clear ALEWarningSign | hi ALEWarningSign
            \
            \ ctermfg=yellow guifg=yellow
            \
    endfunction

    if !has('gui_running')
      call s:apply_highlights()
      augroup CUSTOM_COLORS
        au!
        au ColorScheme * call s:apply_highlights()
      augroup END
    endif
  " }}}
  " Status Line {{{
    " Utilities {{{
      augroup MODIFIED_FLAG
        au!
        au FileChangedShellPost * let b:modified = 1
        au BufRead,BufWrite * if exists('b:modified') |
                            \   unlet b:modified |
                            \ endif
      augroup END

      " Flags for statusline
      function! _s_flags()
        let flags = []

        " See if anything has changed git-wise
        if exists('*GitGutterGetHunkSummary')
          let gits = 0
          for i in GitGutterGetHunkSummary()
            let gits += i
          endfor
          if gits
            call add(flags, '~')
          endif
        endif

        " See if file externally modified
        if exists('b:modified')
          call add(flags, '!')
        endif

        return join(flags, ',')
      endfunction

      " Returns file's syntax
      function! _s_syntax()
        return (&syntax != '') ? &syntax : 'plaintext'
      endfunction

      " Returns &tw if paste mode is disabled
      " Otherwise, return 'P'
      function! _s_tw()
        return (!&paste) ? &tw : 'P'
      endfunction
    " }}}
    " FILENAME                              ~,+   78   vim   44 - 807/1242
    set statusline=\ %f\                            " filename
    set statusline+=%#ErrorMsg#                     " error highlight
    set statusline+=%#Normal#                       " no highlight
    set statusline+=%=                              " left/right separator
    set statusline+=%*                              " statusline highlight
    set statusline+=%(\ %{_s_flags()}%M%R%)         " flags
    set statusline+=\ %#Normal#\ %*                 " separator
    set statusline+=\ %{_s_tw()}                    " text width/paste mode
    set statusline+=\ %#Normal#\ %*                 " separator
    set statusline+=\ %{_s_syntax()}                " syntax
    set statusline+=\ %#Normal#\ %*                 " separator
    set statusline+=\ %2c\ -\ %3l/%L                " x, y/ymax
    set statusline+=\                               " end w/ space
  " }}}
  " Cursor Shape
  if has('nvim')
    let $NVIM_TUI_ENABLE_CURSOR_SHAPE=1
  else
    silent! let &t_EI = "\<Esc>[1 q" " NORMAL:  Flashing block
    silent! let &t_SR = "\<Esc>[3 q" " REPLACE: Flashing underline
    silent! let &t_SI = "\<Esc>[5 q" " INSERT:  Flashing bar
  endif

  " Quickfix Splits
  augroup QUICKFIX_SPLITS
    au!
    au BufEnter * if &buftype == 'quickfix'
          \ | noremap <buffer> q <esc>:q<cr>
          \ | endif
  augroup END

  " Help Splits
  augroup HELP_SPLITS
    au!
    au BufEnter * if &buftype == 'help'
          \ | wincmd L | exe 'vert resize ' . (&tw + 2)
          \ | noremap <buffer> q <esc>:q<cr>
          \ | endif
  augroup END
" }}}
" Navigation {{{
  " General {{{
    " Treat long lines as break lines (useful when moving around in them)
    " Account for <count>j/k
    noremap <silent> <expr> j v:count ? 'j' : 'gj'
    noremap <silent> <expr> k v:count ? 'k' : 'gk'
    noremap <silent> <expr> <down> v:count ? 'j' : 'gj'
    noremap <silent> <expr> <up> v:count ? 'k' : 'gk'
    inoremap <silent> <down> <esc>gja
    inoremap <silent> <up> <esc>gka

    " Preserve selection when (de)indenting in visual mode
    xnoremap > >gv
    xnoremap < <gv

    " Swap 0 and ^, treat long lines as break lines
    noremap 0 g^
    noremap ^ g0
    noremap $ g$

    " Shift-tab to go back in jumplist
    noremap <s-tab> <c-o>
  " }}}
  " Buffers {{{
    " ,bd - Close the current buffer
    nnoremap <silent> <leader>bd <esc>:bd<cr>

    " ,bs - Switch to buffer by name
    nnoremap <leader>bs <esc>:buffers<cr>:buffer<space>

    " ,bc - Switch buffer CWD to the directory of the open buffer
    nnoremap <silent> <leader>bc <esc>:lcd %:p:h<cr> :pwd<cr>

    " Specify the behavior when switching between buffers
    if exists('&switchbuf')
      set switchbuf=useopen,usetab
    endif
  " }}}
  " Splits {{{
    " Open new split panes to the right and bottom, instead of left and top
    set splitbelow
    set splitright

    " ,[sv] - Horizontal/vertical split
    nnoremap <leader>s <C-w>s
    nnoremap <leader>v <C-w>v

    " ,_ - Equalize splits
    nnoremap <leader>_ <C-w>=

    " ,[hjkl] - Switch to split
    nnoremap <leader>h <C-W>h
    nnoremap <leader>j <C-W>j
    nnoremap <leader>k <C-W>k
    nnoremap <leader>l <C-W>l

    " ,[HJKL] - Move split
    nnoremap <leader>H <C-W>H
    nnoremap <leader>J <C-W>J
    nnoremap <leader>K <C-W>K
    nnoremap <leader>L <C-W>L

    " ^[hjkl] - Resize split
    nnoremap <silent> <c-h> <c-w><
    nnoremap <silent> <c-j> <c-w>+
    nnoremap <silent> <c-k> <c-w>-
    nnoremap <silent> <c-l> <c-w>>
  " }}}
  " Tabs {{{
    set showtabline=1  " only show tab line if 2+ tabs
    set tabpagemax=100 " Change maximum number of tabs

    " Useful mappings for managing tabs
    nnoremap          <leader>te <esc>:tabedit <tab>
    nnoremap <silent> <leader>tn <esc>:tabnew<cr>:silent! Startify<cr>
    nnoremap <silent> <leader>to <esc>:tabonly<cr>
    nnoremap <silent> <leader>td <esc>:tabclose<cr>
    nnoremap          <leader>tm <esc>:tabmove<Space>
    nnoremap <silent> <leader>tb <esc>:tab ball<cr>
    nnoremap <silent> <leader>tl <esc>:tabs<cr>

    " ,[1-9] - Switch to tab #
    nnoremap <leader>1 1gt
    nnoremap <leader>2 2gt
    nnoremap <leader>3 3gt
    nnoremap <leader>4 4gt
    nnoremap <leader>5 5gt
    nnoremap <leader>6 6gt
    nnoremap <leader>7 7gt
    nnoremap <leader>8 8gt
    nnoremap <leader>9 9gt

    " [w ]w / H L - Forward and backwards tabs
    nnoremap <silent> [w <esc>:tabprevious<cr>
    nnoremap <silent> ]w <esc>:tabnext<cr>
    nnoremap <silent> H <esc>:tabprevious<cr>
    nnoremap <silent> L <esc>:tabnext<cr>

    " [W ]W - Move tabs
    nnoremap <silent> [W <esc>:tabmove -1<cr>
    nnoremap <silent> ]W <esc>:tabmove +1<cr>

    " ,t(g)t - Open tag in tab
    nnoremap <silent> <leader>tt  <esc>:tab split<cr>:exe("tag ".expand("<cword>"))<cr>
    nnoremap <silent> <leader>tgt <esc>:tab split<cr>:exe("tjump ".expand("<cword>"))<cr>
  " }}}
  " Folds {{{
    if exists("+foldenable")
      set foldenable

      " Zo - Solo curent fold
      nnoremap Zo zMzvzz

      " Zm - Marker mode
      nnoremap Zm <esc>:set foldmethod=marker<cr>zR

      " Zi - Indent mode
      nnoremap Zi <esc>:set foldmethod=indent<cr>zR

      " Zs - Syntax mode
      nnoremap Zs <esc>:set foldmethod=syntax<cr>zR
    endif
  " }}}
  " Pane toggles {{{
    nnoremap <silent> cpc <esc>:cw<cr>
    nnoremap <silent> cpl <esc>:lw<cr>
  " }}}
" }}}
" Style {{{
  " General {{{
    " Format options:
    "   t  - Wrap text using textwidth
    "   c  - Auto-wrap comments
    "   ro - Auto-insert comment leader when newlining
    "   q  - Enable formatting with 'gq'
    "   l  - don't auto-format existing long lines
    "   mM - auto-break for kanji
    "   j  - Exclude comment leader when joining lines
    augroup FORMAT_OPTIONS
      au!
      au BufNewFile,BufRead * setlocal fo=tcroqlmM
      if (version >= 704)
        au BufNewFile,BufRead * setlocal fo+=j
      endif
    augroup END

    " Text file format options:
    "   n - Recognize numbered lists
    "   2 - Paragraph-style indents
    augroup FORMAT_OPTIONS_TXT
      au!
      au BufNewFile,BufRead *.txt,*.md setlocal fo+=n2
    augroup END

    let s:default_tw = 78 " default textwidth
    set linebreak         " line break only at breaking characters
    exe 'set textwidth=' . s:default_tw

    " cot - Toggle text wrap & color column
    function! ToggleTextWidth()
      if (!&paste)
        if (&textwidth == 0)
          exe 'set textwidth=' . s:default_tw
        else
          set textwidth=0
        endif
      else
        echohl WarningMsg | echom 'Paste mode on.' | echohl None
      endif
    endfunction

    nnoremap cot <esc>:call ToggleTextWidth()<cr>

    " ,f (visual mode) - Reflow selection
    xnoremap <silent> <leader>f Jgqq

    " Spellcheck
    set spelllang=en
  " }}}
  " Syntax / FileType {{{
    set smarttab            " remove spaces grouped as tabs
    set autoindent          " copy indent from previous line
    set expandtab           " expand tabs into spaces
    set tabstop=2           " tab is 2 spaces
    set shiftwidth=2        " tab is 2 spaces

    " C indent options
    set cino+=l1   " align with case label
    set cino+=Ws   " indent after lone (
    set cino+=m1   " align ) like }
    set cino+=j1   " properly indent anonymous classes/functions
    set cino+=J1   " properly indent javascript objects
    set cino+=N-s  " don't indent in namespaces
    set cino+=g0   " don't indent scope labels
    set cino+=+0   " don't indent after template directive

    " Define tab settings for filetypes via:
    " au Syntax c,cpp,asm,java,py,othertypes setlocal whatever=#

    " Assembly - 8 char wide tabs, no expansion
    augroup SYNTAX_ASM
      au!
      au Syntax asm setlocal noexpandtab
      au Syntax asm setlocal tabstop=8
      au Syntax asm setlocal shiftwidth=8
    augroup END

    " crontab - no backups
    augroup SYNTAX_CRONTAB
      au!
      au FileType crontab setlocal nobackup nowritebackup
    augroup END
  " }}}
" }}}
" Utilities {{{
  " General {{{
    " :Diff - see file differences
    command! Diff vert new | set bt=nofile | r ++edit # | 0d_
          \ | diffthis | wincmd p | diffthis

    " :Run - Execute current script
    function! s:runbuf(...)
      if exists('s:runbuf') | exe 'bdel '.s:runbuf | endif
      new
      let s:runbuf = bufnr('%')
      setlocal buftype=nofile
      let args = a:000
      map(args, 'shellescape(v:val)')
      silent exe 'r !./# '.join(args, ' ')
      wincmd p
    endfunction
    command! -nargs=* Run call s:runbuf(<f-args>)

    " :Sudow - to write as sudo
    function! s:sudow(...)
      let file = a:0 ? join(a:000, ' ') : bufname('%')
      silent! exe 'w !sudo tee '.file
    endfunction
    command! -nargs=* Sudow call s:sudow(<f-args>)

    " ,q - edit macro
    nnoremap <leader>q :<c-u><c-r><c-r>='let @q = '
          \.string(getreg('q'))<cr><c-f><left>
  " }}}
  " Completion {{{
    " Set completion sources.
    set cpt=.,k,w,b

    " Suppress info messages.
    set shortmess+=c

    inoremap <expr> <tab>   pumvisible() ? "\<c-y>"  : "\<tab>"
    inoremap <expr> <cr>    pumvisible() ? "\<c-y>"  : "\<cr>"
    inoremap <expr> .       pumvisible() ? "\<c-y>." : "."
  " }}}
  " Centralized swap files {{{
    if exists('&directory')
      exe 'set directory='.s:configdir.'/swaps'
      set backupskip=/tmp/*,/private/tmp/* " no backups for tmp files
      if !isdirectory(&directory)
        silent call mkdir(&directory, 'p')
      endif
    endif
  " }}}
  " Persistent Undo {{{
    if exists('&undodir')
      exe 'set undodir='.s:configdir.'/undo'
      set undofile               " use an undo file
      if !isdirectory(&undodir)
        silent call mkdir(&undodir, 'p')
      endif
    endif
  " }}}
  " File backups {{{
    if exists('&backupdir')
      exe 'set backupdir='.s:configdir.'/backups'
      if !isdirectory(&backupdir)
        silent call mkdir(&backupdir, 'p')
      endif
    endif
  " }}}
  " Autocomplete Menus {{{
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
  " }}}
" }}}
" Shortcuts {{{
  " Quickly source vimrc
  command! Resource source $MYVIMRC

  " Swap ; and :
  noremap ; :
  noremap : ;

  " Swap ' and `
  noremap ' `
  noremap ` '

  " Preserve prefix when going through history
  cnoremap <c-n> <down>
  cnoremap <c-p> <up>

  " <leader>[y/p/P/d] - Interact with clipboard
  noremap <leader>y "+y
  noremap <leader>p "+]p
  noremap <leader>P "+]P
  noremap <leader>d "+d

  " _ - Delete to _
  noremap _ "_d

  " Q - Replay macro
  noremap Q @q

  " cop - Toggle paste mode
  nnoremap cop <esc>:setlocal paste!<cr>

  " K - split line
  noremap K i<cr><esc>

  " U - fix syntax highlighting
  nnoremap <silent> U <esc>:syntax sync fromstart<cr>
" }}}
" vimdiff {{{
  noremap <leader>gr :diffget REMOTE<cr>
  noremap <leader>gb :diffget BASE<cr>
  noremap <leader>gl :diffget LOCAL<cr>
" }}}
