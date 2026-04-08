return {
  'chomosuke/typst-preview.nvim',
  ft = 'typst',
  version = '1.*',
  opts = {
    open_cmd = 'firefox %s -P typst-preview --class typst-preview',
    follow_cursor = true,
    dependencies_bin = {
      ['tinymist'] = 'tinymist'
    }
  },
  keys = {
        { '<leader>ts', function() require('typst-preview').sync_with_cursor() end, desc = 'Sync typst preview with cursor' },
        { '<leader>tf', ":TypstPreviewFollowCursorToggle<CR>", desc = 'Toggle Follow Cursor' },
        { '<leader>tt', ":TypstPreviewToggle<CR>", desc = 'Toggle Preview' },
  },
}
