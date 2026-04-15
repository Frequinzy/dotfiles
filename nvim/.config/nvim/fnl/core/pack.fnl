(import-macros {: augroup!} :macros)
(local registry [])
(local registered {})

(fn src->name [src]
  (let [base (src:match "[^/]+$")]
    (or (base:match "^(.+)%.nvim$")
        base)))

(fn add! [spec]
  (when (not (. registered spec.src))
    (set (. registered spec.src) true)
    (let [name (or spec.name (src->name spec.src))
               spec (vim.tbl_extend :force spec {:name name})]
      (table.insert registry spec))))

(fn deps-done? [done spec]
  (if (not spec.after)
      true
      (do (var all-done true)
        (each [_ dep (ipairs spec.after)]
          (when (not (. done dep))
            (set all-done false)))
        all-done)))

(fn sort-by-deps [specs]
  (local done {})
  (local sorted [])
  (var changed true)
  (while changed
    (set changed false)
    (each [_ spec (ipairs specs)]
      (when (and (deps-done? done spec)
                 (not (. done spec.src)))
        (table.insert sorted spec)
        (set (. done spec.src) true)
        (set changed true))))
  sorted)

(fn register-builds [specs]
  (augroup! :pack-build 
            [:PackChanged 
              {:callback (fn [ev]
                           (let [name ev.data.spec.name]
                             (each [_ spec (ipairs specs)]
                               (when (and (= spec.name name) spec.build)
                                 (when (not ev.data.active)
                                   (vim.cmd.packadd name))
                                 (spec.build ev)))))}]))

(fn add-specs-vim-pack [specs]
  (vim.pack.add (icollect [_ spec (ipairs specs)]
                  (if spec.version
                      {:src spec.src :version spec.version}
                      spec.src))))

(fn run-setups [specs]
  (each [_ spec (ipairs specs)]
    (when spec.setup
      (let [module (require spec.name)]
        (spec.setup module)))))

(fn add-keybinds [specs]
  (each [_ spec (ipairs specs)]
    (when spec.keys
      (let [module (require spec.name)]
        (each [_ km (ipairs spec.keys)]
          (vim.keymap.set km.mode km.key (km.action module)
                          {:desc km.desc :silent true}))))))

(fn bootstrap! []
  (let [sorted (sort-by-deps registry)]
    (register-builds sorted)
    (add-specs-vim-pack sorted)
    (run-setups sorted)
    (add-keybinds sorted)))

{: add! : bootstrap!}
