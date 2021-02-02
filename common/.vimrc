"
" brentyi@berkeley.edu
"

" #############################################
" > Initial setup <
" #############################################

" Disable vi compatability
set nocompatible

" Default to utf-8 (not needed/creates error for Neovim)
if !has('nvim')
    set encoding=utf-8
endif

" Backport for trim()
" https://github.com/Cimbali/vim-better-whitespace/commit/855bbef863418a36bc10e5a51ac8ce78bcbdcef8
function! s:trim(s)
    if exists('*trim')
        return trim(a:s)
    else
        return substitute(a:s, '^\s*\(.\{-}\)\s*$', '\1', '')
    endif
endfunction

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
        if b:repo_file_search_type ==# 'hg'
            Hgvdiff
        elseif b:repo_file_search_type ==# 'git'
            Gdiff
        endif
    endfunction

    " Keybinding for printing repo status
    nnoremap <Leader>vcs :call <SID>vc_status()<CR>
    function! s:vc_status()
        if b:repo_file_search_type ==# 'hg'
            Hgstatus
        elseif b:repo_file_search_type ==# 'git'
            Gstatus
        endif
    endfunction

    " Keybinding for blame/annotate
    nnoremap <Leader>vcb :call <SID>vc_blame()<CR>
    function! s:vc_blame()
        if b:repo_file_search_type ==# 'hg'
            Hgannotate
        elseif b:repo_file_search_type ==# 'git'
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
    Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
    Plug 'junegunn/fzf.vim'
    " {{
        function! s:smarter_fuzzy_file_search()
            execute 'Files ' . b:repo_file_search_root
        endfunction

        " Helpers for using &wildignore with fzf
        let s:fzf_ignore_options = ''

        function! s:update_fzf_with_wildignore()
            let s:fzf_ignore_options = ' '.join(map(split(&wildignore, ','), '"--ignore \"" . v:val . "\""'))
            if executable('ag')
                let $FZF_DEFAULT_COMMAND='ag --hidden ' . s:fzf_ignore_options . ' -g ""'
            endif
        endfunction

        augroup ConfigureFzf
            autocmd!
            " Configure fzf after wildignore is set later in vimrc
            autocmd VimEnter * call s:update_fzf_with_wildignore()
        augroup END


        " Show error if ag is unavailable
        if !executable('ag')
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
            \ call fzf#vim#ag(<q-args>, '--hidden ' . s:fzf_ignore_options, fzf#vim#with_preview({
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
        nnoremap <Leader>ph :Files<CR>
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
        vnoremap <Leader>a :<C-U>call <SID>GrepVisual(visualmode())<CR>
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

        " Use Vim colors for fzf
        let g:fzf_layout = {
            \ 'window': 'new'
            \ }
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
"
" Our fork of nerdtree-hg-plugin fixes a compatability issue.
" See: https://github.com/f4t-t0ny/nerdtree-hg-plugin/pull/2
Plug 'tiagofumo/vim-nerdtree-syntax-highlight'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'brentyi/nerdtree-hg-plugin'
" {{
    let g:NERDTreeGitStatusIndicatorMapCustom = {
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
    " Disable csv.vim: this overrides a bunch of default vim bindings with
    " csv-specific ones that looks high-effort to get used to
    "
    " For highlighting etc, we use rainbow_csv (see below)
    if !has("nvim")
        let g:polyglot_disabled = ['csv']
    else
        " Use Semshi for Python
        let g:polyglot_disabled = ['csv', 'python']
        Plug 'numirias/semshi'
    endif

    " Markdown configuration
    let g:vim_markdown_conceal = 0
    let g:vim_markdown_conceal_code_blocks = 0
    let g:vim_markdown_auto_insert_bullets = 0
    let g:vim_markdown_new_list_item_indent = 0
    let g:vim_markdown_math = 1

    augroup SyntaxSettings
        autocmd!
        " For Python, bold TODO keyword in strings (for docstrings)
        function! s:HighlightDocstringTodo()
            syn keyword DocstringTodo TODO FIXME XXX containedin=pythonString,pythonRawString

            redir => l:python_string_highlight
            silent highlight Constant
            redir END

            let l:python_string_highlight = s:trim(split(l:python_string_highlight, 'xxx')[1])
            highlight clear DocstringTodo
            execute 'highlight DocstringTodo ' . l:python_string_highlight . ' cterm=bold'
        endfunction
        autocmd BufEnter,WinEnter *.py  call s:HighlightDocstringTodo()
    augroup END
" }}

" Fancy colors for CSS
Plug 'ap/vim-css-color'

" Dev Docs for web development
Plug 'romainl/vim-devdocs'
" {{
    augroup DevDocsBindings
        " Use `K` to lookup keyword
        autocmd!
        autocmd FileType css setl isk+=-
        autocmd FileType html,css,javascript setlocal keywordprg=:DD
    augroup END
" }}

" Rainbow highlighting + SQL-esque queries in CSV files
Plug 'mechatroner/rainbow_csv'

" Tag matching for HTML
Plug 'gregsexton/MatchTag'
" {{
    " Use % to jump between matching tags
    " (this ships with Vim and is not part of MatchTag)
    packadd matchit
" }}

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
    set tabstop=4
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

" Add syntax for liquid
" This needs to happen _after_ all our markdown stuff in order to override
" properly
Plug 'tpope/vim-liquid'

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
    let g:lightline = {}

    " Lightline colors
    let g:lightline.colorscheme = g:brent_lightline_colorscheme
    let g:lightline.active = {
        \ 'left': [ [ 'mode', 'paste' ],
        \           [ 'readonly', 'filename', 'modified' ],
        \           [ 'signify' ] ],
        \ 'right': [ [ 'lineinfo' ],
        \            [ 'filetype', 'charvaluehex' ],
        \            [ 'linter_checking', 'linter_errors', 'linter_warnings', 'linter_infos', 'linter_ok' ],
        \            [ 'gutentags' ],
        \            [ 'filepath' ],
        \            [ 'truncate' ]]
        \ }
    let g:lightline.inactive = {
        \ 'left': [ [ 'readonly', 'filename', 'modified' ] ],
        \ 'right': [ [],
        \            [],
        \            [ 'linter_checking', 'linter_errors', 'linter_warnings', 'linter_infos', 'linter_ok' ],
        \            [ 'filepath', 'lineinfo' ],
        \            [ 'truncate' ]]
        \ }

    " Components
    let g:lightline.component = {
        \   'charvaluehex': '0x%B',
        \   'gutentags': '%{GutentagsStatus()}%{gutentags#statusline("", "", "[ctags indexing]")}',
        \   'signify': has('patch-8.0.902') ? '%{sy#repo#get_stats_decorated()}' : '',
        \   'truncate': '%<',
        \ }
    let g:lightline.component_function = {
        \   'filepath': string(function('s:lightline_filepath')),
        \ }
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

" Search plugins
" > Show instance # in statusline when we search
" > Use * to search visual mode selections
Plug 'henrik/vim-indexed-search'
Plug 'bronson/vim-visual-star-search'

" Autocompletion for Github issues, users, etc
" > Our fork just adds more emojis :)
Plug 'brentyi/github-complete.vim'

" Lightweight autocompletion w/ tab key
" > Use Tab, S-Tab to select, <CR> to confirm
Plug 'ajh17/VimCompletesMe'
" {{
    " Use <CR> for completion selection
    function! s:smart_carriage_return()
        if !pumvisible()
            " No completion window open -> insert line break
            return "\<CR>"
        endif
        if exists('*complete_info') && complete_info()['selected'] == -1
            " No element selected: close the completion window with Ctrl+E, then
            " carriage return
            "
            " Requires Vim >8.1ish
            return "\<C-e>\<CR>"
        endif

        " Select completion
        return "\<C-y>"
    endfunction
    inoremap <expr> <CR> <SID>smart_carriage_return()

    augroup Autocompletion
        autocmd!

        " Use omnicomplete by default for C++ (clang), Python (jedi), and
        " gitcommit (github-complete)
        autocmd FileType cpp,c,python,gitcommit let b:vcm_tab_complete = 'omni'

        " Use vim-emoji for markdown
        autocmd FileType markdown let b:vcm_tab_complete = 'user'
    augroup END
" }}

" LSP plugins for autocompletion, jump to def, etc
"
" Note that we also need to actually install some LSPs, eg:
" > https://github.com/mattn/vim-lsp-settings
Plug 'prabirshrestha/async.vim'
Plug 'prabirshrestha/vim-lsp'
Plug 'mattn/vim-lsp-settings'

" {{
    " Move servers into .vim directory
    let g:lsp_settings_servers_dir = expand("~/.vim/vim-lsp-settings/servers")

    " Make colors a bit less distracting
    augroup LspColors
        autocmd!

        function! s:SetLspColors()
            highlight LspErrorText ctermfg=red ctermbg=NONE
            highlight LspErrorHighlight ctermbg=236

            highlight LspWarningText ctermfg=yellow ctermbg=NONE
            highlight LspWarningHighlight ctermbg=236

            highlight LspHintText ctermfg=blue ctermbg=NONE
            highlight LspHintHighlight ctermbg=236

            highlight LspErrorVirtualText ctermfg=238
            highlight LspWarningVirtualText ctermfg=238
            highlight LspInformationVirtualText ctermfg=238
            highlight LspHintVirtualText ctermfg=238
        endfunction

        autocmd ColorScheme * call s:SetLspColors()
    augroup END

    " Set sign column symbols
    let g:lsp_diagnostics_signs_error = {'text': '▲'}
    let g:lsp_diagnostics_signs_warning = {'text': '▲'}
    let g:lsp_diagnostics_signs_hint = {'text': '▲'}

    " It'd be nice to use pyls-mypy for type-checking, but mypy is not super
    " useful when installed in an isolated virtual env
    "
    " Might be possible to port this over if we don't use a venv for pyls and pyls-mypy
    "
    " " Jump through some hoops to auto-install pyls-mypy whenever we call :LspInstallServer
    " function! s:check_for_pyls_mypy()
    "     if filereadable(expand(g:lsp_settings_servers_dir . "/pyls-all/venv/bin/pyls"))
    "         \ && !filereadable(expand(g:lsp_settings_servers_dir . "/pyls-all/venv/bin/mypy"))
    "
    "         " Install from source because pypi version of pyls-mypy is broken
    "         " for Python 3 (as of 8/6/2020)
    "         let l:cmd =  g:lsp_settings_servers_dir .
    "             \ "/pyls-all/venv/bin/pip3 install " .
    "             \ "git+https://github.com/tomv564/pyls-mypy.git"
    "
    "         if has('nvim')
    "             split new
    "             call termopen(l:cmd, {'cwd': g:lsp_settings_servers_dir})
    "         else
    "             let l:bufnr = term_start(l:cmd)
    "         endif
    "     endif
    " endfunction
    "
    " augroup CheckForPylsMypy
    "     autocmd!
    "     autocmd User lsp_setup call s:check_for_pyls_mypy()
    " augroup END

    " Use flake8 configs for pyls, configure mypy (currently disabled)
    let g:lsp_settings = {}
    let g:lsp_settings['efm-langserver'] = {'disabled': v:false}
    let g:lsp_settings['pyls-all'] = {
        \     'workspace_config': { 'pyls': {
        \         'configurationSources': ['flake8'],
        \         'plugins': {
        \             'pyls_mypy': {
        \                 'enabled': v:false,
        \                 'live_mode': v:false
        \             }
        \         }
        \     }}
        \ }

    " Show error messages below statusbar
    let g:lsp_diagnostics_echo_cursor = 1

    " Binding for showing loclist with all errors
    nnoremap <Leader><Tab> :LspDocumentDiagnostics<CR>
" }}

" Async 'appears as you type' autocompletion
" > Use Tab, S-Tab to select, <CR> to confirm (see above for binding)
Plug 'prabirshrestha/asyncomplete.vim'
Plug 'prabirshrestha/asyncomplete-lsp.vim'

" {{
    " Bindings
    function! s:on_lsp_buffer_enabled() abort
        setlocal omnifunc=lsp#complete
        if exists('+tagfunc') | setlocal tagfunc=lsp#tagfunc | endif
        nmap <buffer> <Leader>gd <plug>(lsp-definition)
        nmap <buffer> <Leader>gr <plug>(lsp-references)
        nmap <buffer> <Leader>gi <plug>(lsp-implementation)
        " This conflicts with a CtrlP/fzf binding
        "" nmap <buffer> <Leader>gt <plug>(lsp-type-definition)
        nmap <buffer> <Leader>rn <plug>(lsp-rename)
        nmap <buffer> <Leader>[g <Plug>(lsp-previous-diagnostic)
        nmap <buffer> <Leader>]g <Plug>(lsp-next-diagnostic)
        nmap <buffer> K <plug>(lsp-hover)
    endfunction

    " Call s:on_lsp_buffer_enabled only for languages with registered
    " servers
    augroup lsp_install
        autocmd!
        autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
    augroup END
" }}

" Snippets & LSP integration
Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'
Plug 'prabirshrestha/asyncomplete-ultisnips.vim'
" {{
    let g:UltiSnipsSnippetDirectories=[$HOME . '/dotfilesp/snippets']

    let g:UltiSnipsExpandTrigger='<Leader>et'
    let g:UltiSnipsJumpForwardTrigger='<Tab>'
    let g:UltiSnipsJumpBackwardTrigger='<S-Tab>'

    function! s:register_ultisnips() abort
        call asyncomplete#register_source(asyncomplete#sources#ultisnips#get_source_options({
            \ 'name': 'ultisnips',
            \ 'allowlist': ['*'],
            \ 'completor': function('asyncomplete#sources#ultisnips#completor'),
            \ }))
    endfunction

    augroup ultisnips_helpers
        au!
        " Disable autotrigger
        au VimEnter * au! UltiSnips_AutoTrigger
        au VimEnter * call s:register_ultisnips()
    augroup END
