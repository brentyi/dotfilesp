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
    let g:signify_priority = 5
" }}

" Fuzzy-find for files, buffers, tags!
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
" {{
    " Show error if ag is unavailable and should be installed
    function! AgMissingStatus()
        if !executable('ag')
            return '[missing ag]'
        endif
        return ''
    endfunction

    if !executable('ag')
        let $FZF_DEFAULT_COMMAND='find .'
    else
        " Configure ag
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
    endif

    function! s:smarter_fuzzy_file_search()
        execute 'Files ' . b:repo_file_search_root
    endfunction

    " Helpers for using &wildignore with fzf
    let s:fzf_ignore_options = ''

    " We want to use gutentags for tag generation
    let g:fzf_tags_command = ''

    " Bindings: search file names
    nnoremap <C-P> :call <SID>smarter_fuzzy_file_search()<CR>
    nnoremap <Leader>p :Buffers<CR>
    nnoremap <Leader>ph :Files<CR>
    nnoremap <Leader>h :History<CR>
    nnoremap <Leader>gf :call fzf#vim#files(b:repo_file_search_root, fzf#vim#with_preview({
        \ 'options': '--query ' . shellescape(expand('<cfile>'))}))<CR>

    " Bindings: search tags
    nnoremap <Leader>t :Tags<CR>
    nnoremap <Leader>gt :execute 'Tags ' . expand('<cword>')<CR>

    " Bindings: search lines in open buffers
    nnoremap <Leader>l :Lines<CR>
    nnoremap <Leader>gl :call fzf#vim#lines(expand('<cword>'))<CR>

    " Bindings: search lines in files with ag
    nnoremap <Leader>a :Ag<CR>
    vnoremap <Leader>a :<C-U>call <SID>GrepVisual(visualmode())<CR>
    nnoremap <Leader>ga :execute 'Ag ' . expand('<cword>')<CR>

    " Use Vim colors for fzf
    let g:fzf_layout = {
        \ 'window': 'new'
        \ }
" }}

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
    let g:polyglot_disabled = ['csv']

    " Use Semshi for Python
    if has("nvim")
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
        function! s:HighlightPythonSpecial()
            " For Python, bold TODO keyword in strings/docstrings
            " Copy the docstring highlighting, then override (a bit superfluous)
            syn keyword DocstringTodo TODO FIXME XXX containedin=pythonString,pythonRawString

            redir => l:python_string_highlight
            silent highlight Constant
            redir END

            let l:python_string_highlight = s:trim(split(l:python_string_highlight, 'xxx')[1])
            highlight clear DocstringTodo
            execute 'highlight DocstringTodo ' . l:python_string_highlight . ' cterm=bold'
        endfunction

        " Due to trigger ordering, `autocmd Filetype python` here doesn't work!
        autocmd BufEnter,WinEnter *.py call s:HighlightPythonSpecial()
    augroup END
" }}

" Highlighting for flex and bison
Plug 'calincru/flex-bison-syntax'

" G-code highlighting
Plug 'wilriker/gcode.vim'

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
Plug 'ferrine/md-img-paste.vim'
Plug 'iamcco/markdown-preview.nvim', { 'do': ':call mkdp#util#install()', 'for': ['markdown', 'vim-plug']}
Plug 'mzlogin/vim-markdown-toc'
" {{
    augroup MarkdownBindings
        autocmd!
        " Markdown paste image
        autocmd FileType markdown nnoremap <buffer>
            \ <Leader>mdpi :call mdip#MarkdownClipboardImage()<CR>
        " Markdown toggle preview
        autocmd FileType markdown nmap <buffer>
            \ <Leader>mdtp <Plug>MarkdownPreviewToggle
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

" Search plugins
" > Show instance # in statusline when we search
" > Use * to search visual mode selections
Plug 'henrik/vim-indexed-search'
Plug 'bronson/vim-visual-star-search'

" LSP plugins for autocompletion, jump to def, etc
"
" Note that we also need to actually install some LSPs, eg:
" > https://github.com/mattn/vim-lsp-settings
Plug 'prabirshrestha/async.vim'
Plug 'prabirshrestha/vim-lsp'
Plug 'mattn/vim-lsp-settings'

