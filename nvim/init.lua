-- Ensure packer.nvim is installed for plugin management
local fn = vim.fn
local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
if fn.empty(fn.glob(install_path)) > 0 then
	fn.system({
		"git",
		"clone",
		"--depth",
		"1",
		"https://github.com/wbthomason/packer.nvim",
		install_path,
	})
	vim.cmd([[packadd packer.nvim]])
end

vim.deprecate = function() end

-- Auto-reload
vim.cmd([[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost init.lua source <afile>
  augroup end
]])

require("packer").startup(function()
	-- Core plugins
	use("wbthomason/packer.nvim") -- Package manager

	-- UI Enhancements
	use({
		"jasonlong/nord-vim", -- Nord colorscheme
		config = function()
			vim.cmd("colorscheme nord")
		end,
	})

	use({
		"vim-airline/vim-airline", -- Status line
		requires = "vim-airline/vim-airline-themes",
		config = function()
			vim.g.airline_powerline_fonts = 1
			vim.g.airline_theme = "nord"
		end,
	})

	use("airblade/vim-gitgutter") -- Git diff indicators

	use({
		"folke/zen-mode.nvim", -- Distraction-free mode
		config = function()
			require("zen-mode").setup({
				window = {
					width = 0.4,
					options = {},
				},
			})
			vim.api.nvim_set_keymap(
				"n",
				"<F12>",
				":lua require('zen-mode').toggle()<CR>",
				{ noremap = true, silent = true }
			)
		end,
	})

	-- Code Formatting
	use({
		"sbdchd/neoformat", -- General formatting
		config = function()
			-- Enable formatting on save for C/C++ files
			vim.api.nvim_create_autocmd("BufWritePre", {
				pattern = { "*.c", "*.cc", "*.cpp", "*.h", "*.hpp" },
				command = "Neoformat",
			})
		end,
	})
	use({
		"mcauley-penney/tidy.nvim", -- Trim trailing whitespace
		config = function()
			require("tidy").setup({
				enabled = true,
				trim_on_save = true,
				filetype_exclude = { "markdown", "diff" },
			})
		end,
	})

	-- LSP & Autocompletion
	use("neovim/nvim-lspconfig") -- LSP configuration
	use("hrsh7th/nvim-cmp") -- Autocompletion
	use("hrsh7th/cmp-nvim-lsp") -- LSP source for nvim-cmp
	use("hrsh7th/cmp-buffer") -- Buffer completions
	use("hrsh7th/cmp-path") -- Path completions
	use("windwp/nvim-autopairs") -- Auto-pair brackets
	use({
		"onsails/lspkind.nvim", -- Icons for completion menu
		config = function()
			require("lspkind").init()
		end,
	})

	-- Code Analysis
	use({
		"nvim-treesitter/nvim-treesitter", -- Syntax parsing
		run = ":TSUpdate",
		config = function()
			require("nvim-treesitter.configs").setup({
				ensure_installed = { "c", "cpp", "lua", "python", "cmake" },
				ignore_install = { "all" },
				highlight = { enable = true },
			})
		end,
	})

	-- Navigation & Search
	use({
		"ibhagwan/fzf-lua", -- Fuzzy finder
		config = function()
			require("fzf-lua").setup({
				fzf_opts = { ["--layout"] = false },
			})
			-- Helper for setting keymaps
			local map = function(keys, func, desc)
				vim.keymap.set("n", keys, func, { noremap = true, silent = true, desc = "FZF: " .. desc })
			end
			-- Setup keybindings for fzf-lua
			map("<leader>f", "<cmd>lua require('fzf-lua').git_files()<CR>", "Find Git Files")
			map("<leader>b", "<cmd>lua require('fzf-lua').buffers()<CR>", "Find Buffers")
			map("<leader>d", "<cmd>lua require('fzf-lua').git_status()<CR>", "Git Status")
			map("<leader>g", "<cmd>lua require('fzf-lua').grep_cword()<CR>", "Grep for word under cursor")
			map("<leader>v", "<cmd>lua require('fzf-lua').live_grep_native()<CR>", "Live Grep")
			map("<leader>c", "<cmd>lua require('fzf-lua').blines()<CR>", "Find in current buffer lines")
		end,
	})
end)

-- Editor appearance
vim.opt.termguicolors = true
vim.opt.background = "dark"
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.signcolumn = "yes"

-- Indentation
vim.opt.smartindent = true
vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4

-- Performance
vim.opt.updatetime = 300
vim.opt.encoding = "utf-8"

-- Key input
vim.opt.timeout = true
vim.opt.timeoutlen = 1000
vim.opt.ttimeout = true
vim.opt.ttimeoutlen = 0
-- Search
vim.opt.incsearch = false
vim.opt.wrap = false

-- Keybindings
vim.g.mapleader = "<"

vim.opt.mouse = ""

-- Toggles
vim.keymap.set("n", "<F3>", ":set hlsearch!<CR>", { noremap = true, silent = true, desc = "Toggle search highlight" })
vim.keymap.set("n", "<F4>", ":set relativenumber! number!<CR>", { noremap = true, silent = true, desc = "Toggle relative numbers" })

