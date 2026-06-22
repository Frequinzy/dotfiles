(import-macros {: plugin!} :macros)
(local {: gh} (require :core.util))

(plugin! {:src (gh :chomosuke/typst-preview.nvim)
          :setup (fn [tp]
                   (tp.setup {:open_cmd "firefox %s -P typst-preview --new-instance --class typst-preview"
                              :follow_cursor true
                              :extra_args [:--verbose]
                              :dependencies_bin {:tinymist :tinymist}}))
          :keys [{:mode :n
                  :key :<leader>ts
                  :action (fn [tp] tp.sync_with_cursor)
                  :desc "Sync Typst preview with cursor"}
                 {:mode :n
                  :key :<leader>tf
                  :action (fn [_] #(vim.cmd :TypstPreviewFollowCursorToggle))
                  :desc "Toggle follow cursor"}
                 {:mode :n
                  :key :<leader>tt
                  :action (fn [_] #(vim.cmd :TypstPreview))
                  :desc "Toggle Typst preview"}]})
