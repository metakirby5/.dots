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

  " Conditional plugins
  function! When(cond, ...)
    let opts = get(a:000, 0, {})
    return a:cond ? opts : extend(opts, { 'on': [], 'for': [] })
  endfunction

  call plug#begin(s:configdir . '/plugins')
  " }}}
  " Interface {{{
    Plug 'airblade/vim-gitgutter'           " Git gutter {{{
      let g:gitgutter_map_keys = 0
      nmap <leader>gn <Plug>GitGutterNextHunk
      nmap <leader>gp <Plug>GitGutterPrevHunk
      nmap <leader>ga <Plug>GitGutterStageHunk
      nmap <leader>gu <Plug>GitGutterRevertHunk
      nmap <leader>gs <Plug>GitGutterPreviewHunk
      omap ih <Plug>GitGutterTextObjectInnerPending
      omap ah <Plug>GitGutterTextObjectOuterPending
      xmap ih <Plug>GitGutterTextObjectInnerVisual
      xmap ah <Plug>GitGutterTextObjectOuterVisual
    " }}}
    Plug 'DanielFGray/DistractionFree.vim'  " Enable minimalism {{{
      let g:distraction_free#toggle_limelight = 1
      let g:distraction_free#toggle_options = [
            \ 'list',
            \ 'ruler',
            \ 'showtabline',
            \ 'laststatus',
            \]
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
    Plug 'nathanaelkane/vim-indent-guides'  " Indent guides {{{
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
      nmap <silent> <leader>i <Plug>IndentGuidesToggle
      let g:indent_guides_exclude_filetypes = ['help', 'startify']
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
    Plug 'benekastah/neomake'               " Better make {{{
          \, When(has('nvim'))
    " }}}
    Plug 'bronson/vim-visual-star-search'   " Allow * and # on visual {{{
    " }}}
    Plug 'mattn/emmet-vim'                  " Emmet {{{
      let g:user_emmet_leader_key='<c-m>'
      let g:user_emmet_install_global = 0
      autocmd FileType html,css EmmetInstall
    " }}}
    Plug 'sheerun/vim-polyglot'             " Language packs {{{
    " }}}
    Plug 'stgpetrovic/syntastic-async'      " Syntax checker {{{
      let g:syntastic_always_populate_loc_list = 1
      let g:syntastic_auto_loc_list = 1
      let g:syntastic_check_on_open = 0
      let g:syntastic_check_on_wq = 0
      let g:syntastic_error_symbol = 'x'
      let g:syntastic_warning_symbol = '!'
      let g:syntastic_style_error_symbol = 'S'
      let g:syntastic_style_warning_symbol = 's'
    " }}}
    Plug 'osyo-manga/vim-over'              " Better :%s/.../.../ {{{
      nnoremap <silent> <bslash> :OverCommandLine<cr>%s/
      vnoremap <silent> <bslash> :OverCommandLine<cr>s/
    " }}}
    Plug 'Shougo/neosnippet'                " Snippets {{{
      Plug 'Shougo/neosnippet-snippets'       " Snippets pack {{{
      " }}}
    " }}}
    Plug 'Shougo/vimproc'                   " Asynchronous commands {{{
          \, { 'do': 'make' }
    " }}}
    Plug 'Shougo/unite.vim'                 " Fuzzy searcher {{{
      Plug 'Shougo/unite-outline'             " Nice outline view
      Plug 'Shougo/neomru.vim'                " Index most reecntly used files
      Plug 'tsukkee/unite-tag'                " Browse tags
      Plug 'Shougo/neoyank.vim'               " Yank history
      Plug 'thinca/vim-unite-history'         " Command history
      Plug 'kopischke/unite-spell-suggest'    " Spellcheck suggestions
      Plug 'Shougo/unite-help'                " Get help
      Plug 'Shougo/unite-session'             " Save sessions

      let g:unite_enable_auto_select = 0
      noremap <silent> <leader>r  :Unite -auto-resize -buffer-name=register register<cr>
      noremap <silent> <leader>x  :Unite -auto-resize -buffer-name=files    buffer file neomru/file<cr>
      noremap <silent> <leader>z  :Unite -auto-resize -buffer-name=rfiles   file_rec/async<cr>
      noremap <silent> <leader>q  :Unite -auto-resize -buffer-name=grep     grep<cr>
      noremap <silent> <leader>[  :Unite -auto-resize -buffer-name=outline  outline<cr>
      noremap <silent> <leader>]  :Unite -auto-resize -buffer-name=tags     tag<cr>
      noremap <silent> <leader>u  :Unite -auto-resize -buffer-name=history  history/yank<cr>
      noremap <silent> <leader>;  :Unite -auto-resize -buffer-name=command  history/command command<cr>
      noremap <silent> <leader>?  :Unite -auto-resize -buffer-name=help     help<cr>
      noremap <silent> <leader>cw :Unite -auto-resize -buffer-name=spell    spell_suggest<cr>
      autocmd FileType unite call s:unite_my_settings()

      function! s:unite_my_settings() " {{{
        nnoremap <silent><buffer><expr> l unite#smart_map('l', unite#do_action('default'))
        nmap <buffer> <Esc>     <Plug>(unite_exit)
        nmap <buffer> f         <Plug>(unite_quick_match_jump)
        imap <buffer> <tab>     <Plug>(unite_select_next_line)
        imap <buffer> <s-tab>   <Plug>(unite_select_previous_line)
        imap <buffer> <C-w>     <Plug>(unite_delete_backward_path)
        nmap <buffer> '         <Plug>(unite_quick_match_default_action)
        imap <buffer> '         <Plug>(unite_quick_match_default_action)
        nmap <buffer> <C-z>     <Plug>(unite_toggle_transpose_window)
        imap <buffer> <C-z>     <Plug>(unite_toggle_transpose_window)
        nmap <buffer> <C-j>     <Plug>(unite_toggle_auto_preview)
        imap <buffer> <C-j>     <Plug>(unite_toggle_auto_preview)
        nmap <buffer> <C-r>     <Plug>(unite_narrowing_input_history)
        imap <buffer> <C-r>     <Plug>(unite_narrowing_input_history)

        let unite = unite#get_current_unite()
        if unite.profile_name ==# 'search'
          nnoremap <silent><buffer><expr> r     unite#do_action('replace')
        else
          nnoremap <silent><buffer><expr> r     unite#do_action('rename')
        endif

        nnoremap <silent><buffer><expr> cd     unite#do_action('lcd')
      endfunction " }}}
    " }}}
    Plug 'pydave/AsyncCommand'              " Asynchronous commands (2) {{{
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
      noremap <leader>ba :BufOnly<cr>
    " }}}
  " }}}
  " Automation {{{
    Plug 'jiangmiao/auto-pairs'             " Automatically add delimiters {{{
    " }}}
    Plug 'ludovicchabant/vim-gutentags'     " Auto-generate ctags {{{
    " }}}
    Plug 'pbrisbin/vim-mkdir'               " Automatically mkdir {{{
    " }}}
  " }}}
  " Post-hooks {{{
    call plug#end()
    " Unite {{{
      call unite#filters#sorter_default#use(['sorter_rank'])
      call unite#filters#matcher_default#use(['matcher_fuzzy'])
      call unite#set_profile('files', 'context.smartcase', 1)
      call unite#custom#profile('default', 'context', {
            \   'winheight': 10,
            \   'start_insert': 1,
            \   'prompt_focus': 1,
            \   'force_redraw': 1,
            \   'no_empty':     1,
            \ })
    " }}}
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

    noremap <silent> g> :call StoreSearch()<cr>:<C-B>silent <C-E>s/^/<C-R>=escape(b:comment_leader,'\/')<cr>/<cr>:noh<cr>:call RestoreSearch()<cr>
    noremap <silent> g< :call StoreSearch()<cr>:<C-B>silent <C-E>s/^\V<C-R>=escape(b:comment_leader,'\/')<cr>//e<cr>:noh<cr>:call RestoreSearch()<cr>
    xnoremap <silent> g> :call StoreSearch()<cr>gv:<C-B>silent <C-E>s/^/<C-R>=escape(b:comment_leader,'\/')<cr>/<cr>:noh<cr>:call RestoreSearch()<cr>gv
    xnoremap <silent> g< :call StoreSearch()<cr>gv:<C-B>silent <C-E>s/^\V<C-R>=escape(b:comment_leader,'\/')<cr>//e<cr>:noh<cr>:call RestoreSearch()<cr>gv
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
  set hidden                        " hide abandoned buffers
  set exrc                          " open local config files
  set nojoinspaces                  " don't add white space when I don't tell you to
  set autowrite                     " write before make
  set mouse=a                       " allow mouse usage
  set hlsearch                      " highlights all search hits
  set ignorecase                    " search without regards to case
  set smartcase                     " search with smart casing
  set gdefault                      " default global sub
  set tags=./tags;                  " Recursive tag search
  set efm+=\ (%l)\ error:\ %m       " Lint error format
  set timeoutlen=1000 ttimeoutlen=0 " No escape key delay
