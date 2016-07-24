" vimrc / init.vim
" Ethan Chan

" Best viewed with vim: syntax=vim foldmethod=marker foldlevel=0
" Use za to toggle the folds

" Setup {{{
  let s:configdir = '~/.vim'
  let s:configfile = '~/.vimrc'
  if has('nvim')
    let s:configdir = '~/.config/nvim'
    let s:configfile = s:configdir . '/init.vim'
  endif

  " Leader
  let mapleader = "\<Space>"
  let g:mapleader = "\<Space>"
  noremap <leader><space> <space>
" }}}
" Plugins {{{
  " Setup {{{
if empty(glob(s:configdir . '/autoload/plug.vim'))
  exec '!curl -fLo ' . s:configdir . '/autoload/plug.vim --create-dirs
        \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall | source $MYVIMRC
endif

if !empty(glob(s:configdir . '/autoload/plug.vim'))
  command! PU PlugUpdate | PlugUpgrade  " Update and upgrade
  command! PI PlugInstall               " Install

  call plug#begin(s:configdir . '/plugins')
  " }}}
  " Interface {{{
    Plug 'airblade/vim-gitgutter'           " Git gutter {{{
      let g:gitgutter_map_keys = 0
      nmap <leader>gn <Plug>GitGutterNextHunk
      nmap <leader>gp <Plug>GitGutterPrevHunk
      nmap <leader>ga <Plug>GitGutterStageHunk
      nmap <leader>gu <Plug>GitGutterUndoHunk
      nmap <leader>gs <Plug>GitGutterPreviewHunk
      omap ih <Plug>GitGutterTextObjectInnerPending
      omap ah <Plug>GitGutterTextObjectOuterPending
      xmap ih <Plug>GitGutterTextObjectInnerVisual
      xmap ah <Plug>GitGutterTextObjectOuterVisual
    " }}}
    Plug 'gummesson/stereokai.vim'          " Monokai for vim {{{
    " }}}
    Plug 'junegunn/goyo.vim'                " Enable minimalism {{{
      function! s:goyo_enter()
        set noshowmode
        set noshowcmd
        set scrolloff=999
        Limelight
        IndentLinesDisable
      endfunction

      function! s:goyo_leave()
        set showmode
        set showcmd
        set scrolloff=5
        Limelight!
        IndentLinesEnable
        call <SID>apply_highlights()
      endfunction

      autocmd! User GoyoEnter nested call <SID>goyo_enter()
      autocmd! User GoyoLeave nested call <SID>goyo_leave()
    " }}}
    Plug 'junegunn/limelight.vim'           " Spotlight on text {{{
      let g:limelight_conceal_ctermfg = 'darkgrey'
      let g:limelight_conceal_guifg = 'DarkGrey'
    " }}}
    Plug 'junegunn/rainbow_parentheses.vim' " Themed rainbow parens {{{
      au FileType lisp,clojure,scheme RainbowParentheses
    " }}}
    Plug 'haya14busa/incsearch.vim'         " Highlight all as searching {{{
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

      Plug 'haya14busa/incsearch-fuzzy.vim'   " Fuzzy search {{{
        map z/ <Plug>(incsearch-fuzzy-/)
        map z? <Plug>(incsearch-fuzzy-?)
        map zg/ <Plug>(incsearch-fuzzy-stay)
      " }}}
    " }}}
    Plug 'Konfekt/FastFold'                 " Faster folder {{{
    " }}}
    Plug 'mhinz/vim-startify'               " Start screen {{{
      let g:startify_change_to_vcs_root = 1
      if has('nvim')
        let g:startify_custom_header = [
        \ '   ┏┓╻┏━╸┏━┓╻ ╻╻┏┳┓',
        \ '   ┃┗┫┣╸ ┃ ┃┃┏┛┃┃┃┃',
        \ '   ╹ ╹┗━╸┗━┛┗┛ ╹╹ ╹',
        \ '']
      else
        let g:startify_custom_header = [
        \ '   ╻ ╻╻┏┳┓',
        \ '   ┃┏┛┃┃┃┃',
        \ '   ┗┛ ╹╹ ╹',
        \ '']
      endif
    " }}}
    Plug 'Yggdroot/indentLine'              " Indent guides {{{
      let g:indentLine_color_term = 8
      let g:indentLine_char = '│'
    " }}}
  " }}}
  " Completion {{{
    " Engine {{{
      if has('nvim')
        function! DoRemote(arg)
          UpdateRemotePlugins
        endfunction

        Plug 'Shougo/Deoplete.nvim', { 'do': function('DoRemote') }
        let g:completion_engine = 'deoplete'
        let s:completion_prefix = g:completion_engine . '#'
      elseif has('lua')
        if (version >= 704 || version == 703 && has('patch885'))
          Plug 'Shougo/neocomplete.vim'
          let g:completion_engine = 'neocomplete'
          let s:completion_prefix = g:completion_engine . '#'
        else
          Plug 'Shougo/neocomplcache.vim'
          let g:completion_engine = 'neocomplcache'
          let s:completion_prefix = g:completion_engine . '_'
        endif
      else
        Plug 'ervandew/supertab'
      endif
    " }}}
    " Settings {{{
      if exists('g:completion_engine')
        let g:{s:completion_prefix}enable_at_startup = 1
        let g:{s:completion_prefix}enable_smart_case = 1
        set completeopt-=preview
        imap <expr><tab>    pumvisible() ?
              \         "\<c-n>" :
              \         "\<tab>"
        imap <expr><cr>     pumvisible() ?
              \         neosnippet#expandable() ?
              \           neosnippet#mappings#expand_impl() :
              \           "\<c-y>" :
              \         neosnippet#jumpable() ?
              \           neosnippet#mappings#jump_impl() :
              \           "\<cr>"
        imap <expr><bs>     {g:completion_engine}#smart_close_popup() . "\<bs>"
        imap <expr><s-tab>  pumvisible() ? "\<c-p>" : "\<tab>"
      endif
    " }}}
  " }}}
  " Operators {{{
    Plug 'junegunn/vim-easy-align'          " Align with ga {{{
      xmap ga <Plug>(EasyAlign)
      nmap ga <Plug>(EasyAlign)
    " }}}
    Plug 'justinmk/vim-sneak'               " Two-character f and t {{{
      let g:sneak#streak = 1
      let g:sneak#use_ic_scs = 1
    " }}}
    Plug 'tommcdo/vim-exchange'             " Swap using cx {{{
    " }}}
    Plug 'tpope/vim-repeat'                 " Make repeat work with plugins {{{
    " }}}
    Plug 'tpope/vim-speeddating'            " ^a and ^x for dates {{{
    " }}}
    Plug 'tpope/vim-surround'               " Surround with... {{{
    " }}}
  " }}}
  " Text Objects {{{
    Plug 'glts/vim-textobj-comment'         " Comments {{{
    " }}}
    Plug 'kana/vim-textobj-function'        " Functions {{{
      Plug 'thinca/vim-textobj-function-javascript' " Javascript {{{
      " }}}
    " }}}
    Plug 'kana/vim-textobj-user'            " User-defined {{{
      Plug 'kana/vim-textobj-indent'          " Indentation levels {{{
      " }}}
    " }}}
    Plug 'reedes/vim-textobj-sentence'      " Better sentences {{{
    " }}}
    Plug 'wellle/targets.vim'               " More delimiters {{{
    " }}}
  " }}}
  " Utility {{{
    Plug 'bronson/vim-visual-star-search'   " Allow * and # on visual {{{
    " }}}
    Plug 'mattn/emmet-vim'                  " Emmet {{{
      let g:user_emmet_leader_key='<c-m>'
      let g:user_emmet_install_global = 0
      autocmd FileType html,css EmmetInstall
    " }}}
    Plug 'sheerun/vim-polyglot'             " Language packs {{{
    " }}}
    Plug 'junegunn/fzf'                     " Fuzzy find engine {{{
          \, { 'do': './install --bin' }
      Plug 'junegunn/fzf.vim'                 " Fuzzy find wrapper

      let g:fzf_files_options =
            \ '--preview "(pygmentize {} || cat {}) 2>/dev/null"'
      let g:fzf_buffers_jump = 1
      noremap <silent> <leader>x  <esc>:History<cr>
      noremap <silent> <leader>z  <esc>:Files<cr>
      noremap <silent> <leader>a  <esc>:Ag<cr>
      noremap <silent> <leader>q  <esc>:Lines<cr>
      noremap <silent> <leader>;  <esc>:History:<cr>
      noremap <silent> <leader>]  <esc>:exec("Tags '".expand("<cword>"))<cr>
      noremap <silent> <leader>?  <esc>:Helptags<cr>
      noremap <silent> <leader>gz <esc>:GFiles<cr>
      noremap <silent> <leader>gf <esc>:GFiles?<cr>
    " }}}
    Plug 'junegunn/vim-peekaboo'            " Register preview {{{
    " }}}
    Plug 'osyo-manga/vim-over'              " Better :%s/.../.../ {{{
      nnoremap <silent> <bslash> <esc>:OverCommandLine<cr>%s/
      vnoremap <silent> <bslash> <esc>gv:OverCommandLine<cr>s/
    " }}}
    Plug 'Shougo/neosnippet'                " Snippets {{{
      Plug 'Shougo/neosnippet-snippets'       " Snippets pack {{{
      " }}}
    " }}}
    Plug 'mbbill/undotree'                  " Undo tree browser {{{
      noremap <silent> <leader>u <esc>:UndotreeToggle<cr>
      let g:undotree_SetFocusWhenToggle = 1
      let g:undotree_ShortIndicators = 1
    " }}}
    Plug 'terryma/vim-multiple-cursors'     " Multiple cursors {{{
      let g:multi_cursor_use_default_mapping=0
      let g:multi_cursor_next_key='<C-c>'
      let g:multi_cursor_prev_key='<C-u>'
      let g:multi_cursor_skip_key='<C-x>'
      let g:multi_cursor_quit_key='<Esc>'

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
    " }}}
    Plug 'tomtom/tcomment_vim'              " Toggle comments {{{
    " }}}
    Plug 'tpope/vim-fugitive'               " Git functions {{{
    " }}}
    Plug 'tpope/vim-sleuth'                 " Autodetect indentation {{{
    " }}}
    Plug 'vim-scripts/BufOnly.vim'          " Delete all buffers but this one {{{
      noremap <silent> <leader>ba <esc>:BufOnly<cr>
    " }}}
  " }}}
  " Automation {{{
    Plug 'jiangmiao/auto-pairs'             " Automatically add delimiters {{{
      let g:AutoPairsShortcutToggle = ''
      let g:AutoPairsShortcutFastWrap = '<c-l>'
      let g:AutoPairsShortcutJump = ''
      let g:AutoPairsCenterLine = 0
      let g:AutoPairsMultilineClose = 0
    " }}}
    Plug 'ludovicchabant/vim-gutentags'     " Auto-generate ctags {{{
    " }}}
    Plug 'pbrisbin/vim-mkdir'               " Automatically mkdir {{{
    " }}}
  " }}}
  " Post-hooks {{{
    call plug#end()
  " }}}
  " Fallbacks {{{
