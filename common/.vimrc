"
" brent yi
"

if !has('nvim')
    set encoding=utf-8
endif

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
Plugin 'gmarik/Vundle.vim'
Plugin 'easymotion/vim-easymotion'
Plugin 'ctrlpvim/ctrlp.vim'
Plugin 'tpope/vim-surround'
Plugin 'valloric/MatchTagAlways'
Plugin 'vim-scripts/indentpython.vim'
" Plugin 'scrooloose/syntastic'
Plugin 'neomake/neomake'
Plugin 'nvie/vim-flake8'
Plugin 'tomasr/molokai'
Plugin 'sjl/badwolf'
" Plugin 'tmhedberg/SimpylFold'
" Plugin 'Shougo/vimproc.vim'
" Plugin 'Shougo/vimshell.vim'
Plugin 'itchyny/lightline.vim'
Plugin 'christoomey/vim-tmux-navigator'
Plugin 'chreekat/vim-paren-crosshairs'
"
"
if fresh_install == 1
    PluginInstall
endif
call vundle#end()

filetype plugin indent on

"""" plugin specific
let g:ctrlp_map = '<c-o>'
let g:netrw_ftp_cmd = 'ftp -p'
let g:lightline = { 'colorscheme': 'seoul256' }

" autocmd BufWinEnter *.py setlocal foldexpr=SimpylFold(v:lnum) foldmethod=expr
" autocmd BufWinLeave *.py setlocal foldexpr< foldmethod<
" let g:SimpylFold_docstring_preview=1

"""" visuals
syntax on
set number
set relativenumber
set scrolloff=7
au InsertEnter * set cursorline
au InsertLeave * set nocursorline
au InsertEnter * set cursorcolumn
au InsertLeave * set nocursorcolumn
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
" au InsertEnter * set norelativenumber
" au InsertLeave * set relativenumber
match TrailingWhitespace /\s\+$/

"""" indent
set expandtab
set autoindent
set smartindent
set shiftwidth=4
set softtabstop=4


"""" split utils
set winheight=20
set winwidth=50
" set winminheight=3
set winminwidth=10
" nnoremap <C-J> <C-W><C-J>
" nnoremap <C-K> <C-W><C-K>
" nnoremap <C-L> <C-W><C-L>
" nnoremap <C-H> <C-W><C-H>
map <silent> <Up> :exe "resize +5"<CR>
map <silent> <Down> :exe "resize -5"<CR>
map <silent> <Right> :exe "vert resize +5"<CR>
map <silent> <Left> :exe "vert resize -5"<CR>

"""" fold utils
set foldmethod=indent
set foldlevel=99
nnoremap <Bslash> za

"""" search
set hlsearch
nnoremap <Esc> :noh<Return><Esc>
nnoremap <Esc>^[ <Esc>^[

"""" general usability
nmap ; :
vmap [[ <Esc>
vmap ;; <Esc>
imap [[ <Esc>
imap ;; <Esc>
set timeoutlen=300 ttimeoutlen=10
let mapleader = "\<Space>"
set backspace=2
set history=35
set modeline
set laststatus=2
set autochdir
autocmd BufReadPost,FileReadPost,BufNewFile * call system("tmux rename-window vim:" . expand("%:t"))
"" this screws with line-hopping via relative numbering
" nnoremap j gj
" nnoremap k gk

"""" meta
augroup AutoReloadVimRC
    au!
    au BufWritePost $MYVIMRC source $MYVIMRC
    au BufWritePost .vimrc source $MYVIMRC " for init.vim->.vimrc symlinks in neovim
augroup END
