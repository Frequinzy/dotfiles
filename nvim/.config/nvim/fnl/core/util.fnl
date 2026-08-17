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

(fn copy-ref [{: visual}]
  (when visual
    (vim.cmd "normal! \x1b"))
  (let [path (vim.fn.expand "%:.")
        visual-selection (or (when visual
                               (.. ":" (vim.fn.line "'<") "-"
                                   (vim.fn.line "'>")))
                             "")
        note (let [prompt (vim.fn.input "Prompt (optional):")]
              (if (= prompt "") "" (.. " " prompt)))
        ref (.. path visual-selection note)]
    (vim.fn.setreg "+" ref)
    (vim.notify (.. "Copied: " ref))))

{: require-dir! : gh : copy-ref}
