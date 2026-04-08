return {
  'nvim-treesitter/nvim-treesitter',
  lazy = false,
  build = ':TSUpdate',
  config = function ()
    local parsers = {
      'lua',
      'rust',
      'clojure',
      'java',
      'svelte',
      'typescript',
      'css',
      'html',
      'vim',
      'vimdoc'
    }

    require('nvim-treesitter').install(parsers)

    vim.api.nvim_create_autocmd('FileType', {
      pattern = parsers,
      callback = function()
        vim.treesitter.start()
      end,
    })
  end
}
