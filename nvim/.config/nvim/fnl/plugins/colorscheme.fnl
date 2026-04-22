(import-macros {: plugin!} :macros)
(local {: gh} (require :core.util))

(fn set-line-number-colors []
  (let [color "#e83d84"]
    (vim.api.nvim_set_hl 0 :LineNrAbove {:fg color :bold true})
    (vim.api.nvim_set_hl 0 :LineNr {:fg :white :bold true})
    (vim.api.nvim_set_hl 0 :LineNrBelow {:fg color :bold true})))

(plugin! {:src (gh :olimorris/onedarkpro.nvim)
          :priority 1000
          :setup (fn []
                   (vim.cmd.colorscheme :onedark)
                   (set-line-number-colors))})
