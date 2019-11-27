"
" brent yi
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

" Remap <Leader> to <Space>
" This needs to be done before any leader-containing bindings happen
let mapleader = "\<Space>"

" Run shell commands using bash
set shell=/bin/bash

" Automatically install vim-plug plugin manager
let s:vim_plug_path = (has('nvim') ? '~/.config/nvim' : '~/.vim') . '/autoload/plug.vim'
if empty(glob(s:vim_plug_path))
    execute "silent !curl -fLo " . s:vim_plug_path . " --create-dirs "
        \ . "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
    autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif


" #############################################
" > Plugins <
" #############################################

" Use Vundle-style path for vim-plug
let s:bundle_path = (has('nvim') ? '~/.config/nvim' : '~/.vim') . '/bundle'
execute "call plug#begin('" . s:bundle_path . "')"

" Navigation inside files
Plug 'easymotion/vim-easymotion'
Plug 'justinmk/vim-sneak'

" Shortcuts for manipulating quotes, brackets, parentheses, HTML tags
" + vim-repeat for making '.' work for vim-surround
Plug 'tpope/vim-surround'
Plug 'tpope/vim-repeat'

" Make gf, sfind, etc work better in repositories
Plug 'brentyi/vim-repo-file-search'

" Fuzzy-find for files, buffers, tags!
" > note: there are a ton of faster options (fzf, LeaderF, command-T, etc),
" > but ctrlp feels way easier in terms of dependencies, portability, etc...
Plug 'ctrlpvim/ctrlp.vim'
" {{
    let g:ctrlp_extensions = ['tag']
    let g:ctrlp_show_hidden = 1
    let g:ctrlp_follow_symlinks=1
    let g:ctrlp_max_files=300000
    let g:ctrlp_switch_buffer = '0'
    let g:ctrlp_reuse_window = 1
    nnoremap <silent> <Leader>p :CtrlPBuffer<Return>
    nnoremap <silent> <Leader><Leader>p :CtrlPTag<Return>
" }}

" NERDTree for filesystem navigation/manipulation
Plug 'scrooloose/nerdtree'
" {{
    let g:NERDTreeShowHidden = 1
    let g:NERDTreeShowLineNumbers = 1
    autocmd FileType nerdtree setlocal relativenumber
    autocmd VimEnter * if !argc() | NERDTree | endif
    let g:NERDTreeMinimalUI = 1
    let g:NERDTreeFileExtensionHighlightFullName = 1
    let g:NERDTreeExactMatchHighlightFullName = 1
    let g:NERDTreePatternMatchHighlightFullName = 1
    let g:NERDTreeMapJumpNextSibling = '<Nop>'
    let g:NERDTreeMapJumpPrevSibling = '<Nop>'
    nnoremap <Leader>o :NERDTree<Return>
" }}

" NERDTree extensions: syntax highlighting, version control indicators
Plug 'tiagofumo/vim-nerdtree-syntax-highlight'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'f4t-t0ny/nerdtree-hg-plugin'
" {{
let g:NERDTreeIndicatorMapCustom = {
    \ 'Modified'  : "M",
    \ 'Staged'    : "+",
    \ 'Untracked' : "?",
    \ 'Renamed'   : "renamed",
    \ 'Unmerged'  : "unmerged",
    \ 'Deleted'   : "X",
    \ 'Dirty'     : "d",
    \ 'Clean'     : "c",
    \ 'Ignored'   : "-",
    \ 'Unknown'   : "??"
    \ }
" }}

" Massive language pack for syntax highlighting, etc
Plug 'sheerun/vim-polyglot'

" Tag matching for HTML
Plug 'gregsexton/MatchTag'

" Better Python indentation
Plug 'vim-scripts/indentpython.vim'

" ~~ Color schemes ~~
Plug 'vim-scripts/xoria256.vim'
Plug 'tomasr/molokai'
Plug 'sjl/badwolf'

" Vim + tmux integration
Plug 'christoomey/vim-tmux-navigator'
Plug 'tmux-plugins/vim-tmux-focus-events'

" Underline all instances of current word
Plug 'itchyny/vim-cursorword'

