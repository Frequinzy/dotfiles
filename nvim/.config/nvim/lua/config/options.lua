-- Set leader keys
vim.g.mapleader = ' '
vim.g.maplocalleader = ','

-- Disable mouse
vim.o.mouse = ''

-- Set line numbers
vim.o.number = true
vim.o.relativenumber = true

-- Set indentation
vim.o.expandtab = true
vim.o.softtabstop = 4
vim.o.shiftwidth = 4
-- Leave at Default (See `:h tabstop` for why)
vim.o.tabstop = 8

-- Disable text wrapping
vim.o.wrap = false

-- Improve searching
vim.o.hlsearch = false
vim.o.ignorecase = true
vim.o.smartcase = true

-- Set a scrolloff context
vim.o.scrolloff = 8

-- Set a signcolumn to avoid shifting as signs are added
vim.o.signcolumn = 'yes'

-- Set colorcolumn
vim.o.colorcolumn = '80'

-- Set rounded border on floats
vim.o.winborder = 'rounded'

-- Make vertical splitting to default to right
vim.o.splitright = true

