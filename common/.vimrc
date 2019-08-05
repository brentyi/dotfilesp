"
" brent yi
"

if !has('nvim')
    set encoding=utf-8
endif

"""" set leader to spacebar
let mapleader = "\<Space>"

"""" vundle
let fresh_install=0
let vundle_readme=expand('~/.vim/bundle/Vundle.vim/README.md')
if !filereadable(vundle_readme)
    echo "Installing Vundle.."
    echo ""
    silent !mkdir -p ~/.vim/bundle
    silent !git clone https://github.com/VundleVim/Vundle.vim ~/.vim/bundle/Vundle.vim
    let fresh_install=1
endif

set nocompatible
filetype off
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
"
"
Plugin 'VundleVim/Vundle.vim'
Plugin 'easymotion/vim-easymotion'
Plugin 'justinmk/vim-sneak'
Plugin 'ctrlpvim/ctrlp.vim'
" Plugin 'valloric/MatchTagAlways'
Plugin 'gregsexton/MatchTag'
Plugin 'vim-scripts/indentpython.vim'
" Plugin 'scrooloose/syntastic'
Plugin 'neomake/neomake'
Plugin 'nvie/vim-flake8'
Plugin 'vim-scripts/xoria256.vim'
Plugin 'tomasr/molokai'
Plugin 'sjl/badwolf'
Plugin 'sheerun/vim-polyglot'
" Plugin 'tmhedberg/SimpylFold'
" Plugin 'Shougo/vimproc.vim'
" Plugin 'Shougo/vimshell.vim'
Plugin 'christoomey/vim-tmux-navigator'
Plugin 'chreekat/vim-paren-crosshairs'
" Plugin 'lervag/vimtex'
Plugin 'itchyny/vim-cursorword'
Plugin 'tpope/vim-sleuth'
Plugin 'mustache/vim-mustache-handlebars'
Plugin 'scrooloose/nerdtree'
" Plugin 'ryanoasis/vim-devicons'
Plugin 'tiagofumo/vim-nerdtree-syntax-highlight'
" Plugin 'Xuyuanp/nerdtree-git-plugin'
Plugin 'tpope/vim-surround'
Plugin 'tpope/vim-repeat'
Plugin 'vim-scripts/restore_view.vim'
Plugin 'scrooloose/nerdcommenter'
Plugin 'Yggdroot/indentLine'
" Plugin 'octol/vim-cpp-enhanced-highlight'
Plugin 'itchyny/lightline.vim'
Plugin 'henrik/vim-indexed-search'
" Plugin 'plasticboy/vim-markdown'
" Plugin 'mgee/lightline-bufferline'
Plugin 'ajh17/VimCompletesMe'
Plugin 'google/vim-maktaba'
Plugin 'google/vim-glaive'

""" hacked version of codefmt, with --aggressive flag for autopep8
Plugin 'brentyi/vim-codefmt'
""" error-suppressed version of gutentags
Plugin 'brentyi/vim-gutentags'
"
"
if fresh_install == 1
    PluginInstall
endif
call vundle#end()
call glaive#Install()

filetype plugin indent on