-- LSP Configuration
local lspconfig = require("lspconfig")
local lsp_defaults = lspconfig.util.default_config

-- Enhanced capabilities with nvim-cmp
lsp_defaults.capabilities =
	vim.tbl_deep_extend("force", lsp_defaults.capabilities, require("cmp_nvim_lsp").default_capabilities())

-- Common LSP settings
local on_attach = function(client, bufnr)
	-- Enable completion triggered by <c-x><c-o>
	vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")

	-- Mappings
	local opts = { buffer = bufnr, noremap = true, silent = true }
	vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
	vim.keymap.set("n", "gy", vim.lsp.buf.type_definition, opts)
	vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
	vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
	vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
	vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
	vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
	vim.keymap.set("n", "en", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
	vim.keymap.set("n", "ep", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
end

-- Clangd
lspconfig.clangd.setup({
	cmd = {
		"clangd",
		"--compile-commands-dir=build/debug",
		"--clang-tidy",
		"--background-index",
		"--malloc-trim",
	},
	on_attach = on_attach,
})

-- Autocompletion Setup
local cmp = require("cmp")
cmp.setup({
	snippet = {
		expand = function(args)
			vim.snippet.expand(args.body)
		end,
	},
	mapping = {
		["<C-Space>"] = cmp.mapping.complete(),
		["<Esc>"] = cmp.mapping.abort(),
		["<CR>"] = cmp.mapping.confirm({ select = true }),
		["<Tab>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
		["<S-Tab>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
		["<Down>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
		["<Up>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
	},
	sources = cmp.config.sources({
		{ name = "nvim_lsp" },
		{ name = "buffer" },
		{ name = "path" },
	}),
	formatting = {
		format = function(entry, vim_item)
			-- Try to load lspkind if available
			local ok, lspkind = pcall(require, "lspkind")
			if ok then
				return lspkind.cmp_format({
					mode = "symbol_text",
					maxwidth = 50,
					ellipsis_char = "...",
				})(entry, vim_item)
			end
			-- Fallback if lspkind not available
			return vim_item
		end,
	},
	window = {
		completion = cmp.config.window.bordered(),
		documentation = cmp.config.window.bordered(),
	},
	experimental = {
		ghost_text = true,
	},
})

-- If you want insert `(` after select function or method item
require("nvim-autopairs").setup({})
local cmp_autopairs = require("nvim-autopairs.completion.cmp")
local cmp = require("cmp")
cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())

function switch_alternate_file()
	local file = vim.fn.expand("%:p")
	local ext = vim.fn.expand("%:e")
	local alternate

	if ext == "cc" then
		alternate = file:gsub("%.cc$", ".h")
	elseif ext == "hpp" then
		alternate = file:gsub("%.hpp$", ".h")
	elseif ext == "h" then
		alternate = file:gsub("%.h$", ".cc")
		if vim.fn.filereadable(alternate) ~= 1 then
			alternate = file:gsub("%.h$", ".hpp")
		end
	else
		print("No alternate file mapping for this filetype")
		return
	end

	if vim.fn.filereadable(alternate) == 1 then
		vim.cmd("edit " .. alternate)
	else
		print("Alternate file not found: " .. alternate)
	end
end

-- Map a key to switch files
vim.keymap.set("n", "<leader>q", "<cmd>lua switch_alternate_file()<CR>", {
	noremap = true,
	silent = true,
	desc = "Switch to alternate file (.h/.cc)",
})

vim.g.neoformat_enabled_c = { "clangformat" }
vim.g.neoformat_enabled_cpp = { "clangformat" }

-- Diagnostics Configuration
vim.diagnostic.config({
	virtual_text = {
		prefix = "●", -- Change the diagnostic symbol
		spacing = 4,
	},
	signs = true,
	underline = true,
	update_in_insert = false,
	severity_sort = true,
	float = {
		border = "rounded",
		source = "always",
		header = "",
		prefix = "",
	},
})

-- Diagnostic Keymaps
local diagnostic_goto = function(next, severity)
	local go = next and vim.diagnostic.goto_next or vim.diagnostic.goto_prev
	severity = severity and vim.diagnostic.severity[severity] or nil
	return function()
		go({ severity = severity })
	end
end

vim.keymap.set("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line diagnostics" })
vim.keymap.set("n", "]d", diagnostic_goto(true), { desc = "Next diagnostic" })
vim.keymap.set("n", "[d", diagnostic_goto(false), { desc = "Prev diagnostic" })
vim.keymap.set("n", "]e", diagnostic_goto(true, "ERROR"), { desc = "Next error" })
vim.keymap.set("n", "[e", diagnostic_goto(false, "ERROR"), { desc = "Prev error" })
vim.keymap.set("n", "]w", diagnostic_goto(true, "WARN"), { desc = "Next warning" })
vim.keymap.set("n", "[w", diagnostic_goto(false, "WARN"), { desc = "Prev warning" })
