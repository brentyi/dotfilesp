"
" brentyi@berkeley.edu
"
" Currently in an experimental neovim-only state.
" TODOs:
" - Fallbacks for Vim
" - Consider vim-codefmt => null-ls.nvim
" - A lot of cleanup
" - Some automatic help messages for using Mason?
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

if has('nvim') && has('termguicolors')
    set termguicolors
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
                let $FZF_DEFAULT_COMMAND='ag --hidden --skip-vcs-ignores ' . s:fzf_ignore_options . ' -g ""'
            endif
        endfunction

        augroup ConfigureFzf
            autocmd!
            " Configure fzf after wildignore is set later in vimrc
            autocmd VimEnter * call s:update_fzf_with_wildignore()
        augroup END

        " Call Ag relative to repository root
        command! -bang -nargs=* Ag
            \ call fzf#vim#ag(<q-args>, '--hidden --skip-vcs-ignores ' . s:fzf_ignore_options, fzf#vim#with_preview({
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


" Use treesitter in Neovim
if has("nvim")
    Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
endif

" Called after plug#end. Note that we can't indent the lua code.
function! s:treesitter_configure()
lua << EOF
require'nvim-treesitter.configs'.setup {
  -- A list of parser names, or "all"
  ensure_installed = {
    "c",
    "cpp",
    "cuda",
    "lua",
    "vim",
    "python",
    "html",
    "css",
    "javascript",
    "markdown",
  },

  -- Install parsers synchronously (only applied to `ensure_installed`)
  sync_install = false,

  -- Automatically install missing parsers when entering buffer
  auto_install = true,

  -- List of parsers to ignore installing (for "all")
  ignore_install = {},

  ---- If you need to change the installation directory of the parsers (see -> Advanced Setup)
  -- parser_install_dir = "/some/path/to/store/parsers", -- Remember to run vim.opt.runtimepath:append("/some/path/to/store/parsers")!

  highlight = {
    -- `false` will disable the whole extension
    enable = true,

    -- NOTE: these are the names of the parsers and not the filetype. (for example if you want to
    -- disable highlighting for the `tex` filetype, you need to include `latex` in this list as this is
    -- the name of the parser)
    -- list of language that will be disabled
    disable = {},

    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
    -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
    -- Using this option may slow down your editor, and you may see some duplicate highlights.
    -- Instead of true it can also be a list of languages
    additional_vim_regex_highlighting = false,
  },
}
EOF
endfunction

" Massive language pack for syntax highlighting, etc
" We use treesitter in Neovim.
if !has('nvim')
    Plug 'sheerun/vim-polyglot'
endif
" {{
    " Disable csv.vim: this overrides a bunch of default vim bindings with
    " csv-specific ones that looks high-effort to get used to
    "
    " For highlighting etc, we use rainbow_csv (see below)
    let g:polyglot_disabled = ['csv']

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
if has('nvim')
    " Color schemes with treesitter support.

    " - nvcode (basically just dark+)
    " - onedark
    " - nord
    " - aurora (more colorful nord)
    " - gruvbox
    " - palenight
    " - snazzy (Based on hyper-snazzy by Sindre Sorhus)
    " - xoria (Based on xoria-256)
    Plug 'ChristianChiarulli/nvcode-color-schemes.vim'

    Plug 'tanvirtin/monokai.nvim'
endif

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
"
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
Plug 'williamboman/mason.nvim', { 'do': ':MasonUpdate' }
Plug 'williamboman/mason-lspconfig.nvim'
Plug 'neovim/nvim-lspconfig'

    " Make colors a bit less distracting
    augroup LspColors
        autocmd!

        function! s:SetLspColors()
            highlight DiagnosticVirtualTextError ctermfg=238 guifg=#8c3032
            highlight DiagnosticVirtualTextWarn ctermfg=238 guifg=#5a5a30
            highlight DiagnosticVirtualTextInfo ctermfg=238 guifg=#303f5a
            highlight DiagnosticVirtualTextHint ctermfg=238 guifg=#305a35
        endfunction

        autocmd ColorScheme * call s:SetLspColors()
    augroup END

function! s:configure_mason()

lua << EOF
require("mason").setup()
require("mason-lspconfig").setup()

