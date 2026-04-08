(vim.keymap.set ["n" "v"] "<leader>p" "\"+p" {:desc "Paste from system clipboard"})
(vim.keymap.set ["n" "v"] "<leader>P" "\"+P" {:desc "Paste above from system clipboard"})

(vim.keymap.set ["n" "v"] "<leader>y" "\"+y" {:desc "Yank to system clipboard"})
(vim.keymap.set ["n" "v"] "<leader>Y" "\"+Y" {:desc "Yank rest of line to system clipboard"})

(vim.keymap.set "n" "<leader>dd" vim.diagnostic.open_float)
