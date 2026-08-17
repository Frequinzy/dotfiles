(import-macros {: plugin!} :macros)
(local {: gh} (require :core.util))

(plugin! {:src (gh :martindur/zdiff.nvim)
          :setup (fn [zdiff] (zdiff.setup))
          :keys [{:mode :n :key :<leader>zd :action (fn [zdiff] zdiff.open) :desc "Zdiff (uncommitted)"}
                 {:mode :n
                  :key :<leader>zD
                  :action (fn [zdiff] #(zdiff.open :main))
                  :desc "Zdiff (main)"}]})
