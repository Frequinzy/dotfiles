;; The scratch overview buffer: fetch + hunk pipeline, full-rebuild render,
;; collapsing, sticky winbar header, and buffer-local keymaps. Every visible
;; line -- added, context, and deleted -- is a real buffer line, so deleted
;; blocks stay scrollable/searchable/selectable even when large; only added/
;; context lines get an entry in `line-map`, which is what keeps cursor
;; column math in `jump.fnl` a plain subtraction and makes deleted lines
;; simply not jump targets.
;;
;; Per-file content/hunks/syntax are fetched lazily, on first expand (see
;; `ensure-file-loaded`), not eagerly for every changed file -- this is what
;; keeps opening a large diff instant regardless of file count.

(local git (require :diff-review.git))
(local diff (require :diff-review.diff))
(local jump (require :diff-review.jump))
(local config (require :diff-review.config))
(local syntax (require :diff-review.syntax))

(local context-lines 3)
;; Must match jump.fnl's gutter-width -- both measure the same "+ "/"  "
;; prefix prepended to real overview lines.
(local gutter-width 2)
(local ns (vim.api.nvim_create_namespace :diff-review))

;; single active review; personal tool, no need to support more than one.
(var state nil)

(fn header-render [file]
  "Returns {:text :added-range :deleted-range} for one file's header line.
  `text` always starts with the plain '[status] path'/'[R] old -> new'
  text; the ranges are 0-indexed [start end) byte columns of the '+N'/'-N'
  stats suffix within `text` (matching the col-start/col-end convention
  `render` already uses for syntax-highlight extmarks), or nil until this
  file's line stats are loaded (they come from `git.changed-files`, so
  they're actually available immediately -- nil only covers the moment
  before that first callback resolves)."
  (let [base (if (= file.status :R)
                 (.. "[R] " file.old-path " -> " file.path)
                 (.. "[" file.status "] " file.path))]
    (if (and file.added file.deleted)
        (let [added (.. "+" file.added)
              deleted (.. "-" file.deleted)
              added-start (+ (length base) 2)
              added-end (+ added-start (length added))
              deleted-start (+ added-end 1)
              deleted-end (+ deleted-start (length deleted))]
          {:text (.. base "  " added " " deleted)
           :added-range [added-start added-end]
           :deleted-range [deleted-start deleted-end]})
        {:text base})))

(fn merge-intervals [intervals]
  (table.sort intervals (fn [a b] (< a.lo b.lo)))
  (let [merged []]
    (each [_ iv (ipairs intervals)]
      (let [last (. merged (length merged))]
        (if (and last (<= iv.lo (+ last.hi 1)))
            (set last.hi (math.max last.hi iv.hi))
            (table.insert merged {:lo iv.lo :hi iv.hi}))))
    merged))

(fn build-render-plan [new-lines hunks]
  "Expand vim.text.diff's change-only hunks with surrounding context and
  figure out where each hunk's deleted old-lines should be emitted as real
  lines relative to the surrounding added/context lines. Returns {:blocks
  [{lo hi} ...] :added-set :deletions :eof-deletions :whole-file-deleted}."
  (let [new-count (length new-lines)
        added-set {}
        deletions {}
        intervals []]
    (var eof-deletions nil)
    (var whole-file-deleted nil)
    (each [_ h (ipairs hunks)]
      (if (> h.new-count 0)
          (do
            (for [n h.new-start (+ h.new-start h.new-count -1)]
              (tset added-set n true))
            (table.insert intervals
                          {:lo (math.max 1 (- h.new-start context-lines))
                           :hi (math.min new-count
                                         (+ h.new-start h.new-count -1
                                            context-lines))})
            (when (> h.old-count 0)
              (tset deletions h.new-start (or (. deletions h.new-start) []))
              (each [_ l (ipairs h.old-lines)]
                (table.insert (. deletions h.new-start) l))))
          (do
            (table.insert intervals
                          {:lo (math.max 1 (- h.new-start context-lines))
                           :hi (math.min new-count
                                         (+ h.new-start context-lines))})
            (let [target (+ h.new-start 1)]
              (if (= new-count 0)
                  (set whole-file-deleted
                       (vim.list_extend (or whole-file-deleted []) h.old-lines))
                  (if (<= target new-count)
                      (do
                        (tset deletions target (or (. deletions target) []))
                        (vim.list_extend (. deletions target) h.old-lines))
                      (set eof-deletions
                           (vim.list_extend (or eof-deletions []) h.old-lines))))))))
    {:blocks (if (= (length intervals) 0) [] (merge-intervals intervals))
     : added-set
     : deletions
     : eof-deletions
     : whole-file-deleted}))

