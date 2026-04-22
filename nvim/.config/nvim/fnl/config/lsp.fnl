(import-macros {: augroup!} :macros)

(vim.lsp.enable :fennel_ls)
(vim.lsp.enable :ts_ls)
(vim.lsp.enable :svelte)
(vim.lsp.enable :tinymist)

(vim.lsp.config :tinymist {:settings {:projectResolution :lockDatabase}})

(augroup! :lsp
          [:LspAttach
           {:callback (fn [args]
                        (let [client (assert (vim.lsp.get_client_by_id args.data.client_id)
                                             "Failed to find client_id")]
                          (when (client:supports_method :textDocument/completion)
                            (vim.lsp.completion.enable true client.id args.buf
                                                       {:autotrigger true}))))}])