-- Use LspAttach autocommand to only map the following keys
-- after the language server attaches to the current buffer
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(ev)
    -- Enable completion triggered by <c-x><c-o>
    vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

    vim.api.nvim_create_autocmd("CursorHold", {
      buffer = bufnr,
      callback = function()
        local opts = {
          focusable = false,
          close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
          border = "rounded",
          source = "always",
          prefix = " ",
          scope = "cursor",
        }
        vim.diagnostic.open_float(nil, opts)
      end
    })
    vim.lsp.handlers["textDocument/hover"] =
      vim.lsp.with(
      vim.lsp.handlers.hover,
      {
        border = "rounded"
      }
    )

    vim.lsp.handlers["textDocument/signatureHelp"] =
      vim.lsp.with(
      vim.lsp.handlers.signature_help,
      {
        border = "rounded"
      }
    )

    -- Buffer local mappings.
    -- See `:help vim.lsp.*` for documentation on any of the below functions
    local opts = { buffer = ev.buf }
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
    -- vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
    vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, opts)
    vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, opts)
    vim.keymap.set('n', '<space>wl', function()
      print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, opts)
    vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, opts)
    vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
    vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, opts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
    vim.keymap.set('n', '<space>f', function()
      vim.lsp.buf.format { async = true }
    end, opts)
  end,
})

EOF

endfunction

" Completion
" For Copilot setup, we should run `:Copilot auth`
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-cmdline'
Plug 'hrsh7th/cmp-vsnip'
Plug 'hrsh7th/cmp-nvim-lsp-signature-help'
Plug 'hrsh7th/cmp-emoji'
Plug 'zbirenbaum/copilot.lua'
Plug 'zbirenbaum/copilot-cmp'

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

" Lines from Sam
smap <expr> <Tab>   vsnip#jumpable(1)   ? '<Plug>(vsnip-jump-next)'      : '<Tab>'
smap <expr> <S-Tab> vsnip#jumpable(-1)  ? '<Plug>(vsnip-jump-prev)'      : '<S-Tab>'

function! s:setup_nvim_cmp()

lua << EOF
  local has_words_before = function()
    if vim.api.nvim_buf_get_option(0, "buftype") == "prompt" then return false end
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    return col ~= 0 and vim.api.nvim_buf_get_text(0, line-1, 0, line-1, col, {})[1]:match("^%s*$") == nil
  end

  local cmp = require('cmp')
  -- Set up nvim-cmp.
  cmp.setup({
    snippet = {
      -- REQUIRED - you must specify a snippet engine
      expand = function(args)
        vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
        -- require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
        -- require('snippy').expand_snippet(args.body) -- For `snippy` users.
        -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
      end,
    },
    window = {
      completion = cmp.config.window.bordered(),
      documentation = cmp.config.window.bordered(),
    },
    mapping = cmp.mapping.preset.insert({
      ['<C-b>'] = cmp.mapping.scroll_docs(-4),
      ['<C-f>'] = cmp.mapping.scroll_docs(4),
      ['<C-Space>'] = cmp.mapping.complete(),
      ['<CR>'] = cmp.mapping.confirm({ select = false }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
      ["<Tab>"] = vim.schedule_wrap(function(fallback)
          if cmp.visible() and has_words_before() then
            cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
          else
            fallback()
          end
        end),
      ['<S-Tab>'] = function(fallback)
        if cmp.visible() then
          cmp.select_prev_item()
        else
          fallback()
        end
      end
    }),
    sources = cmp.config.sources({
      { name = 'copilot' },
      { name = 'nvim_lsp' },
      { name = 'nvim_lsp_signature_help' },
      { name = 'emoji' },
      { name = 'path' },
      { name = 'vsnip' }, -- For vsnip users.
      -- { name = 'luasnip' }, -- For luasnip users.
      -- { name = 'ultisnips' }, -- For ultisnips users.
      -- { name = 'snippy' }, -- For snippy users.
    }, {
      { name = 'buffer' },
    })
  })

  -- Set configuration for specific filetype.
  cmp.setup.filetype('gitcommit', {
    sources = cmp.config.sources({
      { name = 'cmp_git' }, -- You can specify the `cmp_git` source if you were installed it.
      { name = 'emoji' }
    }, {
      { name = 'buffer' },
    })
  })

  -- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
  cmp.setup.cmdline({ '/', '?' }, {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
      { name = 'buffer' }
    }
  })

  -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
  cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
      { name = 'path' }
    }, {
      { name = 'cmdline' }
    })
  })

  require("mason-lspconfig").setup {
    ensure_installed = { "pyright", "tsserver", "eslint", "html", "cssls" },
  }

  -- Set up lspconfig.
  local capabilities = require('cmp_nvim_lsp').default_capabilities()
  -- Replace <YOUR_LSP_SERVER> with each lsp server you've enabled.
    require("lspconfig").pyright.setup{
        capabilities = capabilities
    }
    require("lspconfig").tsserver.setup{
        capabilities = capabilities
    }
    require("lspconfig").html.setup{
        capabilities = capabilities
    }
    require("lspconfig").cssls.setup{
        capabilities = capabilities
    }
    require("lspconfig").eslint.setup{
        capabilities = capabilities
    }
    require("lspconfig").arduino_language_server.setup{
        cmd = {
            "arduino-language-server",
            -- TODO this should not be hardcoded
            "-cli-config", "/Users/brentyi/Library/Arduino15/arduino-cli.yaml",
        },
        capabilities = capabilities
    }

    -- Copilot.
    require("copilot").setup({
      suggestion = { enabled = false },
      panel = { enabled = false },
    })
    require("copilot_cmp").setup()
    require("lspconfig").texlab.setup{
        capabilities = capabilities
    }