(fn emit-deletions [old-lines lines line-file idx extmarks]
  "Appends `old-lines` as real, non-jumpable buffer lines (prefixed and
  highlighted like a deletion) -- unlike an added/context line, these never
  get a `line-map` entry, so <CR>/<C-CR> on one is just a no-op."
  (each [_ l (ipairs old-lines)]
    (table.insert lines (.. "- " l))
    (tset line-file (length lines) idx)
    (table.insert extmarks
                  {:line (length lines) :hl :DiffDelete :whole-line true})))

(fn restore-pending-cursor [line-map]
  (let [target state.pending-cursor-target]
    (when target
      (var found nil)
      (each [lnum t (pairs line-map)]
        (when (and (not found) (= t.file-idx target.file-idx)
                   (= t.source-line target.source-line))
          (set found lnum)))
      (when found
        (pcall vim.api.nvim_win_set_cursor 0 [found 0])
        (set state.pending-cursor-target nil)))))

(fn render []
  (let [lines []
        line-map {}
        line-file {}
        file-header-lines {}
        extmarks []]
    (var truncated false)
    (each [idx file (ipairs state.files)]
      (when (not truncated)
        (let [{: text : added-range : deleted-range} (header-render file)]
          (table.insert lines text)
          (tset file-header-lines idx (length lines))
          (tset line-file (length lines) idx)
          ;; :Title is split around the +N/-M ranges (rather than left as a
          ;; single whole-line extmark that happens to overlap them) so it
          ;; never competes with DiffAdd/DiffDelete for those columns --
          ;; layering two overlapping highlight extmarks and hoping
          ;; priority/insertion order resolves in our favor would be a
          ;; guess; not covering the columns at all isn't.
          (if (and added-range deleted-range)
              (let [[as ae] added-range
                    [ds de] deleted-range]
                (table.insert extmarks
                              {:line (length lines) :hl :Title :col-start 0
                               :col-end as})
                (table.insert extmarks
                              {:line (length lines) :hl :DiffAdd
                               :col-start as :col-end ae})
                (table.insert extmarks
                              {:line (length lines) :hl :Title :col-start ae
                               :col-end ds})
                (table.insert extmarks
                              {:line (length lines) :hl :DiffDelete
                               :col-start ds :col-end de}))
              (table.insert extmarks
                            {:line (length lines) :hl :Title :whole-line true})))
        (if (not (. state.expanded idx))
            nil
            (if (not file.hunks)
                (do
                  (table.insert lines "  Loading…")
                  (tset line-file (length lines) idx))
                (let [plan (build-render-plan file.new-lines file.hunks)]
                  (when plan.whole-file-deleted
                    (emit-deletions plan.whole-file-deleted lines line-file
                                    idx extmarks))
                  (each [bi block (ipairs plan.blocks)]
                    (when (> bi 1)
                      (let [prev (. plan.blocks (- bi 1))]
                        (when (> block.lo (+ prev.hi 1))
                          (table.insert lines "  ⋯")
                          (tset line-file (length lines) idx)
                          (table.insert extmarks
                                        {:line (length lines)
                                         :hl :Comment
                                         :whole-line true}))))
                    (for [n block.lo block.hi]
                      (let [del (. plan.deletions n)]
                        (when del
                          (emit-deletions del lines line-file idx extmarks)))
                      (let [added (. plan.added-set n)
                            prefix (if added "+ " "  ")
                            text (.. prefix (. file.new-lines n))]
                        (table.insert lines text)
                        (tset line-map (length lines)
                              {:file-idx idx :source-line n})
                        (tset line-file (length lines) idx)
                        (when added
                          (table.insert extmarks
                                        {:line (length lines)
                                         :hl :DiffAdd
                                         :whole-line true}))
                        (when file.syntax-new
                          (each [_ cap (ipairs (or (. file.syntax-new (- n 1))
                                                   []))]
                            (table.insert extmarks
                                          {:line (length lines)
                                           :hl cap.hl
                                           :col-start (+ gutter-width
                                                         cap.col-start)
                                           :col-end (+ gutter-width cap.col-end)}))))))
                  (when plan.eof-deletions
                    (emit-deletions plan.eof-deletions lines line-file idx
                                    extmarks)))))
        (when (>= (length lines) config.max-lines)
          (table.insert lines "  ... truncated (max-lines reached) ...")
          (set truncated true))))
    (vim.api.nvim_set_option_value :modifiable true {:buf state.buf})
    (vim.api.nvim_buf_set_lines state.buf 0 -1 false lines)
    (vim.api.nvim_buf_clear_namespace state.buf ns 0 -1)
    (each [_ em (ipairs extmarks)]
      (let [row (- em.line 1)]
        (if em.col-start
            (vim.api.nvim_buf_set_extmark state.buf ns row em.col-start
                                          {:end_col em.col-end :hl_group em.hl})
            (vim.api.nvim_buf_set_extmark state.buf ns row 0
                                          {:line_hl_group em.hl}))))
    (vim.api.nvim_set_option_value :modifiable false {:buf state.buf})
    (set state.line-map line-map)
    (set state.line-file line-file)
    (set state.file-header-lines file-header-lines)
    (restore-pending-cursor line-map)))

