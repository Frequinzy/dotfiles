(import-macros {: plugin!} :macros)
(local {: gh} (require :core.util))

(plugin! {:src (gh :stevearc/conform.nvim)
          :setup (fn [cf]
                   (cf.setup {:formatters_by_ft {:rust [:rustfmt]
                                                 :fennel [:fnlfmt]
                                                 :javascript [:prettier]
                                                 :typescript [:prettier]
                                                 :svelte [:prettier]
                                                 :go [:gofmt]}}))
          :keys [{:mode :n
                  :key :<leader>cf
                  :action (fn [cf]
                            #(cf.format {:async true :lsp_fallback true}))
                  :desc "Format buffer"}]})
