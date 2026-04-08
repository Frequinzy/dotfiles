(vim.lsp.enable "fennel_ls")
(vim.lsp.enable "ts_ls")
(vim.lsp.enable "svelte")

(vim.api.nvim_create_autocmd :LspAttach {:group (vim.api.nvim_create_augroup :lsp {})
                                         :callback (fn [args]
                                                     (let [client (assert (vim.lsp.get_client_by_id args.data.client_id) "Failed to find client_id")]
                                                       (when (client:supports_method "textDocument/completion")
                                                         (set vim.opt.completeopt ["preinsert" "menu" "menuone" "popup"])
                                                         (vim.lsp.completion.enable true client.id args.buf {:autotrigger true}))))})
