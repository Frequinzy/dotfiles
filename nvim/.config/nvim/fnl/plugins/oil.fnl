(import-macros {: plugin!} :macros)
(local {: gh} (require :core.util))

(plugin! {:src (gh :stevearc/oil.nvim)
          :setup #($1.setup)
          :after [(gh :nvim-mini/mini.icons)]
          :keys [{:mode :n :key "-" :action (fn [o] o.open) :desc "Opens oil"}]})