" }}

" Add pseudo-registers for copying to system clipboard (example usage: "+Y)
" > This basically emulates the +clipboard vim feature flag
" > Our fork contains important bug fixes, feature enhancements, etc from
"    unmerged pull requests made to the upstream repository
" > Also adds support for OSC 52 sequences
Plug 'brentyi/vim-fakeclip'
" {{
    " Ignore has('clipboard')
    let g:fakeclip_provide_clipboard_key_mappings = 1
" }}

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
                call codefmt#FormatBuffer('black') | execute 'redraw!'
                call setpos('.', s:format_python_restore_pos)
            else
                call codefmt#FormatBuffer('black') | execute 'redraw!'
            endif
        endfunction

        " Use prettier for HTML, CSS, Javascript, Markdown, Liquid
        autocmd FileType html,css,javascript,markdown,liquid let b:codefmt_formatter='prettier'
    augroup END

    " Automatically find the newest installed version of clang-format
    function! s:find_clang_format()
        " Delete the autocmd: we only need to find clang-format once
        autocmd! FindClangFormat

        " If clang-format is in PATH, we don't need to do anything
        if executable('clang-format')
            Glaive codefmt clang_format_executable='clang-format'
            return
        endif

        " List all possible paths
        let l:clang_paths =
            \ glob('/usr/lib/llvm-*/bin/clang-format', 0, 1)
            \ + glob('/usr/lib64/llvm-*/bin/clang-format', 0, 1)

        " Find the newest version and set clang_format_executable
        let l:min_version = 0.0
        for l:path in l:clang_paths
            let l:current_version = str2float(
                \ split(split(l:path, '-')[1], '/')[0])

            if filereadable(l:path) && l:current_version > l:min_version
                Glaive codefmt clang_format_executable=`l:path`
                " echom 'Found clang-format: ' . l:path
                let l:min_version = l:current_version
            endif
        endfor

        " Failure message
        if maktaba#plugin#Get('vim-codefmt').Flag('clang_format_executable') ==# ''
            echom 'Couldn''t find clang-format!'
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
    " Ported from:
    " > https://black.readthedocs.io/en/stable/compatible_configs.html#isort
    let g:isort_vim_options = join([
        \ '--multi-line 3',
        \ '--trailing-comma',
        \ '--force-grid-wrap 0',
        \ '--use-parentheses',
        \ '--ensure-newline-before-comments',
        \ '--line-length 88',
        \ ], ' ')

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

    " If we have a hardcoded repository root, use for gutentags
    if exists('g:repo_file_search_root')
        function! FindRepoRoot(path)
            return g:repo_file_search_root
        endfunction
        let g:gutentags_project_root_finder = 'FindRepoRoot'
    endif

    " Lightline integration
    function! GutentagsStatus()
        if exists('g:gutentags_ctags_executable') && executable(expand(g:gutentags_ctags_executable, 1)) == 0
            return 'missing ctags'
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
    let g:tagbar_map_nexttag = 'J'
    let g:tagbar_map_prevtag = 'K'
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

    " Open loclist automatically
    let g:ale_open_list = 1

    " Configure linters
    let g:ale_linters = {
        \ 'asciidoc': ['alex'],
        \ 'cpp': ['alex'],
        \ 'html': ['alex'],
        \ 'javascript': ['alex'],
        \ 'markdown': ['alex'],
        \ 'python': ['alex', 'mypy'],
        \ 'rst': ['alex'],
        \ 'tex': ['alex'],
        \ }
    let g:ale_python_mypy_options= '--ignore-missing-imports'

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

    let g:ale_sign_error = '▲'
    let g:ale_sign_warning = '▲'
    let g:ale_sign_info = '▲'
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

    " Ignore patterns for Python
    set wildignore=*.swp,*.o,*.pyc,*.pb
    set wildignore+=.venv/*,site-packages/*

    " Ignore patterns for version control systems
    set wildignore+=.git/*,.hg/*,.svn/*

    " Ignore patterns for Buck
    set wildignore+=.castle/*,.buckd/*

    " Ignore patterns for Jekyll
    set wildignore+=_site/*,.jekyll-cache/*

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
        if exists('+cursorlineopt')
            " Highlight current line in insertmode, line number always
            " Unfixes this patch: https://github.com/vim/vim/issues/5017
            set cursorline
            set cursorlineopt=number
            autocmd InsertEnter * set cursorlineopt=both
            autocmd InsertLeave * set cursorlineopt=number
        else
            " Neovim + legacy
            autocmd InsertEnter * set cursorline
            autocmd InsertLeave * set nocursorline
        endif
        autocmd InsertEnter * set cursorcolumn
        autocmd InsertLeave * set nocursorcolumn
    augroup END
    inoremap <C-C> <Esc>

    " Configuring colors
    set background=dark
    augroup ColorschemeOverrides
        autocmd!
        function! s:ColorschemeOverrides()
            if g:brent_colorscheme ==# 'legacy'
                " Fallback colors for some legacy terminals
                set t_Co=16
                set foldcolumn=1
                highlight FoldColumn ctermbg=7
                highlight LineNr cterm=bold ctermfg=0 ctermbg=0
                highlight CursorLineNr ctermfg=0 ctermbg=7
                highlight Visual cterm=bold ctermbg=1
                highlight TrailingWhitespace ctermbg=1
                highlight Search ctermfg=4 ctermbg=7
                let l:todo_color = 7
            else
                " When we have 256 colors available
                " (This is usually true)
                set t_Co=256
                highlight LineNr ctermfg=241 ctermbg=234
                highlight CursorLineNr cterm=bold ctermfg=232 ctermbg=250
                highlight Visual cterm=bold ctermbg=238
                highlight TrailingWhitespace ctermbg=52
                let g:indentLine_color_term=237
                highlight SpecialKey ctermfg=238
                let l:todo_color = 247
            endif

            " Todo note highlighting
            " Copy the comment highlighting, then override (a bit superfluous)
            redir => l:comment_highlight
            silent highlight Comment
            redir END
            " Process from:
            " > Comment        xxx term=bold ctermfg=244 guifg=#808080"
            " To produce:
            " > term=bold ctermfg=244 guifg=#808080"
            let l:comment_highlight = s:trim(split(l:comment_highlight, 'xxx')[1])
            highlight clear Todo
            execute 'highlight Todo ' . l:comment_highlight . ' cterm=bold ctermfg=' . l:todo_color
        endfunction
        autocmd ColorScheme * call s:ColorschemeOverrides()
    augroup END

    let g:brent_colorscheme = get(g:, 'brent_colorscheme', 'xoria256')
    if g:brent_colorscheme !=# 'legacy'
        execute 'colorscheme ' . g:brent_colorscheme
    else
        execute 'colorscheme peachpuff'
    endif

    highlight MatchParen cterm=bold,underline ctermbg=none ctermfg=7
    highlight VertSplit ctermfg=0 ctermbg=0

    augroup MatchTrailingWhitespace
        autocmd!
        autocmd VimEnter,BufEnter,WinEnter * call matchadd('TrailingWhitespace', '\s\+$')
    augroup END

    " Visually different markers for various types of whitespace
    " (for distinguishing tabs vs spaces)
    set list listchars=tab:>·,trail:\ ,extends:»,precedes:«,nbsp:×

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

    " By default, disable automatic text wrapping
    " This will often be overrided locally based on filetype
    set formatoptions-=t


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
        let l:path = expand('%:p')

        " Chop off the filename and add wildcard
        let l:pattern = l:path[:-len(expand('%:t')) - 1] . '**/*.' . expand('%:e')
        echom 'Loaded buffers matching pattern: ' . l:pattern
        for l:path in split(glob(l:pattern), '\n')
            let filesize = getfsize(l:path)
            if filesize > 0 && filesize < 80000
                execute 'badd ' . l:path
            endif
        endfor
    endfunction

    " Bindings for switching between tabs
    nnoremap <Leader>tt :tabnew<CR>
    nnoremap <Leader>tn :tabn<CR>

    " 'Force write' binding for writing with sudo
    " Helpful if we don't have permissions for a specific file
    cmap W! w !sudo tee >/dev/null %

    " Some <Leader>direction movement bindings for diffs + loclist + quickfix windows
    function! s:adaptive_motion(next_flag)
        " Check if diff is open
        if &diff
            if a:next_flag
                execute 'normal ]c'
            else
                execute 'normal [c'
            endif
            return
        endif

        " Check for quickfix windows
        let l:quickfix_windows = filter(getwininfo(), 'v:val.quickfix && !v:val.loclist')
        if len(l:quickfix_windows) > 0
            if a:next_flag
                " Note that we use try/catch blocks for wrapping
                try | cnext | catch | cfirst | endtry
            else
                try | cprev | catch | clast | endtry
            endif

            " Quickfix goes between files, and sometimes doesn't trigger a
            " statusline update
            call lightline#update()
            return
        endif

        " Check for loclist windows
        let l:loclist_windows = getloclist(winnr())
        if len(l:loclist_windows) > 0
            if a:next_flag
                try | lnext | catch | lfirst | endtry
            else
                try | lprev | catch | llast | endtry
            endif
            return
        endif

        " Tab through LSP diagnostics without loclist
        let l:diagnostic_count_total = 0
        for l:count in values(lsp#get_buffer_diagnostics_counts())
            let l:diagnostic_count_total += l:count
        endfor
        if l:diagnostic_count_total > 0
            if a:next_flag
                LspNextDiagnostic
            else
                LspPreviousDiagnostic
            endif
            return
        endif

        echom 'Adaptive motion: no target found'
    endfunction
    nnoremap <Tab> :call <SID>adaptive_motion(1)<CR>
    nnoremap <S-Tab> :call <SID>adaptive_motion(0)<CR>

    " Close preview/quickfix/location list/help windows with <Leader>c
    nnoremap <Leader>c :call <SID>window_cleanup()<CR>
    function! s:window_cleanup()
        " Close preview windows
        execute 'pclose'

        " Close quickfix windows
        execute 'cclose'

        " Close location list windows
        execute 'lclose'

        " Close help windows
        execute 'helpclose'

        " Close fugitive diffs
        let l:diff_buffers = range(1, bufnr('$'))
        let l:diff_buffers = filter(l:diff_buffers, 'bufname(v:val) =~# "^fugitive://"')
        for l:b in l:diff_buffers
            execute 'bd ' . l:b
        endfor
        diffoff " Generally not needed, but handles some edge cases when multiple diffs are opened
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
                echo 'disabled friendly mode!'
            endif
        else
            unmap <silent> <Up>
            unmap <silent> <Down>
            unmap <silent> <Right>
            unmap <silent> <Left>
            set mouse=a
            let s:friendly_mode = 1

            if a:verbose
                echo 'enabled friendly mode!'
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

        " (flake8) Highlight as ini
        autocmd BufNewFile,BufRead .flake8 set filetype=dosini

        " (Makefile) Only tabs are supported
        autocmd FileType make setlocal noexpandtab | setlocal shiftwidth&

        " (Buck) Highlight & format as Bazel
        autocmd BufNewFile,BufRead BUCK* set filetype=bzl
        autocmd BufNewFile,BufRead TARGETS set filetype=bzl

        " (C++) Angle bracket matching for templates
        autocmd FileType cpp setlocal matchpairs+=<:>

        " (Python/C++/Markdown/reST) Set textwidth + line overlength
        " indicators: makes text wrap after we hit our length limit, and `gq`
        " useful for formatting
        "
        " 88 for Python (to match black defaults)
        " 80 for Markdown (to match prettier defaults)
        " 80 for reStructuredText
        " Autodetect via clang-format for C++
        highlight OverLength ctermbg=236

        " Getting this to work robustly with FileType autocommands is surprisingly
        " difficult, so we just use BufEnter and WinEnter events
        autocmd BufEnter,WinEnter *.py call matchadd('OverLength', '\%>88v.\+')
            \ | setlocal textwidth=88
        autocmd BufEnter,WinEnter *.md call matchadd('OverLength', '\%>80v.\+')
            \ | setlocal textwidth=80
        autocmd BufEnter,WinEnter *.rst call matchadd('OverLength', '\%>80v.\+')
            \ | setlocal textwidth=80
        autocmd BufEnter,WinEnter *.cpp,*.cc,*.h call s:add_cpp_overlength()
        autocmd BufLeave,WinLeave * call clearmatches()

        let s:cpp_column_limit = 0
        function! s:add_cpp_overlength()
            " Try determining our column limit using clang-format
            "
            " Note: doesn't seem like a big deal, but our caching assumes all
            " files have the same settings
            if s:cpp_column_limit == 0
                let l:executable = maktaba#plugin#Get('vim-codefmt').Flag('clang_format_executable')
                if !executable(l:executable)
                    let s:cpp_column_limit = 80
                    return
                endif
                let s:cpp_column_limit = system(l:executable . ' --dump-config'
                                     \ . ' | grep ColumnLimit'
                                     \ . ' | cut -d ":" -f 2'
                                     \ . ' | tr -d " \n"')
            endif
            call matchadd('OverLength', '\%>' . s:cpp_column_limit . 'v.\+')
            execute "setlocal textwidth=" . s:cpp_column_limit
        endfunction

        " (C/C++) Source/header toggle
        function! s:extension_open_helper(extensions, dir)
            " Helper for source/header toggle: opens file with same name, but
            " different extension. Accepts a list of possible extensions.
            for l:extension in a:extensions
                let l:pattern = a:dir . "/" . expand('%:r') . "." . l:extension
                let l:paths = glob(l:pattern, 0, 1)
                if len(l:paths) > 0
                    execute "e " . l:paths[0]
                    break
                endif
            endfor
        endfunction

        function! s:source_header_toggle()
            " Toggle between C/C++ source and header files.
            " Assumes one of directory structures:
            " - Header and source in the same directory.
            " - Header in `/somepath/include/packagename`, and source in `/somepath/src`.

            let l:extension = expand('%:e')

            let l:source_extensions = ['cpp', 'cc', 'c']
            let l:header_extensions = ['h', 'hpp']

            let l:dir = expand("%:p:h")

            if index(l:source_extensions, l:extension) >= 0
                call s:extension_open_helper(l:header_extensions, l:dir)
                if l:dir =~ '/src$'
                    " If directory ends with '/src', try replacing with
                    " 'include/*'
                    let l:dir = l:dir[:-4] . 'include/*'
                    call s:extension_open_helper(l:header_extensions, l:dir)
                endif
            elseif index(l:header_extensions, l:extension) >= 0
                call s:extension_open_helper(l:source_extensions, l:dir)
                if l:dir =~ '/include/.\+$'
                    " If directory ends with '/include/something/', try replacing with
                    " 'src/*'
                    let l:dir = substitute(l:dir[:-4], '/include/.\+$', '/src', '')
                    call s:extension_open_helper(l:source_extensions, l:dir)
                endif
            else
                echoerr "Invalid file extension for source/header toggle,"
                      \ "must in " . string(l:source_extensions + l:header_extensions)
            endif
        endfunction

        nnoremap <Leader>sht :call <SID>source_header_toggle()<CR>

        " (C/C++) Automatically insert header gates for h/hpp files
        autocmd BufNewFile *.{h,hpp} call <SID>insert_gates()
        function! s:insert_gates()
            let gatename = substitute(toupper(expand('%:t')), '\\.', '_', 'g')
            execute 'normal! i#ifndef ' . gatename
            execute 'normal! o#define ' . gatename . ' '
            execute 'normal! Go#endif /* ' . gatename . ' */'
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
            autocmd BufReadPost,FileReadPost,BufNewFile,BufEnter,FocusGained * call system('tmux rename-window "vim ' . expand('%:t') . '"')
            autocmd VimLeave,FocusLost * call system('tmux set-window-option automatic-rename')
        augroup END
    endif


    " #############################################
    " > Spellcheck <
    " #############################################

    map <F5> :setlocal spell! spelllang=en_us<CR>
    inoremap <F5> <C-\><C-O>:setlocal spelllang=en_us spell! spell?<CR>
    highlight clear SpellBad
    highlight SpellBad cterm=bold,italic ctermfg=red


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