(fn nearest-header [win]
  "The file whose header has scrolled above the window's top visible line,
  if any -- strictly `<` so the sticky winbar stays empty while the header
  itself is still on screen, instead of redundantly repeating it."
  (let [top (vim.fn.line :w0 win)]
    (var best nil)
    (each [idx lnum (pairs state.file-header-lines)]
      (when (and (< lnum top)
                 (or (not best) (> lnum (. state.file-header-lines best))))
        (set best idx)))
    best))

(fn update-winbar [win]
  (when (and state (vim.api.nvim_win_is_valid win))
    (let [idx (nearest-header win)]
      (tset (. vim.wo win) :winbar
            (if (not idx)
                ""
                (let [{: text : added-range : deleted-range}
                      (header-render (. state.files idx))]
                  (if (and added-range deleted-range)
                      (let [[as ae] added-range
                            [ds de] deleted-range]
                        (.. "%#Title#" (text:sub 1 as)
                            "%#DiffAdd#" (text:sub (+ as 1) ae)
                            "%#Title#" (text:sub (+ ae 1) ds)
                            "%#DiffDelete#" (text:sub (+ ds 1) de)
                            "%#Title#" (text:sub (+ de 1)) "%*"))
                      (.. "%#Title#" text "%*"))))))))

(fn ensure-file-loaded [idx]
  "No-ops if `file.hunks` is already computed or a load is already in
  flight -- safe to call redundantly (e.g. rapid toggle-off/toggle-on)."
  (let [file (. state.files idx)]
    (when (and file (not file.hunks) (not file.loading))
      (set file.loading true)
      (let [root state.root
            ref state.ref]
        (git.old-content root ref file.old-path
                         (fn [old-lines]
                           (let [new-lines (git.new-content root file.path)
                                 hunks (diff.compute-hunks old-lines new-lines)]
                             (set file.old-lines old-lines)
                             (set file.new-lines new-lines)
                             (set file.hunks hunks)
                             (set file.loading nil)
                             (when (= config.syntax-mode :projection)
                               (set file.syntax-new
                                    (syntax.highlights-for new-lines file.path)))
                             (when state (render)))))))))

(fn load-expanded [files expanded]
  (each [idx _ (ipairs files)]
    (when (. expanded idx)
      (ensure-file-loaded idx))))

(fn refresh []
  (when state
    (let [cursor-lnum (. (vim.api.nvim_win_get_cursor 0) 1)
          root state.root
          ref state.ref
          old-files state.files
          old-expanded state.expanded]
      (set state.pending-cursor-target (. state.line-map cursor-lnum))
      (git.changed-files root ref
                         (fn [files]
                           (when state
                             (let [expanded {}]
                               (each [idx f (ipairs files)]
                                 (var carried config.default-expanded)
                                 (each [old-idx old-f (ipairs old-files)]
                                   (when (= old-f.path f.path)
                                     (set carried (. old-expanded old-idx))))
                                 (tset expanded idx carried))
                               (set state.files files)
                               (set state.expanded expanded)
                               (render)
                               (update-winbar (vim.api.nvim_get_current_win))
                               (load-expanded files expanded))))))))

(fn toggle-at-cursor []
  (let [lnum (. (vim.api.nvim_win_get_cursor 0) 1)
        idx (. state.line-file lnum)]
    (when idx
      (tset state.expanded idx (not (. state.expanded idx)))
      (when (. state.expanded idx)
        (ensure-file-loaded idx))
      (render)
      (let [new-lnum (or (. state.file-header-lines idx) 1)]
        (pcall vim.api.nvim_win_set_cursor 0 [new-lnum 0])))))