else
  " Autocomplete {{{
    set omnifunc=syntaxcomplete#Complete
    inoremap <S-tab> <C-x><C-o>
  " }}}
  " Search {{{
    noremap N Nzz
    noremap n nzz
    noremap // /\c
    noremap ?? ?\c
  " }}}
  " Spellcheck {{{
    noremap <leader>cw z=
  " }}}
  " Auto-insert Curlies {{{
    inoremap {<cr> {<cr>}<C-o>O
  " }}}
  " Toggle Comments {{{
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

    noremap <silent> g> <esc>:call StoreSearch()<cr>:<C-B>silent <C-E>s/^/<C-R>=escape(b:comment_leader,'\/')<cr>/<cr>:noh<cr>:call RestoreSearch()<cr>
    noremap <silent> g< <esc>:call StoreSearch()<cr>:<C-B>silent <C-E>s/^\V<C-R>=escape(b:comment_leader,'\/')<cr>//e<cr>:noh<cr>:call RestoreSearch()<cr>
    xnoremap <silent> g> <esc>:call StoreSearch()<cr>gv:<C-B>silent <C-E>s/^/<C-R>=escape(b:comment_leader,'\/')<cr>/<cr>:noh<cr>:call RestoreSearch()<cr>gv
    xnoremap <silent> g< <esc>:call StoreSearch()<cr>gv:<C-B>silent <C-E>s/^\V<C-R>=escape(b:comment_leader,'\/')<cr>//e<cr>:noh<cr>:call RestoreSearch()<cr>gv
  " }}}
  " Toggle Distractions {{{
    let g:minimal = 0
    function! ToggleDistractions()
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

    if !exists(':DistractionsToggle')
      command DistractionsToggle call ToggleDistractions()
    endif
  " }}}
endif " }}}
" }}}
" General {{{
  set nu                            " line numbering on
  set noerrorbells                  " turns off annoying bell sounds for errors
  set visualbell                    " disable bell part 1
  set t_vb=                         " disable bell part 2
  set backspace=2                   " backspace over everything
  set fileformats=unix,dos,mac      " open files from mac/dos
  set hidden                        " don't bug me about abandoning buffers
  set nojoinspaces                  " don't add white space when I don't tell you to
  set autowrite                     " write before make
  set mouse=a                       " allow mouse usage
  set ttymouse=xterm2               " non-jumpy mouse visual select
  set hlsearch                      " highlights all search hits
  set ignorecase                    " search without regards to case
  set smartcase                     " search with smart casing
  set gdefault                      " default global sub
  set tags=./tags;                  " recursive tag search
  set efm+=\ (%l)\ error:\ %m       " lint error format
  set timeoutlen=1000 ttimeoutlen=0 " no escape key delay
  set ttyfast                       " assume speedy connection
  set undolevels=10000              " allow lots of undos
" }}}
" Interface {{{
  " General {{{
    " Set color scheme
    if has('gui_running')
      silent! colorscheme stereokai
    else
      silent! colorscheme peachpuff
    endif

    syntax on                      " Syntax highlighting
    set shortmess+=I               " no splash screen
    set showmatch                  " show match when inserting {}, [], or ()
    set scrolloff=5                " keep at least 5 lines above/below
    set sidescrolloff=5            " keep at least 5 lines left/right
    set title                      " allow titles
    set titlestring=%f             " title is the filename
    set ls=2                       " always show status line
    set lcs=tab:│\ ,trail:·,nbsp:_ " whitespace characters
    set list                       " enable whitespace characters
    " let loaded_matchparen = 0      " this is slow, might disable
  " }}}
  " Highlights / Colors {{{
    function! s:apply_highlights()
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
      hi clear SpellCap | hi SpellCap
            \ term=underline cterm=underline gui=underline
            \
            \
      hi clear SpellLocal | hi SpellLocal
            \ term=underline cterm=underline gui=underline
            \
            \
      hi clear SpellRare | hi SpellRare
            \ term=underline cterm=underline gui=underline
            \
            \

      " Cursor line
      hi clear LineNr | hi LineNr
            \
            \ ctermfg=darkgrey guifg=darkgrey
            \
      hi clear CursorLine | hi CursorLine
            \ term=bold     cterm=bold  gui=bold
            \ ctermbg=black guibg=black
            \
      hi clear CursorLineNr | hi CursorLineNr
            \ term=bold     cterm=bold  gui=bold
            \ ctermfg=grey  guifg=grey
            \ ctermbg=black guibg=black

      " Vertial lines
      hi clear CursorColumn | hi CursorColumn
            \
            \
            \ ctermbg=black guibg=black
      hi clear ColorColumn | hi ColorColumn
            \
            \
            \ ctermbg=black guibg=black
      hi clear VertSplit | hi VertSplit
            \
            \ ctermfg=white guifg=white
            \ ctermbg=black guibg=black

      " Tabs
      hi clear TabSel | hi TabLineSel
            \ term=bold     cterm=bold  gui=bold
            \ ctermfg=white guifg=white
            \
      hi clear TabLine | hi TabLine
            \
            \ ctermfg=white guifg=white
            \ ctermbg=black guibg=black
      hi clear TabLineFill | hi TabLineFill
            \
            \ ctermfg=white guifg=white
            \ ctermbg=black guibg=black

      " Status line
      hi clear StatusLine | hi StatusLine
            \ term=bold     cterm=bold  gui=bold
            \ ctermfg=white guifg=white
            \ ctermbg=black guibg=black
      hi clear StatusLineNC | hi StatusLineNC
            \ term=bold        cterm=bold     gui=bold
            \ ctermfg=darkgrey guifg=darkgrey
            \ ctermbg=black    guibg=black

      " Folds
      hi clear Folded | hi Folded
            \
            \ ctermfg=blue guifg=blue
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
    endfunction

    if !has('gui_running')
      call <SID>apply_highlights()
    endif
  " }}}
  " Status Line {{{
    " Utilities {{{
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
    " }}}

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

    " Tags status
    if exists(':GutentagsUnlock')
      set statusline+=%{gutentags#statusline('\ \|\ TAGS')}
    endif

    set statusline+=\                               " end w/ space
  " }}}
  " Cursor Shape {{{
    if has('nvim')
      let $NVIM_TUI_ENABLE_CURSOR_SHAPE=1
    else
      " Enter: Flashing block
      au VimEnter * silent execute "!echo -ne '\e[1 q'"
      silent! let &t_EI = "\<Esc>[1 q" " NORMAL:  Flashing block
      silent! let &t_SR = "\<Esc>[3 q" " REPLACE: Flashing underline
      silent! let &t_SI = "\<Esc>[5 q" " INSERT:  Flashing bar
      " Exit: Flashing bar
      au VimLeave * silent execute "!echo -ne '\e[5 q'"
    endif
  " }}}
" }}}
" Navigation {{{
  " General {{{
    " Treat long lines as break lines (useful when moving around in them)
    noremap <silent> j gj
    noremap <silent> k gk
    noremap <silent> <down> gj
    noremap <silent> <up> gk
    inoremap <silent> <down> <esc>gja
    inoremap <silent> <up> <esc>gka

    " Toggle relative line numbers
    function! ToggleLineNumbers()
      if(&rnu == 1)
        set nornu
      else
        set rnu
      endif
    endfunction

    noremap <silent> <leader>n <esc>:call ToggleLineNumbers()<cr>

    " Toggle virtualedit
    noremap <silent> <leader>e <esc>:let &virtualedit=&virtualedit=="" ? "all" : ""<cr>

    " Preserve selection when (de)indenting in visual mode
    xnoremap > >gv
    xnoremap < <gv

    " Swap 0 and ^
    noremap 0 ^
    noremap ^ 0

    " Return to last edit position when opening files
    au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") |
                   \   exe "normal! g`\"" |
                   \ endif
  " }}}
  " Buffers {{{
    " ,b[p/n] - Switch to next/prev buffer
    noremap <silent> <leader>bn <esc>:bn<cr>
    noremap <silent> <leader>bp <esc>:bN<cr>

    " ,bl - List all buffers
    noremap <silent> <leader>bl <esc>:buffers<cr>

    " ,bs - Switch to buffer by name
    noremap <leader>bs <esc>:buffers<cr>:buffer<space>

    " ,bd - Close the current buffer
    noremap <silent> <leader>bd <esc>:bd<cr>

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
    noremap <silent> <leader>be <esc>:call DeleteEmptyBuffers()<cr>

    " ,bt - Open all buffers as tabs
    noremap <silent> <leader>bt <esc>:tab ball<cr>

    " ,cd - Switch CWD to the directory of the open buffer
    noremap <silent> <leader>cd <esc>:cd %:p:h<cr> :pwd<cr>

    " Specify the behavior when switching between buffers
    if exists('&switchbuf')
      set switchbuf=useopen,usetab,newtab
    endif
  " }}}
  " Splits {{{
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

    " ^[hjkl] - Switch to split
    noremap <leader>h <C-W>h
    noremap <leader>j <C-W>j
    noremap <leader>k <C-W>k
    noremap <leader>l <C-W>l

    " ,[HJKL] - Move split
    noremap <leader>H <C-W>H
    noremap <leader>J <C-W>J
    noremap <leader>K <C-W>K
    noremap <leader>L <C-W>L

    " ,[hjkl] - Resize split
    noremap <silent> <c-h> <esc>:vertical resize -1<cr>
    noremap <silent> <c-j> <esc>:resize +1<cr>
    noremap <silent> <c-k> <esc>:resize -1<cr>
    noremap <silent> <c-l> <esc>:vertical resize +1<cr>
  " }}}
  " Tabs {{{
    set showtabline=1  " only show tab line if 2+ tabs
    set tabpagemax=100 " Change maximum number of tabs

    " Useful mappings for managing tabs
    noremap          <leader>te <esc>:tabedit <tab>
    noremap <silent> <leader>tn <esc>:tabnew<cr>
    noremap <silent> <leader>to <esc>:tabonly<cr>
    noremap <silent> <leader>td <esc>:tabclose<cr>
    noremap          <leader>tm <esc>:tabmove<Space>
    noremap <silent> <leader>tb <esc>:tab ball<cr>
    noremap <silent> <leader>tl <esc>:tabs<cr>

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
    noremap <silent> <C-p>  <esc>:tabprevious<cr>
    noremap <silent> <C-n>  <esc>:tabnext<cr>
    inoremap <silent> <C-p> <esc>:tabprevious<cr>
    inoremap <silent> <C-n> <esc>:tabnext<cr>
    noremap <silent> <C-Left>   <esc>:tabprevious<cr>
    noremap <silent> <C-Right>  <esc>:tabnext<cr>
    inoremap <silent> <C-Left>  <esc>:tabprevious<cr>
    inoremap <silent> <C-Right> <esc>:tabnext<cr>

    " m[T / t] / ^shift[left / right] - Move tabs
    noremap <silent> mT  <esc>:tabmove -1<cr>
    noremap <silent> mt  <esc>:tabmove +1<cr>
    noremap <silent> <C-S-Left>   <esc>:tabmove -1<cr>
    noremap <silent> <C-S-Right>  <esc>:tabmove +1<cr>
    inoremap <silent> <C-S-Left>  <esc>:tabmove -1<cr>
    inoremap <silent> <C-S-Right> <esc>:tabmove +1<cr>

    " ,t(g)t - Open tag in tab
    noremap <silent> <leader>tt  <esc>:tab split<cr>:exec("tag ".expand("<cword>"))<cr>
    noremap <silent> <leader>tgt <esc>:tab split<cr>:exec("tjump ".expand("<cword>"))<cr>
  " }}}
  " Folds {{{
    if exists("+foldenable")
      set foldenable

      " Enable fold column
      " set foldcolumn=1
      hi FoldColumn ctermbg=NONE guibg=NONE

      " z<space> - toggle folds
      noremap zz za

      " The mode settings below all start with folds open

      " zm - Marker mode
      noremap zm <esc>:set foldmethod=marker<cr>zR

      " zi - Indent mode
      noremap zi <esc>:set foldmethod=indent<cr>zR

      " zs - Syntax mode
      noremap zs <esc>:set foldmethod=syntax<cr>zR

      " Use syntax mode by default
      set foldmethod=syntax

      " Unfold everything at start
      set foldlevel=99
    endif
  " }}}
" }}}
" Style {{{
  " General {{{
    " Format options:
    "   t - Wrap text using textwidth
    "   cro - Auto-insert comment leader when newlining
    "   q - Enable formatting with 'gq'
    "   w - End lines unless there is whitespace at the end
    "   1 - Break lines before one-letter words
    au BufNewFile,BufRead * setlocal fo=tcroqw1
    set linebreak " line break only at breaking characters
    set tw=78     " default textwidth

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

    noremap <silent> <leader>\ <esc>:call ToggleTextWrap()<cr>

    " ,f (visual mode) - Reflow selection
    xnoremap <silent> <leader>f Jgqq

    " Spellcheck
    " ,/cc - Toggle spellcheck
    noremap <silent> <leader>cc <esc>:setlocal spell!<cr>

    " More spellcheck shortcuts
    noremap <leader>cn ]s
    noremap <leader>cp [s
    noremap <leader>ca zg

    " Enable spell check for text files
    au BufNewFile,BufRead *.txt setlocal spell spelllang=en
  " }}}
  " Syntax / Filetype {{{
    filetype plugin indent on
    set smarttab            " remove spaces grouped as tabs
    set autoindent          " copy indent from previous line
    set expandtab           " expand tabs into spaces
    set tabstop=2           " tab is 2 spaces
    set shiftwidth=2        " tab is 2 spaces

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

    " crontab - no backups
    au filetype crontab setlocal nobackup nowritebackup
  " }}}
" }}}
" Utilities {{{
  " General {{{
    " Use DiffOrig to see file differences
    if !exists(':DiffOrig')
      command DiffOrig vert new | set bt=nofile | r ++edit # | 0d_
            \ | diffthis | wincmd p | diffthis
    endif

    " ,r - Run using filetype
    xnoremap <expr> <leader>r
          \ "\<Esc>:'<,'>:w !" . getbufvar('%', 'run_command', &filetype) . "\<cr>"
  " }}}
  " Centralized swap files {{{
    if exists('&directory')
      set directory=~/.vim/swaps           " set swap directory
      set backupskip=/tmp/*,/private/tmp/* " no backups for tmp files
      if !isdirectory(&directory)
        silent call mkdir(&directory, 'p')
      endif
    endif
  " }}}
  " Persistent Undo {{{
    if exists('&undodir')
      set undodir=~/.vim/undo    " set undo directory
      set undofile               " use an undo file
      if !isdirectory(&undodir)
        silent call mkdir(&undodir, 'p')
      endif
    endif
  " }}}
  " File backups {{{
    if exists('&backupdir')
      set backupdir=~/.vim/backups  " set backup directory
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

  " There's only four words in the English langauge with jj.
  inoremap jj <esc>

  " Swap ; and :
  noremap ; :
  noremap : ;

  " Swap ' and `
  noremap ' `
  noremap ` '

  " Indent-aware pasting
  noremap p ]p
  noremap P [p

  " Y - Yank to clipboard
  noremap Y "+y

  " ,p - Toggle paste mode
  noremap <silent> <leader>p <esc>:setlocal paste!<cr>

  " ,/ - Disable highlight
  noremap <silent> <leader>/  <esc>:noh<cr>

  " K - split line
  noremap <silent> K i<cr><esc>

  " ,m - Make and go to first error
  noremap <silent> <leader>m <esc>:silent make\|redraw!\|cc<cr>
" }}}
" Macros {{{
  " " File header function
  " function FileHeader()
  "     let s:line=line(".")
  "     call setline(s:line, "/*******************************************************************************")
  "     call append(s:line,  " * Filename: ".expand("%:t"))
  "     call append(s:line+1," * Author: Ethan Chan")
  "     call append(s:line+3," * Date: ".strftime("%D"))
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
  "
  " Automatically insert file header in *.{c,cpp,h,s}
  " au BufNewFile *.{c,cpp,h,s} exe "normal mz:exe FileHeader()\<cr>zR`z8\<cr>A"
" }}}
