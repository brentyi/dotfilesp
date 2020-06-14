"
" brent yi


" #############################################
" > Initial setup <
" #############################################

" Disable vi compatability
set nocompatible

" Default to utf-8 (not needed/creates error for Neovim)
if !has('nvim')
    set encoding=utf-8
endif

" Remap <Leader> to <Space>
" This needs to be done before any leader-containing bindings happen
let mapleader = "\<Space>"

" Run shell commands using bash
set shell=/bin/bash

" Automatically install vim-plug plugin manager
let s:vim_plug_folder = (has('nvim') ? '$HOME/.config/nvim' : '$HOME/.vim') . '/autoload/'
let s:vim_plug_path = s:vim_plug_folder . 'plug.vim'
let s:fresh_install = 0
if empty(glob(s:vim_plug_path))
    if executable('curl')
        execute 'silent !curl -fLo ' . s:vim_plug_path . ' --create-dirs '
            \ . 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
    elseif executable('wget')
        execute 'silent !mkdir -p ' . s:vim_plug_folder
        execute 'silent !wget --output-document=' . s:vim_plug_path
            \ . ' https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
    else
        echoerr 'Need curl or wget to download vim-plug!'
    endif
    autocmd VimEnter * PlugUpdate! --sync 32 | source $MYVIMRC
    let s:fresh_install = 1
endif


" #############################################
" > Plugins <
" #############################################

" Use Vundle-style path for vim-plug
let s:bundle_path = (has('nvim') ? '~/.config/nvim' : '~/.vim') . '/bundle'
execute 'call plug#begin("' . s:bundle_path . '")'

" Navigation inside files
Plug 'easymotion/vim-easymotion'
" {{
    map s <Plug>(easymotion-f)
    map S <Plug>(easymotion-F)
" }}

" Shortcuts for manipulating quotes, brackets, parentheses, HTML tags
" + vim-repeat for making '.' work for vim-surround
Plug 'tpope/vim-surround'
Plug 'tpope/vim-repeat'

" Various path/repository-related helpers
" > Make gf, sfind, etc work better in repositories
" > Populates b:repo_file_search_root, b:repo_file_search_type,
"   b:repo_file_search_display variables
Plug 'brentyi/vim-repo-file-search'

" Doodads for Mercurial, Git
Plug 'tpope/vim-fugitive'
Plug 'ludovicchabant/vim-lawrencium'
if has('nvim') || has('patch-8.0.902')
    Plug 'mhinz/vim-signify'
else
    Plug 'mhinz/vim-signify', { 'branch': 'legacy' }
endif
" {{
    " Keybinding for opening diffs
    nnoremap <Leader>vcd :call <SID>vc_diff()<CR>
    function! s:vc_diff()
        if b:repo_file_search_type == 'hg'
            Hgvdiff
        elseif b:repo_file_search_type == 'git'
            Gdiff
        endif
    endfunction

    " Keybinding for printing repo status
    nnoremap <Leader>vcs :call <SID>vc_status()<CR>
    function! s:vc_status()
        if b:repo_file_search_type == 'hg'
            Hgstatus
        elseif b:repo_file_search_type == 'git'
            Gstatus
        endif
    endfunction

    " Keybinding for blame/annotate
    nnoremap <Leader>vcb :call <SID>vc_blame()<CR>
    function! s:vc_blame()
        if b:repo_file_search_type == 'hg'
            Hgannotate
        elseif b:repo_file_search_type == 'git'
            Gblame
        endif
    endfunction

    " For vim-signify
    set updatetime=300
    augroup SignifyColors
        autocmd!
        function! s:SetSignifyColors()
            highlight SignColumn ctermbg=NONE guibg=NONE
            highlight SignifySignAdd ctermfg=green guifg=#00ff00 cterm=NONE gui=NONE
            highlight SignifySignDelete ctermfg=red guifg=#ff0000 cterm=NONE gui=NONE
            highlight SignifySignChange ctermfg=yellow guifg=#ffff00 cterm=NONE gui=NONE
        endfunction
        autocmd ColorScheme * call s:SetSignifyColors()
    augroup END
    let g:signify_sign_add = '•'
    let g:signify_sign_delete = '•'
    let g:signify_sign_delete_first_line = '•'
    let g:signify_sign_change = '•'
" }}

" Fuzzy-find for files, buffers, tags!
let g:brent_use_fzf = get(g:, 'brent_use_fzf', 0)
if !g:brent_use_fzf
    " Default to ctrlp, which is really nice & portable!
    " Note: we've experimented with ctrlp-py-matcher, cpsm, etc, but support
    " across systems + vim versions has been shaky for all of them
    "
    Plug 'ctrlpvim/ctrlp.vim'
    " {{
        let g:ctrlp_extensions = ['tag', 'line']
        let g:ctrlp_show_hidden = 1
        let g:ctrlp_follow_symlinks=1
        let g:ctrlp_max_files=300000
        let g:ctrlp_switch_buffer = '0'
        let g:ctrlp_reuse_window = 1

        " Bindings
        nnoremap <Leader>p :CtrlPBuffer<CR>
        nnoremap <Leader>h :CtrlPMRUFiles<CR>
        nnoremap <Leader>t :CtrlPTag<CR>
        nnoremap <Leader>gt :call <SID>ctrlp_tag_under_cursor()<CR>
        nnoremap <Leader>l :CtrlPLine<CR>
        nnoremap <Leader>gl :call <SID>ctrlp_line_under_cursor()<CR>
        nnoremap <Leader>gf :call <SID>ctrlp_file_under_cursor()<CR>

        " Binding implementations
        function! s:ctrlp_file_under_cursor()
            let g:ctrlp_default_input = expand('<cfile>')
            CtrlP
            let g:ctrlp_default_input = ''
        endfunction

        function! s:ctrlp_tag_under_cursor()
            let g:ctrlp_default_input = expand('<cword>')
            CtrlPTag
            let g:ctrlp_default_input = ''
        endfunction

        function! s:ctrlp_line_under_cursor()
            let g:ctrlp_default_input = expand('<cword>')
            CtrlPLine
            let g:ctrlp_default_input = ''
        endfunction
    " }}
