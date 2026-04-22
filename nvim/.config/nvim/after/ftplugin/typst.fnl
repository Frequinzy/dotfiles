(set vim.opt_local.wrap true)
(set vim.opt_local.spell true)
(set vim.opt_local.linebreak true)
(set vim.opt_local.breakindent true)

(fn vmove [normal visual]
  (fn []
    (if (> vim.v.count 0)
        normal
        visual)))

(vim.keymap.set [:n :v] :<leader>p "\"+p" {:desc "Paste from system clipboard"})
(vim.keymap.set [:n :x] :j (vmove :j :gj)
                {:buffer true :expr true :silent true})

(vim.keymap.set [:n :x] :k (vmove :k :gk)
                {:buffer true :expr true :silent true})

(vim.keymap.set [:n :x] :0 :g0 {:buffer true :silent true})

(vim.keymap.set [:n :x] "$" :g$ {:buffer true :silent true})