"""" plugin specific
let g:netrw_ftp_cmd = 'ftp -p'
let g:NERDTreeShowHidden = 1
let g:NERDTreeShowLineNumbers = 1
autocmd FileType nerdtree setlocal relativenumber
autocmd VimEnter * if !argc() | NERDTree | endif
let g:NERDTreeMinimalUI = 1
let g:NERDTreeFileExtensionHighlightFullName = 1
let g:NERDTreeExactMatchHighlightFullName = 1
let g:NERDTreePatternMatchHighlightFullName = 1
let g:NERDSpaceDelims = 1
let g:NERDCompactSexyComs = 1
let g:NERDCommentEmptyLines = 1
let g:NERDTrimTrailingWhitespace = 1
let g:NERDDefaultAlign = 'left'
let g:NERDAltDelims_python = 1
let g:NERDAltDelims_cython = 1
let g:NERDAltDelims_pyrex = 1
let g:NERDTreeMapJumpNextSibling = '<Nop>'
let g:NERDTreeMapJumpPrevSibling = '<Nop>'
let g:indentLine_char = '·'
let g:indentLine_fileTypeExclude = ['json', 'markdown', 'tex']
let g:ctrlp_extensions = ['tag']
let g:ctrlp_show_hidden = 1
let g:ctrlp_follow_symlinks=1
let g:ctrlp_max_files=300000
let g:ctrlp_switch_buffer = '0'
let g:ctrlp_reuse_window = 1
let g:gutentags_cache_dir = '~/.cache/tags'
set shell=/bin/bash
set wildignore=*.swp,*.o,*.pyc,*.pb
set wildignore+=*/.git/*,*/.hg/*,*/.svn/*,*/.castle/*,*/.buckd/*        " Linux/MacOSX
set wildignore+=*\\.git\\*,*\\.hg\\*,*\\.svn\\*,*\\.castle\\*,*\\.buckd\\  " Windows ('noshellslash')
set viewoptions=cursor,folds,slash,unix
set noshowmode
runtime! plugin/sleuth.vim " load vim-sleuth early so user-defined autocmds override it
let g:lightline = {
    \ 'colorscheme': 'wombat',
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
Glaive codefmt plugin[mappings]
nnoremap <Leader>cf :FormatCode<CR>
vnoremap <Leader>cf :FormatLines<CR>

" autocmd BufWinEnter *.py setlocal foldexpr=SimpylFold(v:lnum) foldmethod=expr
" autocmd BufWinLeave *.py setlocal foldexpr< foldmethod<
" let g:SimpylFold_docstring_preview=1

"""" visuals
syntax on
if v:version > 703
    set number
endif
set relativenumber
set scrolloff=7
inoremap <C-C> <Esc>
autocmd InsertEnter * set cursorline
autocmd InsertLeave * set nocursorline
autocmd InsertEnter * set cursorcolumn
autocmd InsertLeave * set nocursorcolumn
" set foldcolumn=1
" set clipboard=unnamed
set background=dark
" hi FoldColumn ctermfg=0 ctermbg=0
if $TERM == "xterm-256color" || $TERM == "screen-256color" || $COLORTERM == "gnome-terminal"
    set t_Co=256
    colorscheme molokai
    hi LineNr ctermfg=241 ctermbg=234
    hi CursorLineNr cterm=bold ctermfg=232 ctermbg=250
    hi Visual cterm=bold ctermbg=238
    hi TrailingWhitespace ctermbg=52
    let g:indentLine_color_term=237
else
    set t_Co=16
    set foldcolumn=1
    hi FoldColumn ctermbg=7
    hi LineNr cterm=bold ctermfg=0 ctermbg=0
    hi CursorLineNr ctermfg=0 ctermbg=7
    hi Visual cterm=bold ctermbg=1
    hi TrailingWhitespace ctermbg=1
    hi Search ctermfg=4 ctermbg=7
endif
hi VertSplit ctermfg=0 ctermbg=0
autocmd VimEnter,WinEnter * match TrailingWhitespace /\s\+$/

"""" indent
set list listchars=tab:❘-,trail:\ ,extends:»,precedes:«,nbsp:×
autocmd FileType make setlocal noexpandtab

"""" fold utils
set foldmethod=indent
set foldlevel=99
nnoremap <Bslash> za