" Super intelligent indentation level detection
" > We load this early so user-defined autocmds override it
Plug 'tpope/vim-sleuth'
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

" Display markers to signify different indentation levels
Plug 'Yggdroot/indentLine'
" {{
    let g:indentLine_char = '·'
    let g:indentLine_fileTypeExclude = ['json', 'markdown', 'tex']
" }}

" Status line
Plug 'itchyny/lightline.vim'
" {{
    let g:brent_lightline_colorscheme = get(g:, 'brent_lightline_colorscheme', "wombat")
    let g:lightline = {
    \ 'colorscheme': g:brent_lightline_colorscheme,
    \ 'active': {
    \   'right': [ [ 'lineinfo' ],
    \              [ 'filetype', 'charvaluehex' ],
    \              [ 'gutentags' ]]
    \ },
    \ 'inactive': {
    \   'right': [ [], [], [ 'lineinfo' ] ]
    \ },
    \ 'component': {
    \   'charvaluehex': '0x%B',
    \   'gutentags': '%{GutentagsStatus()}%{gutentags#statusline("", "", "ctags indexing...")}'
    \ },
    \ }
" }}

" Show instance # in statusline when we search
Plug 'henrik/vim-indexed-search'

" Lightweight autocompletion!
Plug 'ajh17/VimCompletesMe'

" Add pseudo-registers for copying to system clipboard (example usage: "+Y)
" > This basically emulates the +clipboard vim feature flag
Plug 'kana/vim-fakeclip'

" Google's code format plugin + dependencies
" > Our vim-codefmt fork just adds the --aggressive flag for autopep8
Plug 'google/vim-maktaba'
Plug 'google/vim-glaive'
Plug 'brentyi/vim-codefmt'
" {{
    nnoremap <Leader>cf :FormatCode<CR>
    vnoremap <Leader>cf :FormatLines<CR>
" }}

" Gutentags, for generating tag files
" > Our fork suppresses some errors for machines without ctags installed
Plug 'brentyi/vim-gutentags'
" {{
    " Set cache location
    let g:gutentags_cache_dir = '~/.cache/tags'

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

call plug#end()

" Initialize Glaive + codefmt
call glaive#Install()
Glaive codefmt plugin[mappings]

