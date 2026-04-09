(vim.api.nvim_create_autocmd :PackChanged
                             {:callback (fn [ev]
                                          (let [name ev.data.spec.name
                                                kind ev.data.kind]
                                            (when (and (= name :nvim-treesitter) (= kind :update))
                                              (when (not ev.data.active)
                                                (vim.cmd.packadd :nvim-treesitter))
                                              (vim.cmd :TSUpdate))))})

(vim.pack.add ["https://github.com/olimorris/onedarkpro.nvim"
	       "https://github.com/stevearc/oil.nvim"
               "https://github.com/nvim-treesitter/nvim-treesitter"
	       "https://github.com/neovim/nvim-lspconfig"
	       "https://github.com/nvim-mini/mini.icons"])

(local icons (require "mini.icons"))
(icons.setup)

(local oil (require "oil"))
(oil.setup)
(vim.keymap.set "n" "-" oil.open)

(require :config.lsp)
(require :config.options)
(require :config.keymaps)
(require :config.treesitter)

(vim.cmd.colorscheme :onedark)
