(fn gh [repo] (.. "https://github.com/" repo))

(fn require-dir! [dir]
  (let [config (vim.fn.stdpath :config)
        pattern (.. config :/fnl/ dir :/*.fnl)
        files (vim.fn.glob pattern false true)]
    (each [_ path (ipairs files)]
      (let [mod-name (-> path
                         (: :gsub (.. config :/fnl/) "")
                         (: :gsub "%.fnl$" "")
                         (: :gsub "/" "."))]
        (require mod-name)))))

{: require-dir! : gh}
