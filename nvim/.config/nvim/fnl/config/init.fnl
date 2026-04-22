(import-macros {: augroup!} :macros)

(require :config.options)
(require :config.lsp)
(require :config.keymaps)

(augroup! :trailing-whitespace
          [:BufWritePre
           {:pattern "*"
            :callback (fn []
                        (let [view (vim.fn.winsaveview)]
                          (vim.cmd "keeppatterns %s/\\s\\+$//e")
                          (vim.fn.winrestview view)))}])

(let [{: require-dir!} (require :core.util)]
  (require-dir! :plugins))

(let [{: bootstrap!} (require :core.pack)]
  (bootstrap!))