else
    " FZF + ag is _much_ faster & actually useful when working with big repos
    "
    Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all', 'tag': '0.19.0' }
    Plug 'junegunn/fzf.vim'
    " {{
        function! s:smarter_fuzzy_file_search()
            execute 'Files ' . b:repo_file_search_root
        endfunction

        " Use ag if available
        if executable('ag')
            let $FZF_DEFAULT_COMMAND='ag --hidden --ignore .git -g ""'
        else
            echoerr 'fzf enabled without ag!'
        endif

        " We want to use gutentags for tag generation
        let g:fzf_tags_command = ''

        " Preview for tag search
        " Note that line numbers must be included in tag files (see gutentags config)
        let s:preview_script = s:bundle_path . '/fzf.vim/bin/preview.sh '
            \ . '{2}:$(echo {} | cut -f 5 | sed -r ''s/line://g'')'
        command! -bang -nargs=* TagsWithPreview
            \ call fzf#vim#tags(<q-args>, {
            \      'options': '
            \         --preview ''' . s:preview_script . ''''
            \ }, <bang>0)

        " Call Ag relative to repository root
        command! -bang -nargs=* Ag
            \ call fzf#vim#ag(<q-args>, '--hidden --ignore .git', fzf#vim#with_preview({
            \     'dir': b:repo_file_search_root
            \ }), <bang>0)

        " Using grep for visual mode selection
        function! s:GrepVisual(type)
            " Save the contents of the unnamed register
            let l:save_tmp = @@

            " Copy visual selection into unnamed_register
            if a:type ==# 'v'
                normal! `<v`>y
            elseif a:type ==# 'char'
                normal! `[v`]y
            else
                return
            endif

            execute 'Ag ' @@

            " Restore the unnamed register
            let @@ = l:save_tmp
        endfunction

        " Bindings: search file names
        nnoremap <C-P> :call <SID>smarter_fuzzy_file_search()<CR>
        nnoremap <Leader>p :Buffers<CR>
        nnoremap <Leader>h :History<CR>
        nnoremap <Leader>gf :call fzf#vim#files(b:repo_file_search_root, fzf#vim#with_preview({
            \ 'options': '--query ' . shellescape(expand('<cfile>'))}))<CR>

        " Bindings: search tags
        nnoremap <Leader>t :TagsWithPreview<CR>
        nnoremap <Leader>gt :execute 'TagsWithPreview ' . expand('<cword>')<CR>

        " Bindings: search lines in open buffers
        nnoremap <Leader>l :Lines<CR>
        nnoremap <Leader>gl :call fzf#vim#lines(expand('<cword>'))<CR>

        " Bindings: search lines in files with ag
        nnoremap <Leader>a :Ag<CR>
        vnoremap <Leader>a :<c-u>call <SID>GrepVisual(visualmode())<cr>
        nnoremap <Leader>ga :execute 'Ag ' . expand('<cword>')<CR>

        " Automatically change working directory to current file location
        " Emulates `set autochdir`, which appears to have some issues w/ fzf
        "
        " Reproducing the error without this hack:
        "     (1) set autochdir
        "     (2) Open a file
        "     (3) Open another file w/ fzf
        "     (4) :edit .  # <= this should show some errors
        "     (5) Run `pwd` and `echo getcwd()` -- these will no longer match
        "
        augroup AutochdirFix
            autocmd!
            autocmd BufReadPost * silent! lcd %:p:h
        augroup END
    " }}
endif

" NERDTree for filesystem navigation/manipulation
Plug 'scrooloose/nerdtree'
" {{
    let g:NERDTreeShowHidden = 1
    let g:NERDTreeShowLineNumbers = 1
    let g:NERDTreeMinimalUI = 1
    let g:NERDTreeFileExtensionHighlightFullName = 1
    let g:NERDTreeExactMatchHighlightFullName = 1
    let g:NERDTreePatternMatchHighlightFullName = 1
    let g:NERDTreeMapJumpNextSibling = '<Nop>'
    let g:NERDTreeMapJumpPrevSibling = '<Nop>'
    nnoremap <Leader>o :NERDTree<CR>

    augroup NERDTreeSettings
        autocmd!
        " Relative line numbering, match 'open in split' bindings of CtrlP and fzf
        autocmd FileType nerdtree setlocal relativenumber
        autocmd FileType nerdtree nmap <buffer> <C-v> s
        autocmd FileType nerdtree nmap <buffer> <C-x> i
    augroup END
