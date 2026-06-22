(import-macros {: plugin!} :macros)
(local {: gh} (require :core.util))

(plugin! {:src (gh :saghen/blink.cmp)
          :version (vim.version.range "^1")
          :setup (fn [blink]
                   (blink.setup {:keymap {:preset :default}
                                 :appearance {:nerd_font_variant :mono}
                                 :sources {:default [:lsp
                                                     :path
                                                     :snippets
                                                     :buffer]}
                                 :fuzzy {:implementation :prefer_rust_with_warning}}))})
