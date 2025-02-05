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
			-- Setup keybindings for fzf-lua
			vim.api.nvim_set_keymap(
				"n",
				"<leader>f",
				"<cmd>lua require('fzf-lua').git_files()<CR>",
				{ noremap = true, silent = true }
			)
			vim.api.nvim_set_keymap(
				"n",
				"<leader>b",
				"<cmd>lua require('fzf-lua').buffers()<CR>",
				{ noremap = true, silent = true }
			)
			vim.api.nvim_set_keymap(
				"n",
				"<leader>d",
				"<cmd>lua require('fzf-lua').git_status()<CR>",
				{ noremap = true, silent = true }
			)
			vim.api.nvim_set_keymap(
				"n",
				"<leader>g",
				"<cmd>lua require('fzf-lua').grep_cword()<CR>",
				{ noremap = true, silent = true }
			)
			vim.api.nvim_set_keymap(
				"n",
				"<leader>v",
				"<cmd>lua require('fzf-lua').live_grep_native()<CR>",
				{ noremap = true, silent = true }
			)
			vim.api.nvim_set_keymap(
				"n",
				"<leader>c",
				"<cmd>lua require('fzf-lua').blines()<CR>",
				{ noremap = true, silent = true }
			)
		end,
	})
end)

require("fzf-lua").setup({
	fzf_opts = {
		["--layout"] = false,
	},
})

-- Editor appearance
vim.o.termguicolors = true
vim.o.background = "dark"
vim.o.number = true
vim.o.relativenumber = true
vim.o.cursorline = true
vim.o.signcolumn = "yes"

-- Indentation
vim.o.smartindent = true
vim.o.expandtab = true
vim.o.tabstop = 4
vim.o.shiftwidth = 4

-- Performance
vim.o.updatetime = 300
vim.o.encoding = "utf-8"

-- Key input
vim.opt.timeout = true
vim.opt.timeoutlen = 1000
vim.opt.ttimeout = true
vim.opt.ttimeoutlen = 0

-- Search
vim.opt.incsearch = false
vim.o.wrap = false

-- Keybindings
vim.g.mapleader = "<"

vim.opt.mouse = ""

-- Toggles
vim.api.nvim_set_keymap("n", "<F3>", ":set hlsearch!<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<F4>", ":set relativenumber! number!<CR>", { noremap = true, silent = true })

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

local opts = { noremap = true, silent = true }
vim.api.nvim_set_keymap("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
vim.api.nvim_set_keymap("n", "gy", "<cmd>lua vim.lsp.buf.type_definition()<CR>", opts)
vim.api.nvim_set_keymap("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)
vim.api.nvim_set_keymap("n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", opts)
vim.api.nvim_set_keymap("n", "<leader>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
vim.api.nvim_set_keymap("n", "en", "<cmd>lua vim.diagnostic.goto_prev()<CR>", opts)
vim.api.nvim_set_keymap("n", "ep", "<cmd>lua vim.diagnostic.goto_next()<CR>", opts)

-- doc
vim.api.nvim_set_keymap("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)

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
vim.api.nvim_set_keymap("n", "<leader>q", "<cmd>lua switch_alternate_file()<CR>", opts)

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

-- Zen Mode
require("zen-mode").setup({
	window = {
		width = 0.4, -- Adjust the width to your preference
		options = {},
	},
})
vim.api.nvim_set_keymap("n", "<F12>", ":lua require('zen-mode').toggle()<CR>", { noremap = true, silent = true })