EOF
endfunction


" Trouble for quickfix.
Plug 'folke/trouble.nvim'

nmap <Leader><Tab> :TroubleToggle<CR>

function! s:configure_trouble()
lua << EOF
  require("trouble").setup {
    position = "bottom", -- position of the list can be: bottom, top, left, right
    height = 10, -- height of the trouble list when position is top or bottom
    width = 50, -- width of the list when position is left or right
    icons = false, -- use devicons for filenames
    mode = "workspace_diagnostics", -- "workspace_diagnostics", "document_diagnostics", "quickfix", "lsp_references", "loclist"
    fold_open = "v", -- icon used for open folds
    fold_closed = ">", -- icon used for closed folds
    group = true, -- group results by file
    padding = true, -- add an extra new line on top of the list
    action_keys = { -- key mappings for actions in the trouble list
        -- map to {} to remove a mapping, for example:
        -- close = {},
        close = "q", -- close the list
        cancel = "<esc>", -- cancel the preview and get back to your last window / buffer / cursor
        refresh = "r", -- manually refresh
        jump = {"<cr>", "<tab>"}, -- jump to the diagnostic or open / close folds
        open_split = { "<c-x>" }, -- open buffer in new split
        open_vsplit = { "<c-v>" }, -- open buffer in new vsplit
        open_tab = { "<c-t>" }, -- open buffer in new tab
        jump_close = {"o"}, -- jump to the diagnostic and close the list
        toggle_mode = "m", -- toggle between "workspace" and "document" diagnostics mode
        toggle_preview = "P", -- toggle auto_preview
        hover = "K", -- opens a small popup with the full multiline message
        preview = "p", -- preview the diagnostic location
        close_folds = {"zM", "zm"}, -- close all folds
        open_folds = {"zR", "zr"}, -- open all folds
        toggle_fold = {"zA", "za"}, -- toggle fold of current file
        previous = "k", -- previous item
        next = "j" -- next item
    },
    indent_lines = true, -- add an indent guide below the fold icons
    auto_open = false, -- automatically open the list when you have diagnostics
    auto_close = false, -- automatically close the list when you have no diagnostics
    auto_preview = true, -- automatically preview the location of the diagnostic. <esc> to close preview and go back to last window
    auto_fold = false, -- automatically fold a file trouble list at creation
    auto_jump = {"lsp_definitions"}, -- for the given modes, automatically jump if there is only a single result
    signs = {
        -- icons / text used for a diagnostic
        error = "error",
        warning = "warn ",
        hint = "hint ",
        information = "info "
    },
    use_diagnostic_signs = false -- enabling this will use the signs defined in your lsp client
  }
EOF
endfunction


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

" Automated import sorting. isort is now also supported by vim-codefmt, but
" our isort plugin has a few more features that we think are useful. (it runs
" asynchronously, specifies the --project flag, lets us specify flags, etc).
"
" See <Leader>cf binding under vim-codefmt for details on how this is called.
Plug 'brentyi/isort.vim'
" {{
    " Match black style
    let g:isort_vim_options = '--profile black'
" }}