(fn goto-at-cursor [diffmode?]
  (let [[lnum col] (vim.api.nvim_win_get_cursor 0)
        target (jump.resolve state.line-map lnum col)]
    (when target
      (if diffmode?
          ((. (require :diff-review.splitdiff) :open) state.root state.ref
                                                      state.files target
                                                      state.tab)
          (jump.open-file state.root state.files target)))))

(fn close []
  (when (and state (vim.api.nvim_buf_is_valid state.buf))
    (let [buf state.buf]
      (set state nil)
      (pcall vim.cmd.tabclose)
      ;; bufhidden=hide (needed so <CR>/<C-o> can round-trip through the
      ;; overview) means the buffer survives losing its last window --
      ;; :tabclose alone won't destroy it, so `q` must delete it explicitly
      ;; or the next :DiffReview collides on the "diff-review" buffer name.
      (when (vim.api.nvim_buf_is_valid buf)
        (vim.api.nvim_buf_delete buf {:force true})))))

(fn show-help []
  (vim.notify (.. "diff-review: " config.keymaps.goto-file " goto  "
                  config.keymaps.goto-file-diffmode " goto (diff-mode)  "
                  config.keymaps.toggle " toggle  " config.keymaps.refresh
                  " refresh  " config.keymaps.close " close")))

(fn setup-keymaps [buf]
  (let [opts {:buffer buf :silent true :nowait true}]
    (vim.keymap.set :n config.keymaps.goto-file #(goto-at-cursor false)
                    (vim.tbl_extend :force opts
                                    {:desc "Diff review: goto file"}))
    (vim.keymap.set :n config.keymaps.goto-file-diffmode #(goto-at-cursor true)
                    (vim.tbl_extend :force opts
                                    {:desc "Diff review: goto file (diff-mode)"}))
    (vim.keymap.set :n config.keymaps.toggle toggle-at-cursor
                    (vim.tbl_extend :force opts {:desc "Diff review: toggle"}))
    (vim.keymap.set :n config.keymaps.close close
                    (vim.tbl_extend :force opts {:desc "Diff review: close"}))
    (vim.keymap.set :n config.keymaps.refresh #(refresh)
                    (vim.tbl_extend :force opts {:desc "Diff review: refresh"}))
    (vim.keymap.set :n config.keymaps.help show-help
                    (vim.tbl_extend :force opts {:desc "Diff review: help"}))))

(fn ensure-buf []
  (if (and state (vim.api.nvim_buf_is_valid state.buf))
      state.buf
      (let [buf (vim.api.nvim_create_buf false true)]
        (vim.api.nvim_set_option_value :buftype :nofile {: buf})
        (vim.api.nvim_set_option_value :bufhidden :hide {: buf})
        (vim.api.nvim_set_option_value :swapfile false {: buf})
        (vim.api.nvim_buf_set_name buf :diff-review)
        (setup-keymaps buf)
        (vim.api.nvim_create_autocmd [:CursorMoved :WinScrolled]
                                     {:buffer buf
                                      :callback (fn []
                                                  (update-winbar (vim.api.nvim_get_current_win)))})
        buf)))

(fn open [ref]
  (let [root (git.root)
        buf (ensure-buf)]
    (set state {: buf
                : root
                : ref
                :files []
                :expanded {}
                :line-map {}
                :line-file {}
                :file-header-lines {}})
    (vim.cmd.tabnew)
    (set state.tab (vim.api.nvim_get_current_tabpage))
    (vim.api.nvim_set_current_buf buf)
    ;; No line numbers -- overview-buffer line numbers don't correspond to
    ;; anything in the real files. Also strip sign/fold columns: `winbar`
    ;; doesn't reserve gutter space the way the text area does, so any
    ;; gutter left enabled here (e.g. from gitsigns/diagnostics config)
    ;; would push buffer text right of the winbar's flush-left text by
    ;; whatever width that gutter happens to be.
    (let [win (vim.api.nvim_get_current_win)]
      (tset (. vim.wo win) :number false)
      (tset (. vim.wo win) :relativenumber false)
      (tset (. vim.wo win) :signcolumn :no)
      (tset (. vim.wo win) :foldcolumn "0")
      (tset (. vim.wo win) :statuscolumn ""))
    (git.changed-files root ref
                       (fn [files]
                         (when state
                           (let [expanded {}]
                             (each [idx _ (ipairs files)]
                               (tset expanded idx config.default-expanded))
                             (set state.files files)
                             (set state.expanded expanded)
                             (render)
                             (update-winbar (vim.api.nvim_get_current_win))
                             (load-expanded files expanded)))))))

{: open : refresh : close}
