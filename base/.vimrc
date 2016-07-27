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
  let s:plugfile = s:configdir . '/autoload/plug.vim'
  exec 'silent !curl -fLo ' . s:plugfile . ' --create-dirs
        \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  exec 'source ' . s:plugfile
  au VimEnter * PlugInstall
endif

if !empty(glob(s:configdir . '/autoload/plug.vim'))
  command! PU PlugUpdate | PlugUpgrade  " Update and upgrade
  command! PI PlugInstall               " Install

  call plug#begin(s:configdir . '/plugins')
  " }}}
  " Interface {{{
    " Git gutter {{{
      Plug 'airblade/vim-gitgutter'
      let g:gitgutter_map_keys = 0
      nmap <leader>gn <Plug>GitGutterNextHunk
      nmap <leader>gp <Plug>GitGutterPrevHunk
      nmap <leader>ga <Plug>GitGutterStageHunk
      nmap <leader>gu <Plug>GitGutterUndoHunk
      nmap <leader>go <Plug>GitGutterPreviewHunk
      omap ih <Plug>GitGutterTextObjectInnerPending
      omap ah <Plug>GitGutterTextObjectOuterPending
      xmap ih <Plug>GitGutterTextObjectInnerVisual
      xmap ah <Plug>GitGutterTextObjectOuterVisual
    " }}}
    " Monokai for vim {{{
      Plug 'gummesson/stereokai.vim'
    " }}}
    " Enable minimalism {{{
      Plug 'junegunn/goyo.vim'
            \, { 'on': 'Goyo' }
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
    " Spotlight on text {{{
      Plug 'junegunn/limelight.vim'
            \, { 'on': 'Limelight' }
      let g:limelight_conceal_ctermfg = 'darkgrey'
      let g:limelight_conceal_guifg = 'DarkGrey'
    " }}}
    " Themed rainbow parens {{{
      Plug 'junegunn/rainbow_parentheses.vim'
            \, { 'for': [
            \ 'lisp',
            \ 'clojure',
            \ 'scheme' ] }
      augroup PLUG_RAINBOW_PARENTHESES
        au!
        au FileType lisp,clojure,scheme RainbowParentheses
      augroup END
    " }}}
    " Highlight all as searching {{{
      if (version >= 704)
        Plug 'haya14busa/incsearch.vim'
              \, { 'on': '<Plug>(incsearch' }
              \| Plug 'haya14busa/incsearch-fuzzy.vim'
                \, { 'on': '<Plug>(incsearch-fuzzy' }
        set hlsearch
        let g:incsearch#auto_nohlsearch = 1
        let g:incsearch#is_stay = 1
        map /  <Plug>(incsearch-forward)
        map ?  <Plug>(incsearch-backward)
        map // <Plug>(incsearch-forward)\c
        map ?? <Plug>(incsearch-backward)\c
        map n  <Plug>(incsearch-nohl-n)zz
        map N  <Plug>(incsearch-nohl-N)zz
        map *  <Plug>(incsearch-nohl-*)
        map #  <Plug>(incsearch-nohl-#)
        map g* <Plug>(incsearch-nohl-g*)
        map g# <Plug>(incsearch-nohl-g#)
        map z/ <Plug>(incsearch-fuzzy-/)
        map z? <Plug>(incsearch-fuzzy-?)
        map zg/ <Plug>(incsearch-fuzzy-stay)
      endif
    " }}}
    " Faster folder {{{
      Plug 'Konfekt/FastFold'
    " }}}
    " Start screen {{{
      Plug 'mhinz/vim-startify'
      let g:startify_list_order = [
            \ ['   Files'], 'files',
            \ ['   Directory'], 'dir',
            \ ['   Bookmarks'], 'bookmarks',
            \ ['   Sessions'], 'sessions',
            \ ['   Commands'], 'commands']
      let g:startify_change_to_vcs_root = 1
      let g:startify_relative_path = 1
      let g:startify_session_autoload = 1
      let g:startify_session_persistence = 1
      let g:startify_session_delete_buffers = 1
      let g:startify_session_sort = 1
      if has('nvim')
        let g:startify_ascii = [
              \ '            _     ',
              \ '  ___ _  __(_)_ _ ',
              \ ' / _ \ |/ / /  / \',
              \ '/_//_/___/_/_/_/_/',
              \ '']
      else
        let g:startify_ascii = [
              \ '       _     ',
              \ ' _  __(_)_ _ ',
              \ '| |/ / /  / \',
              \ '|___/_/_/_/_/',
              \ '']
      endif
      let g:startify_custom_header = map(g:startify_ascii, "\"   \".v:val")
    " }}}
    " Indent guides {{{
      Plug 'Yggdroot/indentLine'
      let g:indentLine_color_term = 8
      let g:indentLine_char = '│'

      " Fix json quotes
      Plug 'elzr/vim-json'
      let g:vim_json_syntax_conceal = 0
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
    " Snippets {{{
      if (version >= 704)
        Plug 'SirVer/ultisnips'
              \| Plug 'honza/vim-snippets'
        let g:UltiSnipsExpandTrigger = '<c-bslash>'
        let g:UltiSnipsJumpForwardTrigger = '<c-j>'
        let g:UltiSnipsJumpBackwardTrigger = '<c-k>'
      endif
    " }}}
    " Settings {{{
      if exists('g:completion_engine')
        let g:{s:completion_prefix}enable_at_startup = 1
        let g:{s:completion_prefix}enable_smart_case = 1
        set completeopt-=preview
        inoremap <expr> <tab>    pumvisible() ? "\<c-n>" : "\<tab>"
        inoremap <expr> <s-tab>  pumvisible() ? "\<c-p>" : "\<c-d>"
        inoremap <expr> <bs>     {g:completion_engine}#smart_close_popup() . "\<bs>"
        inoremap <silent> <cr>   <c-r>=<SID>smart_cr()<cr>

        let g:ulti_expand_or_jump_res = 0
        function! s:smart_cr()
          silent! call UltiSnips#ExpandSnippet()
          return g:ulti_expand_res ? "" :
                \ (pumvisible() ? "\<c-y>" : "\<cr>")
        endfunction
      endif
    " }}}
  " }}}
  " Operators {{{
    " Align with ga {{{
      Plug 'junegunn/vim-easy-align'
            \, { 'on': '<Plug>(EasyAlign)' }
      xmap ga <Plug>(EasyAlign)
      nmap ga <Plug>(EasyAlign)
    " }}}
    " Make repeat work with plugins {{{
      Plug 'tpope/vim-repeat'
    " }}}
    " Surround with... {{{
      Plug 'tpope/vim-surround'
    " }}}
  " }}}
  " Utility {{{
    " Allow * and # on visual {{{
      Plug 'bronson/vim-visual-star-search'
    " }}}
    " Emmet {{{
      Plug 'mattn/emmet-vim'
            \, { 'for': ['html', 'javascript.jsx'] }
      let g:user_emmet_leader_key='<c-e>'
    " }}}
    " Language packs {{{
      Plug 'sheerun/vim-polyglot'
    " }}}
    " Fuzzy find engine {{{
      Plug 'junegunn/fzf'
            \, { 'do': './install --bin' }
            \| Plug 'junegunn/fzf.vim'
              \, { 'on': [
              \ 'History',
              \ 'Files',
              \ 'Ag',
              \ 'Lines',
              \ 'History',
              \ 'Tags',
              \ 'Helptags',
              \ 'GFiles'] }

      let g:fzf_files_options =
            \ '--preview "(pygmentize {} || cat {}) 2>/dev/null"'
      let g:fzf_buffers_jump = 1
      noremap <silent> <leader>x  <esc>:History<cr>
      noremap <silent> <leader>z  <esc>:Files<cr>
      noremap          <leader>q  <esc>:Ag<space>
      noremap <silent> <leader>bq <esc>:Lines<cr>
      noremap <silent> <leader>;  <esc>:History:<cr>
      noremap <silent> <leader>]  <esc>:exec("Tags '".expand("<cword>"))<cr>
      noremap <silent> <leader>?  <esc>:Helptags<cr>
      noremap <silent> <leader>gz <esc>:GFiles<cr>
      noremap <silent> <leader>gs <esc>:GFiles?<cr>
      noremap          <leader>gq <esc>:GGrep<space>

      function! s:git_grep_handler(line)
        let parts = split(a:line, ':')
        let [f, l] = parts[0 : 1]
        execute 'e +' . l . ' `git rev-parse --show-toplevel`/'
              \. substitute(f, ' ', '\\ ', 'g')
      endfunction

      command! -nargs=+ GGrep call fzf#run({
            \ 'source':
            \ '(cd "$(git rev-parse --show-toplevel)" && git grep --color=always -niI --untracked "<args>")',
            \ 'sink': function('<sid>git_grep_handler'),
            \ 'options': '--ansi --multi',
            \ })
    " }}}
    " Emojis {{{
      Plug 'junegunn/vim-emoji'
            \, { 'for': ['markdown', 'gitcommit'] }
      augroup PLUG_VIM_EMOJI
        au!
        au FileType markdown,gitcommit setlocal completefunc=emoji#complete
      augroup END
    " }}}
    " Register preview {{{
      Plug 'junegunn/vim-peekaboo'
      let g:peekaboo_delay = 100
    " }}}
    " Tag browser {{{
      if v:version >= 703
        Plug 'majutsushi/tagbar'
              \, { 'on': 'TagbarToggle' }
        noremap <silent> <leader>[ <esc>:TagbarToggle<cr>
      endif
    " }}}
    " Undo tree browser {{{
      Plug 'mbbill/undotree'
            \, { 'on': 'UndotreeToggle' }
      noremap <silent> <leader>u <esc>:UndotreeToggle<cr>
      let g:undotree_SetFocusWhenToggle = 1
      let g:undotree_ShortIndicators = 1
    " }}}
    " Better :%s/.../.../ {{{
      Plug 'osyo-manga/vim-over'
              \, { 'on': 'OverCommandLine' }
      nnoremap <silent> <bslash> <esc>:OverCommandLine<cr>%s/
      vnoremap <silent> <bslash> <esc>gv:OverCommandLine<cr>s/
    " }}}
    " Syntax checker {{{
      Plug 'scrooloose/syntastic'
            \, { 'on': 'SyntasticCheck' }
      noremap <silent> <leader>- <esc>:SyntasticCheck<cr>
    " }}}
    " Multiple cursors {{{
      Plug 'terryma/vim-multiple-cursors'
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
    " Toggle comments {{{
      Plug 'tpope/vim-commentary'
    " }}}
    " Autodetect indentation {{{
      Plug 'tpope/vim-sleuth'
    " }}}
  " }}}
  " Automation {{{
  " Automatically return to last edit position {{{
      Plug 'dietsche/vim-lastplace'
  " }}}
    " Automatically add delimiters {{{
      Plug 'jiangmiao/auto-pairs'
      let g:AutoPairsShortcutToggle = ''
      let g:AutoPairsShortcutFastWrap = '<c-l>'
      let g:AutoPairsShortcutJump = ''
      let g:AutoPairsCenterLine = 0
      let g:AutoPairsMapSpace = 0
      let g:AutoPairsMultilineClose = 0
    " }}}
    " Auto-generate ctags {{{
      if (version >= 704)
        Plug 'ludovicchabant/vim-gutentags'
      endif
    " }}}
    " Automatically mkdir {{{
      Plug 'pbrisbin/vim-mkdir'
    " }}}
    " Automatically add endif, etc. {{{
      Plug 'tpope/vim-endwise'
    " }}}
  " }}}
  " Post-hooks {{{
    call plug#end()
  " }}}
  " Fallbacks {{{
else
    " Syntax {{{
      syntax on
      filetype plugin indent on
    " }}}
    " Autocomplete {{{
      set omnifunc=syntaxcomplete#Complete
      inoremap <S-tab> <C-x><C-o>
    " }}}
    " Search {{{
      noremap N Nzz
      noremap n nzz
      noremap // /\c
      noremap ?? ?\c
      nnoremap <silent> <bslash> <esc>:%s/
      vnoremap <silent> <bslash> <esc>gv:s/
    " }}}
    " Auto-insert Curlies {{{
      inoremap {<cr> {<cr>}<C-o>O
    " }}}
    " Automatically return to last edit position {{{
      augroup LAST_EDIT
        au!
        au BufReadPost * silent! normal! g`"zv"`
      augroup END
    " }}}
    " Toggle Comments {{{
      augroup TOGGLE_COMMENTS
        au!
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
      augroup END

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
    " Shortcuts {{{
      " s-tab - Unindent
      inoremap <s-tab> <c-d>
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
  set infercase                     " smart casing for keyword completion
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
    set background=dark
    if has('gui_running')
      silent! colorscheme stereokai
    else
      silent! colorscheme peachpuff
    endif

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
    " let loaded_matchparen = 0      " this is slow, might disable
  " }}}
  " Highlights / Colors {{{
    function! s:apply_highlights()
      " No tildes for empty lines
      hi clear NonText | hi NonText
            \
            \ ctermfg=darkgrey guifg=darkgrey
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
      hi clear FoldColumn | hi FoldColumn
            \
            \ ctermbg=NONE guibg=NONE
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

      augroup MODIFIED_FLAG
        au!
        au FileChangedShellPost * let b:modified = 1
        au BufRead,BufWrite * if exists('b:modified') |
                            \   unlet b:modified |
                            \ endif
      augroup END

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

      " Returns file's syntax
      function! GetSyntax()
        return (&syntax != '') ? &syntax : 'plaintext'
      endfunction

      " Returns &tw if paste mode is disabled
      " Otherwise, return 'P'
      function! TextWidth()
        return (!&paste) ? &tw : 'P'
      endfunction

      " Safely gives gutentags status
      function! GutenStatus()
        if !exists('*gutentags#statusline')
          return ''
        endif
        let guten_status = gutentags#statusline('Generating tags...')
        return empty(guten_status) ? ''
              \: ("\<space>" . guten_status . "\<space>")
      endfunction

      " Safely gives syntastic status
      function! SyntasticStatus()
        if !exists('*SyntasticStatuslineFlag')
          return ''
        endif
        let syntastic_status = SyntasticStatuslineFlag()
        return empty(syntastic_status) ? ''
              \: ("\<space>" . syntastic_status . "\<space>")
      endfunction
    " }}}
    " 1   .vimrc                                    ve   vim   0   12 - 193/689 - 25%
    set statusline=\                                " initialize w/ space
    set statusline+=%n                              " buffer number
    set statusline+=\ %#Normal#%<\ %*               " separator
    set statusline+=\ %f                            " relative path
    set statusline+=%(\ [%{ExtModified()}%M%R]%)    " flags
    set statusline+=\ %#ErrorMsg#                   " error highlight
    set statusline+=%{SyntasticStatus()}            " gutentags
    set statusline+=%#WarningMsg#                   " warning highlight
    set statusline+=%{GutenStatus()}                " gutentags
    set statusline+=%#Normal#                       " no highlight
    set statusline+=%=                              " left/right separator
    set statusline+=%*                              " statusline highlight
    set statusline+=%(\ %{GetVe()}\ %)%#Normal#\ %* " virtualedit
    set statusline+=\ %{GetSyntax()}                " syntax
    set statusline+=\ %#Normal#\ %*                 " separator
    set statusline+=\ %{TextWidth()}                " text width/paste mode
    set statusline+=\ %#Normal#\ %*                 " separator
    set statusline+=\ %2c\ -\ %3l/%L\ -\ %P         " char# - curline/totline - file%
    set statusline+=\                               " end w/ space
  " }}}
  " Cursor Shape {{{
    if has('nvim')
      let $NVIM_TUI_ENABLE_CURSOR_SHAPE=1
    else
      augroup CHANGE_CURSOR
        au!
        " Enter: Flashing block
        au VimEnter * silent execute "!echo -ne '\e[1 q'"
        " Exit: Flashing bar
        au VimLeave * silent execute "!echo -ne '\e[5 q'"
      augroup END

      silent! let &t_EI = "\<Esc>[1 q" " NORMAL:  Flashing block
      silent! let &t_SR = "\<Esc>[3 q" " REPLACE: Flashing underline
      silent! let &t_SI = "\<Esc>[5 q" " INSERT:  Flashing bar
    endif
  " }}}
  " Help Splits {{{
    augroup HELP_SPLITS
      au!
      au FileType help wincmd L | vert resize 79
    augroup END
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

    " Shift-tab to go back in jumplist
    noremap <s-tab> <c-o>
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

    " ,= - Equalize splits
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

      " z<space> - toggle folds
      noremap z<leader> za

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
    "   a - Actively auto-format paragraphs
    "   n - Recognize numbered lists
    "   2 - Paragraph-style indents
    augroup FORMAT_OPTIONS_TXT
      au!
      au BufNewFile,BufRead *.txt,*.md setlocal fo+=an2
    augroup END

    let s:default_tw = 78 " default textwidth
    set linebreak         " line break only at breaking characters
    set colorcolumn=+1    " column guide
    exe 'set textwidth=' . s:default_tw

    " ,\ - Toggle text wrap & color column
    function! ToggleTextWidth()
      if (!&paste)
        if (&textwidth == 0)
          exe 'set textwidth=' . s:default_tw
          set colorcolumn=+1
        else
          set textwidth=0
          set colorcolumn=0
        endif
      else
        echohl WarningMsg | echom 'Paste mode on.' | echohl None
      endif
    endfunction

    noremap <silent> <leader>\ <esc>:call ToggleTextWidth()<cr>

    " ,f (visual mode) - Reflow selection
    xnoremap <silent> <leader>f Jgqq

    " Spellcheck
    " ,/cc - Toggle spellcheck
    noremap <silent> <leader>cc <esc>:setlocal spell!<cr>

    " More spellcheck shortcuts
    noremap <leader>cn ]s
    noremap <leader>cp [s
    noremap <leader>cw z=
    noremap <leader>ca zg

    " Enable spell check for text files
    augroup SPELLCHECK
      au!
      au BufNewFile,BufRead *.txt,*.md setlocal spell spelllang=en
    augroup END
  " }}}
  " Syntax / FileType {{{
    set smarttab            " remove spaces grouped as tabs
    set autoindent          " copy indent from previous line
    set expandtab           " expand tabs into spaces
    set tabstop=2           " tab is 2 spaces
    set shiftwidth=2        " tab is 2 spaces

    " Define tab settings for filetypes via:
    " au Syntax c,cpp,asm,java,py,othertypes setlocal whatever=#

    " Markdown - 4 char wide tabs
    augroup SYNTAX_MARKDOWN
      au BufNewFile,BufFilePre,BufRead *.md set filetype=markdown
      au Syntax markdown setlocal tabstop=4
      au Syntax markdown setlocal shiftwidth=4
    augroup END

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
    " Use DiffOrig to see file differences
    if !exists(':DiffOrig')
      command DiffOrig vert new | set bt=nofile | r ++edit # | 0d_
            \ | diffthis | wincmd p | diffthis
    endif

    " Use w!! to write as sudo
    cmap w!! w !sudo tee > /dev/null %

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
