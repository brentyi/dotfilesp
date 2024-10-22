-- Map leader to space.
vim.g.mapleader = " "
vim.opt.timeoutlen = 200
vim.opt.ttimeoutlen = 10

-- Some visuals.
vim.wo.relativenumber = true
vim.wo.number = true
vim.opt.cursorline = true
vim.opt.termguicolors = true
vim.opt.showmode = false

-- Suppress swap file errors.
vim.opt.shortmess:append("A")
vim.opt.autoread = true

-- Use current file's parent as cwd.
vim.opt.autochdir = true

-- Disable netrw.
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Display tabs as 4 spaces. Indentation settings will usually be overridden
-- guess-indent.nvim.
vim.o.tabstop = 4
vim.o.shiftwidth = 4

-- Escape bindings.
vim.keymap.set("v", "[[", "<Esc>")
vim.keymap.set("i", "[[", "<Esc>")

-- Tmux-style split bindings.
vim.keymap.set("n", '<C-w>"', ":sp<CR>")
vim.keymap.set("n", "<C-w>%", ":vsp<CR>")

-- Use arrow keys to resize splits.
vim.keymap.set("n", "<Up>", function()
	vim.api.nvim_win_set_height(0, vim.api.nvim_win_get_height(0) + vim.v.count1 * 8)
end)
vim.keymap.set("n", "<Down>", function()
	vim.api.nvim_win_set_height(0, vim.api.nvim_win_get_height(0) - vim.v.count1 * 8)
end)
vim.keymap.set("n", "<Right>", function()
	vim.api.nvim_win_set_width(0, vim.api.nvim_win_get_width(0) + vim.v.count1 * 8)
end)
vim.keymap.set("n", "<Left>", function()
	vim.api.nvim_win_set_width(0, vim.api.nvim_win_get_width(0) - vim.v.count1 * 8)
end)

-- Bindings for things we do a lot.
vim.keymap.set("n", "<Leader>wq", ":wq<CR>")
vim.keymap.set("n", "<Leader>w", ":w<CR>")
vim.keymap.set("n", "<Leader>q", ":q<CR>")
vim.keymap.set("n", "<Leader>q!", ":q!<CR>")
vim.keymap.set("n", "<Leader>e", ":e<CR>")
vim.keymap.set("n", "<Leader>e!", ":e!<CR>")
vim.keymap.set("n", "<Leader>e.", ":e .<CR>")
vim.keymap.set("n", "<Leader>ip", ":set invpaste<CR>")
vim.keymap.set("n", "<Leader>rtw", ":%s/\\<<C-r><C-w>\\>/") -- "replace this word"

-- Turn on spellcheck for commit messages.
vim.api.nvim_create_autocmd("FileType", {
	pattern = "gitcommit,hgcommit",
	callback = function()
		vim.opt_local.spell = true
	end,
})

-- Install lazy.nvim. (plugin manager)
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

-- Helper for making sure a package is installed via Mason.
ENSURE_INSTALLED = function(filetype, package_name)
	vim.api.nvim_create_autocmd("FileType", {
		pattern = filetype,
		callback = function()
			local registry = require("mason-registry")
			-- Notification wrapper that suppresses some type errors. We call
			-- notify.notify() instead of notify() to make sure that a
			-- notification handle is returned; the latter sometimes only
			-- schedules a notification and returns nil.
			local notify = function(message, level, opts)
				return require("notify").notify(message, level, opts)
			end

			-- Is the package installed yet?
			if not registry.is_installed(package_name) then
				-- We'll make a spinner to show that something is happening.
				local spinner_frames = { "⣾", "⣽", "⣻", "⢿", "⡿", "⣟", "⣯", "⣷" }

				-- Try to install!
				registry.refresh()
				local install_handle = registry.get_package(package_name):install()
				local notif_id = notify("", "info", {}).id
				while not install_handle:is_closed() do
					---@diagnostic disable-next-line: missing-parameter
					local spinner_index = (math.floor(vim.fn.reltimefloat(vim.fn.reltime()) * 10.0)) % #spinner_frames
						+ 1
					notif_id = notify("Installing " .. package_name .. "...", 2, {
						title = "Setup",
						icon = spinner_frames[spinner_index],
						replace = notif_id,
					}).id
					vim.wait(100)
					vim.cmd("redraw")
				end

				-- Did installation succeed?
				if registry.is_installed(package_name) then
					---@diagnostic disable-next-line: missing-fields
					notify("Installed " .. package_name, 2, {
						title = "Setup",
						icon = "✓",
						replace = notif_id,
					})
				else
					---@diagnostic disable-next-line: missing-fields
					notify("Failed to install " .. package_name, "error", {
						title = "Setup",
						icon = "𐄂",
						replace = notif_id,
					})
				end
			end
		end,
	})
