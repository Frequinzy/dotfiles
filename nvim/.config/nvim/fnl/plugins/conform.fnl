(import-macros {: plugin!} :macros)
(local {: gh} (require :core.util))

(plugin! {:src (gh :stevearc/conform.nvim)
          :setup (fn [cf]
                   (cf.setup {:formatters_by_ft {:rust [:rustfmt]
                                                 :fennel [:fnlfmt]
                                                 :javascript [:prettier]
                                                 :typescript [:prettier]
                                                 :svelte [:prettier]
                                                 :go [:gofmt]
                                                 :templ {:templ {:command "go tool templ fmt"}}
                                                 :sql [:pg_format]
                                                 :python [:ruff_format]}}))
          :keys [{:mode :n
                  :key :<leader>c
                  :action (fn [cf]
                            #(cf.format {:async true :lsp_fallback true}))
                  :desc "Format buffer"}]})