" }}

" NERDTree extensions: syntax highlighting, version control indicators
" > Our fork of vim-nerdtree-syntax-highlight suppresses some icon errors
" > See: https://github.com/tiagofumo/vim-nerdtree-syntax-highlight/pull/39
Plug 'brentyi/vim-nerdtree-syntax-highlight'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'f4t-t0ny/nerdtree-hg-plugin'
" {{
    let g:NERDTreeIndicatorMapCustom = {
        \ 'Modified'  : 'M',
        \ 'Staged'    : '+',
        \ 'Untracked' : '?',
        \ 'Renamed'   : 'renamed',
        \ 'Unmerged'  : 'unmerged',
        \ 'Deleted'   : 'X',
        \ 'Dirty'     : 'd',
        \ 'Clean'     : 'c',
        \ 'Ignored'   : '-',
        \ 'Unknown'   : '??'
        \ }
" }}

" Massive language pack for syntax highlighting, etc
Plug 'sheerun/vim-polyglot'
" {{
    " Disable weird 'commas as pipes' feature in csv.vim
    let g:csv_no_conceal = 1

    " Markdown configuration
    let g:vim_markdown_conceal = 0
    let g:vim_markdown_auto_insert_bullets = 0
    let g:vim_markdown_new_list_item_indent = 0
    let g:vim_markdown_math = 1
" }}

" Fancy colors for CSS
Plug 'ap/vim-css-color'

" Rainbow highlighting + SQL-esque queries in CSV files
Plug 'mechatroner/rainbow_csv'

" Tag matching for HTML
Plug 'gregsexton/MatchTag'

" ~~ Color schemes ~~
Plug 'vim-scripts/xoria256.vim'
Plug 'tomasr/molokai'
Plug 'sjl/badwolf'

" Vim + tmux integration
Plug 'christoomey/vim-tmux-navigator'
Plug 'tmux-plugins/vim-tmux-focus-events'
" {{
    " https://github.com/tmux-plugins/vim-tmux-focus-events/issues/2
    augroup BlurArtifactBandaid
        autocmd!
        au FocusLost * silent redraw!
    augroup END
" }}

" Underline all instances of current word
Plug 'itchyny/vim-cursorword'

" Super intelligent indentation level detection
Plug 'tpope/vim-sleuth'
" {{
    " Default to 4 spaces
    set shiftwidth=4
    set expandtab

    " Load plugin early so user-defined autocmds override it
    runtime! plugin/sleuth.vim
" }}

" Shortcuts for adding comments (<Leader>cc, <Leader>ci, etc)
Plug 'scrooloose/nerdcommenter'
" {{
    let g:NERDSpaceDelims = 1
    let g:NERDCompactSexyComs = 1
    let g:NERDCommentEmptyLines = 1
    let g:NERDTrimTrailingWhitespace = 1
    let g:NERDDefaultAlign = 'left'
    let g:NERDAltDelims_python = 1
    let g:NERDAltDelims_cython = 1
    let g:NERDAltDelims_pyrex = 1
" }}

" Persistent cursor position + folds
Plug 'vim-scripts/restore_view.vim'
" {{
    set viewoptions=cursor,folds,slash,unix
" }}

" Helpers for Markdown:
" 1) Directly paste images
" 2) Live preview
" 3) Table of contents generation
" 4) Emoji autocompletion
"    > Our fork removes emojis not found in common markdown parsers (Github,
"      markdown-it), and adds ones that are
Plug 'ferrine/md-img-paste.vim'
Plug 'iamcco/markdown-preview.nvim', { 'do': ':call mkdp#util#install()', 'for': ['markdown', 'vim-plug']}
Plug 'mzlogin/vim-markdown-toc'
Plug 'brentyi/vim-emoji'
" {{
    augroup MarkdownBindings
        autocmd!
        " Markdown paste image
        autocmd FileType markdown nnoremap <buffer>
            \ <Leader>mdpi :call mdip#MarkdownClipboardImage()<CR>
        " Markdown toggle preview
        autocmd FileType markdown nmap <buffer>
            \ <Leader>mdtp <Plug>MarkdownPreviewToggle
        autocmd FileType markdown setlocal completefunc=emoji#complete
        " Markdown generate TOC
        autocmd FileType markdown nnoremap <buffer>
            \ <Leader>mdtoc :GenTocGFM<CR>
    augroup END

    " Don't automatically close preview windows when we switch buffers
    let g:mkdp_auto_close = 0

    " KaTeX options
    let g:mkdp_preview_options = {
        \ 'katex': {
            \ 'globalGroup': 1,
            \  },
        \ }
" }}

" Display markers to signify different indentation levels
Plug 'Yggdroot/indentLine'
" {{
    let g:indentLine_char = '·'
    let g:indentLine_fileTypeExclude = ['json', 'markdown', 'tex']
" }}