" {{
    " Move servers into .vim directory
    let g:lsp_settings_servers_dir = expand(s:vim_plug_folder . "/../vim-lsp-settings/servers")

    " Global LSP config
    function! s:on_lsp_buffer_enabled() abort
        setlocal omnifunc=lsp#complete
        if exists('+tagfunc') | setlocal tagfunc=lsp#tagfunc | endif
        nmap <buffer> <Leader>gd <plug>(lsp-definition)
        nmap <buffer> <Leader>gr <plug>(lsp-references)
        nmap <buffer> <Leader>gi <plug>(lsp-implementation)
        " This conflicts with an fzf binding
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
    let g:lsp_diagnostics_signs_error = {'text': '▴'}
    let g:lsp_diagnostics_signs_warning = {'text': '▴'}
    let g:lsp_diagnostics_signs_information = {'text': '▴'}
    let g:lsp_diagnostics_signs_hint = {'text': '▴'}
    let g:lsp_diagnostics_signs_priority = 10

    " Jump through some hoops to auto-install pylsp-mypy whenever we call :LspInstallServer
    function! s:check_for_pylsp_mypy()
        if filereadable(expand(g:lsp_settings_servers_dir . "/pylsp-all/venv/bin/pylsp"))
            \ && !filereadable(expand(g:lsp_settings_servers_dir . "/pylsp-all/venv/bin/mypy"))

            " Install from source because pypi version of pylsp-mypy is broken
            " for Python 3. Our fork includes support for various settings and
            " flags that aren't available upstream.
            let l:cmd =  g:lsp_settings_servers_dir .
                \ '/pylsp-all/venv/bin/pip3 install ' .
                \ 'git+https://github.com/brentyi/pylsp-mypy.git'

            if has('nvim')
                split new
                call termopen(l:cmd, {'cwd': g:lsp_settings_servers_dir})
            else
                let l:bufnr = term_start(l:cmd)
            endif
        endif
    endfunction

    augroup CheckForPylspMypy
        autocmd!
        autocmd User lsp_setup call s:check_for_pylsp_mypy()
    augroup END

    let g:lsp_settings = {}
    let g:lsp_settings['efm-langserver'] = {'disabled': v:false}
    let g:lsp_settings['pylsp-all'] = {
        \     'workspace_config': { 'pylsp': {
        \         'configurationSources': ['flake8'],
        \         'plugins': {
        \             'pylsp_mypy': {
        \                 'enabled': v:true,
        \                 'live_mode': v:false,
        \                 'dmypy': v:false,
        \                 'strict': v:false,
        \                 'prepend': ['--python-executable', s:trim(system('which python'))],
        \                 'colocate_cache_with_config': v:true
        \             }
        \         }
        \     }}
        \ }
    let g:lsp_settings['clangd'] = {'allowlist': ['c', 'cpp', 'objc', 'objcpp', 'cuda']}

    " Show error messages below statusbar
    let g:lsp_diagnostics_echo_cursor = 1

    " Binding for showing loclist with all errors
    nnoremap <Leader><Tab> :LspDocumentDiagnostics<CR>

    " Disable tex.vim errors; texlab is far more useful
    let g:tex_no_error=1
" }}

" Async 'appears as you type' autocompletion
" > Use Tab, S-Tab to select, <CR> to confirm (see above for binding)
Plug 'prabirshrestha/asyncomplete.vim'
Plug 'prabirshrestha/asyncomplete-lsp.vim'
Plug 'prabirshrestha/asyncomplete-file.vim'
Plug 'prabirshrestha/asyncomplete-tags.vim'
Plug 'prabirshrestha/asyncomplete-emoji.vim'
Plug 'thecontinium/asyncomplete-buffer.vim'

" {{
    " Bindings
    " Use <CR> for completion confirmation, <Tab> and <S-Tab> for selection
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

    function! s:check_back_space() abort
        let col = col('.') - 1
        return !col || getline('.')[col - 1]  =~ '\s'
    endfunction

    " Jump forward or backward
    " Note: inoremap will not work here, since we need to call vsnip-jump-*
    imap <expr> <TAB>
        \ vsnip#jumpable(1) ? '<Plug>(vsnip-jump-next)' :
        \ pumvisible() ? "\<C-n>" :
        \ <SID>check_back_space() ? "\<TAB>" :
        \ asyncomplete#force_refresh()
    imap <expr><S-TAB>
        \ vsnip#jumpable(-1) ? '<Plug>(vsnip-jump-prev)' :
        \ pumvisible() ? "\<C-p>" : "\<C-h>"

    " Register path completer
    function! s:register_asyncomplete_sources() abort
        call asyncomplete#register_source(asyncomplete#sources#file#get_source_options({
            \ 'name': 'file',
            \ 'allowlist': ['*'],
            \ 'priority': 10,
            \ 'completor': function('asyncomplete#sources#file#completor')
            \ }))

        call asyncomplete#register_source(asyncomplete#sources#tags#get_source_options({
            \ 'name': 'tags',
            \ 'allowlist': ['c'],
            \ 'completor': function('asyncomplete#sources#tags#completor'),
            \ 'config': {
            \    'max_file_size': 50000000,
            \  },
            \ }))

        call asyncomplete#register_source(asyncomplete#sources#emoji#get_source_options({
            \ 'name': 'emoji',
            \ 'allowlist': ['gitcommit', 'markdown'],
            \ 'completor': function('asyncomplete#sources#emoji#completor'),
            \ }))

        call asyncomplete#register_source(asyncomplete#sources#buffer#get_source_options({
            \ 'name': 'buffer',
            \ 'allowlist': ['*'],
            \ 'blocklist': ['go'],
            \ 'completor': function('asyncomplete#sources#buffer#completor'),
            \ 'config': {
            \    'max_buffer_size': 1000000,
            \  },
            \ }))
    endfunction

    autocmd User asyncomplete_setup call s:register_asyncomplete_sources()
" }}

