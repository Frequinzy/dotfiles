(import-macros {: plugin!} :macros)
(local {: gh} (require :core.util))

(plugin! {:src (gh :ibhagwan/fzf-lua)
          :setup (fn [fzf]
                   (fzf.setup {:winopts {:border :rounded
                                         :preview {:layout :vertical
                                                   :vertical "down:50%"}}}))
          :keys [{:mode :n
                  :key :<leader>ff
                  :action (fn [fzf] #(fzf.files))
                  :desc "Find files"}
                 {:mode :n
                  :key :<leader>fg
                  :action (fn [fzf] #(fzf.live_grep))
                  :desc "Live grep"}
                 {:mode :n
                  :key :<leader>fh
                  :action (fn [fzf] #(fzf.help_tags))
                  :desc "Help tags"}]})
