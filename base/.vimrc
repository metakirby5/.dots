" vimrc / init.vim
" Ethan Chan

" Best viewed with vim: syntax=vim foldmethod=marker foldlevel=0
" Use za to toggle the folds

" Setup {{{
  let s:configdir = $HOME.(has('nvim') ? '/.config/nvim' : '/.vim')

  " Leader
  let mapleader = "\<Space>"
  let g:mapleader = mapleader
  noremap <leader><space> <space>
" }}}
" Plugins {{{
  " Native {{{
    runtime macros/matchit.vim
  " }}}
  " Setup {{{
if empty(glob(s:configdir . '/autoload/plug.vim'))
  let s:plugfile = s:configdir . '/autoload/plug.vim'
  exe 'silent !curl -fLo ' . s:plugfile . ' --create-dirs
        \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  exe 'source ' . s:plugfile
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
      nmap [g <Plug>GitGutterPrevHunk
      nmap ]g <Plug>GitGutterNextHunk
      nmap <leader>ga <Plug>GitGutterStageHunk
      nmap <leader>gu <Plug>GitGutterUndoHunk
      nmap <leader>go <Plug>GitGutterPreviewHunk
      omap ig <Plug>GitGutterTextObjectInnerPending
      omap ag <Plug>GitGutterTextObjectOuterPending
      xmap ig <Plug>GitGutterTextObjectInnerVisual
      xmap ag <Plug>GitGutterTextObjectOuterVisual
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

      nnoremap cog <esc>:Goyo<cr>
    " }}}
    " Spotlight on text {{{
      Plug 'junegunn/limelight.vim'
            \, { 'on': 'Limelight' }
      let g:limelight_conceal_ctermfg = 'darkgrey'
      let g:limelight_conceal_guifg = 'DarkGrey'
    " }}}
    " Themed rainbow parens {{{
      Plug 'junegunn/rainbow_parentheses.vim'
            \, { 'on': 'RainbowParentheses' }
      augroup PLUG_RAINBOW_PARENTHESES
        au!
        au FileType lisp,clojure,scheme RainbowParentheses
      augroup END
    " }}}
    " Highlight all as searching {{{
      if (version >= 704)
        Plug 'haya14busa/incsearch.vim'
              \| Plug 'haya14busa/incsearch-fuzzy.vim'
        set hlsearch
        let g:incsearch#auto_nohlsearch = 1
        let g:incsearch#is_stay = 1
        map /  <Plug>(incsearch-forward)
        map ?  <Plug>(incsearch-backward)
        map // <Plug>(incsearch-fuzzy-/)
        map ?? <Plug>(incsearch-fuzzy-?)
        map n  <Plug>(incsearch-nohl-n)zz
        map N  <Plug>(incsearch-nohl-N)zz
        map *  <Plug>(incsearch-nohl-*)
        map #  <Plug>(incsearch-nohl-#)
        map g* <Plug>(incsearch-nohl-g*)
        map g# <Plug>(incsearch-nohl-g#)
        map g/ <Plug>(incsearch-fuzzy-stay)
      endif
    " }}}
    " Start screen {{{
      Plug 'mhinz/vim-startify'
      let g:startify_list_order = [
            \ ['   Bookmarks'], 'bookmarks',
            \ ['   Sessions'], 'sessions',
            \ ['   Files'], 'files',
            \ ['   Directory'], 'dir',
            \ ['   Commands'], 'commands']
      let g:startify_change_to_vcs_root = 1
      let g:startify_relative_path = 1
      let g:startify_session_autoload = 1
      let g:startify_session_persistence = 1
      let g:startify_session_delete_buffers = 1
      let g:startify_session_sort = 1
      if has('nvim')
        let g:startify_ascii = [
              \ '           _     ',
              \ '  __ _  __(_)_ _ ',
              \ ' /  \ |/ / /  / \',
              \ '/_/_/___/_/_/_/_/',
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

      " Fix conceals
      Plug 'elzr/vim-json'
      let g:vim_json_syntax_conceal = 0
      let g:vim_markdown_conceal = 0
    " }}}
  " }}}
  " Completion {{{
    " Engine {{{
      if has('nvim')
        function! DoRemote(arg)
          UpdateRemotePlugins
        endfunction

        Plug 'Shougo/Deoplete.nvim', { 'do': function('DoRemote') }
        let s:completion_engine = 'deoplete'
        let s:completion_prefix = s:completion_engine . '#'
      elseif has('lua')
        if (version >= 704 || version == 703 && has('patch885'))
          Plug 'Shougo/neocomplete.vim'
          let s:completion_engine = 'neocomplete'
          let s:completion_prefix = s:completion_engine . '#'
        else
          Plug 'Shougo/neocomplcache.vim'
          let s:completion_engine = 'neocomplcache'
          let s:completion_prefix = s:completion_engine . '_'
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
        let g:UltiSnipsJumpBackwardTrigger = '<c-k>'
        let g:UltiSnipsJumpForwardTrigger = '<c-j>'
      endif
    " }}}
    " Settings {{{
      if exists('s:completion_engine')
        let g:{s:completion_prefix}enable_at_startup = 1
        let g:{s:completion_prefix}enable_smart_case = 1
        let g:{s:completion_prefix}auto_completion_start_length = 3
        set completeopt-=preview
        inoremap <expr> <tab>   pumvisible() ? "\<c-n>" : "\<tab>"
        inoremap <expr> <s-tab> pumvisible() ? "\<c-p>" :
              \ neocomplete#undo_completion()
        inoremap <expr> <bs>    {s:completion_engine}#smart_close_popup()
              \. "\<bs>"
        inoremap <silent> <cr>  <c-r>=<SID>smart_cr()<cr>

        let g:ulti_expand_res = 0
        function! s:smart_cr()
          silent! call UltiSnips#ExpandSnippet()
          return g:ulti_expand_res ? ""
                \: {s:completion_engine}#smart_close_popup()."\<cr>"
        endfunction

        " Custom completions
        augroup PLUG_COMPLETION
          au!
        augroup END
        if !exists('g:neocomplete#force_omni_input_patterns')
          let g:{s:completion_prefix}force_omni_input_patterns = {}
        endif
      endif
    " }}}
  " }}}
  " Text objects {{{
    Plug 'kana/vim-textobj-user'
    Plug 'kana/vim-textobj-entire'
    Plug 'kana/vim-textobj-line'
    Plug 'kana/vim-smartword' " {{{
      map w  <Plug>(smartword-w)
      map b  <Plug>(smartword-b)
      map e  <Plug>(smartword-e)
      map ge  <Plug>(smartword-ge)
    " }}}
    Plug 'michaeljsmith/vim-indent-object'
    Plug 'wellle/targets.vim'
  " }}}
  " Operators {{{
    " User operators {{{
      Plug 'kana/vim-operator-user'
    " }}}
    " Make repeat work with plugins {{{
      Plug 'tpope/vim-repeat'
    " }}}
    " Align with ga {{{
      Plug 'junegunn/vim-easy-align'
            \, { 'on': '<Plug>(EasyAlign)' }
      xmap ga <Plug>(EasyAlign)
      nmap ga <Plug>(EasyAlign)
    " }}}
    " Exchange text {{{
      Plug 'tommcdo/vim-exchange'
    " }}}
    " Toggle comments {{{
      Plug 'tpope/vim-commentary'
    " }}}
    " Surround with... {{{
      Plug 'tpope/vim-surround'
      nmap s <Plug>Ysurround
      nmap S <Plug>YSurround
      nmap ss <Plug>Yssurround
      nmap Ss <Plug>YSsurround
      nmap SS <Plug>YSsurround
      xmap s <Plug>VSurround
      xmap S <Plug>VgSurround
    " }}}
    " Replace with register {{{
      Plug 'vim-scripts/ReplaceWithRegister'
    " }}}
  " }}}
  " Utility {{{
    " Emacs which-key for vim {{{
      Plug 'hecal3/vim-leader-guide'
      function! s:map_leader_guides(l)
        for k in a:l
          let g = k == '<leader>' ? g:mapleader : k
          exe 'nnoremap <silent> '.k.' :<c-u>LeaderGuide '''.g.'''<CR>'
          exe 'vnoremap <silent> '.k.' :<c-u>LeaderGuideVisual '''.g.'''<CR>'
        endfor
      endfunction
      call s:map_leader_guides([
            \ '<leader>', '[', ']',
            \ ])
    " }}}
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
              \ 'Files', 'GFiles', 'Buffers', 'Colors', 'Ag', 'Lines',
              \ 'Blines', 'Tags', 'BTags', 'Marks', 'Windows', 'Locate',
              \ 'History', 'Snippets', 'Commits', 'BCommits', 'Commands',
              \ 'Maps', 'Helptags', 'Filetypes' ] }

      let g:fzf_files_options =
            \ '--preview "(pygmentize {} || less {}) 2>/dev/null"'
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
    " }}}
    " Register preview {{{
      Plug 'junegunn/vim-peekaboo'
      let g:peekaboo_delay = 100
    " }}}
    " Tag browser {{{
      if v:version >= 703
        Plug 'majutsushi/tagbar'
              \, { 'on': 'TagbarToggle' }
        nnoremap <silent> <leader>[ <esc>:TagbarToggle<cr>
      endif
    " }}}
    " Undo tree browser {{{
      Plug 'mbbill/undotree'
            \, { 'on': 'UndotreeToggle' }
      nnoremap <silent> <leader>u <esc>:UndotreeToggle<cr>
      let g:undotree_SetFocusWhenToggle = 1
      let g:undotree_ShortIndicators = 1
    " }}}
    " Numi-esque code interpreter {{{
      Plug 'metakirby5/codi.vim'
      let g:codi#interpreters = {
          \     'purescript': {
          \         'bin': ['pulp', 'psci'],
          \         'prompt': '^> ',
          \     },
          \ }
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
      nnoremap <silent> <leader>- <esc>:SyntasticCheck<cr>
    " }}}
    " Add highlight groups {{{
      Plug 't9md/vim-quickhl'
            \, { 'on': [
            \ '<Plug>(quickhl',
            \ '<Plug>(operator-quickhl'] }
      nmap M <Plug>(operator-quickhl-manual-this-motion)
      xmap M <Plug>(quickhl-manual-this)
      nmap <leader>M <Plug>(quickhl-manual-reset)
      xmap <leader>M <Plug>(quickhl-manual-reset)
    " }}}
    " Multiple cursors {{{
      Plug 'terryma/vim-multiple-cursors'
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
    " Ablolish, Subvert, and Coerce {{{
      Plug 'tpope/vim-abolish'
    " }}}
    " Readline bindings {{{
      Plug 'tpope/vim-rsi'
    " }}}
    " Autodetect indentation {{{
      Plug 'tpope/vim-sleuth'
    " }}}
    " Paired keybindings {{{
      Plug 'tpope/vim-unimpaired'
    " }}}
    " Autocomplete from tmux panes {{{
      Plug 'wellle/tmux-complete.vim'
    " }}}
  " }}}
  " Automation {{{
    " Automatically set paste {{{
      Plug 'ConradIrwin/vim-bracketed-paste'
    " }}}
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
      if version >= 704 && executable('ctags')
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

    " vim-leader-guide
    let g:lgmap = {}
    call leaderGuide#register_prefix_descriptions('', 'g:lgmap')
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
      noremap n nzz
      noremap N Nzz
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
        let s:ps = getreg('/', 1)
        let s:ps_t = getregtype('/')
      endfunction

      function! RestoreSearch()
        if !(exists('s:ps') && exists('s:ps_t'))
          return
        endif

        call setreg('/', s:ps, s:ps_t)
      endfunction

      noremap <silent> g> <esc>:call StoreSearch()<cr>:<C-B>silent <C-E>s/^/<C-R>=escape(b:comment_leader,'\/')<cr>/<cr>:noh<cr>:call RestoreSearch()<cr>
      noremap <silent> g< <esc>:call StoreSearch()<cr>:<C-B>silent <C-E>s/^\V<C-R>=escape(b:comment_leader,'\/')<cr>//e<cr>:noh<cr>:call RestoreSearch()<cr>
      xnoremap <silent> g> <esc>:call StoreSearch()<cr>gv:<C-B>silent <C-E>s/^/<C-R>=escape(b:comment_leader,'\/')<cr>/<cr>:noh<cr>:call RestoreSearch()<cr>gv
      xnoremap <silent> g< <esc>:call StoreSearch()<cr>gv:<C-B>silent <C-E>s/^\V<C-R>=escape(b:comment_leader,'\/')<cr>//e<cr>:noh<cr>:call RestoreSearch()<cr>gv
    " }}}
    " Toggle Distractions {{{
      let s:minimal = 0
      function! ToggleDistractions()
        if !s:minimal
          let s:minimal = 1
          set noshowmode
          set noruler
          set showtabline=1
          set nonu
          set ls=0
        else
          let s:minimal = 0
          set showmode
          set ruler
          set showtabline=2
          set nu
          set ls=2
        endif
      endfunction

      if !exists(':DistractionsToggle')
        command DistractionsToggle call ToggleDistractions()
        nnoremap cog :DistractionsToggle<cr>
      endif
    " }}}
endif " }}}
" }}}
" General {{{
  set nu                            " line numbering on
  set noerrorbells                  " disable bell part 1
  set novisualbell                  " disable bell part 2
  set t_vb=                         " disable bell part 3
  set backspace=2                   " backspace over everything
  set fileformats=unix,dos,mac      " open files from mac/dos
  set hidden                        " don't bug me about abandoning buffers
  set nojoinspaces                  " don't add white space when I don't tell you to
  set autowrite                     " write before make
  set mouse=a                       " allow mouse usage
  silent! set ttymouse=xterm2       " non-jumpy mouse visual select
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
  exe "set viminfo='100,n".s:configdir.'/info'
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
    endfunction

    if !has('gui_running')
      call <SID>apply_highlights()
      augroup CUSTOM_COLORS
        au!
        au ColorScheme * call <SID>apply_highlights()
      augroup END
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
      silent! let &t_EI = "\<Esc>[1 q" " NORMAL:  Flashing block
      silent! let &t_SR = "\<Esc>[3 q" " REPLACE: Flashing underline
      silent! let &t_SI = "\<Esc>[5 q" " INSERT:  Flashing bar
    endif
  " }}}
  " Help Splits {{{
    augroup HELP_SPLITS
      au!
      au BufEnter * if &buftype == 'help' |
            \ wincmd L | exe 'vert resize ' . &tw
            \ | noremap <buffer> q <esc>:q<cr>
            \ | endif
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
    " ,bl - List all buffers
    nnoremap <silent> <leader>bl <esc>:buffers<cr>

    " ,bs - Switch to buffer by name
    nnoremap <leader>bs <esc>:buffers<cr>:buffer<space>

    " ,bd - Close the current buffer
    nnoremap <silent> <leader>bd <esc>:bd<cr>

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
    nnoremap <silent> <leader>be <esc>:call DeleteEmptyBuffers()<cr>

    " ,bt - Open all buffers as tabs
    nnoremap <silent> <leader>bt <esc>:tab ball<cr>

    " ,cd - Switch CWD to the directory of the open buffer
    nnoremap <silent> <leader>cd <esc>:cd %:p:h<cr> :pwd<cr>

    " Specify the behavior when switching between buffers
    if exists('&switchbuf')
      set switchbuf=useopen,usetab,newtab
    endif
  " }}}
  " Splits {{{
    " Open new split panes to the right and bottom, instead of left and top
    set splitbelow
    set splitright

    " ,[sv] - Horizontal/vertical split
    nnoremap <leader>s <C-w>s
    nnoremap <leader>v <C-w>v

    " ,= - Equalize splits
    nnoremap <leader>= <C-w>=

    " ^[hjkl] - Switch to split
    nnoremap <leader>h <C-W>h
    nnoremap <leader>j <C-W>j
    nnoremap <leader>k <C-W>k
    nnoremap <leader>l <C-W>l

    " ,[HJKL] - Move split
    nnoremap <leader>H <C-W>H
    nnoremap <leader>J <C-W>J
    nnoremap <leader>K <C-W>K
    nnoremap <leader>L <C-W>L

    " ,[hjkl] - Resize split
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

    " [w ]w - Forward and backwards tabs
    nnoremap <silent> [w <esc>:tabprevious<cr>
    nnoremap <silent> ]w <esc>:tabnext<cr>

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

      " zm - Marker mode
      nnoremap zm <esc>:set foldmethod=marker<cr>zR

      " zi - Indent mode
      nnoremap zi <esc>:set foldmethod=indent<cr>zR

      " zs - Syntax mode
      nnoremap zs <esc>:set foldmethod=syntax<cr>zR
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
    "   n - Recognize numbered lists
    "   2 - Paragraph-style indents
    augroup FORMAT_OPTIONS_TXT
      au!
      au BufNewFile,BufRead *.txt,*.md setlocal fo+=n2
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

    nnoremap cot <esc>:call ToggleTextWidth()<cr>

    " ,f (visual mode) - Reflow selection
    xnoremap <silent> <leader>f Jgqq

    " Spellcheck
    set spelllang=en

    " Enable spell check for text files
    augroup SPELLCHECK
      au!
      au BufNewFile,BufRead *.txt setlocal spell
      au Filetype markdown,help setlocal spell
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

    " :R - Execute current script
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
    nnoremap <leader>q :<c-u><c-r><c-r>='let @'.v:register.' = '
          \.string(getreg(v:register))<cr><c-f><left>

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

  " Y - Yank to clipboard
  noremap Y "+y

  " ,p - Toggle paste mode
  nnoremap cop <esc>:setlocal paste!<cr>

  " K - split line
  noremap K i<cr><esc>
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