" Google's code format plugin + dependencies
Plug 'google/vim-maktaba'
Plug 'google/vim-glaive'
Plug 'google/vim-codefmt'
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

    function! s:glaive_configure_vim_codefmt()
        " This is called after Glaive is initialized.
        Glaive codefmt prettier_options=`['--prose-wrap', 'always']`
    endfunction

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

" Automated docstrings
" > Install currently breaks in Neovim, where we need to run
"   :call doge#install after installation
Plug 'kkoomen/vim-doge', { 'do': { -> doge#install() } }
" {{
    let g:doge_doc_standard_python = 'google'

    " Binding: *P*ut *D*oc *S*tring.
    let g:doge_mapping = '<Leader>pds'
" }}

" Status line
Plug 'itchyny/lightline.vim'
Plug 'josa42/nvim-lightline-lsp'
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
        \            [ 'lsp_info', 'lsp_hints', 'lsp_errors', 'lsp_warnings', 'lsp_ok' ],
        \            [ 'ag_missing_status' ],
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
        \   'ag_missing_status': '%{"' . AgMissingStatus() . '"}',
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
    let g:lightline.component_expand = {
        \   'lsp_warnings': 'lightline#lsp#warnings',
        \   'lsp_errors': 'lightline#lsp#errors',
        \   'lsp_info': 'lightline#lsp#info',
        \   'lsp_hints': 'lightline#lsp#hints',
        \   'lsp_ok': 'lightline#lsp#ok',
        \   'status': 'lightline#lsp#status',
        \ }
    let g:lightline.component_type = {
        \   'lsp_warnings': 'warning',
        \   'lsp_errors': 'error',
        \   'lsp_info': 'info',
        \   'lsp_hints': 'hints',
        \   'lsp_ok': 'left',
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
    call s:glaive_configure_vim_codefmt()
    call s:configure_mason()
    call s:setup_nvim_cmp()
    call s:configure_trouble()

    if has('nvim')
        call s:treesitter_configure()
    endif

    " Automatically change working directory to current file's parent
    set autochdir

    " Suppress existing swapfile errors; this can be disabled via
    " `set shortmess-=A` or swapfiles can be recovered manually if we ever do
    " need them
    set shortmess+=A

    " Ignore patterns for Python
    set wildignore=*.swp,*.o,*.pyc,*.pb
    set wildignore+=.venv/*,site-packages/*

    " Ignore patterns for version control systems
    set wildignore+=.git/*,.hg/*,.svn/*

    " Ignore patterns for Buck
    set wildignore+=.castle/*,.buckd/*

    " Ignore patterns for Jekyll
    set wildignore+=_site/*,.jekyll-cache/*

    " Ignore patterns for Node
    set wildignore+=node_modules/*

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
                " TODO: most of this won't do anything when termguicolors is
                " set!

                " When we have 256 colors available
                " (This is usually true)
                set t_Co=256
                highlight LineNr ctermfg=241 ctermbg=234
                highlight CursorLineNr cterm=bold ctermfg=232 ctermbg=250 guifg=#080808 guibg=#585858
                highlight Visual cterm=bold ctermbg=238
                highlight TrailingWhitespace ctermbg=52
                let g:indentLine_color_term=237
                highlight SpecialKey ctermfg=238
                let l:todo_color = 247

                " Cursorword: just underline
                highlight CursorWord0 ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE
                highlight CursorWord1 ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE

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
            execute 'highlight Todo ' . l:comment_highlight . ' cterm=bold ctermfg=' . l:todo_color . ' guifg=#9e9e9e'
        endfunction
        autocmd ColorScheme * call s:ColorschemeOverrides()
    augroup END

    if has('nvim')
        " Treesitter support.
        let g:brent_colorscheme = get(g:, 'brent_colorscheme', 'monokai_pro')
    else
        let g:brent_colorscheme = get(g:, 'brent_colorscheme', 'xoria256')
    endif
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

        if a:next_flag
            Trouble
lua << EOF
require("trouble").next({skip_groups = true, jump = true});
EOF
        else
            Trouble
lua << EOF
require("trouble").previous({skip_groups = true, jump = true});
EOF
        endif
        " echom 'Adaptive motion: no target found'
    endfunction
    " We used to use <Tab> and <S-Tab> here, but <Tab> interferes with <C-i>
    nnoremap <Leader>j :call <SID>adaptive_motion(1)<CR>
    nnoremap <Leader>k :call <SID>adaptive_motion(0)<CR>

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

        TroubleClose

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