" }}}
" Interface {{{
  " General {{{
    " Set color scheme
    silent! colorscheme peachpuff

    syntax on           " Syntax highlighting
    set shortmess+=I    " no splash screen
    set cursorline      " highlight current line
    set showmatch       " show match when inserting {}, [], or ()
    set scrolloff=5     " keep at least 5 lines above/below
    set sidescrolloff=5 " keep at least 5 lines left/right
    set title           " allow titles
    set titlestring=%f  " title is the filename
    set ls=2            " always show status line
  " }}}
  " Highlights / Colors {{{
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
      silent! let &t_SI = "\<Esc>[5 q"
      silent! let &t_SR = "\<Esc>[3 q"
      silent! let &t_EI = "\<Esc>[1 q"
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
    noremap <leader>bn :bn<cr>
    noremap <leader>bp :bN<cr>

    " ,bl - List all buffers
    noremap <leader>bl :buffers<cr>

    " ,bs - Switch to buffer by name
    noremap <leader>bs :buffers<cr>:buffer<space>

    " ,bd - Close the current buffer
    noremap <leader>bd :bd<cr>

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

    " ,cd - Switch CWD to the directory of the open buffer
    noremap <leader>cd :cd %:p:h<cr>:pwd<cr>

    " Specify the behavior when switching between buffers
    if exists('&switchbuf')
      set switchbuf=useopen,usetab,newtab
      set stal=2
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
  " }}}
  " Tabs {{{
    " Change maximum number of tabs
    set tabpagemax=100

    " Useful mappings for managing tabs
    noremap <silent> <leader>te :tabedit <tab>
    noremap <silent> <leader>tn :tabnew<cr>
    noremap <silent> <leader>to :tabonly<cr>
    noremap <silent> <leader>tw :tabclose<cr>
    noremap <silent> <leader>tm :tabmove<Space>
    noremap <silent> <leader>tb :tab ball<cr>
    noremap <silent> <leader>tl :tabs<cr>

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
  " }}}
  " Folds {{{
    if exists("+foldenable")
      set foldenable

      " Enable fold column
      " set foldcolumn=1
      hi FoldColumn ctermbg=NONE guibg=NONE

      " zz - toggle folds
      noremap zz za

      " The mode settings below all start with folds open

      " ,zm - Manual mode
      noremap zm :set foldmethod=manual<cr>zR

      " ,zi - Indent mode
      noremap zi :set foldmethod=indent<cr>zR

      " ,zs - Syntax mode
      noremap zs :set foldmethod=syntax<cr>zR

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

    noremap <silent> <leader>\ :call ToggleTextWrap()<cr>

    " ,f (visual mode) - Reflow selection
    xnoremap <silent> <leader>f Jgqq

    " Spellcheck
    " ,/cc - Toggle spellcheck
    noremap <leader>cc :setlocal spell!<cr>

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
  " Persistent Undo {{{
    if exists('&undodir')
      if !isdirectory($HOME . '/.vim/undo')
        silent call mkdir($HOME . '/.vim/undo', 'p')
      endif
      set undodir=~/.vim/undo/    " set undo directory (use vim's)
      set undofile                " use an undo file
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
  noremap <leader>tt :tab split<cr>:exec("tjump ".expand("<cword>"))<cr>

  " ,y - Yank to clipboard
  noremap <leader>y "+y

  " ,p - Toggle paste mode
  noremap <leader>p :setlocal paste!<cr>

  " ,/ - Disable highlight
  noremap <silent> <leader>/ :noh<cr>

  " K - split line
  noremap <silent> K i<cr><esc>

  " ,m - Make and go to first error
  if exists(':Neomake')
    noremap <leader>m :silent Neomake!\|redraw!\|cc<cr>
  else
    noremap <leader>m :silent make\|redraw!\|cc<cr>
  endif
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
