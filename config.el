;;; config.el -*- lexical-binding: t; -*-
;;
;; Migrated from Emacs Prelude sean-config.el → Doom Emacs
;; Backup at ~/.emacs.d.prelude-backup/

;; ============================================================
;;  0. Windows: force UTF-8 for external processes (rg, git, etc.)
;; ============================================================

(prefer-coding-system 'utf-8-unix)
(set-default-coding-systems 'utf-8-unix)

(add-to-list 'process-coding-system-alist '("rg" utf-8 . utf-8))
(add-to-list 'process-coding-system-alist '("git" utf-8 . utf-8))
(add-to-list 'process-coding-system-alist '("fd" utf-8 . utf-8))

;; NOTE: SPC s f (locate) unavailable on Windows, use SPC SPC instead

;; Disable evil mouse drag to avoid CJK font rendering crash
(after! evil
  (define-key evil-normal-state-map [down-mouse-1] nil)
  (define-key evil-motion-state-map [down-mouse-1] nil))

;; ============================================================
;;  1. User info
;; ============================================================

(setq user-full-name "Sean Chen"
      user-mail-address "yuanxiang424@gmail.com")

;; ============================================================
;;  2. Fonts — Maple Mono NF CN (中英等宽，自带 CJK + Nerd Font)
;; ============================================================

(defun my/first-available-font (candidates)
  "Return the first font family from CANDIDATES that is available."
  (catch 'found
    (dolist (font candidates)
      (when (find-font (font-spec :family font))
        (throw 'found font)))
    nil))

(setq doom-font (font-spec :family "Maple Mono NF CN" :size 17)
      doom-variable-pitch-font (font-spec :family "LXGW WenKai Screen" :size 19)
      doom-big-font (font-spec :family "Maple Mono NF CN" :size 24))

;; CJK + emoji fontset (after GUI frame is ready)
(defun my/setup-cjk-fonts (&optional _frame)
  "Configure CJK and emoji fonts for Doom."
  (when (display-graphic-p)
    (let ((cjk-font (my/first-available-font
                     '("等距更纱黑体 SC" "Sarasa Mono SC"
                       "霞鹜文楷等宽" "LXGW WenKai Mono"
                       "Microsoft YaHei UI" "Microsoft YaHei"
                       "Noto Sans SC"))))
      (when cjk-font
        (dolist (charset '(kana han cjk-misc bopomofo))
          (set-fontset-font t charset (font-spec :family cjk-font) nil 'prepend))
        (setq face-font-rescale-alist
              (list (cons (regexp-quote cjk-font) 1.0)))))

    (let ((emoji-font (my/first-available-font
                       '("Segoe UI Emoji" "Apple Color Emoji" "Noto Color Emoji")))
          (symbol-font (my/first-available-font
                        '("Segoe UI Symbol" "Apple Symbols" "Symbola"))))
      (when emoji-font
        (set-fontset-font t 'emoji (font-spec :family emoji-font) nil 'prepend))
      (when symbol-font
        (set-fontset-font t 'symbol (font-spec :family symbol-font) nil 'prepend)))))

(add-hook 'after-setting-font-hook #'my/setup-cjk-fonts)
(add-hook 'doom-init-ui-hook #'my/setup-cjk-fonts)

;; ============================================================
;;  3. Theme
;; ============================================================

;; (setq doom-theme 'modus-operandi)
(setq doom-theme 'modus-operandi-tinted)

;; ============================================================
;;  4. Windows-specific performance tuning
;; ============================================================

(when (featurep :system 'windows)
  ;; VC / Git
  (setq auto-revert-check-vc-info nil
        auto-revert-interval 10
        vc-handled-backends '(Git)
        vc-git-annotate-switches "-w")

  ;; Process creation
  (setq w32-pipe-read-delay 0
        w32-pipe-buffer-size (* 64 1024)
        process-adaptive-read-buffering nil)

  ;; File I/O
  (setq inhibit-compacting-font-caches t
        w32-get-true-file-attributes nil)

  ;; Rendering (only what Doom doesn't set)
  (setq jit-lock-defer-time 0.05)

  ;; Long lines (Emacs 29+)
  (when (boundp 'long-line-threshold)
    (setq long-line-threshold 1000
          large-hscroll-threshold 1000
          syntax-wholeline-max 1000))

  ;; Large files: disable font-lock for >512KB
  (add-hook 'find-file-hook
            (lambda ()
              (when (> (buffer-size) (* 512 1024))
                (fundamental-mode)
                (font-lock-mode -1)
                (message "WARN: large file; disabled font-lock"))))

  ;; pdf-tools: MSYS2 epdfinfo
  (setenv "PATH" (concat "C:\\Users\\fengxing.chen\\scoop\\apps\\msys2\\current\\mingw64\\bin" ";" (getenv "PATH")))
  (setq pdf-info-epdfinfo-program "C:\\Users\\fengxing.chen\\scoop\\apps\\msys2\\current\\mingw64\\bin\\epdfinfo.exe"))

;; ============================================================
;;  5. General settings
;; ============================================================

(setq system-time-locale "C")

;; ============================================================
;;  6. Org-mode — core workflow
;; ============================================================

(setq org-directory "~/org")

(after! org
  (require 'org-protocol)
  (require 'org-habit)

  (setq org-habit-graph-column 50
        org-habit-preceding-days 21
        org-habit-following-days 7
        org-habit-show-habits-only-for-today nil)

  ;; Todo keywords
  (setq org-todo-keywords
        '((sequence "TODO(t)" "NEXT(n)" "WAITING(w!)" "HOLD(h@/!)" "|" "DONE(d!)" "CANCELLED(c@)")))
  (setq org-todo-keyword-faces
        '(("TODO"      :foreground "#2952a3" :weight bold)
          ("NEXT"      :foreground "#c0392b" :weight bold)
          ("WAITING"   :foreground "#8b6914" :weight bold)
          ("HOLD"      :foreground "#6c6c6c" :weight bold)
          ("DONE"      :foreground "#2e7d32" :weight bold)
          ("CANCELLED" :foreground "#9e9e9e" :weight bold)))

  (setq org-log-done 'time
        org-log-into-drawer t)

  ;; Display (only set what Doom doesn't already handle)
  (setq org-confirm-babel-evaluate nil
        org-return-follows-link t
        org-startup-folded 'content
        org-hide-emphasis-markers t
        org-ellipsis " ▾")

  ;; Inline images
  (setq image-use-external-converter t
        org-image-actual-width '(600))

  ;; ---- org-attach: 统一附件管理 ----
  (require 'org-attach)
  (setq org-attach-id-dir (expand-file-name "data/" org-directory)
        org-attach-method 'cp
        org-attach-use-inheritance t
        org-attach-store-link-p 'attached
        org-attach-auto-tag nil)

  ;; Fix attachment 链接中文乱码
  (defun my/org-attach-store-link-decoded (&rest _)
    "Fix stored links from `org-attach-attach' to include decoded description."
    (when org-stored-links
      (let ((latest (car org-stored-links)))
        (when (and (stringp (car latest))
                   (string-prefix-p "attachment:" (car latest))
                   (or (null (cadr latest)) (string= (cadr latest) "")))
          (setcar (cdr latest)
                  (decode-coding-string
                   (url-unhex-string
                    (file-name-nondirectory
                     (substring (car latest) (length "attachment:"))))
                   'utf-8))))))
  (advice-add 'org-attach-attach :after #'my/org-attach-store-link-decoded)

  ;; Agenda
  (setq org-agenda-inhibit-startup t
        org-agenda-tags-column -200)
        (setq org-agenda-files '("~/org/inbox.org"
                                 "~/org/append-note.org"
                                 "~/org/projects/"
                                 "~/org/areas/"
                                 "~/org/.calendar"))
  (setq org-default-notes-file "~/org/inbox.org")

  ;; Archive
  (setq org-archive-location
        (concat (expand-file-name ".archive/" org-directory)
                "%s_archive.org::"))

  ;; Time grid in agenda
  (setq org-agenda-use-time-grid t
        org-agenda-show-current-time-in-grid t
        org-agenda-time-grid
        '((daily today)
          (600 800 1000 1200 1400 1600 1800 2000 2200)
          " ┄┄┄┄┄ " "┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄")
        org-agenda-current-time-string
        "◀── now ─────────────────────")

  ;; ---- Append Note helper ----
  (defun my/append-note-goto-bottom ()
    "Move point to end of append-note.org with date separator."
    (let ((today-sep (format-time-string "-- %Y-%m-%d --")))
      (goto-char (point-max))
      (unless (save-excursion
                (goto-char (point-min))
                (search-forward today-sep nil t))
        (unless (bolp) (insert "\n"))
        (insert "\n" today-sep "\n")))
    (goto-char (point-max)))

  (defun my/append-note-open-at-end-h ()
    "Always place point at the end when visiting append-note.org."
    (when (and buffer-file-name
               (file-equal-p buffer-file-name
                             (expand-file-name "~/org/append-note.org")))
      (goto-char (point-max))))

  (add-hook 'find-file-hook #'my/append-note-open-at-end-h t)

  ;; ---- Habit capture helper ----
  (defun my/org-capture-habit ()
    "Generate a capture template for a habit."
    (let* ((name (read-string "Habit 名称: "))
           (raw  (read-string "提醒时间 (HH:MM): "))
           (repeat (completing-read "重复周期: "
                                    '(".+1d  — 每天（从完成日起）"
                                      ".+2d  — 每2天"
                                      ".+1w  — 每周"
                                      ".+2w  — 每2周"
                                      ".+1m  — 每月"
                                      "++1d  — 每天（固定日期）"
                                      "++1w  — 每周（固定星期）"
                                      ".+1d/2d — 每天，最多隔2天"
                                      ".+1d/3d — 每天，最多隔3天")
                                    nil t))
           (repeat-val (car (split-string repeat " ")))
           (parts (split-string raw ":"))
           (hour (string-to-number (nth 0 parts)))
           (min  (string-to-number (nth 1 parts)))
           (time (format "%02d:%02d" hour min))
           (today (format-time-string "%Y-%m-%d %a"))
           (end-min (+ min 5))
           (end-hour (+ hour (/ end-min 60)))
           (end-time (format "%02d:%02d" end-hour (% end-min 60))))
      (format "* TODO %s\nSCHEDULED: <%s %s %s>\n:PROPERTIES:\n:STYLE:    habit\n:calendar-id: yuanxiang424@gmail.com\n:END:\n:org-gcal:\n<%s %s-%s>\n:END:\n"
              name today time repeat-val today time end-time)))

  ;; ---- Capture templates ----
  (setq org-capture-templates
        '(("a" "Append Note" plain
           (file+function "~/org/append-note.org" my/append-note-goto-bottom)
           "- %?"
           :empty-lines 1 :jump-to-captured t)
          ("i" "Inbox" entry (file "~/org/inbox.org")
           "* %?\n:PROPERTIES:\n:CREATED: %U\n:END:\n" :empty-lines 1)
          ("n" "Note" entry (file "~/org/inbox.org")
           "* %^{标题}  %^g\n:PROPERTIES:\n:CREATED: %U\n:END:\n\n%?"
           :empty-lines 1 :jump-to-captured t)
          ("t" "Task" entry (file "~/org/inbox.org")
           "* TODO %?\n:PROPERTIES:\n:CREATED: %U\n:END:\n" :empty-lines 1)
          ("j" "Journal" plain
           (function my/journal-capture-goto-today)
           "* %(format-time-string \"%H:%M\")\n%?"
           :empty-lines 1 :jump-to-captured t)
          ("r" "r · 稍后读 [inbox]" entry (file "~/org/inbox.org")
           "* TODO [[%^{URL}][%^{Title}]]\n:PROPERTIES:\n:CREATED: %U\n:END:\n%?" :empty-lines 1)
          ("m" "Movie" entry (file+headline "~/org/collections/media.org" "观影记录")
           "* %^{片名}\n:PROPERTIES:\n:评分: %^{评分|⭐⭐⭐|⭐⭐⭐⭐|⭐⭐⭐⭐⭐|⭐⭐|⭐}\n:END:\n%U\n%?"
           :empty-lines 1)
          ("w" "w · 精读笔记 [ref/]" plain (function my/capture-web-article-target)
           "%?"
           :empty-lines 1 :jump-to-captured t)
          ("h" "Habit" entry (file "~/org/areas/habits.org")
           (function my/org-capture-habit)
           :empty-lines 1)
          ("pl" "Protocol: Read later" entry (file "~/org/inbox.org")
           "* TODO %:annotation\n:PROPERTIES:\n:CREATED: %U\n:END:\n%i\n"
           :immediate-finish t :jump-to-captured t)
          ("pn" "Protocol: Note → references/" plain
           (function my/protocol-note-target)
           "#+begin_quote\n%i\n#+end_quote\n%?"
           :jump-to-captured t)))

  ;; ---- Refile targets ----
  (defun my/org-top-level-org-files (dir)
    "Return top-level non-hidden .org files in DIR."
    (let ((dir (expand-file-name dir))
          result)
      (dolist (path (directory-files dir t "^[^.].*\\.org$") (nreverse result))
        (when (file-regular-p path)
          (push path result)))))

  (defun my/org-project-files ()  (my/org-top-level-org-files "~/org/projects/"))
  (defun my/org-area-files ()     (my/org-top-level-org-files "~/org/areas/"))
  (defun my/org-reference-files () (my/org-top-level-org-files "~/org/references/"))
  (defun my/org-notes-files ()    (my/org-top-level-org-files "~/org/notes/"))

  (setq org-refile-targets
        '(("~/org/inbox.org" :maxlevel . 1)
          (my/org-project-files :maxlevel . 2)
          (my/org-area-files :maxlevel . 2)
          (my/org-reference-files :maxlevel . 1)
          (my/org-notes-files :maxlevel . 1)))
  (setq org-refile-use-outline-path 'file
        org-outline-path-complete-in-steps nil
        org-refile-allow-creating-parent-nodes 'confirm
        org-refile-use-cache nil)

  ;; ---- Tags ----
  (setq org-tag-alist '((:startgroup)
                        ("work" . ?w) ("personal" . ?p) ("learning" . ?l)
                        (:endgroup)
                        ("projectS" . ?s) ("ai" . ?a) ("hiring" . ?h)
                        ("@office" . ?o) ("@home" . ?H) ("@phone" . ?P)))

  ;; ---- Agenda views ----
  (setq org-stuck-projects '("" nil nil ""))

  (defun my/skip-habit ()
    "Skip entries with :STYLE: habit."
    (let ((subtree-end (save-excursion (org-end-of-subtree t))))
      (when (string= (org-entry-get nil "STYLE") "habit")
        subtree-end)))

  (setq org-agenda-custom-commands
        '(("d" "Daily"
           ((agenda "" ((org-agenda-span 'day)
                        (org-agenda-start-day nil)
                        (org-deadline-warning-days 3)
                        (org-agenda-skip-scheduled-if-done t)
                        (org-agenda-skip-deadline-if-done t)))
            (todo "NEXT"
                  ((org-agenda-overriding-header "⚡ Next Actions")
                   (org-agenda-skip-function 'my/skip-habit)
                   (org-agenda-sorting-strategy '(priority-down category-keep))))
            (todo "WAITING"
                  ((org-agenda-overriding-header "⏳ Waiting (FYI)")
                   (org-agenda-sorting-strategy '(category-keep))))))

          ("w" "Weekly"
           ((agenda "" ((org-agenda-span 'week)
                        (org-deadline-warning-days 7)
                        (org-habit-show-habits nil)))
            (tags-todo "+work"
                       ((org-agenda-overriding-header "🏢 Work")
                        (org-agenda-skip-function 'my/skip-habit)
                        (org-agenda-sorting-strategy '(todo-state-down priority-down))))
            (tags-todo "+personal"
                       ((org-agenda-overriding-header "🏠 Personal")
                        (org-agenda-skip-function 'my/skip-habit)
                        (org-agenda-sorting-strategy '(todo-state-down priority-down))))
            (tags-todo "+learning"
                       ((org-agenda-overriding-header "📚 Learning")
                        (org-agenda-skip-function 'my/skip-habit)
                        (org-agenda-sorting-strategy '(todo-state-down priority-down))))
            (tags-todo "-work-personal-learning"
                       ((org-agenda-overriding-header "📦 Untagged")
                        (org-agenda-skip-function 'my/skip-habit)
                        (org-agenda-sorting-strategy '(todo-state-down category-keep))))))

          ("g" "GTD Review"
           ((agenda "" ((org-agenda-span 'day)
                        (org-agenda-start-day nil)))
            (todo "NEXT"
                  ((org-agenda-overriding-header "⚡ Next Actions")
                   (org-agenda-skip-function 'my/skip-habit)
                   (org-agenda-sorting-strategy '(priority-down category-keep))))
            (todo "TODO"
                  ((org-agenda-overriding-header "📋 All Tasks (Backlog)")
                   (org-agenda-skip-function 'my/skip-habit)
                   (org-agenda-sorting-strategy '(tag-up priority-down category-keep))))
            (todo "WAITING"
                  ((org-agenda-overriding-header "⏳ Waiting")
                   (org-agenda-sorting-strategy '(category-keep))))
            (todo "HOLD"
                  ((org-agenda-overriding-header "🧊 On Hold")
                   (org-agenda-sorting-strategy '(category-keep))))))))

  ;; ---- Babel image dir ----
  (defun my/org-babel-image-dir ()
    (when buffer-file-name
      (let ((dir (expand-file-name ".images/" (file-name-directory buffer-file-name))))
        (make-directory dir t)
        dir)))

  (advice-add 'org-babel-temp-file :around
              (lambda (orig-fn prefix &optional suffix)
                (let ((dir (my/org-babel-image-dir)))
                  (if (and dir suffix (string-match-p "\\.\\(png\\|svg\\|pdf\\|jpg\\)$" suffix))
                      (let ((temporary-file-directory dir))
                        (funcall orig-fn prefix suffix))
                    (funcall orig-fn prefix suffix)))))

  ;; ---- Archive done tasks ----
  (defun my/org-entry-done-or-cancelled-p ()
    "Return non-nil when the current Org heading is DONE or CANCELLED."
    (member (org-get-todo-state) '("DONE" "CANCELLED")))

  (defun my/org-entry-has-done-or-cancelled-parent-p ()
    "Return non-nil when an ancestor heading is DONE or CANCELLED."
    (save-excursion
      (let (found)
        (while (and (not found) (org-up-heading-safe))
          (when (my/org-entry-done-or-cancelled-p)
            (setq found t)))
        found)))

  (defun my/org-archive-target-file ()
    "Return the expanded archive file path for the current Org buffer."
    (let* ((fname (file-name-nondirectory (buffer-file-name)))
           (location (replace-regexp-in-string "%s" fname org-archive-location t t)))
      (expand-file-name (car (split-string location "::")))))

  (defun my/org-archive-done-tasks ()
    "Archive DONE/CANCELLED tasks in the current file."
    (interactive)
    (unless (buffer-file-name)
      (user-error "Not visiting a file; open an Org file first"))
    (let (items)
      (org-with-wide-buffer
        (org-map-entries
         (lambda ()
           ;; Only archive the outermost done subtree; nested done children move
           ;; with their archived parent and do not need a second pass.
           (unless (my/org-entry-has-done-or-cancelled-parent-p)
             (let ((beg (point))
                   (end (save-excursion (org-end-of-subtree t t))))
               (push (list :beg beg
                           :end end
                           :text (buffer-substring-no-properties beg end))
                     items))))
         "/DONE|CANCELLED" 'file))
      (setq items
            (sort items
                  (lambda (a b)
                    (> (plist-get a :beg) (plist-get b :beg)))))
      (let ((count (length items))
            (archive-file (my/org-archive-target-file)))
        (when items
          (make-directory (file-name-directory archive-file) t)
          ;; Remove inline image overlays before structural edits on Windows.
          (when (fboundp 'org-remove-inline-images)
            (org-remove-inline-images))
          (with-temp-buffer
            (when (file-exists-p archive-file)
              (insert-file-contents archive-file))
            (goto-char (point-max))
            (unless (bolp)
              (insert "\n"))
            (dolist (item (reverse items))
              (insert "\n" (plist-get item :text))
              (unless (bolp)
                (insert "\n")))
            (write-region (point-min) (point-max) archive-file nil 'silent))
          (save-excursion
            (dolist (item items)
              (delete-region (plist-get item :beg) (plist-get item :end))))
          (save-buffer))
        (message "Archived %d done/cancelled task(s) in %s"
                 count (file-name-nondirectory (buffer-file-name))))))

  ;; Hide redundant tags in agenda
  (setq org-agenda-hide-tags-regexp "personal\\|habit")

  ;; ---- CJK emphasis fix (中文加粗/高亮) ----
  (setcar org-emphasis-regexp-components
          " \t('\"{[:alpha:][:nonascii:]")
  (setcar (nthcdr 1 org-emphasis-regexp-components)
          "[:alpha:][:nonascii:]- \t.,:!?;'\")}\\")
  (org-set-emph-re 'org-emphasis-regexp-components
                   org-emphasis-regexp-components))

;; ============================================================
;;  7. Org clipboard helpers
;; ============================================================

(defun my/org-download-screenshot-command ()
  "Platform-appropriate screenshot command for org-download."
  (cond
   ((featurep :system 'windows)
    "powershell -Command \"Add-Type -AssemblyName System.Windows.Forms; $img = [System.Windows.Forms.Clipboard]::GetImage(); if ($img) { $img.Save('%s', [System.Drawing.Imaging.ImageFormat]::Png) } else { Write-Error 'No image in clipboard' }\"")
   ((featurep :system 'macos)
    "sh -c 'if command -v pngpaste >/dev/null 2>&1 && pngpaste \"$1\" >/dev/null 2>&1; then exit 0; else screencapture -i \"$1\"; fi' _ %s")
   (t
    "sh -c 'if command -v xclip >/dev/null 2>&1; then xclip -selection clipboard -t image/png -o > \"$1\" 2>/dev/null || true; fi; if [ ! -s \"$1\" ]; then if command -v wl-paste >/dev/null 2>&1; then wl-paste --no-newline --type image/png > \"$1\" 2>/dev/null || true; fi; fi; if [ ! -s \"$1\" ]; then if command -v maim >/dev/null 2>&1; then maim -s \"$1\"; elif command -v grim >/dev/null 2>&1 && command -v slurp >/dev/null 2>&1; then grim -g \"$(slurp)\" \"$1\"; fi; fi' _ %s")))

(defun my/org-paste-rich ()
  "Paste rich text (HTML with images) from clipboard as Org content."
  (interactive)
  (unless buffer-file-name
    (user-error "Please save the current buffer first"))
  (pcase system-type
    ('windows-nt
     (let* ((img-dir (expand-file-name ".images" (file-name-directory buffer-file-name)))
            (script (expand-file-name "~/org/.src/clipboard-to-org.ps1"))
            (img-dir-win (replace-regexp-in-string "/" "\\\\" img-dir))
            (script-win (replace-regexp-in-string "/" "\\\\" script))
            (cmd (format "powershell.exe -NoProfile -ExecutionPolicy Bypass -File \"%s\" -ImageDir \"%s\""
                         script-win img-dir-win))
            (out-file (string-trim (shell-command-to-string cmd))))
       (if (and (not (string-blank-p out-file))
                (file-exists-p out-file))
           (progn
             (insert-file-contents out-file)
             (delete-file out-file)
             (message "OK: rich text pasted"))
         (message "WARN: clipboard empty or conversion failed (out: %s)" out-file))))
    ('darwin
     (let* ((script (expand-file-name "~/org/.src/clipboard-to-org-macos.sh"))
            (img-dir (expand-file-name ".images" (file-name-directory buffer-file-name))))
       (cond
        ((file-exists-p script)
         (let ((out-file (string-trim (shell-command-to-string
                                       (format "sh %s %s" (shell-quote-argument script) (shell-quote-argument img-dir))))))
           (if (and (not (string-blank-p out-file))
                    (file-exists-p out-file))
               (progn
                 (insert-file-contents out-file)
                 (delete-file out-file)
                 (message "OK: rich text pasted"))
             (message "WARN: macOS clipboard conversion failed"))))
        ((executable-find "pbpaste")
         (let ((text (shell-command-to-string "pbpaste")))
           (if (string-blank-p text)
               (message "WARN: macOS clipboard empty")
             (insert text)
             (message "OK: plain text pasted (macOS fallback)"))))
        (t (message "WARN: pbpaste not found")))))
    (_ (message "WARN: rich text clipboard not implemented for this platform"))))

;; ============================================================
;;  8. Org visual enhancements
;; ============================================================

;; Pixel-aligned agenda tags (fix CJK misalignment)
(defun my/org-agenda-align-tags-pixel ()
  "Right-align agenda tags using pixel-based display alignment."
  (let ((inhibit-read-only t)
        (target-pixel (- (window-text-width nil t)
                         (* 2 (string-pixel-width " ")))))
    (save-excursion
      (goto-char (point-min))
      (while (re-search-forward "\\([ \t]+\\)\\(:[[:alnum:]_@#%:]+:\\)[ \t]*$" nil t)
        (let* ((tags-str (match-string 2))
               (tags-pixel (string-pixel-width tags-str))
               (align-to (- target-pixel tags-pixel)))
          (when (> align-to 0)
            (put-text-property (match-beginning 1) (match-end 1)
                               'display `(space :align-to (,align-to)))))))))

(add-hook 'org-agenda-finalize-hook #'my/org-agenda-align-tags-pixel)

;; org-download — 走 org-attach 体系
(after! org
  (use-package! org-download
    :commands (org-download-clipboard org-download-screenshot org-download-yank org-download-delete)
    :config
    (add-hook 'org-mode-hook 'org-download-enable)
    (setq org-download-method 'attach
          org-download-heading-lvl 0
          org-download-timestamp "%Y%m%d%H%M%S-"
          org-download-image-org-width 800
          org-download-annotate-function (lambda (_link) "")
          org-download-screenshot-method (my/org-download-screenshot-command))

    ;; Fix: org-download-dnd-fallback for Emacs 30+
    (when (fboundp 'dnd-handle-multiple-urls)
      (defun org-download-dnd-fallback (uri action)
        (let ((dnd-protocol-alist
               (rassq-delete-all
                'org-download-dnd
                (copy-alist dnd-protocol-alist))))
          (dnd-handle-multiple-urls
           (selected-window) (list uri) action))))

    ;; Fix: Full percent-decoding for non-ASCII filenames
    (defun org-download--fullname (link &optional ext)
      "Return the file name where LINK will be saved to.
EXT can hold the file extension, in case LINK doesn't provide it.
[patched] Full percent-decoding for non-ASCII filenames."
      (let ((filename
             (decode-coding-string
              (url-unhex-string
               (file-name-nondirectory
                (car (url-path-and-query
                      (url-generic-parse-url link)))))
              'utf-8))
            (dir (org-download--dir)))
        (when (string-match ".*?\\.\\(?:png\\|jpg\\)\\(.*\\)$" filename)
          (setq filename (replace-match "" nil nil filename 1)))
        (when ext
          (setq filename (concat (file-name-sans-extension filename) "." ext)))
        (abbreviate-file-name
         (expand-file-name
          (funcall org-download-file-format-function filename)
          dir))))))

;; ============================================================
;;  9. Org-gcal (Google Calendar sync)
;; ============================================================

;; plstore encryption workaround (defer until needed)
(after! plstore
  (advice-add 'plstore-save :around
              (lambda (orig-fun plstore)
                (let ((secret-alist (copy-tree (plstore--get-secret-alist plstore))))
                  (dolist (sec secret-alist)
                    (let ((pub (assoc (car sec) (plstore--get-alist plstore))))
                      (when pub (nconc pub (cdr sec)))))
                  (plstore--set-secret-alist plstore nil)
                  (unwind-protect
                      (funcall orig-fun plstore)
                    (plstore--set-secret-alist plstore secret-alist))))))

(use-package! org-gcal
  :commands (org-gcal-sync org-gcal-fetch org-gcal-delete-at-point org-gcal-post-at-point)
  :config
  (setq org-gcal-up-days 7
        org-gcal-down-days 60)

  (defvar my/org-gcal-default-calendar-id
    "f3f2ce4fb88adc5db8f25b71d3c75d20924a8c147a0feb34eafe477f173a860b@group.calendar.google.com")

  (defun my/org-gcal-drawer-timestamp ()
    "返回当前 entry 的 :org-gcal: drawer 里的时间戳。"
    (save-excursion
      (let ((end (save-excursion (outline-next-heading) (point))))
        (when (re-search-forward ":org-gcal:" end t)
          (let ((drawer-end (save-excursion
                              (re-search-forward ":END:" end t)
                              (point))))
            (let ((content (buffer-substring-no-properties (point) drawer-end)))
              (when (string-match "<[^>]+>" content)
                (match-string 0 content))))))))

  (defun my/org-gcal-set-drawer (timestamp)
    "把 TIMESTAMP 写入 :org-gcal: drawer。"
    (save-excursion
      (let* ((entry-start (point))
             (entry-end   (save-excursion (outline-next-heading) (point))))
        (goto-char entry-start)
        (if (re-search-forward "^:org-gcal:$" entry-end t)
            (let ((content-start (point)))
              (re-search-forward "^:END:$" entry-end t)
              (beginning-of-line)
              (delete-region content-start (point))
              (insert "\n" timestamp "\n"))
          (goto-char entry-start)
          (if (re-search-forward "^:END:$" entry-end t)
              (progn (end-of-line) (insert "\n:org-gcal:\n" timestamp "\n:END:"))
            (org-end-of-meta-data nil)
            (insert ":org-gcal:\n" timestamp "\n:END:\n"))))))

  (defun my/org-gcal-patch-status (calendar-id event-id gcal-status)
    "PATCH GCal event status."
    (require 'request)
    (let ((url (concat (org-gcal-events-url calendar-id)
                       "/" (url-hexify-string event-id)))
          (token (org-gcal--get-access-token calendar-id)))
      (request url
        :type "PATCH"
        :headers `(("Content-Type"  . "application/json")
                   ("Accept"        . "application/json")
                   ("Authorization" . ,(format "Bearer %s" token)))
        :data (json-encode `(("status" . ,gcal-status)))
        :parser 'org-gcal--json-read
        :success (cl-function
                  (lambda (&key _data &allow-other-keys)
                    (message "org-gcal: status → %s ✓ (%s)" gcal-status event-id)))
        :error (cl-function
                (lambda (&key error-thrown &allow-other-keys)
                  (message "org-gcal: PATCH status failed: %S" error-thrown))))))

  (defun my/org-gcal-todo-to-gcal-status (todo-state)
    (cond
     ((member todo-state '("CANCELLED"))  "cancelled")
     ((member todo-state '("TODO" "NEXT" "WAITING" "HOLD" "DONE")) "confirmed")
     (t nil)))

  (defun my/org-gcal-auto-post ()
    "Auto push/update entries with timestamps to GCal."
    (interactive)
    (when (derived-mode-p 'org-mode)
      (org-save-outline-visibility t
        (org-map-entries
         (lambda ()
           (let* ((scheduled   (org-entry-get nil "SCHEDULED"))
                  (deadline    (org-entry-get nil "DEADLINE"))
                  (timestamp   (or scheduled deadline))
                  (has-id      (org-entry-get nil "entry-id"))
                  (calendar-id (or (org-entry-get nil "calendar-id")
                                   my/org-gcal-default-calendar-id))
                  (todo-state  (org-get-todo-state))
                  (gcal-status (my/org-gcal-todo-to-gcal-status todo-state))
                  (last-state  (org-entry-get nil "gcal-todo-state"))
                  (state-changed (and has-id gcal-status
                                      (not (equal last-state todo-state))))
                  (drawer-ts   (my/org-gcal-drawer-timestamp))
                  (ts-changed  (and timestamp has-id
                                    (or (not drawer-ts)
                                        (not (string= (string-trim timestamp)
                                                      (string-trim drawer-ts)))))))
             (when (and timestamp (or (not has-id) ts-changed))
               (my/org-gcal-set-drawer timestamp)
               (org-entry-put nil "calendar-id" calendar-id)
               (condition-case err
                   (org-gcal-post-at-point)
                 (error (message "org-gcal push failed: %s" err))))
             (when state-changed
               (let ((event-id (org-gcal--get-id (point))))
                 (when event-id
                   (org-entry-put nil "gcal-todo-state" todo-state)
                   (my/org-gcal-patch-status calendar-id event-id gcal-status))))))
         nil 'file))))

  ;; Dedup after fetch
  (defun my/org-gcal-dedup-after-fetch ()
    (let ((fetch-files (mapcar #'cdr org-gcal-fetch-file-alist))
          (known-ids (make-hash-table :test #'equal)))
      (dolist (file (org-agenda-files t))
        (unless (member (expand-file-name file) (mapcar #'expand-file-name fetch-files))
          (when (file-exists-p file)
            (with-temp-buffer
              (insert-file-contents file)
              (goto-char (point-min))
              (while (re-search-forward "^[ \t]*:entry-id:[ \t]+\\(.+\\)" nil t)
                (puthash (string-trim (match-string 1)) file known-ids))))))
      (dolist (fetch-file fetch-files)
        (let ((fpath (expand-file-name fetch-file)))
          (when (file-exists-p fpath)
            (with-current-buffer (find-file-noselect fpath)
              (org-with-wide-buffer
               (goto-char (point-min))
               (let ((kill-list nil))
                 (org-map-entries
                  (lambda ()
                    (let ((eid (org-entry-get nil "entry-id")))
                      (when (and eid (gethash eid known-ids))
                        (push (point) kill-list)))))
                 (when kill-list
                   (dolist (pos (sort kill-list #'>))
                     (goto-char pos)
                     (org-cut-subtree))
                   (save-buffer)
                   (message "org-gcal dedup: removed %d duplicate(s) from %s"
                            (length kill-list) fetch-file))))))))))

  (advice-add 'org-gcal-fetch :after
              (lambda (&rest _) (run-with-idle-timer 5 nil #'my/org-gcal-dedup-after-fetch)))

  ;; Periodic sync every 30 min
  (run-with-timer 120 1800
                  (lambda ()
                    (when (not org-gcal--sync-lock)
                      (org-gcal-sync)))))

;; ============================================================
;;  10. Org-roam
;; ============================================================

(after! org-roam
  (setq org-roam-directory "~/org/roam"
        org-roam-completion-everywhere t
        org-roam-capture-templates
        '(("d" "Default" plain "%?"
           :target (file+head "%<%Y%m%d%H%M%S>-${slug}.org"
                              "#+title: ${title}\n#+date: %U\n#+filetags: \n\n")
           :unnarrowed t)
          ("f" "Fleeting" plain "%?"
           :target (file+head "fleeting/%<%Y%m%d%H%M%S>-${slug}.org"
                              "#+title: ${title}\n#+date: %U\n#+filetags: :fleeting:\n\n")
           :unnarrowed t)))
  (make-directory (expand-file-name "roam" org-directory) t)
  (make-directory (expand-file-name "roam/fleeting" org-directory) t))

;; Web article target for capture "w"
(defun my/capture-web-article-target ()
  "Target function for org-capture: reference note from clipboard URL."
  (let* ((url (string-trim (current-kill 0 t)))
         (title (or (ignore-errors
                      (with-temp-buffer
                        (url-insert-file-contents url)
                        (goto-char (point-min))
                        (when (re-search-forward "<title>\\([^<]*\\)</title>" nil t)
                          (string-trim (match-string 1)))))
                    (read-string "Title: ")))
         (slug (replace-regexp-in-string "[^a-zA-Z0-9\u4e00-\u9fff]+" "-"
                                         (downcase (string-trim title)) t t))
         (slug (replace-regexp-in-string "^-\\|-$" "" slug))
         (file (expand-file-name (concat "references/" slug ".org") org-directory)))
    (set-buffer (org-capture-target-buffer file))
    (when (= (buffer-size) 0)
      (insert (format "#+title: %s\n#+filetags: :ref:\n#+created: %s\n\n* Source\n%s\n\n* Summary\n\n* My Notes\n"
                      title (format-time-string "[%Y-%m-%d %a]") url)))
    (goto-char (point-max))
    (or (re-search-backward "^\\* My Notes" nil t) (goto-char (point-max)))
    (forward-line 1)))

;; org-protocol target for "pn"
(defun my/protocol-note-target ()
  "Target for org-capture 'pn': reference note from org-protocol."
  (let* ((url   (or (plist-get org-store-link-plist :link)
                    (plist-get org-store-link-plist :url) ""))
         (title (or (plist-get org-store-link-plist :description)
                    (read-string "Title: ")))
         (slug  (replace-regexp-in-string
                 "^-\\|-$" ""
                 (replace-regexp-in-string
                  "[^a-zA-Z0-9\u4e00-\u9fff]+" "-"
                  (downcase (string-trim title)) t t)))
         (file  (expand-file-name (concat "references/" slug ".org") org-directory)))
    (set-buffer (org-capture-target-buffer file))
    (when (= (buffer-size) 0)
      (insert (format "#+title: %s\n#+filetags: :ref:\n#+created: %s\n\n* Source\n%s\n\n* Summary\n\n* My Notes\n"
                      title (format-time-string "[%Y-%m-%d %a]") url)))
    (goto-char (point-max))
    (or (re-search-backward "^\\* My Notes" nil t) (goto-char (point-max)))
    (forward-line 1)))

;; ============================================================
;;  11. Elfeed & Elfeed-org
;; ============================================================

(use-package! elfeed
  :commands elfeed
  :config
  (setq elfeed-db-directory (expand-file-name "~/org/collections/.elfeed")
        elfeed-curl-max-connections 4)
  (setq-default elfeed-search-filter "@1-month-ago +unread")
  (add-hook 'elfeed-search-mode-hook #'elfeed-update)
  (add-hook 'elfeed-show-mode-hook (lambda () (setq-local shr-use-fonts nil)))

  ;; Defensive fix: elfeed-db corruption
  (defun my/elfeed-db-sanitize-before-save (&rest _)
    (unless (and elfeed-db (plistp elfeed-db))
      (message "elfeed-db is corrupt (%S), reloading from disk..." elfeed-db)
      (setf elfeed-db nil)
      (elfeed-db-load)))
  (advice-add 'elfeed-db-save :before #'my/elfeed-db-sanitize-before-save)

  ;; mpv integration
  (defun my/elfeed-play-with-mpv ()
    "Play the current elfeed entry with mpv."
    (interactive)
    (let ((link (if (derived-mode-p 'elfeed-show-mode)
                    (elfeed-entry-link elfeed-show-entry)
                  (let ((entries (elfeed-search-selected)))
                    (when entries
                      (elfeed-entry-link (car entries)))))))
      (if link
          (progn
            (message "Starting mpv for %s..." link)
            (start-process "elfeed-mpv" nil "mpv" link)
            (when (derived-mode-p 'elfeed-search-mode)
              (elfeed-search-untag-all-unread)))
        (message "No link found."))))

  (map! :map elfeed-search-mode-map "v" #'my/elfeed-play-with-mpv)
  (map! :map elfeed-show-mode-map   "v" #'my/elfeed-play-with-mpv))

(use-package! elfeed-org
  :after elfeed
  :config
  (elfeed-org)
  (setq rmh-elfeed-org-files (list (expand-file-name "~/org/collections/elfeed.org"))))

;; ============================================================
;;  12. Journal — org-journal
;; ============================================================

(after! org-journal
  (setq org-journal-dir "~/org/journal/"
        org-journal-file-type 'daily
        org-journal-file-format "%Y-%m-%d.org"
        org-journal-date-format "%Y-%m-%d"
        org-journal-file-header "#+title: %Y-%m-%d\n#+filetags: :journal:\n"
        org-journal-start-on-weekday 1
        org-journal-carryover-items nil))

(defun my/journal-capture-goto-today ()
  "Open today's journal for org-capture. Before 03:00 uses previous day."
  (let* ((now  (decode-time))
         (hour (nth 2 now))
         (time (if (< hour 3)
                   (time-subtract (current-time) (seconds-to-time 86400))
                 (current-time)))
         (file (expand-file-name
                (format-time-string "%Y-%m-%d.org" time)
                "~/org/journal/")))
    (set-buffer (org-capture-target-buffer file))
    (when (= (buffer-size) 0)
      (insert (format "#+title: %s\n#+filetags: :journal:\n"
                      (format-time-string "%Y-%m-%d" time))))
    (goto-char (point-max))))

;; ============================================================
;;  13. Chinese calendar (cal-china-x)
;; ============================================================

(use-package! cal-china-x
  :after calendar
  :config
  (setq calendar-mark-holidays-flag t
        cal-china-x-important-holidays cal-china-x-chinese-holidays
        calendar-holidays
        (append cal-china-x-important-holidays
                cal-china-x-general-holidays))
  (setq org-agenda-include-diary nil))

;; ============================================================
;;  14. Reading: nov.el + org-noter (pdf-tools via Doom :tools pdf)
;; ============================================================

;; PDF file apps for org links
(after! org
  (defun my/org-open-pdf-with-pdf-tools (file _link)
    (require 'pdf-tools nil t)
    (require 'pdf-view nil t)
    (find-file file)
    (unless (derived-mode-p 'pdf-view-mode)
      (pdf-view-mode)))

  (defun my/org-open-epub-with-nov (file _link)
    (require 'nov nil t)
    (find-file file)
    (unless (derived-mode-p 'nov-mode)
      (nov-mode)))

  (let ((pdf-entry (assoc "\\.pdf\\'" org-file-apps)))
    (if pdf-entry
        (setcdr pdf-entry #'my/org-open-pdf-with-pdf-tools)
      (add-to-list 'org-file-apps '("\\.pdf\\'" . my/org-open-pdf-with-pdf-tools))))
  (let ((epub-entry (assoc "\\.epub\\'" org-file-apps)))
    (if epub-entry
        (setcdr epub-entry #'my/org-open-epub-with-nov)
      (add-to-list 'org-file-apps '("\\.epub\\'" . my/org-open-epub-with-nov)))))

;; pdf-view tweaks
(after! pdf-view
  (setq-default pdf-view-display-size 'fit-page)
  (setq pdf-view-midnight-colors '("#ffffff" . "#1e1e2e"))
  (map! :map pdf-view-mode-map
        "C-c C-a h" #'pdf-annot-add-highlight-markup-annotation
        "C-c C-a t" #'pdf-annot-add-text-annotation
        "C-c C-a d" #'pdf-annot-add-strikeout-markup-annotation))

;; nov.el: EPUB reader
(use-package! nov
  :mode ("\\.epub\\'" . nov-mode)
  :config
  (when (featurep :system 'windows)
    (setq nov-unzip-program "C:/Program Files/Git/usr/bin/unzip.exe"))
  (setq nov-variable-pitch nil)

  (defun my/nov-setup ()
    (let ((font (or (my/first-available-font '("Noto Sans SC"
                                               "Noto Serif SC"
                                               "Microsoft YaHei UI"
                                               "Microsoft YaHei"))
                    "Microsoft YaHei")))
      (face-remap-add-relative 'default :family font :height 140)
      (face-remap-add-relative 'variable-pitch :family font :height 140)
      (set-fontset-font t nil (font-spec :family font) nil 'prepend)
      (message "nov: using font \"%s\"" font))
    (visual-line-mode 1)
    (setq nov-text-width 80))
  (add-hook 'nov-mode-hook #'my/nov-setup)

  ;; Fix: nov-save-place 中文路径 utf-8
  (defun my/nov-save-place-a (orig-fn &rest args)
    (let ((coding-system-for-write 'utf-8))
      (apply orig-fn args)))
  (advice-add 'nov-save-place :around #'my/nov-save-place-a))

;; org-noter
(use-package! org-noter
  :commands org-noter
  :config
  (setq org-noter-notes-search-path '("~/org/references/")
        org-noter-default-notes-file-names '("notes.org")
        org-noter-auto-save-last-location t
        org-noter-notes-window-location 'horizontal-split
        org-noter-highlight-selected-text t)

  (defun my/org-noter-create-session-in-references (&optional arg document-file-name)
    "Create org-noter session, always placing notes in ~/org/references/."
    (let* ((document-file-name (or (run-hook-with-args-until-success
                                    'org-noter-get-buffer-file-name-hook major-mode)
                                   document-file-name))
           (document-path (or document-file-name buffer-file-truename
                              (error "This buffer does not seem to be visiting any file")))
           (document-name (file-name-nondirectory document-path))
           (document-base (file-name-base document-name))
           (notes-dir (expand-file-name "~/org/references/"))
           (notes-file (expand-file-name (concat document-base ".org") notes-dir)))
      (make-directory notes-dir t)
      (unless (file-exists-p notes-file)
        (with-temp-file notes-file
          (insert (format "#+title: %s\n#+filetags: :ref:\n#+created: %s\n\n* %s\n:PROPERTIES:\n:NOTER_DOCUMENT: %s\n:END:\n"
                          document-base
                          (format-time-string "[%Y-%m-%d %a]")
                          document-base
                          (expand-file-name document-path)))))
      (with-current-buffer (find-file-noselect notes-file)
        (goto-char (point-min))
        (re-search-forward (org-re-property org-noter-property-doc-file) nil t)
        (org-back-to-heading t)
        (org-noter))))

  (setq org-noter-create-session-from-document-hook
        '(my/org-noter-create-session-in-references)))

;; ============================================================
;;  15. PowerShell mode
;; ============================================================

(use-package! powershell
  :mode ("\\.ps1\\'" . powershell-mode)
  :config
  (defun my/powershell-run-file ()
    "Run current .ps1 file."
    (interactive)
    (unless buffer-file-name (user-error "Buffer has no file"))
    (save-buffer)
    (compile (format "pwsh -NoProfile -ExecutionPolicy Bypass -File \"%s\""
                     (expand-file-name buffer-file-name))))

  (defun my/powershell-run-region ()
    "Send region or current line to inferior PowerShell."
    (interactive)
    (let* ((beg (if (use-region-p) (region-beginning) (line-beginning-position)))
           (end (if (use-region-p) (region-end)       (line-end-position)))
           (code (buffer-substring-no-properties beg end)))
      (unless (get-buffer "*PowerShell*") (powershell))
      (comint-send-string (get-buffer-process "*PowerShell*") (concat code "\n"))
      (display-buffer "*PowerShell*")))

  (map! :map powershell-mode-map
        "C-c C-c" #'my/powershell-run-file
        "C-c C-r" #'my/powershell-run-region
        "C-c C-z" #'powershell))

;; ============================================================
;;  16. Markdown enhancements
;; ============================================================

(after! markdown-mode
  (setq markdown-command "pandoc"
        markdown-fontify-code-blocks-natively t
        markdown-header-scaling t
        markdown-enable-wiki-links t
        markdown-italic-underscore t
        markdown-asymmetric-header nil
        markdown-live-preview-delete-export 'delete-on-destroy))

;; ============================================================
;;  17. Keybindings (SPC leader + local maps)
;; ============================================================

(map! :leader
      ;; Gcal
      (:prefix ("G" . "gcal")
       :desc "Sync"   "s" #'org-gcal-sync
       :desc "Fetch"  "f" #'org-gcal-fetch
       :desc "Delete" "d" #'org-gcal-delete-at-point
       :desc "Push"   "p" #'my/org-gcal-auto-post)

      ;; Elfeed
      (:prefix ("o" . "open")
       :desc "Elfeed" "e" #'elfeed)

      ;; Org-noter
      :desc "org-noter" "N" #'org-noter)

;; Org-mode local keybindings
(map! :after org
      :map org-mode-map
      :localleader
      ;; Image / org-download
      (:prefix ("i" . "image")
       :desc "Toggle inline"  "t" #'org-toggle-inline-images
       :desc "Paste clipboard" "p" #'org-download-clipboard
       :desc "Screenshot"     "s" #'org-download-screenshot
       :desc "Yank"           "y" #'org-download-yank
       :desc "Delete"         "d" #'org-download-delete)
      ;; Rich paste
      :desc "Paste rich text" "V" #'my/org-paste-rich
      ;; Archive
      :desc "Archive done tasks" "A" #'my/org-archive-done-tasks)

;; ============================================================
;;  18. Smart input source (sis) + Weasel/Rime
;; ============================================================

(use-package sis
  :demand t
  :config
  ;; Windows 下把 SIS 状态和系统 IME 真实状态对齐。
  (defun my/sis-refresh-from-system-ime ()
    "Refresh SIS state from the current system IME."
    (when (and (eq system-type 'windows-nt)
               (fboundp 'w32-get-ime-open-status))
      (setq sis--for-buffer-locked nil)
      (if (w32-get-ime-open-status)
          (sis--set-other)
        (sis--set-english))))

  (defun my/sis-switch ()
    "Toggle between English and the other input source."
    (interactive)
    (setq sis--for-buffer-locked nil)
    (if (if (and (eq system-type 'windows-nt)
                 (fboundp 'w32-get-ime-open-status))
            (not (w32-get-ime-open-status))
          (eq sis--current 'english))
        (sis--set-other)
      (sis--set-english)))

  ;; 设置 Windows / macOS 输入法后端
  (cond ((eq system-type 'windows-nt)
         (setq sis-english-source nil))
        ;; 设置Emacs-plus with input patch
        ((eq system-type 'darwin)
         (sis-ism-lazyman-config "com.apple.keylayout.UnicodeHexInput"
                                 "im.rime.inputmethod.Squirrel.Hans"
                                 'emp)))
  ;; 启用全局光标颜色
  (sis-global-cursor-color-mode t)
  ;;设置sis的状态光标颜色
  (setq sis-other-cursor-color (modus-themes-get-color-value 'fg-alt))
  (setq sis-default-cursor-color (modus-themes-get-color-value 'border))
  (set-cursor-color "#ffffff")
  ;; enable the /respect/ mode
  ;; 启用全局respect模式
  (sis-global-respect-mode t)
  ;; enable the /context/ mode for all buffers
  (sis-global-context-mode t)
  ;; enable the /inline english/ mode for all buffers
  (sis-global-inline-mode t)
  ;;自动设置为英文的函数
  (setq sis-respect-go-english-triggers
        (list #'org-agenda))
  ;; 在切换窗口后获取并更新一次输入法状态
  (add-function :after after-focus-change-function #'my/sis-refresh-from-system-ime)

  ;; 这些场景通常需要直接进入中文输入。
  (add-hook 'org-capture-mode-hook #'sis-set-other)
  (add-hook 'atomic-chrome-edit-mode-hook #'sis-set-other)
  (add-hook 'beancount-mode-hook #'sis-set-other)
  (add-hook 'xeft-mode-hook #'sis-set-other)
  :bind
  ("C-\\" . my/sis-switch))
;; ============================================================
;;  19. Fix: C-c C-c in *Org Note* buffer (log notes, etc.)
;; ============================================================

;; Doom's popup system can interfere with org-finish-function being
;; buffer-local in *Org Note*. Force org-store-log-note when in that buffer.
(defadvice! my/org-ctrl-c-ctrl-c-note-fix (fn &rest args)
  :around #'org-ctrl-c-ctrl-c
  (if (string= (buffer-name) "*Org Note*")
      (org-store-log-note)
    (apply fn args)))

;; ============================================================
;;  20. Fix: Windows server sentinel error on exit
;; ============================================================

;; Silence the "Removing old connection file" error that occurs on Windows exit
(advice-add 'server-stop-connections :around
            (lambda (orig-fn &rest args)
              (condition-case err
                  (apply orig-fn args)
                (file-missing nil))))

;; Also suppress sentinel errors from server processes
(setq server-process-query-function #'ignore)

;; Load secrets (org-gcal credentials etc.)
(load! "secrets" doom-user-dir t)
