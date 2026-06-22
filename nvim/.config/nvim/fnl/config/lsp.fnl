(import-macros {: augroup!} :macros)

(vim.lsp.enable :fennel_ls)
(vim.lsp.enable :ts_ls)
(vim.lsp.enable :svelte)
(vim.lsp.enable :tinymist)
(vim.lsp.enable :rust_analyzer)
(vim.lsp.enable :gopls)
(vim.lsp.enable :templ)
(vim.lsp.enable :posgres_lsp)

(vim.lsp.config :tinymist
                {:settings {:projectResolution :lockDatabase}
                 :root_markers [:main.typ :tinymist.lock :.git]})

(vim.lsp.config :templ {:cmd [:go :tool :templ :lsp]})