" Status line
Plug 'itchyny/lightline.vim'
" {{
    " Display human-readable path to file
    " This is generated in vim-repo-file-search
    function! s:lightline_filepath()
        return get(b:, 'repo_file_search_display', '')
    endfunction

    let g:brent_lightline_colorscheme = get(g:, 'brent_lightline_colorscheme', 'wombat')
    let g:lightline = {
        \ 'colorscheme': g:brent_lightline_colorscheme,
        \ 'active': {
        \   'left': [ [ 'mode', 'paste' ],
        \             [ 'readonly', 'filename', 'modified' ],
        \             [ 'signify' ] ],
        \   'right': [ [ 'lineinfo' ],
        \              [ 'filetype', 'charvaluehex' ],
        \              [ 'linter_checking', 'linter_errors', 'linter_warnings', 'linter_infos', 'linter_ok' ],
        \              [ 'gutentags' ],
        \              [ 'filepath' ],
        \              [ 'truncate' ]]
        \ },
        \ 'inactive': {
        \   'left': [ [ 'readonly', 'filename', 'modified' ] ],
        \   'right': [ [],
        \              [],
        \              [ 'linter_checking', 'linter_errors', 'linter_warnings', 'linter_infos', 'linter_ok' ],
        \              [ 'filepath', 'lineinfo' ],
        \              [ 'truncate' ]]
        \ },
        \ 'component': {
        \   'charvaluehex': '0x%B',
        \   'gutentags': '%{GutentagsStatus()}%{gutentags#statusline("", "", "[ctags indexing]")}',
        \   'signify': has('patch-8.0.902') ? '%{sy#repo#get_stats_decorated()}' : '',
        \   'truncate': '%<',
        \ },
        \ 'component_function': {
        \   'filepath': string(function('s:lightline_filepath')),
        \ },
        \ }

    " ALE components
    let g:lightline.component_expand = {
        \  'linter_checking': 'lightline#ale#checking',
        \  'linter_infos': 'lightline#ale#infos',
        \  'linter_warnings': 'lightline#ale#warnings',
        \  'linter_errors': 'lightline#ale#errors',
        \  'linter_ok': 'lightline#ale#ok',
        \ }

    let g:lightline.component_type = {
        \     'linter_checking': 'right',
        \     'linter_infos': 'right',
        \     'linter_warnings': 'warning',
        \     'linter_errors': 'error',
        \     'linter_ok': 'ok',
        \ }

" }}

" Show instance # in statusline when we search
Plug 'henrik/vim-indexed-search'

" Autocompletion for Github issues, users, etc
" > Our fork just adds more emojis :)
Plug 'brentyi/github-complete.vim'

" Lightweight autocompletion w/ tab key
Plug 'ajh17/VimCompletesMe'
" {{
    " Use j, k for selecting autocompletion results & enter for selection
    inoremap <expr> j ((pumvisible())?("\<C-n>"):('j'))
    inoremap <expr> k ((pumvisible())?("\<C-p>"):('k'))
    inoremap <expr> <CR> ((pumvisible())?("\<C-y>"):("\<CR>"))

    augroup Autocompletion
        autocmd!

        " Use omnicomplete by default for C++ (clang), Python (jedi), and
        " gitcommit (github-complete)
        autocmd FileType cpp,c,python,gitcommit let b:vcm_tab_complete = "omni"

        " Use vim-emoji for markdown
        autocmd FileType markdown let b:vcm_tab_complete = "user"
    augroup END
" }}

" Python magic (auto-completion, definition jumping, etc)
Plug 'davidhalter/jedi-vim'
" {{
    " Disable automatic autocomplete popup
    let g:jedi#popup_on_dot=0

    " Leave docs open (close binding below)
    let g:jedi#auto_close_doc=0

    " Disable call signature popup
    let g:jedi#show_call_signatures=0
" }}

" C/C++ autocompletion
Plug 'xavierd/clang_complete'
" {{
    " Automatically find all installed versions of libclang, for when clang isn't
    " in the system search path
    function! s:find_libclang()
        " Delete the autocmd: we only need to find libclang once
        autocmd! FindLibclang

        " List all possible paths
        let l:clang_paths =
            \ glob('/usr/lib/llvm-*/lib/libclang.so.1', 0, 1)
            \ + glob('/usr/lib64/llvm-*/lib/libclang.so.1', 0, 1)
            \ + glob('/usr/lib/libclang.so.*', 0, 1)
            \ + glob('/usr/lib64/libclang.so.*', 0, 1)

        " Find the newest version and set g:clang_library_path
        let l:min_version = 0.0
        for l:path in l:clang_paths
            try
                " Figure out version from filename
                let l:current_version = str2float(
                    \ split(split(l:path, '-')[1], '/')[0])
            catch
                " No version in filename, let's just use pi...
                let l:current_version = 3.14159265
            endtry

            if filereadable(l:path) && l:current_version > l:min_version
                let g:clang_library_path=l:path
                echom "Found libclang: " . l:path . ", v" .
                       \ string(l:current_version)
                let l:min_version = l:current_version
            endif
        endfor

        " Failure message
        if !exists('g:clang_library_path')
            echom "Couldn't find libclang!"
        endif
    endfunction

    " Search for libclang when we open a C/C++ file
    augroup FindLibclang
        autocmd!
        autocmd Filetype c,cpp call s:find_libclang()
    augroup END
" }}

" Add pseudo-registers for copying to system clipboard (example usage: "+Y)
" > This basically emulates the +clipboard vim feature flag
" > Our fork contains important bug fixes, feature enhancements, etc from
"    unmerged pull requests made to the upstream repository
Plug 'brentyi/vim-fakeclip'

