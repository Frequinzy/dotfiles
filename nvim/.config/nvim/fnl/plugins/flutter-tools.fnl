(import-macros {: plugin!} :macros)
(local {: gh} (require :core.util))

(plugin! {:src (gh :nvim-flutter/flutter-tools.nvim)
          :after [(gh :nvim-lua/plenary.nvim)]
          :setup (fn [flutter]
                   (flutter.setup {}))
          :keys [{:mode :n
                  :key :<leader>fr
                  :ft :dart
                  :action (fn [flutter] #(vim.cmd "FlutterRun"))
                  :desc "Flutter run"}
                 {:mode :n
                  :key :<leader>fq
                  :ft :dart
                  :action (fn [flutter] #(vim.cmd "FlutterQuit"))
                  :desc "Flutter quit"}
                 {:mode :n
                  :key :<leader>fR
                  :ft :dart
                  :action (fn [flutter] #(vim.cmd "FlutterReload"))
                  :desc "Flutter hot reload"}
                 {:mode :n
                  :key :<leader>fD
                  :ft :dart
                  :action (fn [flutter] #(vim.cmd "FlutterDevices"))
                  :desc "Flutter devices"}]})
