return {
  'windwp/nvim-autopairs',
  ft = { 'clojure', 'fennel', 'racket', 'scheme', },
  lazy = true,
  opts = {
    check_ts = true,
    enable_check_bracket_line = false,
  },
  config = true,
}