" Google's code format plugin + dependencies
" > Our vim-codefmt fork adds support for black, tweaks some autopep8/yapf
"   settings (these aren't used with black enabled, though)
Plug 'google/vim-maktaba'
Plug 'google/vim-glaive'
Plug 'brentyi/vim-codefmt'
" {{
    nnoremap <Leader>cf :FormatCode<CR>:redraw!<CR>
    vnoremap <Leader>cf :FormatLines<CR>:redraw!<CR>

    " Autoformatter configuration
    augroup CodeFmtSettings
        autocmd!

        " Async Python formatting: run isort, then Black
        " + some hacky stuff to prevent cursor jumps
        "
        " If formatting in visual mode, use yapf
        autocmd FileType python nnoremap <buffer> <Leader>cf
            \ :call <SID>format_python()<CR>
        autocmd FileType python vnoremap <buffer> <Leader>cf :FormatLines yapf<CR>:redraw!<CR>

        function! s:format_python()
            let s:format_python_restore_pos = getpos('.')
            let s:format_python_orig_line_count = line('$')
            call isort#Isort(1, line('$'), function('s:format_python_callback'))
        endfunction

        function! s:format_python_callback()
            if s:format_python_orig_line_count != line('$')
                call codefmt#FormatBuffer('black') | execute "redraw!"
                call setpos('.', s:format_python_restore_pos)
            else
                call codefmt#FormatBuffer('black') | execute "redraw!"
            endif
        endfunction

        " Use prettier for Javascript
        autocmd FileType javascript let b:codefmt_formatter='prettier'
    augroup END

    " Automatically find the newest installed version of clang-format
    function! s:find_clang_format()
        " Delete the autocmd: we only need to find clang-format once
        autocmd! FindClangFormat

        " If clang-format is in PATH, we don't need to do anything
        if executable('clang-format')
            echom "Found clang-format in $PATH"
                Glaive codefmt clang_format_executable='clang-format'
            return
        endif

        " List all possible paths
        let l:clang_paths =
            \ glob('/usr/lib/llvm-*/bin/clang-format', 0, 1)
            \ + glob('/usr/lib64/llvm-*/bin/clang-format', 0, 1)

        " Find the newest version and set clang_format_executable
        let l:min_version = 0.0
        for l:path in split(l:clang_paths, '\n')
            let l:current_version = str2float(
                \ split(split(l:path, '-')[1], '/')[0])

            if filereadable(l:path) && l:current_version > l:min_version
                Glaive codefmt clang_format_executable=`l:path`
                echom "Found clang-format: " . l:path
                let l:min_version = l:current_version
            endif
        endfor

        " Failure message
        if g:clang_format_executable == ""
            echom "Couldn't find clang-format!"
        endif
    endfunction

    " Search for clang-format when we open a C/C++ file
    augroup FindClangFormat
        autocmd!
        autocmd Filetype c,cpp call s:find_clang_format()
    augroup END
" }}

" Automated import sorting
Plug 'brentyi/isort.vim'
" {{
    " (Python) isort bindings
    augroup IsortMappings
        autocmd!
        autocmd FileType python nnoremap <buffer> <Leader>si :Isort<CR>
        autocmd FileType python vnoremap <buffer> <Leader>si :Isort<CR>
    augroup END
" }}

" Automated docstring template generation
Plug 'heavenshell/vim-pydocstring', { 'do': 'make install' }
" {{
    " (Python) Docstring bindings
    let g:pydocstring_formatter = get(g:, 'pydocstring_formatter', 'google')

    " <Plug>(pydocstring) needs to be mapped, or the plugin will override our
    " <C-l> binding
    nmap <Leader>pds <Plug>(pydocstring)
" }}

" Gutentags, for generating tag files
" > Our fork suppresses some errors for machines without ctags installed
Plug 'brentyi/vim-gutentags'
" {{
    " Set cache location
    let g:gutentags_cache_dir = '~/.vim/.cache/tags'

    " Enable extra ctags features
    " - a: Access/export of class members
    " - i: Inheritance information
    " - l: Programming language
    " - m: Implementation information
    " - n: Line number
    " - S: Signature of routine (e.g. prototype or parameter list)
    let g:gutentags_ctags_extra_args = [
          \ '--fields=+ailmnS',
          \ ]

    " Lightline integration
    function! GutentagsStatus()
        if exists('g:gutentags_ctags_executable') && executable(expand(g:gutentags_ctags_executable, 1)) == 0
            return 'missing ctags'
        elseif !g:gutentags_enabled
            return 'ctags off'
        endif
        return ''
    endfunction
    augroup GutentagsStatusLineRefresher
        autocmd!
        autocmd User GutentagsUpdating call lightline#update()
        autocmd User GutentagsUpdated call lightline#update()
    augroup END
" }}

" Summarize tags in current file
Plug 'majutsushi/tagbar'
" {{
    nmap <Leader>tbt :TagbarToggle<CR>
    let g:tagbar_show_linenumbers = 2
    let g:tagbar_map_nexttag = "J"
    let g:tagbar_map_prevtag = "K"
" }}

