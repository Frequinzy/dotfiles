return {
  'julienvincent/nvim-paredit',
  config = function(_, _)
    local paredit = require("nvim-paredit")
    paredit.setup({
      keys = {
        ['<leader>s'] = { paredit.api.slurp_forwards, 'Slurp forward' },
        ['<leader>b'] = { paredit.api.barf_forwards, 'Barf forward' },
      },
    })
  end,
  ft = { 'clojure', 'fennel', 'racket', 'scheme', },
  lazy = true,
}