" Snippets & LSP integration
Plug 'hrsh7th/vim-vsnip'
Plug 'hrsh7th/vim-vsnip-integ'
" {{
    let g:vsnip_snippet_dir = expand('~/dotfilesp/snippets/')

    " <Tab>/<S-Tab> are bound under asyncomplete

    " Select or cut text to use as $TM_SELECTED_TEXT in the next snippet.
    " See https://github.com/hrsh7th/vim-vsnip/pull/50
    nmap <Leader>s <Plug>(vsnip-select-text)
    xmap <Leader>s <Plug>(vsnip-select-text)
    nmap <Leader>S <Plug>(vsnip-cut-text)
    xmap <Leader>S <Plug>(vsnip-cut-text)
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
" > Our vim-codefmt fork enables --prose-wrap for markdown formatting
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

        " CUDA => C++
        autocmd FileType cuda let b:codefmt_formatter='clang-format'
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
                " In Vim 8.1, Glaive is throwing an error when we configure
                " with a local variable
                let g:clang_format_executable_path = l:path
                Glaive codefmt clang_format_executable=`g:clang_format_executable_path`
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
        autocmd Filetype c,cpp,cuda call s:find_clang_format()
    augroup END
" }}

" Automated import sorting
Plug 'brentyi/isort.vim'
" {{
    " Match black style
    let g:isort_vim_options = '--profile black'

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
" > TODO: do we even use tags anymore? maybe for barebones C code?
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
    function! GutentagsMissingStatus()
        if exists('g:gutentags_ctags_executable') && executable(expand(g:gutentags_ctags_executable, 1)) == 0
            return '[missing ctags]'
        endif
        return ''
    endfunction
    augroup GutentagsStatusLineRefresher
        autocmd!
        autocmd User GutentagsUpdating call lightline#update()
        autocmd User GutentagsUpdated call lightline#update()
    augroup END
" }}

" Status line
Plug 'itchyny/lightline.vim'
Plug 'halkn/lightline-lsp'
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
        \            [ 'lsp_errors', 'lsp_warnings', 'lsp_ok' ],
        \            [ 'ag_and_gutentags' ],
        \            [ 'filepath' ],
        \            [ 'truncate' ]]
        \ }
    let g:lightline.inactive = {
        \ 'left': [ [ 'readonly', 'filename', 'modified' ] ],
        \ 'right': [ [],
        \            [ 'lsp_errors', 'lsp_warnings', 'lsp_ok', 'lineinfo' ],
        \            [ 'filepath', 'lineinfo' ],
        \            [ 'truncate' ]]
        \ }

    " Components
    let g:lightline.component = {
        \   'charvaluehex': '0x%B',
        \   'ag_and_gutentags': '%{"' . AgMissingStatus() . '"}%{"' . GutentagsMissingStatus() . '"}%{gutentags#statusline("", "", "[ctags indexing]")}',
        \   'signify': has('patch-8.0.902') ? '%{sy#repo#get_stats_decorated()}' : '',
        \   'truncate': '%<',
        \ }
    let g:lightline.component_function = {
        \   'filepath': string(function('s:lightline_filepath')),
        \ }
    let g:lightline.component_expand = {
        \   'lsp_warnings': 'lightline_lsp#warnings',
        \   'lsp_errors': 'lightline_lsp#errors',
        \   'lsp_ok': 'lightline_lsp#ok',
        \ }
    let g:lightline.component_type = {
        \   'lsp_warnings': 'warning',
        \   'lsp_errors': 'error',
        \   'lsp_ok': 'middle',
        \ }

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

    " Automatically change working directory to current file's parent
    set autochdir
    augroup AutochdirHack
        " Hack: for whatever reason, autochdir has begun to fail for files
        " opened with FZF in splits in Neovim >=0.6.1. This is reproducible
        " across systems and I've tried fudging with various stable/unstable
        " plugin + Neovim versions without luck, so we instead just
        " redundantly repeat the behavior of autochdir with an autocmd.
        "
        " Note that this is not required (but should be harmless) for Vim 8.2.
        autocmd!
        autocmd BufEnter * silent! lcd %:p:h
    augroup END


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

                " The rest of this block is doing some colors for popups, eg
                " autocomplete or floating help windows.

                " The main purpose here is to make the Pmenu color
                " darker than the default, as a light Pmenu can cause display
                " issues for syntax highlighting applied within popups.
                highlight Pmenu ctermfg=252 ctermbg=235
                highlight PmenuSel cterm=bold ctermfg=255 ctermbg=238

                " We also darken the scrollbar to increase contrast:
                highlight PmenuSbar ctermbg=237

                " Some newer builds of Neovim add a distinct highlight group
                " for borders of floating windows.
                highlight FloatBorder ctermfg=242 ctermbg=235

                " And, to be explicit, we (unnecessarily) link the
                " Neovim-specific 'normal' floating text highlight group. Like
                " FloatBorder, this is unused in Vim8.
                highlight link NormalFloat Pmenu
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

        " (OpenGL) Additional shader extensions
        autocmd BufNewFile,BufRead *.vertexshader set filetype=glsl
        autocmd BufNewFile,BufRead *.fragmentshader set filetype=glsl

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
