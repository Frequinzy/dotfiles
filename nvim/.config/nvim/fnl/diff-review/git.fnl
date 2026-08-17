;; All git I/O for diff-review lives here. Content-fetching calls are async
;; (`vim.system`) so opening the overview never blocks the UI; `refs` is the
;; one deliberate exception since :command completion must return
;; synchronously.
;;
;; All paths in and out of this module are repo-root-relative, matching
;; `git diff --name-status`'s (fixed) output convention -- `git ls-files`
;; needs `--full-name` to match it, since it's cwd-relative by default.
;; `root` is resolved once per :DiffReview invocation (not cached at require
;; time) since nvim's cwd can change between sessions/tabs.

(fn split-lines [s]
  "Split on newlines, preserving blank lines (unlike a `[^
]+` gmatch
  pattern, which silently drops them since `+` can't match zero chars).
  Drops a single trailing empty element from a final trailing newline, to
  match `vim.fn.readfile`'s line count for the same content."
  (let [parts (vim.split s "\n" {:plain true})]
    (if (= (. parts (length parts)) "")
        (do
          (table.remove parts)
          parts)
        parts)))

(fn split-tab [s]
  (vim.split s "\t" {:plain true}))

(fn root []
  "Sync: absolute path to the repo's working-tree root."
  (let [obj (: (vim.system [:git :rev-parse :--show-toplevel] {:text true})
               :wait)]
    (vim.trim obj.stdout)))

(fn parse-name-status [output]
  "Parse `git diff --name-status -M` output into {status old-path path}."
  (icollect [_ line (ipairs (split-lines output))]
    (let [fields (split-tab line)
          status (. fields 1)]
      (if (= (status:sub 1 1) :R)
          {:status :R :old-path (. fields 2) :path (. fields 3)}
          {: status :old-path (. fields 2) :path (. fields 2)}))))

(fn new-content [root path]
  "Sync: working-tree content of `path` off disk, or {} if it no longer
  exists there (deleted file)."
  (let [abs (.. root "/" path)]
    (if (= (vim.fn.filereadable abs) 1)
        (vim.fn.readfile abs)
        [])))

(fn parse-numstat-z [output]
  "Parse `git diff --numstat -M -z` output into {path -> {added deleted}},
  keyed by each entry's NEW path. Handles the -z rename encoding: a renamed
  file's <added>\\t<deleted>\\t segment has an empty trailing path field,
  immediately followed by two more NUL-terminated fields (old-path, new-
  path) instead of the usual single path field. Binary files report \"-\"
  for both counts, which `tonumber` turns into nil (no stats shown)."
  (let [tokens (vim.split output "\000" {:plain true})
        n (length tokens)
        stats {}]
    (var i 1)
    (while (<= i n)
      (let [tok (. tokens i)]
        (if (= tok "")
            (set i (+ i 1))
            (let [fields (split-tab tok)
                  added (tonumber (. fields 1))
                  deleted (tonumber (. fields 2))
                  path-field (. fields 3)]
              (if (= path-field "")
                  (do
                    (tset stats (. tokens (+ i 2)) {: added : deleted})
                    (set i (+ i 3)))
                  (do
                    (tset stats path-field {: added : deleted})
                    (set i (+ i 1))))))))
    stats))

(fn changed-files [root ref callback]
  "Async: callback([{status old-path path added deleted} ...]) for `ref` vs
  working tree, tracked changes plus untracked files (shown as status A).
  Paths are repo-root-relative. `added`/`deleted` are line counts (nil for
  binary files); untracked files count as entirely added, sync-read off
  disk since there's no git-tracked blob for numstat to diff against."
  (var tracked nil)
  (var untracked nil)
  (var stats nil)

  (fn maybe-done [] ; maybe-done is a manual join barrier for the three async git calls.
    (when (and tracked untracked stats)
      ;; Deferred as a whole, not just the final `callback` -- the
      ;; untracked-file branch below calls `new-content` (vim.fn.readfile),
      ;; and this runs inside a vim.system exit handler, a fast-event
      ;; context where Vimscript functions aren't allowed to run.
      (vim.schedule (fn []
                      (let [seen {}
                            files []]
                        (each [_ f (ipairs tracked)]
                          (tset seen f.path true)
                          (let [s (. stats f.path)]
                            (table.insert files
                                          {:status f.status
                                           :old-path f.old-path
                                           :path f.path
                                           :added (and s s.added)
                                           :deleted (and s s.deleted)})))
                        (each [_ path (ipairs untracked)]
                          (when (not (. seen path))
                            (table.insert files
                                          {:status :A
                                           :old-path path
                                           : path
                                           :added (length (new-content root
                                                                       path))
                                           :deleted 0})))
                        (callback files))))))

  (vim.system [:git :diff :--name-status :-M ref] {:cwd root :text true}
              (fn [obj]
                (set tracked (if (= obj.code 0)
                                 (parse-name-status (or obj.stdout ""))
                                 []))
                (maybe-done)))
  (vim.system [:git :ls-files :--others :--exclude-standard :--full-name]
              {:cwd root :text true}
              (fn [obj]
                (set untracked (if (= obj.code 0)
                                   (split-lines (or obj.stdout ""))
                                   []))
                (maybe-done)))
  (vim.system [:git :diff :--numstat :-M :-z ref] {:cwd root :text true}
              (fn [obj]
                (set stats (if (= obj.code 0)
                               (parse-numstat-z (or obj.stdout ""))
                               {}))
                (maybe-done))))

(fn old-content [root ref path callback]
  "Async: callback([line ...]) of `path` as it existed at `ref`, or {} if it
  didn't exist there (new/untracked file)."
  (vim.system [:git :show (.. ref ":" path)] {:cwd root :text true}
              (fn [obj]
                (vim.schedule #(callback (if (= obj.code 0)
                                             (split-lines (or obj.stdout ""))
                                             []))))))

(fn refs [root]
  "Sync: branch and tag names, for :DiffReview completion only."
  (let [branches (vim.system [:git :branch "--format=%(refname:short)"]
                             {:cwd root :text true})
        tags (vim.system [:git :tag] {:cwd root :text true})
        b (branches:wait)
        t (tags:wait)
        names []]
    (each [_ line (ipairs (if (= b.code 0) (split-lines (or b.stdout "")) []))]
      (table.insert names line))
    (each [_ line (ipairs (if (= t.code 0) (split-lines (or t.stdout "")) []))]
      (table.insert names line))
    names))

{: root : changed-files : old-content : new-content : refs}