"""" search
set hlsearch
nnoremap <Esc> :noh<Return><Esc>
nnoremap <Esc>^[ <Esc>^[

"""" general usability
vmap [[ <Esc>
vmap ;; <Esc>
imap [[ <Esc>
imap ;; <Esc>
set timeoutlen=300 ttimeoutlen=10
set backspace=2
set history=35
set modeline
set laststatus=2
set autochdir
nnoremap <Leader>ip :set invpaste<Return>
nnoremap <Leader>rtws :%s/\s\+$//e<Return>
nnoremap <Leader>o :NERDTree<Return>
if v:version > 703
    nnoremap <Leader>tln :set number!<Return>:set relativenumber!<Return>
else
    nnoremap <Leader>tln :set relativenumber!<Return>
endif
nnoremap ' `
nnoremap ` '

"""" buffers
" set hidden
nnoremap <silent> <Leader>bn :bn<Return>
nnoremap <silent> <Leader>bd :bd<Return>
nnoremap <silent> <Leader>bl :ls<Return>
nnoremap <silent> <Leader>p :CtrlPBuffer<Return>

"""" tabs
nnoremap <silent> <Leader>tt :tabnew<Return>
nnoremap <silent> <Leader>tn :tabn<Return>
nnoremap <silent> <Leader>n :tabn<Return>
nnoremap <silent> <Leader>tp :tabp<Return>

"""" tags
nnoremap <silent> <Leader><Leader>p :CtrlPTag<Return>
nnoremap <silent> <Leader>ts :tselect<Return>

"""" syntax highlighting special cases
autocmd BufNewFile,BufRead *.launch set filetype=xml
autocmd BufNewFile,BufRead BUCK* set filetype=python
autocmd BufNewFile,BufRead TARGETS set filetype=python

"""" automatic tmux pane renaming
if exists('$TMUX')
    autocmd BufReadPost,FileReadPost,BufNewFile,BufEnter * call system("tmux rename-window vim:" . expand("%:t"))
    autocmd VimLeave * call system("tmux setw automatic-rename")
endif

"""" set path to repository root when we open a file
"""" this is mostly to make gf actually work for #includes
function! s:add_repo_to_path()
    let s:git_path=system("git rev-parse --show-toplevel | tr -d '\\n'")
    if strlen(s:git_path) > 0 && s:git_path !~ "\^fatal" && s:git_path !~ "command not found" && &path !~ s:git_path
        let &path .= "," . s:git_path . "/**9"
    endif
    let s:hg_path=system("hg root | tr -d '\\n'")
    if strlen(s:hg_path) > 0 && s:hg_path !~ "\^abort" && s:hg_path !~ "command not found" && &path !~ s:hg_path
        let &path .= "," . s:hg_path . "/**9"
    endif
endfunction
autocmd BufEnter * call <SID>add_repo_to_path()

" forgot to sudo!
cmap W! w !sudo tee >/dev/null %

"""" split utils
set winheight=20
set winwidth=50
set winminwidth=10
set splitbelow
set splitright
" strange tmux-style window splitting shortcuts
nmap <C-w>" :sp<Return>:e .<Return>
nmap <C-w>% :vsp<Return>:e .<Return>

"""" map <Leader>F to toggle mouse + arrow keys
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

"""" c++
function! s:insert_gates()
    let gatename = substitute(toupper(expand("%:t")), "\\.", "_", "g")
    execute "normal! i#ifndef " . gatename
    execute "normal! o#define " . gatename . " "
    execute "normal! Go#endif /* " . gatename . " */"
    normal! kk
endfunction
autocmd BufNewFile *.{h,hpp} call <SID>insert_gates()

"""" navigation in insert mode
inoremap <C-H> <Left>
inoremap <C-J> <Down>
inoremap <C-K> <Up>
inoremap <C-L> <Right>

"""" meta
augroup AutoReloadVimRC
    autocmd!
    autocmd BufWritePost $MYVIMRC source $MYVIMRC
    autocmd BufWritePost .vimrc source $MYVIMRC " for init.vim->.vimrc symlinks in neovim
augroup END

"""" spelling utilities
map <F5> :setlocal spell! spelllang=en_us<CR>
inoremap <F5> <C-\><C-O>:setlocal spelllang=en_us spell! spell?<CR>
hi clear SpellBad
hi SpellBad cterm=bold,italic ctermfg=red