" Animations for fun?
" > Note: enabling this for fzf will partially break preview windows
Plug 'camspiers/animate.vim'
" {{
    let g:animate#duration = 150.0
    let g:animate#easing_func = 'animate#ease_out_quad'
" }}

" Linting
" > Our fork expands support for alex, which is somewhat problematic but can
"   still be helpful?
Plug 'brentyi/ale'
Plug 'maximbaz/lightline-ale'
" {{
    " Bindings
    nnoremap <Leader>al :ALELint<CR>
    nnoremap <Leader>ar :ALEReset<CR>
    nnoremap <Leader>arb :ALEResetBuffer<CR>

    " Disable ALE by default
    let g:ale_lint_on_text_changed = 'never'
    let g:ale_lint_on_insert_leave = 0
    let g:ale_lint_on_enter = 0
    let g:ale_lint_on_save = 0

    " Populate errors in a quickfix window, and open it automatically
    let g:ale_set_loclist = 0
    let g:ale_set_quickfix = 1
    let g:ale_open_list = 1

    " Python specific options
    " Flake8 ignore list:
    "     E501: line too long (<n> characters)
    "     D100: Missing docstring in public module
    "     D101: Missing docstring in public class
    "     D102: Missing docstring in public method
    "     D103: Missing docstring in public function
    "     W503: line break before binary operator
    let g:ale_python_flake8_options = "--ignore=E501,D100,D101,D102,D103,W503"
    let g:ale_python_mypy_options= "--ignore-missing-imports"

    " Alex stuff needs to be manually enabled
    let g:ale_linters = {
        \ 'asciidoc': ['alex'],
        \ 'cpp': ['alex'],
        \ 'html': ['alex'],
        \ 'javascript': ['alex'],
        \ 'markdown': ['alex'],
        \ 'python': ['alex', 'flake8', 'mypy', 'pylint'],
        \ 'rst': ['alex'],
        \ 'tex': ['alex'],
        \ }

    " ALE sign column stuff
    augroup ALEColors
        autocmd!

        function! s:SetALEColors()
            highlight ALEErrorSign ctermfg=red ctermbg=NONE
            highlight ALEWarningSign ctermfg=yellow ctermbg=NONE
            highlight ALEInfoSign ctermfg=blue ctermbg=NONE
        endfunction

        autocmd ColorScheme * call s:SetALEColors()
    augroup END

    let g:ale_sign_error = '••'
    let g:ale_sign_warning = '••'
    let g:ale_sign_info = '••'
" }}

" Show unsaved changes to a file
Plug 'jmcantrell/vim-diffchanges'
" {{
    nnoremap <Leader>dc :DiffChangesDiffToggle<CR>
" }}

call plug#end()

