"""" Github API token for github-complete.vim
" let g:github_complete_github_api_token=""

"""" Color configuration

" let g:brent_colorscheme = 'molokai'
" let g:brent_lightline_colorscheme = 'wombat'
"
" let g:brent_colorscheme = 'badwolf'
" let g:brent_lightline_colorscheme = 'powerline'

let g:brent_colorscheme = 'xoria256'
let g:brent_lightline_colorscheme = 'jellybeans'

"" Set colorscheme to 'legacy' for non-256-color terminals
" let g:brent_colorscheme = 'legacy'

"""" Ignore patterns for gutentags

" let g:gutentags_ctags_exclude = [
"     \ 'third_party',
"     \ 'third-party',
"     \ ]

"""" Move swap files
"""" Sometimes speeds things up if working with virtual filesystem, etc

" set directory=$HOME/.vim/swapfiles//

"""" Python docstring generation format

" let g:pydocstring_formatter = 'google'
" let g:pydocstring_formatter = 'numpy'
" let g:pydocstring_formatter = 'sphinx'

"""" Project root overrides

" let g:repo_file_search_root = '/path'
" let g:repo_file_search_type = 'hg'


"""" Set to debug LSP
" let g:lsp_log_file = $HOME . "/lsp_log_file"

source ~/dotfilesp/common/.vimrc


"""" Disable pycodestyle (eg for reading other people's code)
" let g:lsp_settings['pylsp-all']['workspace_config']['pylsp']['plugins']['pycodestyle'] = {'enabled': v:false}