end

-- Configure plugins.
local lazy_plugins = {
	-- Color scheme.
	{
		"navarasu/onedark.nvim",
		priority = 1000,
		config = function()
			require("onedark").setup({ style = "darker" })
			vim.cmd.colorscheme("onedark")
		end,
	},
	-- Statusline.
	{
		"nvim-lualine/lualine.nvim",
		opts = {
			options = {
				icons_enabled = false,
				theme = "auto",
				component_separators = { left = "|", right = "|" },
				section_separators = { left = "", right = "" },
			},
			sections = {
				lualine_a = { "mode" },
				lualine_b = { "filename" },
				lualine_c = { "diff" },
				lualine_x = {
					{
						function(name, context) -- Filepath.
							return vim.fn.fnamemodify(vim.fn.getcwd(), ":~")
						end,
						color = { fg = "#777777" },
					},
					"diagnostics",
				},
				lualine_y = { "filetype", "progress" },
				lualine_z = { "location" },
			},
		},
	},
	-- Notification helper!
	{
		"rcarriga/nvim-notify",
		opts = {
			icons = {
				DEBUG = "(!)",
				ERROR = "🅔",
				INFO = "ⓘ ", -- "ⓘ",
				TRACE = "(⋱)",
				WARN = "⚠️ ",
			},
		},
	},
	-- Syntax highlighting.
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		config = function()
			---@diagnostic disable-next-line: missing-fields
			require("nvim-treesitter.configs").setup({
				sync_install = false,
				auto_install = true,
				highlight = { enable = true },
			})
		end,
	},
	-- Show indentation guides.
	{
		"lukas-reineke/indent-blankline.nvim",
		config = function()
			vim.api.nvim_set_hl(0, "IblIndent", { fg = "#573757" })
			vim.api.nvim_set_hl(0, "IblScope", { fg = "#555585" })
			require("ibl").setup({ indent = { char = "·" }, scope = { show_start = false, show_end = false } })
		end,
	},
	-- Fuzzy find.
	{
		"nvim-telescope/telescope.nvim",
		tag = "0.1.4",
		dependencies = {
			"nvim-lua/plenary.nvim",
			{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
		},
		config = function()
			require("telescope").setup({ pickers = { find_files = { hidden = true } } })
			require("telescope").load_extension("fzf")

			-- Use repository root as cwd for Telescope.
			vim.api.nvim_create_autocmd("BufWinEnter", {
				pattern = "*",
				callback = vim.schedule_wrap(function()
					local root = vim.fs.dirname(vim.fs.find(".git", { upward = true })[1])
					if root ~= nil then
						vim.b["Telescope#repository_root"] = root
					else
						vim.b["Telescope#repository_root"] = "."
					end
				end),
			})

			-- Bindings.
			local builtin = require("telescope.builtin")
			vim.keymap.set("n", "<C-p>", function()
				builtin.find_files({ cwd = vim.b["Telescope#repository_root"] })
			end)
			vim.keymap.set("n", "<Leader>fg", function()
				builtin.live_grep({ cwd = vim.b["Telescope#repository_root"] })
			end)
			vim.keymap.set("n", "<Leader>gf", function()
				-- Grep for the current word.
				builtin.grep_string({ cwd = vim.b["Telescope#repository_root"] })
			end)
			vim.keymap.set("n", "<Leader>fb", builtin.buffers)
			vim.keymap.set("n", "<Leader>fh", builtin.help_tags)
			vim.keymap.set("n", "<Leader>h", builtin.oldfiles)
		end,
	},
	-- Tagbar-style code overview.
	{
		"stevearc/aerial.nvim",
		config = function()
			require("aerial").setup()
			vim.keymap.set("n", "<leader>a", "<cmd>AerialToggle!<CR>")
		end,
	},
	-- Git helpers.
	{ "tpope/vim-fugitive" },
	{ "lewis6991/gitsigns.nvim", config = true },
	{ "akinsho/git-conflict.nvim", version = "*", config = true },
	-- Comments. By default, bound to `gcc`.
	{ "numToStr/Comment.nvim", config = true },
	-- Motions.
	{ "kylechui/nvim-surround", config = true },
	{ "easymotion/vim-easymotion" },
	-- Persist the cursor position when we close a file.
	{ "vim-scripts/restore_view.vim" },
	-- Web-based Markdown preview.
	{
		"iamcco/markdown-preview.nvim",
		cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
		ft = { "markdown" },
		build = function()
			vim.fn["mkdp#util#install"]()
		end,
		config = function()
			vim.api.nvim_create_autocmd("FileType", {
				pattern = "markdown",
				callback = function()
					vim.keymap.set("n", "<Leader>mdtp", "<Plug>MarkdownPreviewToggle")
				end,
			})
		end,
	},
	-- File browser.
	{
		"nvim-neo-tree/neo-tree.nvim",
		branch = "v3.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"MunifTanjim/nui.nvim",
		},
		opts = {
			default_component_configs = {
				icon = {
					folder_closed = "+",
					folder_open = "-",
					folder_empty = "%",
					default = "",
				},
				git_status = {
					symbols = {
						deleted = "x",
						renamed = "r",
						modified = "m",
						untracked = "u",
						ignored = "i",
						unstaged = "u",
						staged = "s",
						conflict = "c",
					},
				},
				name = {
					use_git_status_colors = true,
				},
			},
			filesystem = {
				bind_to_cwd = false,
				hijack_netrw_behavior = "open_current",
				filtered_items = {
					visible = false,
					hide_dotfiles = false,
					hide_gitignored = false,
					hide_hidden = false,
				},
			},
		},
	},
	-- Automatically set indentation settings.
	{ "NMAC427/guess-indent.nvim", config = true },
	-- Misc visuals from mini.nvim.
	{
		"echasnovski/mini.nvim",
		config = function()
			require("mini.animate").setup({
				cursor = { enable = false },
				scroll = { enable = false },
			})
			require("mini.cursorword").setup()
			require("mini.trailspace").setup()
			local hipatterns = require("mini.hipatterns")
			hipatterns.setup({
				highlighters = {
					fixme = { pattern = "%f[%w]()FIXME()%f[%W]", group = "MiniHipatternsFixme" },
					hack = { pattern = "%f[%w]()HACK()%f[%W]", group = "MiniHipatternsHack" },
					todo = { pattern = "%f[%w]()TODO()%f[%W]", group = "MiniHipatternsTodo" },
					note = { pattern = "%f[%w]()NOTE()%f[%W]", group = "MiniHipatternsNote" },
					hex_color = hipatterns.gen_highlighter.hex_color(),
				},
			})
		end,
	},
	-- Split navigation. Requires corresponding changes to tmux config for tmux
	-- integration.
	{
		"alexghergh/nvim-tmux-navigation",
		config = function()
			local nvim_tmux_nav = require("nvim-tmux-navigation")
			nvim_tmux_nav.setup({
				disable_when_zoomed = true, -- defaults to false
			})
			vim.keymap.set("n", "<C-h>", nvim_tmux_nav.NvimTmuxNavigateLeft)
			vim.keymap.set("n", "<C-j>", nvim_tmux_nav.NvimTmuxNavigateDown)
			vim.keymap.set("n", "<C-k>", nvim_tmux_nav.NvimTmuxNavigateUp)
			vim.keymap.set("n", "<C-l>", nvim_tmux_nav.NvimTmuxNavigateRight)
			vim.keymap.set("n", "<C-\\>", nvim_tmux_nav.NvimTmuxNavigateLastActive)
			vim.keymap.set("n", "<C-Space>", nvim_tmux_nav.NvimTmuxNavigateNext)
		end,
	},
	-- Package management.
	{
		"williamboman/mason.nvim",
		opts = {
			ui = {
				icons = {
					package_installed = "✓",
					package_pending = "➜",
					package_uninstalled = "✗",
				},
			},
		},
	},
	-- Formatting.
	{
		"mhartington/formatter.nvim",
		config = function()
			-- Format keybinding.
			vim.keymap.set("n", "<Leader>cf", ":Format<CR>", { noremap = true })

			-- Automatically install formatters via Mason.
			ENSURE_INSTALLED("lua", "stylua")
			ENSURE_INSTALLED("python", "isort")
			ENSURE_INSTALLED("python", "ruff") -- Can replace both black and isort!
			ENSURE_INSTALLED("typescript,javascript,typescriptreact,javascriptreact", "prettier")
			ENSURE_INSTALLED("html,css", "prettier")
			ENSURE_INSTALLED("c,cpp,cuda", "clang-format")

			-- Configure formatters.
			local util = require("formatter.util")
			require("formatter").setup({
				logging = true,
				log_level = vim.log.levels.WARN,
				filetype = {
					-- What's available:
					-- https://github.com/mhartington/formatter.nvim/tree/master/lua/formatter/filetypes
					lua = { require("formatter.filetypes.lua").stylua },
					python = { require("formatter.filetypes.python").isort, require("formatter.filetypes.python").ruff },
					typescript = { require("formatter.filetypes.typescript").prettier },
					typescriptreact = { require("formatter.filetypes.typescript").prettier },
					javascript = { require("formatter.filetypes.javascript").prettier },
					javascriptreact = { require("formatter.filetypes.javascript").prettier },
					html = { require("formatter.filetypes.html").prettier },
					css = { require("formatter.filetypes.css").prettier },
					markdown = { require("formatter.filetypes.markdown").prettier },
					cpp = { require("formatter.filetypes.cpp").clangformat },
					["*"] = { require("formatter.filetypes.any").remove_trailing_whitespace },
				},
			})
		end,
	},
	-- Language servers.
	{
		"williamboman/mason-lspconfig.nvim",
		config = { true },
	},
	-- Snippets.
	{
		"L3MON4D3/LuaSnip",
		-- follow latest release.
		version = "v2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
		-- install jsregexp (optional!).
		build = "make install_jsregexp",
		dependencies = { "rafamadriz/friendly-snippets" },
	},
	-- Completion sources.
	{ "hrsh7th/cmp-nvim-lsp" },
	{ "hrsh7th/cmp-buffer" },
	{ "hrsh7th/cmp-path" },
	{ "hrsh7th/cmp-cmdline" },
	{ "hrsh7th/cmp-nvim-lsp-signature-help" },
	{ "hrsh7th/cmp-emoji" },
	{
		"github/copilot.vim",
		config = function()
			vim.g.copilot_no_tab_map = true
			vim.api.nvim_set_keymap("i", "<C-c>", "<Esc><C-c>", { noremap = true })
			vim.api.nvim_set_keymap("i", "<C-J>", 'copilot#Accept("<CR>")', { silent = true, expr = true })
		end,
	},
	{
		"hrsh7th/nvim-cmp",
		config = function()
			local has_words_before = function()
				if vim.api.nvim_buf_get_option(0, "buftype") == "prompt" then
					return false
				end
				local line, col = unpack(vim.api.nvim_win_get_cursor(0))
				return col ~= 0
					and vim.api.nvim_buf_get_text(0, line - 1, 0, line - 1, col, {})[1]:match("^%s*$") == nil
			end

			-- Set up nvim-cmp.
			local cmp = require("cmp")
			cmp.setup({
				-- Need to set a snippet engine up, even if we don't care about snippets.
				snippet = {
					expand = function(args)
						require("luasnip").lsp_expand(args.body)
					end,
				},
				window = {
					completion = cmp.config.window.bordered(),
					documentation = cmp.config.window.bordered(),
				},
				mapping = cmp.mapping.preset.insert({
					["<C-b>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),
					["<C-Space>"] = cmp.mapping.complete(),
					["<CR>"] = cmp.mapping.confirm({ select = false }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
					["<Tab>"] = vim.schedule_wrap(function(fallback)
						if cmp.visible() and has_words_before() then
							cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
						else
							fallback()
						end
					end),
					["<S-Tab>"] = function(fallback)
						if cmp.visible() then
							cmp.select_prev_item()
						else
							fallback()
						end
					end,
				}),
				sources = cmp.config.sources({
					{ name = "nvim_lsp" },
					{ name = "nvim_lsp_signature_help" },
					{ name = "emoji" },
					-- { name = "path" },
				}, {
					{ name = "buffer" },
				}),
			})

			-- Set configuration for specific filetype.
			cmp.setup.filetype("gitcommit", {
				sources = cmp.config.sources({
					{ name = "emoji" },
				}, {
					{ name = "buffer" },
				}),
			})

			-- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
			cmp.setup.cmdline({ "/", "?" }, {
				mapping = cmp.mapping.preset.cmdline(),
				sources = {
					{ name = "buffer" },
				},
			})

			-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
			cmp.setup.cmdline(":", {
				mapping = cmp.mapping.preset.cmdline(),
				sources = cmp.config.sources({ { name = "path" } }, { { name = "cmdline" } }),
			})
		end,
	},
	{
		"neovim/nvim-lspconfig",
		dependencies = { { "folke/neodev.nvim", config = true } },
		config = function()
			-- Dim LSP errors.
			vim.api.nvim_set_hl(0, "DiagnosticVirtualTextError", { fg = "#8c3032" })
			vim.api.nvim_set_hl(0, "DiagnosticVirtualTextWarn", { fg = "#5a5a30" })
			vim.api.nvim_set_hl(0, "DiagnosticVirtualTextInfo", { fg = "#303f5a" })
			vim.api.nvim_set_hl(0, "DiagnosticVirtualTextHint", { fg = "#305a35" })
			vim.api.nvim_set_hl(0, "CursorLineNr", { fg = "#333333", bg = "#a7a7a7" })
			vim.api.nvim_set_hl(0, "CursorLine", { bg = "#2b2b2b" })

			-- Automatically install language servers via Mason.
			ENSURE_INSTALLED("python", "pyright")
			ENSURE_INSTALLED("lua", "lua-language-server")
			ENSURE_INSTALLED("typescript,javascript,typescriptreact,javascriptreact", "typescript-language-server")
			ENSURE_INSTALLED("html", "html-lsp")
			ENSURE_INSTALLED("css", "css-lsp")
			ENSURE_INSTALLED("typescript,javascript,typescriptreact,javascriptreact", "eslint-lsp")
			ENSURE_INSTALLED("plaintex", "texlab")
			ENSURE_INSTALLED("c,cpp,cuda", "clangd")

			-- Set up lspconfig.
			local capabilities = require("cmp_nvim_lsp").default_capabilities()
			require("lspconfig").pyright.setup({ capabilities = capabilities })
			require("lspconfig").lua_ls.setup({ capabilities = capabilities })
			require("lspconfig").ts_ls.setup({ capabilities = capabilities })
			require("lspconfig").html.setup({ capabilities = capabilities })
			require("lspconfig").cssls.setup({ capabilities = capabilities })
			require("lspconfig").eslint.setup({ capabilities = capabilities })
			require("lspconfig").texlab.setup({ capabilities = capabilities })
			require("lspconfig").clangd.setup({ capabilities = capabilities })

			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("UserLspConfig", {}),
				callback = function(ev)
					-- Enable completion triggered by <c-x><c-o>
					vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"

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
						end,
					})
					vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
						border = "rounded",
					})

					vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
						border = "rounded",
					})

					-- Buffer local mappings.
					-- See `:help vim.lsp.*` for documentation on any of the below functions
					local opts = { buffer = ev.buf }
					vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
					vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
					vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
					vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
					-- vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
					vim.keymap.set("n", "<space>wa", vim.lsp.buf.add_workspace_folder, opts)
					vim.keymap.set("n", "<space>wr", vim.lsp.buf.remove_workspace_folder, opts)
					vim.keymap.set("n", "<space>wl", function()
						print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
					end, opts)
					vim.keymap.set("n", "<space>D", vim.lsp.buf.type_definition, opts)
					vim.keymap.set("n", "<space>rn", vim.lsp.buf.rename, opts)
					vim.keymap.set("n", "<space>ca", vim.lsp.buf.code_action, opts)
					vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
					vim.keymap.set("n", "<space>lf", function()
						vim.lsp.buf.format({ async = true })
					end, opts)
				end,
			})
		end,
	},
	{
		"folke/trouble.nvim",
		cmd = "Trouble",
		opts = {},
		keys = {
			{
				"<leader>xx",
				"<cmd>Trouble diagnostics toggle<cr>",
				desc = "Diagnostics (Trouble)",
			},
			{
				"<leader>xX",
				"<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
				desc = "Buffer Diagnostics (Trouble)",
			},
			{
				"<leader>cs",
				"<cmd>Trouble symbols toggle focus=false<cr>",
				desc = "Symbols (Trouble)",
			},
			{
				"<leader>cl",
				"<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
				desc = "LSP Definitions / references / ... (Trouble)",
			},
			{
				"<leader>xL",
				"<cmd>Trouble loclist toggle<cr>",
				desc = "Location List (Trouble)",
			},
			{
				"<leader>xQ",
				"<cmd>Trouble qflist toggle<cr>",
				desc = "Quickfix List (Trouble)",
			},
		},
	},
	{
		"yetone/avante.nvim",
		event = "VeryLazy",
		lazy = false,
		version = false, -- set this if you want to always pull the latest change
		opts = {
			windows = {
				sidebar_header = {
					align = "left", -- left, center, right for title
					rounded = false,
				},
			},
		},
		build = "make",
		dependencies = {
			-- "nvim-tree/nvim-web-devicons",
			"stevearc/dressing.nvim",
			"nvim-lua/plenary.nvim",
			"MunifTanjim/nui.nvim",
		},
	},
	{
		"CopilotC-Nvim/CopilotChat.nvim",
		branch = "canary",
		dependencies = {
			{ "zbirenbaum/copilot.lua" }, -- or github/copilot.vim
			{ "nvim-lua/plenary.nvim" }, -- for curl, log wrapper
		},
		build = "make tiktoken", -- Only on MacOS or Linux
		config = function()
			require("CopilotChat.integrations.cmp").setup()
			require("CopilotChat").setup({
				debug = true, -- Enable debugging
				-- See Configuration section for rest
				mappings = {
					reset = {
						normal = "<C-r>",
						insert = "<C-r>",
					},
					complete = {
						insert = "",
					},
				},
				-- rest of your config
			})
			vim.keymap.set({ "n", "v" }, "<Leader>cc", "<cmd>lua require('CopilotChat').open()<CR>")
		end,
		-- See Commands section for default commands if you want to lazy load on them
	},
}
local lazy_opts = {
	-- We don't want to install custom fonts, so we'll switch to Unicode icons.
	ui = {
		icons = {
			cmd = "⌘",
			config = "🛠",
			event = "📅",
			ft = "📂",
			init = "⚙",
			keys = "🗝",
			plugin = "🔌",
			runtime = "💻",
			require = "🌙",
			source = "📄",
			start = "🚀",
			task = "📌",
			lazy = "💤 ",
		},
	},
}
require("lazy").setup(lazy_plugins, lazy_opts)
