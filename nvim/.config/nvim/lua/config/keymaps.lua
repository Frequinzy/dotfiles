-- Paste from system clipboard
vim.keymap.set('n', '<leader>p', '\"+p', { desc = 'Paste from system clipboard' })
vim.keymap.set('v', '<leader>p', '\"+p')
vim.keymap.set('n', '<leader>P', '\"+P', { desc = 'Paste above from system clipboard' })
vim.keymap.set('v', '<leader>P', '\"+P')

-- Yank to system clipboard
vim.keymap.set('n', '<leader>y', '\"+y', { desc = 'Yank to system clipboard' })
vim.keymap.set('v', '<leader>y', '\"+y')
vim.keymap.set('n', '<leader>Y', '\"+Y', { desc = 'Yank rest of line to system clipboard' })
vim.keymap.set('v', '<leader>Y', '\"+Y')

-- Open diagnostics
vim.keymap.set('n', '<leader>dd', vim.diagnostic.open_float, { desc = 'Open diagnostic' })
