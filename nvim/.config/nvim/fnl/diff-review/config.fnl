(local default-expanded false)
(local default-branch :main)
(local keymaps {:goto-file :<CR>
                :goto-file-diffmode :<C-CR>
                :toggle :<Tab>
                :close :q
                :refresh :R
                :help "?"})

(local syntax-mode :projection)

; or :hunk for lower overhead on huge files
(local max-lines 8000)

{: default-expanded : default-branch : keymaps : syntax-mode : max-lines}