" Files for ctrlp + gutentags to ignore!
set wildignore=*.swp,*.o,*.pyc,*.pb
" Linux/MacOSX
set wildignore+=*/.git/*,*/.hg/*,*/.svn/*,*/.castle/*,*/.buckd/*,*/.venv/*,*/site-packages/*
" Windows ('noshellslash')
set wildignore+=*\\.git\\*,*\\.hg\\*,*\\.svn\\*,*\\.castle\\*,*\\.buckd\\*,*\\.venv\\*,*\\site-packages\\*


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
if $TERM == "xterm-256color" || $TERM == "screen-256color" || $COLORTERM == "gnome-terminal"
    " When we have 256 colors available
    " (This is usually true)
    set t_Co=256
    let g:brent_colorscheme = get(g:, 'brent_colorscheme', "xoria256")
    execute "colorscheme " . g:brent_colorscheme
    hi LineNr ctermfg=241 ctermbg=234
    hi CursorLineNr cterm=bold ctermfg=232 ctermbg=250
    hi Visual cterm=bold ctermbg=238
    hi TrailingWhitespace ctermbg=52
    let g:indentLine_color_term=237
else
    " Fallback colors for some legacy terminals
    set t_Co=16
    set foldcolumn=1
    hi FoldColumn ctermbg=7
    hi LineNr cterm=bold ctermfg=0 ctermbg=0
    hi CursorLineNr ctermfg=0 ctermbg=7
    hi Visual cterm=bold ctermbg=1
    hi TrailingWhitespace ctermbg=1
    hi Search ctermfg=4 ctermbg=7
endif
hi MatchParen cterm=bold,underline ctermbg=none ctermfg=7
hi VertSplit ctermfg=0 ctermbg=0
autocmd VimEnter,WinEnter * match TrailingWhitespace /\s\+$/

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

" Automatically change working directory to current file location
set autochdir

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
nnoremap <Esc> :noh<Return><Esc>
nnoremap <Esc>^[ <Esc>^[

" Use backslash to toggle folds
nnoremap <Bslash> za

" Binding to disable line numbering -- useful for copy & paste, etc
if v:version > 703
    nnoremap <Leader>tln :set number!<Return>:set relativenumber!<Return>
else
    nnoremap <Leader>tln :set relativenumber!<Return>
endif

" Binding to switch into/out of PASTE mode
nnoremap <Leader>ip :set invpaste<Return>

" Binding to remove trailing whitespaces in current files
nnoremap <Leader>rtws :%s/\s\+$//e<Return>

" Switch ' and ` for jumps: ' is much more intuitive and easier to access
onoremap ' `
vnoremap ' `
nnoremap ' `
onoremap ` '
vnoremap ` '
nnoremap ` '

" Bindings for deleting buffers
nnoremap <silent> <Leader>bd :bd<Return>

" Bindings for switching between tabs
nnoremap <silent> <Leader>tt :tabnew<Return>
nnoremap <silent> <Leader>n :tabn<Return>

" Bindings to navigate using Ctrl+hjkl in insert mode
inoremap <C-H> <Left>
inoremap <C-J> <Down>
inoremap <C-K> <Up>
inoremap <C-L> <Right>

" 'Force write' binding for writing with sudo
" Helpful if we don't have permissions for a specific file
cmap W! w !sudo tee >/dev/null %


" #############################################
" > Configuring splits <
" #############################################

" Sizing defaults + minimum
set winheight=20
set winwidth=50
set winminwidth=10

" Match tmux behavior + bindings (with <C-w> instead of <C-b>)
set splitbelow
set splitright
nmap <C-w>" :sp<Return>:e .<Return>
nmap <C-w>% :vsp<Return>:e .<Return>


" #############################################
" > Friendly mode <
" ##############################################

" This maps <Leader>f to toggle between:
"  - 'Default mode': arrow keys resize splits, mouse disabled
"  - 'Friendly mode': arrow keys, mouse behave as usual

let s:friendly_mode = 0
function! s:toggle_friendly_mode()
    if s:friendly_mode
        unmap <silent> <Up>
        unmap <silent> <Down>
        unmap <silent> <Right>
        unmap <silent> <Left>
        set mouse=a
        let s:friendly_mode = 0
        echo "enabled friendly mode!"
    else
        nmap <silent> <Up> :exe "resize +5"<CR>
        nmap <silent> <Down> :exe "resize -5"<CR>
        nmap <silent> <Right> :exe "vert resize +5"<CR>
        nmap <silent> <Left> :exe "vert resize -5"<CR>
        set mouse=
        let s:friendly_mode = 1
    endif
endfunction
call <SID>toggle_friendly_mode()
nmap <Leader>f :call <SID>toggle_friendly_mode()<CR>


" #############################################
" > Filetype-specific configurations <
" #############################################

augroup FiletypeHelpers
    autocmd!

    " (ROS) Launch files should be highlighted as xml
    autocmd BufNewFile,BufRead *.launch set filetype=xml

    " Make files need to be indented with tabs
    autocmd FileType make setlocal noexpandtab

    " Buck files should be highlighted as python
    autocmd BufNewFile,BufRead BUCK* set filetype=python
    autocmd BufNewFile,BufRead TARGETS set filetype=python

    " Automatically insert header gates for h/hpp files
    function! s:insert_gates()
        let gatename = substitute(toupper(expand("%:t")), "\\.", "_", "g")
        execute "normal! i#ifndef " . gatename
        execute "normal! o#define " . gatename . " "
        execute "normal! Go#endif /* " . gatename . " */"
        normal! kk
    endfunction
    autocmd BufNewFile *.{h,hpp} call <SID>insert_gates()
augroup END


" #############################################
" > Automatic window renaming for tmux <
" #############################################

if exists('$TMUX')
    augroup TmuxHelpers
        autocmd!
        autocmd BufReadPost,FileReadPost,BufNewFile,BufEnter,FocusGained * call system("tmux rename-window 'vim " . expand("%:t") . "'")
        autocmd VimLeave * call system("tmux setw automatic-rename")
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