" We only want to do the rest if our plugins are already installed :)
if !s:fresh_install
    " Initialize Glaive + codefmt
    call glaive#Install()
    Glaive codefmt plugin[mappings]

    " Files for ctrlp + gutentags to ignore!
    set wildignore=*.swp,*.o,*.pyc,*.pb
    " Linux/MacOSX
    set wildignore+=*/.git/*,*/.hg/*,*/.svn/*,*/.castle/*,*/.buckd/*,*/.venv/*,*/site-packages/*
    " Windows ('noshellslash')
    set wildignore+=*\\.git\\*,*\\.hg\\*,*\\.svn\\*,*\\.castle\\*,*\\.buckd\\*,*\\.venv\\*,*\\site-packages\\*

    " Set up the wild menu
    set wildmenu
    set wildmode=longest:full,full

    " #############################################
    " > Visuals <
    " #############################################

    syntax on

    " Line numbering
    if v:version > 703
        " Vim versions after 703 support enabling both number and relativenumber
        " (To display relative numbers for all but the current line)
        set number
    endif
    set relativenumber

    " Show at least 7 lines above/below the cursor when we scroll
    set scrolloff=7

    " Cursor crosshair when we enter insert mode
    " Note we re-bind Ctrl+C in order for InsertLeave to be called
    augroup InsertModeCrossHairs
        autocmd!
        autocmd InsertEnter * set cursorline
        autocmd InsertLeave * set nocursorline
        autocmd InsertEnter * set cursorcolumn
        autocmd InsertLeave * set nocursorcolumn
    augroup END
    inoremap <C-C> <Esc>

    " Configuring colors
    set background=dark
    augroup ColorschemeOverrides
        autocmd!
        function! s:ColorschemeOverrides()
            if g:brent_colorscheme == 'legacy'
                " Fallback colors for some legacy terminals
                set t_Co=16
                set foldcolumn=1
                hi FoldColumn ctermbg=7
                hi LineNr cterm=bold ctermfg=0 ctermbg=0
                hi CursorLineNr ctermfg=0 ctermbg=7
                hi Visual cterm=bold ctermbg=1
                hi TrailingWhitespace ctermbg=1
                hi Search ctermfg=4 ctermbg=7
            else
                " When we have 256 colors available
                " (This is usually true)
                set t_Co=256
                hi LineNr ctermfg=241 ctermbg=234
                hi CursorLineNr cterm=bold ctermfg=232 ctermbg=250
                hi Visual cterm=bold ctermbg=238
                hi TrailingWhitespace ctermbg=52
                let g:indentLine_color_term=237
            endif
        endfunction
        autocmd ColorScheme * call s:ColorschemeOverrides()
    augroup END

    let g:brent_colorscheme = get(g:, 'brent_colorscheme', 'xoria256')
    if g:brent_colorscheme != 'legacy'
        execute "colorscheme " . g:brent_colorscheme
    else
        execute "colorscheme peachpuff"
    endif

    hi MatchParen cterm=bold,underline ctermbg=none ctermfg=7
    hi VertSplit ctermfg=0 ctermbg=0

    augroup MatchTrailingWhitespace
        autocmd!
        autocmd VimEnter,BufEnter,WinEnter * call matchadd('TrailingWhitespace', '\s\+$')
    augroup END

    " Visually different markers for various types of whitespace
    " (for distinguishing tabs vs spaces)
    set list listchars=tab:❘-,trail:\ ,extends:»,precedes:«,nbsp:×

    " Show the statusline, always!
    set laststatus=2

    " Hide redundant mode indicator underneath statusline
    set noshowmode

    " Highlight searches
    set hlsearch


    " #############################################
    " > General behavior stuff <
    " #############################################

    " Set plugin, indentation settings automatically based on the filetype
    filetype plugin indent on

    " Make escape insert mode zippier
    set timeoutlen=300 ttimeoutlen=10

    " Allow backspacing over everything (eg line breaks)
    set backspace=2

    " Expand history of saved commands
    set history=35

    " Enable modeline for file-specific vim settings
    " This is insecure on some vim versions and should maybe be removed?
    set modeline

    " Fold behavior tweaks
    set foldmethod=indent
    set foldlevel=99

    " Passive FTP mode for remote netrw
    let g:netrw_ftp_cmd = 'ftp -p'


    " #############################################
    " > Key mappings for usability <
    " #############################################

    " Alternate escape key bindings
    vmap [[ <Esc>
    vmap ;; <Esc>
    imap [[ <Esc>
    imap ;; <Esc>

    " Search utilities -- highlight matches, clear highlighting with <Esc>
    nnoremap <Esc> :noh<CR>:redraw!<CR><Esc>
    nnoremap <Esc>^[ <Esc>^[

    " Use backslash to toggle folds
    nnoremap <Bslash> za

    " Binding to toggle line numbering -- useful for copy & paste, etc
    if v:version > 703
        nnoremap <Leader>tln :set number!<CR>:set relativenumber!<CR>
    else
        nnoremap <Leader>tln :set relativenumber!<CR>
    endif

    " Bindings for lower-effort writing, quitting, reloading
    nnoremap <Leader>wq :wq<CR>
    nnoremap <Leader>w :w<CR>
    nnoremap <Leader>q :q<CR>
    nnoremap <Leader>q! :q!<CR>
    nnoremap <Leader>e :e<CR>
    nnoremap <Leader>e! :e!<CR>
    nnoremap <Leader>e. :e .<CR>

    " Binding to switch into/out of PASTE mode
    nnoremap <Leader>ip :set invpaste<CR>

    " Binding to trim trailing whitespaces in current file
    nnoremap <Leader>ttws :%s/\s\+$//e<CR>

    " Binding to 'replace this word'
    nnoremap <Leader>rtw :%s/\<<C-r><C-w>\>/

    " Switch ' and ` for jumps: ' is much more intuitive and easier to access
    onoremap ' `
    vnoremap ' `
    nnoremap ' `
    onoremap ` '
    vnoremap ` '
    nnoremap ` '

    " Bindings for buffer stuff
    " > bd: delete current buffer
    " > bc: clear all but current buffer
    " > baa: open buffer for all files w/ same extension in current directory
    nnoremap <Leader>bd :bd<CR>
    nnoremap <Leader>bc :%bd\|e#<CR>
    nnoremap <Leader>baa :call <SID>buffer_add_all()<CR>
    function! s:buffer_add_all()
        " Get a full path to the current file
        let l:path = expand("%:p")

        " Chop off the filename and add wildcard
        let l:pattern = l:path[:-len(expand("%:t")) - 1] . "**/*." . expand("%:e")
        echom "Loaded buffers matching pattern: " . l:pattern
        for l:path in split(glob(l:pattern), '\n')
            let filesize = getfsize(l:path)
            if filesize > 0 && filesize < 80000
                execute "badd " . l:path
            endif
        endfor
    endfunction

    " Bindings for switching between tabs
    nnoremap <Leader>tt :tabnew<CR>
    nnoremap <Leader>tn :tabn<CR>

    " 'Force write' binding for writing with sudo
    " Helpful if we don't have permissions for a specific file
    cmap W! w !sudo tee >/dev/null %

    " Some <Leader>direction movement bindings for diffs + quickfix windows
    " We also throw in a lightline update, to fix a statusline bug when a
    " quickfix jump goes between files
    nnoremap <expr> <Leader>j (&diff ? "]c" : ":cnext\<CR>:call lightline#update()<CR>")
    nnoremap <expr> <Leader>k (&diff ? "[c" : ":cprev\<CR>:call lightline#update()<CR>")

    " Close preview/quickfix/location list/help windows with <Leader>c
    nnoremap <Leader>c :call <SID>window_cleanup()<CR>
    function! s:window_cleanup()
        " Close preview windows
        execute "pclose"

        " Close quickfix windows
        execute "cclose"

        " Close location list windows
        execute "lclose"

        " Close help windows
        execute "helpclose"

        " Close Python docstring buffers (eg from jedi-vim)
        for l:b in filter(range(1, bufnr('$')), 'bufloaded(v:val)')
            if bufname(l:b)[-7:] ==# '__doc__'
                execute "bd " . l:b
            endif
        endfor
    endfun


    " #############################################
    " > Configuring splits <
    " #############################################

    " Match tmux behavior + bindings (with <C-w> instead of <C-b>)
    set splitbelow
    set splitright
    nmap <C-w>" :sp<CR>
    nmap <C-w>% :vsp<CR>


    " #############################################
    " > Friendly mode <
    " ##############################################

    " This maps <Leader>f to toggle between:
    "  - 'Default mode': arrow keys resize splits, mouse disabled
    "  - 'Friendly mode': arrow keys, mouse behave as usual

    nnoremap <silent> <Leader>f :call <SID>toggle_friendly_mode(1)<CR>

    let s:friendly_mode = 1
    function! s:toggle_friendly_mode(verbose)
        if s:friendly_mode
            nnoremap <silent> <Up>
                        \ :<C-U>call animate#window_delta_height(v:count1 * 8)<CR>
            nnoremap <silent> <Down>
                        \ :<C-U>call animate#window_delta_height(v:count1 * -8)<CR>
            nnoremap <silent> <Left>
                        \ :<C-U>call animate#window_delta_width(v:count1 * -8)<CR>
            nnoremap <silent> <Right>
                        \ :<C-U>call animate#window_delta_width(v:count1 * 8)<CR>
            set mouse=
            let s:friendly_mode = 0

            if a:verbose
                echo "disabled friendly mode!"
            endif
        else
            unmap <silent> <Up>
            unmap <silent> <Down>
            unmap <silent> <Right>
            unmap <silent> <Left>
            set mouse=a
            let s:friendly_mode = 1

            if a:verbose
                echo "enabled friendly mode!"
            endif
        endif
    endfunction
    call <SID>toggle_friendly_mode(0)


    " #############################################
    " > Filetype-specific configurations <
    " #############################################

    augroup FiletypeHelpers
        autocmd!

        " (ROS) Launch files should be highlighted as xml
        autocmd BufNewFile,BufRead *.launch set filetype=xml

        " (Makefile) Only tabs are supported
        autocmd FileType make setlocal noexpandtab | setlocal shiftwidth&

        " (Buck) Highlight as python
        autocmd BufNewFile,BufRead BUCK* set filetype=python
        autocmd BufNewFile,BufRead TARGETS set filetype=python

        " (C++) Angle bracket matching for templates
        autocmd FileType cpp setlocal matchpairs+=<:>

        " (Python/C++/Markdown) Highlight lines that are too long
        " 88 for Python (to match black defaults)
        " 80 for Markdown (to match prettier defaults)
        " 100 for C++ (clang-format is 80 by default, but we've been overriding to 100)
        highlight OverLength ctermbg=darkgrey
        autocmd VimEnter,BufEnter,WinEnter *.py call matchadd('OverLength', '\%>88v.\+')
        autocmd VimEnter,BufEnter,WinEnter *.md call matchadd('OverLength', '\%>80v.\+')
        autocmd VimEnter,BufEnter,WinEnter *.cpp call matchadd('OverLength', '\%>100v.\+')
        autocmd VimLeave,BufLeave,WinLeave * call
            \ clearmatches()

        " (C/C++) Automatically insert header gates for h/hpp files
        autocmd BufNewFile *.{h,hpp} call <SID>insert_gates()
        function! s:insert_gates()
            let gatename = substitute(toupper(expand("%:t")), "\\.", "_", "g")
            execute "normal! i#ifndef " . gatename
            execute "normal! o#define " . gatename . " "
            execute "normal! Go#endif /* " . gatename . " */"
            normal! kk
        endfunction

        " (Commits) Enable spellcheck
        autocmd FileType gitcommit,hgcommit setlocal spell
    augroup END


    " #############################################
    " > Automatic window renaming for tmux <
    " #############################################

    if exists('$TMUX')
        augroup TmuxHelpers
          " TODO: fix strange behavior when we break-pane in tmux
            autocmd!
            autocmd BufReadPost,FileReadPost,BufNewFile,BufEnter,FocusGained * call system("tmux rename-window 'vim " . expand("%:t") . "'")
            autocmd VimLeave,FocusLost * call system("tmux set-window-option automatic-rename")
        augroup END
    endif


    " #############################################
    " > Spellcheck <
    " #############################################

    map <F5> :setlocal spell! spelllang=en_us<CR>
    inoremap <F5> <C-\><C-O>:setlocal spelllang=en_us spell! spell?<CR>
    hi clear SpellBad
    hi SpellBad cterm=bold,italic ctermfg=red


    " #############################################
    " > Meta <
    " #############################################

    augroup AutoReloadVimRC
        autocmd!
        autocmd BufWritePost $MYVIMRC source $MYVIMRC

        " For init.vim->.vimrc symlinks in Neovim
        autocmd BufWritePost .vimrc source $MYVIMRC
    augroup END
endif
