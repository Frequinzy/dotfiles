-- Going back into normal mode
vim.keymap.set("i", "jk", "<esc>")

-- Keep cursor centered while scrolling code
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "<C-d>", "<C-d>zz")

-- Keep cursor centered while searching
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- Paste from system clipboard
vim.keymap.set("n", "<leader>p", "\"+p", {desc="Paste from system clipboard"})
vim.keymap.set("v", "<leader>p", "\"+p")
vim.keymap.set("n", "<leader>P", "\"+P", {desc="Paste from system clipboard above"})
vim.keymap.set("v", "<leader>P", "\"+P")

-- Yank to system clipboard
vim.keymap.set("n", "<leader>y", "\"+y", {desc="Yank to system clipboard"})
vim.keymap.set("v", "<leader>y", "\"+y")
vim.keymap.set("n", "<leader>Y", "\"+Y", {desc="Yank rest to system clipboard"})
vim.keymap.set("v", "<leader>Y", "\"+Y")

-- Delete without yanking
vim.keymap.set("n", "<leader>d", "\"_d", {desc="Delete (Don't save in register)"})
vim.keymap.set("v", "<leader>d", "\"_d")
vim.keymap.set("n", "<leader>D", "\"_D", {desc="Delete rest (Don't save in register)"})
vim.keymap.set("v", "<leader>D", "\"_D")

-- Open diagnostics
vim.keymap.set("n", "<leader>v", "<cmd> lua vim.diagnostic.open_float() <CR>", {desc="Open diagnostic in float window"})
