(import-macros {: plugin!} :macros)
(local {: gh} (require :core.util))

(plugin! {:src (gh "olimorris/onedarkpro.nvim")
         :setup #(vim.cmd.colorscheme :onedark)})
