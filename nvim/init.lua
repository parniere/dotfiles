-- Ensure packer.nvim is installed for plugin management
local fn = vim.fn
local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
if fn.empty(fn.glob(install_path)) > 0 then
  fn.system({
    'git',
    'clone',
    '--depth', '1',
    'https://github.com/wbthomason/packer.nvim',
    install_path
  })
  vim.cmd [[packadd packer.nvim]]
end

-- Autocommand to auto-reload and install/update plugins when saving this file
vim.cmd [[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost init.lua source <afile> | PackerSync
  augroup end
]]

require('packer').startup(function()
  use 'wbthomason/packer.nvim' -- Package manager
  use 'jasonlong/nord-vim' -- Nord colorscheme
  use 'vim-airline/vim-airline'
  use 'vim-airline/vim-airline-themes'
  use 'airblade/vim-gitgutter'
  use 'rhysd/vim-clang-format'
  use 'neovim/nvim-lspconfig'
  use 'hrsh7th/nvim-cmp'
  use 'hrsh7th/cmp-nvim-lsp'
  use {
    "windwp/nvim-autopairs",
  }
  use {
        'nvim-treesitter/nvim-treesitter',
        run = ':TSUpdate'
  }
  use { "ibhagwan/fzf-lua",
    -- optional for icon support
    -- requires = { "nvim-tree/nvim-web-devicons" }
    -- or if using mini.icons/mini.nvim
    -- requires = { "echasnovski/mini.icons" }
  }
  -- Trim plugin
  use {
    'mcauley-penney/tidy.nvim',
     config = function()
      require('tidy').setup()
     end
  }
  use {
  'sbdchd/neoformat',
  config = function()
    -- Enable formatting on save
    vim.api.nvim_create_autocmd("BufWritePre", {
      pattern = {"*.c", "*.cc", "*.cpp", "*.h"},
      command = "Neoformat"
    })
  end
}
end)

-- General settings
vim.o.termguicolors = true
vim.o.background = 'dark'
vim.cmd('colorscheme nord')
vim.o.number = true
vim.o.relativenumber = true
vim.o.smartindent = true
vim.o.expandtab = true
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.wrap = false
vim.o.signcolumn = 'yes'
vim.o.cursorline = true
vim.o.encoding = 'utf-8'
vim.o.updatetime = 300


-- https://www.johnhawthorn.com/2012/09/vi-escape-delays/
vim.opt.timeout = true
vim.opt.timeoutlen = 1000
vim.opt.ttimeout = true
vim.opt.ttimeoutlen = 0

vim.opt.incsearch = false


-- Airline
vim.g.airline_powerline_fonts = 1
vim.g.airline_theme = 'nord'

-- Keybindings
vim.g.mapleader = "<"
local map = vim.api.nvim_set_keymap
map('n', '<F3>', ':set hlsearch!<CR>', { noremap = true, silent = true })
map('n', '<F4>', ':set relativenumber! number!<CR>', { noremap = true, silent = true })

-- CoC (LSP and autocompletion)
--map('n', 'gd', '<Plug>(coc-definition)', {})
--map('n', 'gy', '<Plug>(coc-type-definition)', {})
--map('n', 'gi', '<Plug>(coc-implementation)', {})
--map('n', 'gr', '<Plug>(coc-references)', {})
--map('n', '<leader>rn', '<Plug>(coc-rename)', {})
vim.api.nvim_set_keymap('n', '<leader>f', "<cmd>lua require('fzf-lua').git_files()<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>b', "<cmd>lua require('fzf-lua').buffers()<CR>", { noremap = true, silent = true })
-- Map <leader>d to search for modified files in Git
vim.api.nvim_set_keymap('n', '<leader>d', "<cmd>lua require('fzf-lua').git_status()<CR>", { noremap = true, silent = true })
-- Map <leader>g to search for the word under the cursor using Ripgrep
vim.api.nvim_set_keymap('n', '<leader>g', "<cmd>lua require('fzf-lua').grep_cword()<CR>", { noremap = true, silent = true })


-- Treesitter
require'nvim-treesitter.configs'.setup {
  ensure_installed = "all",
  highlight = {
    enable = true,
  },
}

require('lspconfig').clangd.setup {
  cmd = {
    "clangd",
    "--compile-commands-dir=build/debug",
    "--clang-tidy",
    "--background-index",
    "--malloc-trim"
  },
}

-- Add cmp_nvim_lsp capabilities settings to lspconfig
-- This should be executed before you configure any language server
local lspconfig_defaults = require('lspconfig').util.default_config
lspconfig_defaults.capabilities = vim.tbl_deep_extend(
  'force',
  lspconfig_defaults.capabilities,
  require('cmp_nvim_lsp').default_capabilities()
)

local cmp = require('cmp')
cmp.setup({
  sources = {
    {name = 'nvim_lsp'},
  },
  snippet = {
    expand = function(args)
      -- You need Neovim v0.10 to use vim.snippet
      vim.snippet.expand(args.body)
    end,
  },
  window = {
      -- completion = cmp.config.window.bordered(),
      -- documentation = cmp.config.window.bordered(),
    },
    mapping = {
    -- Navigate the suggestion list with arrow keys
    ['<Down>'] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
    ['<Up>'] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),

    -- Confirm completion with Enter
    ['<CR>'] = cmp.mapping.confirm({ select = true }),

    -- Close the completion menu
    ['<C-e>'] = cmp.mapping.close(),
  },
})

-- If you want insert `(` after select function or method item
 require('nvim-autopairs').setup {}
local cmp_autopairs = require('nvim-autopairs.completion.cmp')
local cmp = require('cmp')
cmp.event:on(
  'confirm_done',
  cmp_autopairs.on_confirm_done()
)

local opts = { noremap = true, silent = true }
vim.api.nvim_set_keymap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
vim.api.nvim_set_keymap('n', 'gy', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
vim.api.nvim_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
vim.api.nvim_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
vim.api.nvim_set_keymap('n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
vim.api.nvim_set_keymap('n', 'en', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
vim.api.nvim_set_keymap('n', 'ep', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)

-- doc
vim.api.nvim_set_keymap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)

function switch_alternate_file()
  local file = vim.fn.expand('%:p')
  local ext = vim.fn.expand('%:e')
  local alternate

  if ext == 'cc' then
    alternate = file:gsub('%.cc$', '.h')
  elseif ext == 'h' then
    alternate = file:gsub('%.h$', '.cc')
  else
    print('No alternate file mapping for this filetype')
    return
  end

  if vim.fn.filereadable(alternate) == 1 then
    vim.cmd('edit ' .. alternate)
  else
    print('Alternate file not found: ' .. alternate)
  end
end

-- Map a key to switch files
vim.api.nvim_set_keymap('n', '<leader>q', '<cmd>lua switch_alternate_file()<CR>', opts)

require('tidy').setup({
  -- Enable or disable the plugin
  enabled = true,
  -- Enable or disable trimming on save
  trim_on_save = true,
  -- Filetypes to exclude from trimming
  filetype_exclude = { 'markdown', 'diff' },
})

vim.g.neoformat_enabled_c = {'clangformat'}
vim.g.neoformat_enabled_cpp = {'clangformat'}
