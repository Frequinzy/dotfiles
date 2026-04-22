(import-macros {: plugin!} :macros)
(local {: gh} (require :core.util))

(plugin! {:src (gh :nvim-mini/mini.icons) :setup #($1.setup)})
