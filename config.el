;;; config.el -*- lexical-binding: t; -*-
;; (prefer-coding-system 'utf-8-unix)
;; (set-default-coding-systems 'utf-8-unix)
;; (setq locale-coding-system 'utf-8-unix)
;; (when (eq system-type 'windows-nt)
;;   (setq file-name-coding-system 'utf-8-unix
;;         default-file-name-coding-system 'utf-8-unix))

;; (add-to-list 'process-coding-system-alist '("rg" utf-8 . utf-8))
;; (add-to-list 'process-coding-system-alist '("git" utf-8 . utf-8))
;; (add-to-list 'process-coding-system-alist '("fd" utf-8 . utf-8))

;; ;; NOTE: SPC s f (locate) unavailable on Windows, use SPC SPC instead

;; ;; Disable evil mouse drag to avoid CJK font rendering crash
;; (after! evil
;;   (define-key evil-normal-state-map [down-mouse-1] nil)
;;   (define-key evil-motion-state-map [down-mouse-1] nil))

;; ;; Work around a native Windows crash when splitting Elfeed windows.
;; (after! evil
;;   (defun my/elfeed-buffer-p ()
;;     "Return non-nil when the current buffer is an Elfeed buffer."
;;     (derived-mode-p 'elfeed-search-mode 'elfeed-show-mode))

;;   (evil-define-command my/evil-window-split-a (&optional count file)
;;     "Like Doom's split advice, but avoid extra redraw in Elfeed on Windows."
;;     :repeat nil
;;     (interactive "P<f>")
;;     (if (and (featurep :system 'windows)
;;              (my/elfeed-buffer-p))
;;         (let ((origwin (selected-window))
;;               window-selection-change-functions)
;;           (select-window (split-window origwin count 'below))
;;           (unless evil-split-window-below
;;             (select-window origwin))
;;           (when file
;;             (evil-edit file)))
;;       (+evil-window-split-a count file)))

;;   (evil-define-command my/evil-window-vsplit-a (&optional count file)
;;     "Like Doom's vsplit advice, but avoid extra redraw in Elfeed on Windows."
;;     :repeat nil
;;     (interactive "P<f>")
;;     (if (and (featurep :system 'windows)
;;              (my/elfeed-buffer-p))
;;         (let ((origwin (selected-window))
;;               window-selection-change-functions)
;;           (select-window (split-window origwin count 'right))
;;           (unless evil-vsplit-window-right
;;             (select-window origwin))
;;           (when file
;;             (evil-edit file)))
;;       (+evil-window-vsplit-a count file)))

;;   (advice-remove #'evil-window-split #'+evil-window-split-a)
;;   (advice-remove #'evil-window-vsplit #'+evil-window-vsplit-a)
;;   (advice-add #'evil-window-split :override #'my/evil-window-split-a)
;;   (advice-add #'evil-window-vsplit :override #'my/evil-window-vsplit-a))

;; ;; evil-org-mode bug: `evil-org-select-an-element' uses `(region-beginning)'
;; ;; unconditionally, which returns `(min point mark)' even when no region is
;; ;; active. In operator-pending mode (e.g. daR), that pulls the start back to
;; ;; a stale mark, so `daR' deletes from that mark to the end of the subtree
;; ;; instead of just the subtree.
;; (after! evil-org
;;   (defun evil-org-select-an-element (element)
;;     "Select an org ELEMENT (fixed for operator-pending state)."
;;     (let ((elem-begin (org-element-property :begin element)))
;;       (list (if (evil-visual-state-p)
;;                 (min (region-beginning) elem-begin)
;;               elem-begin)
;;             (org-element-property :end element)))))

;; ;; Work around a native Windows crash when key-help commands read real keys
;; ;; while the system IME is open.
;; (when (featurep :system 'windows)
;;   (defun my/windows-disable-ime-for-key-help-a (fn &rest args)
;;     "Temporarily close the Windows IME while FN reads a key sequence."
;;     (let ((restore-ime
;;            (and (fboundp 'w32-get-ime-open-status)
;;                 (fboundp 'w32-set-ime-open-status)
;;                 (ignore-errors (w32-get-ime-open-status)))))
;;       (unwind-protect
;;           (progn
;;             (when restore-ime
;;               (ignore-errors (w32-set-ime-open-status nil)))
;;             (apply fn args))
;;         (when restore-ime
;;           (ignore-errors (w32-set-ime-open-status t))))))

;;   (with-eval-after-load 'help-fns
;;     (dolist (fn '(describe-key describe-key-briefly))
;;       (advice-remove fn #'my/windows-disable-ime-for-key-help-a)
;;       (advice-add fn :around #'my/windows-disable-ime-for-key-help-a)))

;;   (with-eval-after-load 'helpful
;;     (advice-remove 'helpful-key #'my/windows-disable-ime-for-key-help-a)
;;     (advice-add 'helpful-key :around #'my/windows-disable-ime-for-key-help-a)))

;; 把之前AI写的一些东西备注掉了，下面是自己加的
;; (prefer-coding-system 'utf-8)
;; (set-default-coding-systems 'utf-8)
;; (set-file-name-coding-system 'utf-8)
(setq user-full-name "Sean Chen"
      user-mail-address "yuanxiang424@gmail.com")
;; (defun my/first-available-font (candidates)
;;   "Return the first font family from CANDIDATES that is available."
;;   (catch 'found
;;     (dolist (font candidates)
;;       (when (find-font (font-spec :family font))
;;         (throw 'found font)))
;;     nil))

(setq doom-font (font-spec :family "Maple Mono NF CN" :size 17)
      doom-variable-pitch-font (font-spec :family "LXGW WenKai Screen" :size 19)
      doom-big-font (font-spec :family "Maple Mono NF CN" :size 24))

;; CJK font override — must run AFTER unicode-fonts-setup (depth -90)
;; Change `my/cjk-mono-font' to pick a different CJK font
(defvar my/cjk-mono-font "Maple Mono NF CN"
  "CJK font for monospace contexts (code, fixed-pitch).")

(defun my/setup-cjk-fonts (&optional _frame)
  "Force CJK characters to use a specific font."
  (when (display-graphic-p)
    (let ((font-family (or my/cjk-mono-font
                           (catch 'found
                             (dolist (f '("Maple Mono NF CN" "Sarasa Mono SC"
                                          "霞鹜文楷等宽" "LXGW WenKai Mono"
                                          "Noto Sans CJK SC"))
                               (when (find-font (font-spec :family f))
                                 (throw 'found f)))
                             nil))))
      (when font-family
        (dolist (charset '(kana han cjk-misc bopomofo))
          (set-fontset-font t charset (font-spec :family font-family) nil 'prepend))))))

;; Depth 0 = runs after unicode-fonts (depth -90), so prepend wins
(add-hook 'after-setting-font-hook #'my/setup-cjk-fonts 0)
;; (setq doom-theme 'modus-operandi)
;; (setq doom-theme 'modus-operandi-tinted)
(setq doom-theme 'modus-operandi-tritanopia)
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
  (setq pdf-info-epdfinfo-program "C:\\Users\\fengxing.chen\\scoop\\apps\\msys2\\current\\mingw64\\bin\\epdfinfo.exe")

  ;; project.el / grep / locate all call bare `find`, which on Windows PATH
  ;; resolves to C:\Windows\System32\FIND.EXE — a completely different tool
  ;; (file-content search), whose Unix-style args trigger
  ;; "FIND: Parameter format not correct". Point at GNU find from Git for
  ;; Windows (same source as the unzip binary used for nov.el).
  (let ((gnu-find "C:/Program Files/Git/usr/bin/find.exe"))
    (when (file-executable-p gnu-find)
      (setq find-program gnu-find))))
(setq system-time-locale "C")
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
      '((sequence "TODO(t)" "NEXT(n)" "PROG(p!)" "WAIT(w@/!)" "|" "DONE(d!)" "FAIL(f@)")))
(setq org-todo-keyword-faces
      '(("TODO" :foreground "#2952a3" :weight bold)
        ("NEXT" :foreground "#e67e22" :weight bold)
        ("PROG" :foreground "#c0392b" :weight bold)
        ("WAIT" :foreground "#8b6914" :weight bold)
        ("DONE" :foreground "#2e7d32" :weight bold)
        ("FAIL" :foreground "#9e9e9e" :weight bold)))

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
;; org-modern headings 和 org-indent-mode 都会改 heading 可见属性，
;; Windows CJK 字体下冲突导致同级标题对不齐。关掉 heading 美化，让
;; org-superstar 专门管 bullet，org-indent 单独管缩进。
(setq org-modern-star nil
      org-modern-hide-stars nil
      org-modern-keyword nil
      org-modern-priority nil
      org-modern-todo nil
      org-modern-tag nil)
;; org-superstar: 只替换 bullet 字符，不动字体度量，对齐不会歪
(setq org-superstar-headline-bullets-list '(?◉ ?○ ?⚬ ?◈ ?◇)
      org-superstar-cycle-headline-bullets nil
      org-superstar-remove-leading-stars nil
      org-superstar-todo-bullet-alist
      '(("TODO" . ?☐) ("NEXT" . ?▶) ("PROG" . ?◉) ("WAIT" . ?⏳)
        ("DONE" . ?☑) ("FAIL" . ?✗))
      org-superstar-item-bullet-alist
      '((?* . ?•) (?+ . ?➤) (?- . ?–)))
(add-hook 'org-mode-hook #'org-superstar-mode)
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
        ("j" "Journal" entry
         (file my/journal-capture-target)
         "* %<%H:%M>\n%?"
         :empty-lines 1 :jump-to-captured t)
        ("r" "r · 稍后读 [inbox]" entry (file "~/org/inbox.org")
         "* TODO [[%^{URL}][%^{Title}]]\n:PROPERTIES:\n:CREATED: %U\n:END:\n%?" :empty-lines 1)
        ("m" "Media")
        ("mm" "电影 · 想看" entry
         (file+olp "~/org/collections/media.org" "影视动漫" "电影" "想看")
         "**** TODO %^{片名}\n:PROPERTIES:\n:添加时间: %U\n:END:\n%?"
         :empty-lines 1 :jump-to-captured t)
        ("mM" "电影 · 看完" entry
         (file+olp "~/org/collections/media.org" "影视动漫" "电影" "看完")
         "**** DONE %^{片名}\n:PROPERTIES:\n:完成日期: %<[%Y-%m-%d]>\n:END:\n%?"
         :empty-lines 1 :jump-to-captured t)
        ("mt" "电视剧 · 想看" entry
         (file+olp "~/org/collections/media.org" "影视动漫" "电视剧" "想看")
         "**** TODO %^{片名}\n:PROPERTIES:\n:添加时间: %U\n:END:\n%?"
         :empty-lines 1 :jump-to-captured t)
        ("mT" "电视剧 · 看完" entry
         (file+olp "~/org/collections/media.org" "影视动漫" "电视剧" "看完")
         "**** DONE %^{片名}\n:PROPERTIES:\n:完成日期: %<[%Y-%m-%d]>\n:END:\n%?"
         :empty-lines 1 :jump-to-captured t)
        ("ma" "动漫 · 想看" entry
         (file+olp "~/org/collections/media.org" "影视动漫" "动漫" "想看")
         "**** TODO %^{片名}\n:PROPERTIES:\n:添加时间: %U\n:END:\n%?"
         :empty-lines 1 :jump-to-captured t)
        ("mA" "动漫 · 看完" entry
         (file+olp "~/org/collections/media.org" "影视动漫" "动漫" "看完")
         "**** DONE %^{片名}\n:PROPERTIES:\n:完成日期: %<[%Y-%m-%d]>\n:END:\n%?"
         :empty-lines 1 :jump-to-captured t)
        ("b" "Books")
        ("bb" "书 · 待阅读" entry
         (file+olp "~/org/collections/books.org" "待阅读")
         "*** TODO %^{书名}\n:PROPERTIES:\n:作者: %^{作者}\n:类型: %^{类型|小说|非虚构|理财|网文|漫画|其他}\n:来源: %^{来源|微信读书|豆瓣|Z-Library|实体书|其他}\n:添加时间: %U\n:END:\n%?"
         :empty-lines 1 :jump-to-captured t)
        ("bB" "书 · 阅读中" entry
         (file+olp "~/org/collections/books.org" "阅读中")
         "*** READING %^{书名}\n:PROPERTIES:\n:作者: %^{作者}\n:类型: %^{类型|小说|非虚构|理财|网文|漫画|其他}\n:来源: %^{来源|微信读书|豆瓣|Z-Library|实体书|其他}\n:添加时间: %U\n:END:\n%?"
         :empty-lines 1 :jump-to-captured t)
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
        ("~/org/collections/books.org" :maxlevel . 2)
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

;; ---- Force org-babel shell blocks to use Git bash on Windows ----
;; Default shell-file-name is cmdproxy.exe → cmd.exe, which can't handle "\"
;; line continuations, $VAR expansion, or the "TOKEN=val" preamble that :var emits.
;; 8.3 short path avoids the space in "Program Files" — ob-shell's
;; org-babel-eval uses (format "%s %s" shell-file-name ...) without quoting.
(defvar my/org-babel-bash nil)
(setq my/org-babel-bash "C:/PROGRA~1/Git/usr/bin/bash.exe")
(after! ob-shell
  (define-advice org-babel-execute:shell
      (:around (orig body params) use-bash-on-windows)
    (if (and (eq system-type 'windows-nt)
             (file-exists-p my/org-babel-bash))
        (let ((shell-file-name my/org-babel-bash)
              (shell-command-switch "-c")
              (explicit-shell-file-name my/org-babel-bash))
          (funcall orig body params))
      (funcall orig body params)))
  (define-advice org-babel-execute:bash
      (:around (orig body params) use-bash-on-windows)
    (if (and (eq system-type 'windows-nt)
             (file-exists-p my/org-babel-bash))
        (let ((shell-file-name my/org-babel-bash)
              (shell-command-switch "-c")
              (explicit-shell-file-name my/org-babel-bash))
          (funcall orig body params))
      (funcall orig body params))))
;; ---- Media library auto-rebucket on TODO state change ----
(defun my/media-org-file-p ()
  "Return non-nil when visiting the media library file."
  (and (buffer-file-name)
       (file-equal-p (expand-file-name "~/org/collections/media.org")
                     (expand-file-name (buffer-file-name)))))

(defun my/media-org-target-section-for-state (state)
  "Map TODO STATE to a media library section name."
  (pcase state
    ((or "TODO" "NEXT") "想看")
    ("DOING" "在看")
    ("DONE" "看完")
    ((or "DROPPED" "CANCELLED") "已放弃")
    (_ nil)))

(defun my/media-org-current-entry-context ()
  "Return plist for the current media entry, or nil when not applicable."
  (save-excursion
    (org-back-to-heading t)
    (when (= (org-outline-level) 4)
      (let (category section)
        (save-excursion
          (while (org-up-heading-safe)
            (pcase (org-outline-level)
              (3 (setq section (org-get-heading t t t t)))
              (2 (setq category (org-get-heading t t t t))))))
        (when (and (member category '("电影" "电视剧" "动漫"))
                   (member section '("想看" "在看" "看完" "已放弃")))
          (list :category category :section section))))))

(defun my/media-org-find-section-position (category section)
  "Return buffer position of CATEGORY -> SECTION in media.org."
  (save-excursion
    (save-restriction
      (goto-char (point-min))
      (when (re-search-forward "^\\* 影视动漫$" nil t)
        (org-narrow-to-subtree)
        (goto-char (point-min))
        (when (re-search-forward (format "^\\*\\* %s$" (regexp-quote category)) nil t)
          (org-narrow-to-subtree)
          (goto-char (point-min))
          (when (re-search-forward (format "^\\*\\*\\* %s$" (regexp-quote section)) nil t)
            (line-beginning-position)))))))

(defun my/media-org-rebucket-current-entry ()
  "Move the current media entry to the section implied by its TODO state."
  (interactive)
  (when-let* ((context (and (my/media-org-file-p)
                            (my/media-org-current-entry-context)))
              (target-section (my/media-org-target-section-for-state org-state))
              (category (plist-get context :category))
              (current-section (plist-get context :section)))
    (unless (equal current-section target-section)
      (let ((level (org-outline-level)))
        (org-cut-subtree)
        (when-let ((target-pos (my/media-org-find-section-position category target-section)))
          (goto-char target-pos)
          (org-end-of-subtree t t)
          (unless (bolp)
            (insert "\n"))
          (org-paste-subtree level))))))

(add-hook 'org-after-todo-state-change-hook #'my/media-org-rebucket-current-entry)
(defun my/books-org-file-p ()
  "Return non-nil when visiting the books collection file."
  (and (buffer-file-name)
       (file-equal-p (expand-file-name "~/org/collections/books.org")
                     (expand-file-name (buffer-file-name)))))

(defun my/books-org-target-section-for-state (state)
  "Map TODO STATE to a books collection section name."
  (pcase state
    ((or "TODO" "NEXT" "WAITING") "待阅读")
    ("READING" "阅读中")
    ("DONE" "已读完")
    ((or "DROPPED" "HOLD" "CANCELLED") "已放弃")
    (_ nil)))

(defun my/books-org-current-entry-context ()
  "Return plist for the current books entry, or nil when not applicable."
  (save-excursion
    (org-back-to-heading t)
    (when (= (org-outline-level) 2)
      (let (section)
        (save-excursion
          (when (org-up-heading-safe)
            (setq section (org-get-heading t t t t))))
        (when (member section '("待阅读" "阅读中" "已读完" "已放弃"))
          (list :section section))))))

(defun my/books-org-find-section-position (section)
  "Return buffer position of SECTION in books.org."
  (save-excursion
    (save-restriction
      (goto-char (point-min))
      (when (re-search-forward (format "^\\* %s$" (regexp-quote section)) nil t)
        (line-beginning-position)))))

(defun my/books-org-rebucket-current-entry ()
  "Move the current books entry to the section implied by its TODO state."
  (interactive)
  (when-let* ((context (and (my/books-org-file-p)
                            (my/books-org-current-entry-context)))
              (target-section (my/books-org-target-section-for-state org-state))
              (current-section (plist-get context :section)))
    (unless (equal current-section target-section)
      (let ((level (org-outline-level)))
        (org-cut-subtree)
        (when-let ((target-pos (my/books-org-find-section-position target-section)))
          (goto-char target-pos)
          (org-end-of-subtree t t)
          (unless (bolp)
            (insert "\n"))
          (org-paste-subtree level))))))

(add-hook 'org-after-todo-state-change-hook #'my/books-org-rebucket-current-entry)
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
(defun my/org-download-screenshot-command ()
  "Platform-appropriate screenshot command for org-download."
  (cond
   ((featurep :system 'windows)
    "powershell -Command \"Add-Type -AssemblyName System.Windows.Forms; $img = [System.Windows.Forms.Clipboard]::GetImage(); if ($img) { $img.Save('%s', [System.Drawing.Imaging.ImageFormat]::Png) } else { Write-Error 'No image in clipboard' }\"")
   ((featurep :system 'macos)
    "sh -c 'if command -v pngpaste >/dev/null 2>&1 && pngpaste \"$1\" >/dev/null 2>&1; then exit 0; else screencapture -i \"$1\"; fi' _ %s")
   (t
    "sh -c 'if command -v xclip >/dev/null 2>&1; then xclip -selection clipboard -t image/png -o > \"$1\" 2>/dev/null || true; fi; if [ ! -s \"$1\" ]; then if command -v wl-paste >/dev/null 2>&1; then wl-paste --no-newline --type image/png > \"$1\" 2>/dev/null || true; fi; fi; if [ ! -s \"$1\" ]; then if command -v maim >/dev/null 2>&1; then maim -s \"$1\"; elif command -v grim >/dev/null 2>&1 && command -v slurp >/dev/null 2>&1; then grim -g \"$(slurp)\" \"$1\"; fi; fi' _ %s")))

(defun my/org-download-denote-file-format (filename)
  "Rewrite FILENAME to denote style: <id>--<slug><ext>.
Delegates to `denote-format-file-name' so sluggify rules, separators,
and the @@-identifier delimiter behavior all track denote itself.
Used as `org-download-file-format-function'."
  (let* ((ext  (or (file-name-extension filename t) ""))
         (base (or (file-name-sans-extension filename) ""))
         (id   (format-time-string denote-date-identifier-format)))
    (file-name-nondirectory
     (denote-format-file-name "./" id nil base ext nil))))

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
;; Pixel-aligned agenda tags (fix CJK misalignment)
(defun my/org-agenda-align-tags-pixel ()
  "Right-align agenda tags using pixel-based display alignment."
  ;; Windows Emacs 30.2 is currently crashing in agenda display paths on this
  ;; machine, so keep the safer default spacing there.
  (unless (eq system-type 'windows-nt)
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
                                 'display `(space :align-to (,align-to))))))))))

(add-hook 'org-agenda-finalize-hook #'my/org-agenda-align-tags-pixel)
;; org-download — 走 org-attach 体系
(after! org
  (use-package! org-download
    :commands (org-download-clipboard org-download-screenshot org-download-yank org-download-delete)
    :config
    (add-hook 'org-mode-hook 'org-download-enable)
    (setq org-download-method 'directory
          org-download-image-dir (expand-file-name "data/" org-directory)
          org-download-heading-lvl nil
          org-download-timestamp ""
          org-download-image-org-width 800
          org-download-annotate-function (lambda (_link) "")
          org-download-screenshot-method (my/org-download-screenshot-command)
          org-download-file-format-function #'my/org-download-denote-file-format)

    ;; Fix: org-download-dnd-fallback for Emacs 30+
    (when (fboundp 'dnd-handle-multiple-urls)
      (defun org-download-dnd-fallback (uri action)
        (let ((dnd-protocol-alist
               (rassq-delete-all
                'org-download-dnd
                (copy-alist dnd-protocol-alist))))
          (dnd-handle-multiple-urls
           (selected-window) (list uri) action))))

    ;; Fix: Full percent-decoding for non-ASCII filenames.
    ;; Also fixes Windows local paths: url-generic-parse-url treats "C:" as a
    ;; URL scheme, so url-path-and-query can return nil for C:/... paths.
    ;; Use file-name-nondirectory directly for absolute local paths.
    (defun org-download--fullname (link &optional ext)
      "Return the file name where LINK will be saved to.
EXT can hold the file extension, in case LINK doesn't provide it.
[patched] Robust Windows path handling + full percent-decoding."
      (let ((filename
             (decode-coding-string
              (url-unhex-string
               (file-name-nondirectory
                (if (file-name-absolute-p link)
                    link
                  (or (car (url-path-and-query
                            (url-generic-parse-url link)))
                      link))))
              'utf-8))
            (dir (org-download--dir)))
        (when (string-match ".*?\\.\\(?:png\\|jpg\\)\\(.*\\)$" filename)
          (setq filename (replace-match "" nil nil filename 1)))
        (when ext
          (setq filename (concat (file-name-sans-extension filename) "." ext)))
        (abbreviate-file-name
         (expand-file-name
          (funcall org-download-file-format-function filename)
          dir))))

    ;; Fix: org-download-clipboard on Windows ignores user's screenshot-method
    ;; and hard-requires ImageMagick. Since our PowerShell method already reads
    ;; from clipboard, just bypass the override and call org-download-screenshot.
    (when (featurep :system 'windows)
      (defadvice! my/org-download-clipboard-use-powershell (&optional basename)
        :override #'org-download-clipboard
        (org-id-get-create)
        (org-download-screenshot basename)))))
;; 任意文件拖入 org buffer → 复制到 ~/org/data/ 并用 denote 命名 +
;; 在光标处插入 file: 链接。对 epub / pdf / zip 等非图片也生效。
(defun my/org-dnd-copy-to-data (uri _action)
  "Copy locally-dropped file URI into ~/org/data/ with a denote-style name,
insert a `file:' link at point, and return 'copy.
Only active in `org-mode'; returns nil elsewhere so the next handler runs."
  (when (derived-mode-p 'org-mode)
    (let ((src (ignore-errors (dnd-get-local-file-name uri t))))
      (when (and src (file-regular-p src))
        (let* ((dest-dir  (expand-file-name "data/" org-directory))
               (dest-name (my/org-download-denote-file-format
                           (file-name-nondirectory src)))
               (dest      (expand-file-name dest-name dest-dir)))
          (make-directory dest-dir t)
          (copy-file src dest 1)
          (insert (format "[[file:%s]]"
                          (file-relative-name dest default-directory)))
          'copy)))))

;; Org 9.7+ 在 `org-setup-yank-dnd-handlers' 里用 `setq-local' 把
;; "^file:///" 等 3 条前置到 buffer-local `dnd-protocol-alist'，走 org-attach
;; 的桶路径。全局 `add-to-list' 压不住 buffer-local。改成在 `org-mode-hook'
;; 里显式往 buffer-local 前面插我们的 handler。
(defun my/org-prepend-flat-dnd-handler ()
  "Make our flat-data DnD handler win over Org's builtin file: handlers."
  (setq-local dnd-protocol-alist
              (cons '("^file:" . my/org-dnd-copy-to-data)
                    dnd-protocol-alist)))
(add-hook 'org-mode-hook #'my/org-prepend-flat-dnd-handler)
;; Markdown: 同样的扁平 + denote 命名流程。插入 ![alt](path) 或 [name](path)。
(defconst my/markdown-image-extensions
  '("png" "jpg" "jpeg" "gif" "svg" "webp" "bmp" "avif")
  "Extensions treated as images for markdown DnD insertion.")

(defun my/markdown-dnd-copy-to-data (uri _action)
  "Copy locally-dropped file URI into ~/org/data/ with denote-style name,
insert a markdown image / link at point, return 'copy.
Only active in `markdown-mode'; returns nil elsewhere."
  (when (derived-mode-p 'markdown-mode)
    (let ((src (ignore-errors (dnd-get-local-file-name uri t))))
      (when (and src (file-regular-p src))
        (let* ((dest-dir  (expand-file-name "data/" org-directory))
               (orig-name (file-name-nondirectory src))
               (dest-name (my/org-download-denote-file-format orig-name))
               (dest      (expand-file-name dest-name dest-dir))
               (ext       (downcase (or (file-name-extension orig-name) "")))
               (rel       (file-relative-name dest default-directory))
               (label     (file-name-base orig-name)))
          (make-directory dest-dir t)
          (copy-file src dest 1)
          (insert (if (member ext my/markdown-image-extensions)
                      (format "![%s](%s)" label rel)
                    (format "[%s](%s)" label rel)))
          'copy)))))

(defun my/markdown-prepend-flat-dnd-handler ()
  "Prepend our flat-data DnD handler buffer-locally in markdown-mode."
  (setq-local dnd-protocol-alist
              (cons '("^file:" . my/markdown-dnd-copy-to-data)
                    dnd-protocol-alist)))
(add-hook 'markdown-mode-hook #'my/markdown-prepend-flat-dnd-handler)
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
     ((member todo-state '("DROPPED" "CANCELLED"))  "cancelled")
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
                      (org-gcal-sync)
                      (my/org-gcal-auto-post)))))
(use-package! denote
  ;; NOT lazy-loaded: we need denote-dired-directories and the dired-mode-hook
  ;; in place as soon as any dired buffer opens, otherwise keyword highlighting
  ;; silently no-ops until you first invoke a denote command.
  :demand t
  :init
  (make-directory (expand-file-name "denote/" org-directory) t)
  :config
  (setq denote-directory (file-name-as-directory (expand-file-name org-directory))
        denote-file-type 'org
        denote-known-keywords '("emacs" "read")
        denote-infer-keywords t
        denote-sort-keywords t
        ;; Prompt for subdir so new notes land in references/ | denote/ | notes/
        denote-prompts '(subdirectory title keywords)
        denote-date-prompt-use-org-read-date t
        ;; Only scan references/, denote/, notes/, journal/ — skip everything else under ~/org/
        denote-excluded-directories-regexp
        (rx (or (seq bos ".")
                (seq bos (or "areas" "collections" "data"
                             "projects" "roam" "templates" "tmp") eos)))
        denote-rename-confirmations nil
        denote-backlinks-show-context t
        denote-dired-directories (list denote-directory)
        denote-dired-directories-include-subdirectories t)
;; Windows-safe replacement for `denote-dired-mode-in-directories' — the
  ;; stock version uses case-sensitive `string-prefix-p' against file-truename,
  ;; which fails on Windows when drive-letter or path case disagrees
  ;; (e.g. "c:/Users/..." vs "C:/Users/...").
  (defun my/denote-dired-mode-maybe ()
    "Enable `denote-dired-mode' when the current dired buffer is under a
denote-dired directory, matching case-insensitively.

Hooked onto `after-change-major-mode-hook' (append) rather than
`dired-mode-hook' because the latter fires BEFORE
`font-lock-global-mode' and `diredfl-global-mode' are applied to
the buffer — anything we add to `font-lock-keywords' at that point
gets reset by `font-lock-set-defaults' later, and diredfl's override
faces cover ours. `after-change-major-mode-hook' runs those global
modes first, so when our hook lands everything is settled."
    (when (derived-mode-p 'dired-mode)
      (let ((dir (file-name-as-directory (expand-file-name default-directory))))
        (when (seq-some
               (lambda (root)
                 (let ((root (file-name-as-directory (expand-file-name root))))
                   (or (string-equal-ignore-case dir root)
                       (and denote-dired-directories-include-subdirectories
                            (eq t (compare-strings
                                   root 0 nil
                                   dir  0 (length root)
                                   t))))))  ; t = ignore case
               denote-dired-directories)
          ;; Order matters: disable diredfl BEFORE enabling denote-dired-mode.
          ;; diredfl-mode's disable body calls `font-lock-refresh-defaults',
          ;; which toggles font-lock off/on and wipes `font-lock-keywords' back
          ;; to the mode default. If we enable denote-dired-mode first, its
          ;; `font-lock-add-keywords' call gets erased by the subsequent
          ;; diredfl disable.
          (when (bound-and-true-p diredfl-mode)
            (diredfl-mode -1))
          (denote-dired-mode 1)
          (font-lock-flush)))))

  ;; append=t → run after font-lock-global-mode and diredfl-global-mode.
  (add-hook 'after-change-major-mode-hook #'my/denote-dired-mode-maybe t)

  ;; Strip newlines from the complete filename — catches \n wherever it enters
  ;; the pipeline (title prompt, slug, or upstream callers).
  (advice-add 'denote-format-file-name :filter-return
              (lambda (filename) (replace-regexp-in-string "[\n\r]" "" filename))))
;; Disable dirvish globally — its pre-redisplay overlay attrs cover denote's
;; font-lock-based filename highlighting, and user prefers plain dired anyway.
(after! dirvish
  (dirvish-override-dired-mode -1))

;; Dired: show filenames only (hide permissions/size/time/owner columns).
;; `(` toggles details back on when you need them.
;;
;; Defer via `run-at-time 0' so we enable hide-details AFTER the whole
;; mode-setup cascade finishes — in denote-managed dirs like
;; ~/org/notes/, `my/denote-dired-mode-maybe' disables diredfl, enables
;; denote-dired-mode and calls `font-lock-flush', and the subsequent
;; jit-lock fontification is what lays down the `invisible' text
;; properties that hide-details relies on. Enabling the mode inline
;; (whether in dired-mode-hook or after-change-major-mode-hook) sets
;; the invisibility spec too early in that cascade, so the flushed
;; refontification never tags the detail columns as invisible.
(defun my/dired-hide-details-on ()
  (when (derived-mode-p 'dired-mode)
    (run-at-time 0 nil
                 (lambda (buf)
                   (when (buffer-live-p buf)
                     (with-current-buffer buf
                       (dired-hide-details-mode 1))))
                 (current-buffer))))
(add-hook 'after-change-major-mode-hook #'my/dired-hide-details-on t)
(use-package! denote-org
  :after (denote org))

(use-package! denote-markdown
  :after (denote markdown-mode)
  :commands (denote-markdown-convert-links-to-file-paths
             denote-markdown-convert-links-to-denote-type
             denote-markdown-convert-links-to-obsidian-type
             denote-markdown-convert-obsidian-links-to-denote-type))
;; ---- consult-notes: 多源统一检索 ----
(use-package! consult-notes
  :after (consult denote)
  :commands (consult-notes consult-notes-search-in-all-notes)
  :config
  ;; Directory sources — narrow by key
  (setq consult-notes-file-dir-sources
        `(("Notes"      ?n ,(expand-file-name "notes/"      org-directory))
          ("Denote"     ?d ,(expand-file-name "denote/"     org-directory))
          ("References" ?r ,(expand-file-name "references/" org-directory))
          ("Projects"   ?p ,(expand-file-name "projects/"   org-directory))
          ("Areas"      ?a ,(expand-file-name "areas/"      org-directory))
          ("Collections" ?c ,(expand-file-name "collections/" org-directory))))

  ;; Surface headings from single-file inboxes
  (setq consult-notes-org-headings-files
        (list (expand-file-name "inbox.org"       org-directory)
              (expand-file-name "append-note.org" org-directory)))
  (consult-notes-org-headings-mode)

  ;; Denote integration — adds ID/title/#keywords/dir columns
  (when (locate-library "denote")
    (consult-notes-denote-mode))

  ;; Only text files from denote dir (Denote 3.x API)
  (setq consult-notes-denote-files-function
        (lambda () (denote-directory-files nil t t))))
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
         (slug (replace-regexp-in-string "[^a-zA-Z0-9一-鿿]+" "-"
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
                  "[^a-zA-Z0-9一-鿿]+" "-"
                  (downcase (string-trim title)) t t)))
         (file  (expand-file-name (concat "references/" slug ".org") org-directory)))
    (set-buffer (org-capture-target-buffer file))
    (when (= (buffer-size) 0)
      (insert (format "#+title: %s\n#+filetags: :ref:\n#+created: %s\n\n* Source\n%s\n\n* Summary\n\n* My Notes\n"
                      title (format-time-string "[%Y-%m-%d %a]") url)))
    (goto-char (point-max))
    (or (re-search-backward "^\\* My Notes" nil t) (goto-char (point-max)))
    (forward-line 1)))
(use-package! elfeed
  :commands elfeed
  :config
  (require 'subr-x)
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

  (defvar my/elfeed-feed-history nil
    "Minibuffer history for feed selection commands.")

  (defun my/elfeed-current-entry ()
    "Return the current Elfeed entry in search or show buffers."
    (cond
     ((derived-mode-p 'elfeed-show-mode) elfeed-show-entry)
     ((derived-mode-p 'elfeed-search-mode) (elfeed-search-selected :ignore-region))
     (t nil)))

  (defun my/elfeed-feed-display-title (feed)
    "Return a human-readable title for FEED."
    (or (elfeed-meta feed :title)
        (elfeed-feed-title feed)
        (elfeed-feed-url feed)
        "Unknown feed"))

  (defun my/elfeed-url-origin (url)
    "Return the scheme and host portion of URL, ending with a slash."
    (when (and url (string-match "\\`\\(https?://[^/]+\\)" url))
      (concat (match-string 1 url) "/")))

  (defun my/elfeed-guess-homepage (feed-url)
    "Best-effort homepage guess for FEED-URL."
    (when feed-url
      (let ((homepage (car (split-string feed-url "[?#]" t))))
        (dolist (pattern '("/index\\.xml/?$"
                           "/atom\\.xml/?$"
                           "/rss\\.xml/?$"
                           "/feed\\.xml/?$"
                           "/feeds?/[^/]+\\(?:\\.xml\\|\\.atom\\|\\.rss\\)?/?$"
                           "/\\(?:feed\\|rss\\|atom\\)/?$"))
          (setq homepage (replace-regexp-in-string pattern "/" homepage t t)))
        (unless (string-match-p "/$" homepage)
          (setq homepage
                (replace-regexp-in-string "/[^/]+\\(?:\\.xml\\|\\.rss\\|\\.atom\\)?$"
                                          "/"
                                          homepage
                                          t
                                          t)))
        (replace-regexp-in-string "/+$" "/" homepage t t))))

  (defun my/elfeed-entry-homepage (entry)
    "Return a homepage URL for ENTRY."
    (when-let* ((feed (elfeed-entry-feed entry))
                (feed-url (elfeed-feed-url feed)))
      (let* ((entry-url (elfeed-entry-link entry))
             (feed-origin (my/elfeed-url-origin feed-url))
             (entry-origin (my/elfeed-url-origin entry-url)))
        (cond
         ;; Prefer the article host when the feed comes from a proxy or bridge.
         ((and entry-origin feed-origin (not (string= entry-origin feed-origin)))
          entry-origin)
         (t
          (or (my/elfeed-guess-homepage feed-url)
              entry-origin
              feed-origin))))))

  (defun my/elfeed-browse-homepage ()
    "Open the homepage of the current entry's feed."
    (interactive)
    (if-let ((entry (my/elfeed-current-entry)))
        (if-let ((homepage (my/elfeed-entry-homepage entry)))
            (browse-url homepage)
          (user-error "Could not infer a homepage for this feed"))
      (user-error "No Elfeed entry at point")))

  (defun my/elfeed-toggle-unread ()
    "Toggle the `unread' tag on the current Elfeed entry or entries."
    (interactive)
    (cond
     ((derived-mode-p 'elfeed-search-mode)
      (elfeed-search-toggle-all 'unread))
     ((derived-mode-p 'elfeed-show-mode)
      (if (elfeed-tagged-p 'unread elfeed-show-entry)
          (elfeed-show-untag 'unread)
        (elfeed-show-tag 'unread)))
     (t
      (user-error "Not in an Elfeed buffer"))))

  (defun my/elfeed-feed-candidates ()
    "Return an alist of display string to feed URL for Elfeed feeds."
    (let ((table (make-hash-table :test 'equal)))
      (with-elfeed-db-visit (entry feed)
        (let* ((url (elfeed-feed-url feed))
               (title (my/elfeed-feed-display-title feed))
               (current (or (gethash url table)
                            (list :url url :title title :all 0 :unread 0)))
               (all (1+ (plist-get current :all)))
               (unread (if (elfeed-tagged-p 'unread entry)
                           (1+ (plist-get current :unread))
                         (plist-get current :unread))))
          (puthash url
                   (list :url url :title title :all all :unread unread)
                   table)))
      (sort
       (let (candidates)
         (maphash
          (lambda (url data)
            (push (cons (format "[%d/%d] %s\t%s"
                                (plist-get data :unread)
                                (plist-get data :all)
                                (plist-get data :title)
                                url)
                        url)
                  candidates))
          table)
         candidates)
       (lambda (a b) (string-lessp (car a) (car b))))))

  (defun my/elfeed-read-feed-url ()
    "Prompt for a feed URL from the current Elfeed database."
    (let* ((all-feeds "[All feeds]")
           (candidates (my/elfeed-feed-candidates))
           (choices (cons all-feeds (mapcar #'car candidates)))
           (choice (if (require 'consult nil t)
                       (consult--read
                        choices
                        :prompt "Feed: "
                        :sort nil
                        :require-match t
                        :history 'my/elfeed-feed-history)
                     (completing-read "Feed: " choices nil t nil 'my/elfeed-feed-history))))
      (unless (equal choice all-feeds)
        (cdr (assoc choice candidates)))))

  (defun my/elfeed-replace-feed-filter (filter feed-url)
    "Replace feed-specific clauses in FILTER with FEED-URL."
    (let ((parts (cl-remove-if (lambda (part) (string-prefix-p "=" part))
                               (split-string (string-trim (or filter "")) "[ \t\n]+" t))))
      (string-join
       (append parts
               (when feed-url
                 (list (concat "=" (regexp-quote feed-url)))))
       " ")))

  (defun my/elfeed-search-filter-by-feed ()
    "Use `consult' or `completing-read' to filter Elfeed by feed."
    (interactive)
    (unless (derived-mode-p 'elfeed-search-mode)
      (user-error "Feed filtering is only available in elfeed-search"))
    (let* ((feed-url (my/elfeed-read-feed-url))
           (new-filter (my/elfeed-replace-feed-filter elfeed-search-filter feed-url)))
      (elfeed-search-set-filter new-filter)
      (message (if feed-url
                   "Filtered Elfeed to %s"
                 "Cleared feed-specific filter")
               (or feed-url "all feeds"))))

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

  (map! :map elfeed-search-mode-map
        :desc "Filter by feed"      "F" #'my/elfeed-search-filter-by-feed
        :desc "Browse feed homepage" "B" #'my/elfeed-browse-homepage
        :desc "Toggle unread"       "R" #'my/elfeed-toggle-unread
        :desc "Play with mpv"       "v" #'my/elfeed-play-with-mpv)
  (map! :map elfeed-show-mode-map
        :desc "Browse feed homepage" "B" #'my/elfeed-browse-homepage
        :desc "Toggle unread"       "R" #'my/elfeed-toggle-unread
        :desc "Play with mpv"       "v" #'my/elfeed-play-with-mpv))
(use-package! elfeed-org
  :after elfeed
  :config
  (elfeed-org)
  (setq rmh-elfeed-org-files (list (expand-file-name "~/org/collections/elfeed.org"))))
(use-package! denote-journal
  :after denote
  :hook (calendar-mode . denote-journal-calendar-mode)
  :init
  (with-eval-after-load 'calendar
    (define-key calendar-mode-map (kbd "f") #'denote-journal-calendar-find-file)
    (define-key calendar-mode-map (kbd "n") #'denote-journal-calendar-new-or-existing)
    (with-eval-after-load 'evil
      (evil-define-key '(normal motion emacs) calendar-mode-map
        (kbd "F") #'denote-journal-calendar-find-file
        (kbd "N") #'denote-journal-calendar-new-or-existing)))
  :config
  (setq denote-journal-directory (expand-file-name "journal/" org-directory)
        denote-journal-keyword "journal"
        denote-journal-title-format 'day-date-month-year))

(defun my/journal-capture-target ()
  "Return path to today's denote-journal entry for `org-capture'.
Before 03:00 falls back to the previous day, matching the prior
org-journal behaviour. Creates the file with denote-journal's standard
front-matter if it does not yet exist."
  (let* ((now  (decode-time))
         (hour (nth 2 now))
         (time (if (< hour 3)
                   (time-subtract (current-time) (seconds-to-time 86400))
                 (current-time))))
    (denote-journal-path-to-new-or-existing-entry
     (format-time-string "%Y-%m-%d" time))))
(defvar my/weather-location "上海"
  "wttr.in 查询地点，中英文均可。")

(defun my/get-weather ()
  "从 wttr.in 获取天气，返回紧凑单行字符串，格式：上海: ⛅️  +22°C"
  (let ((coding-system-for-read 'utf-8))
    (string-trim
     (shell-command-to-string
      (format "curl -s --max-time 5 \"https://wttr.in/%s?format=3\""
              (url-hexify-string my/weather-location))))))

(defun my/insert-weather ()
  "在光标处插入当前天气（M-x my/insert-weather）。"
  (interactive)
  (insert (my/get-weather)))

(defun my/denote-journal-auto-weather ()
  "新建 journal 文件时自动在末尾追加天气。"
  (when (and (buffer-file-name)
             (string-match-p "__journal" (buffer-file-name)))
    (save-excursion
      (goto-char (point-max))
      (unless (bolp) (insert "\n"))
      (insert "\n** 天气\n")
      (insert (my/get-weather))
      (insert "\n"))))

(add-hook 'denote-after-new-note-hook #'my/denote-journal-auto-weather)
(use-package! cal-china-x
  :after calendar
  :config
  (setq calendar-mark-holidays-flag t
        cal-china-x-important-holidays cal-china-x-chinese-holidays
        calendar-holidays
        (append cal-china-x-important-holidays
                cal-china-x-general-holidays))
  (setq org-agenda-include-diary nil))
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
(after! org-noter
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
(after! markdown-mode
  (setq markdown-command "pandoc"
        markdown-open-command
        (when (featurep :system 'windows) "explorer.exe")
        markdown-fontify-code-blocks-natively t
        markdown-header-scaling t
        markdown-enable-wiki-links t
        markdown-italic-underscore t
        markdown-asymmetric-header nil
        markdown-live-preview-delete-export 'delete-on-destroy))
(map! :leader
      ;; :desc "org-capture" "X" nil
      ;; Gcal
      (:prefix ("G" . "gcal")
       :desc "Sync"   "s" #'org-gcal-sync
       :desc "Fetch"  "f" #'org-gcal-fetch
       :desc "Delete" "d" #'org-gcal-delete-at-point
       :desc "Push"   "p" #'my/org-gcal-auto-post)

      ;; Elfeed
      (:prefix ("o" . "open")
       ;; :desc "Org capture" "c" #'org-capture
       :desc "Elfeed" "e" #'elfeed)

      ;; Denote
      (:prefix ("n" . "notes")
       :desc "Consult notes (pick)"   "s" #'consult-notes
       :desc "Consult notes (search)" "S" #'consult-notes-search-in-all-notes
       (:prefix ("d" . "denote")
        :desc "New note"              "n" #'denote
        :desc "New note (choose type)" "N" #'denote-type
        :desc "New note in subdir"    "D" #'denote-subdirectory
        :desc "Open or create"        "f" #'denote-open-or-create
        :desc "Insert link"           "i" #'denote-link-or-create
        :desc "Insert link (region → title)" "I" #'denote-link
        :desc "Add links (search)"    "L" #'denote-add-links
        :desc "Backlinks"             "b" #'denote-backlinks
        :desc "Rename file"           "r" #'denote-rename-file
        :desc "Rename from front-matter" "R" #'denote-rename-file-using-front-matter
        :desc "Add keywords"          "k" #'denote-keywords-add
        :desc "Remove keywords"       "K" #'denote-keywords-remove
        :desc "Dired in denote dir"   "d" #'denote-dired
        :desc "Today's journal"       "j" #'denote-journal-new-or-existing-entry))

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
      ;; Denote link in org buffers
      (:prefix ("d" . "denote")
       :desc "Insert link"       "i" #'denote-link-or-create
       :desc "Backlinks"         "b" #'denote-backlinks
       :desc "Add keywords"      "k" #'denote-keywords-add
       :desc "Rename (front-matter)" "r" #'denote-rename-file-using-front-matter
       ;; denote-org: heading-level links + subtree extraction
       :desc "Link to heading"        "h" #'denote-org-link-to-heading
       :desc "Backlinks for heading"  "H" #'denote-org-backlinks-for-heading
       :desc "Extract subtree to note" "x" #'denote-org-extract-org-subtree
       ;; denote-org: dynamic blocks (update with C-c C-x C-u)
       (:prefix ("o" . "dblock")
        :desc "Links (by regexp)"        "l" #'denote-org-dblock-insert-links
        :desc "Backlinks"                "b" #'denote-org-dblock-insert-backlinks
        :desc "Missing links"            "m" #'denote-org-dblock-insert-missing-links
        :desc "Files"                    "f" #'denote-org-dblock-insert-files
        :desc "Files as headings"        "F" #'denote-org-dblock-insert-files-as-headings))
      ;; Todo
      :desc "TODO state" "t" #'org-todo
      ;; Rich paste
      :desc "Paste rich text" "V" #'my/org-paste-rich
      ;; Archive
      :desc "Archive done tasks" "A" #'my/org-archive-done-tasks)
;; Markdown-mode local keybindings — denote-markdown link conversion
(map! :after markdown-mode
      :map markdown-mode-map
      :localleader
      (:prefix ("d" . "denote")
       :desc "Insert link"              "i" #'denote-link-or-create
       :desc "Backlinks"                "b" #'denote-backlinks
       :desc "Rename (front-matter)"    "r" #'denote-rename-file-using-front-matter
       ;; Link conversion (denote-markdown)
       :desc "denote: → file path"      "f" #'denote-markdown-convert-links-to-file-paths
       :desc "file path → denote:"      "F" #'denote-markdown-convert-links-to-denote-type
       :desc "denote: → Obsidian"       "o" #'denote-markdown-convert-links-to-obsidian-type
       :desc "Obsidian → denote:"       "O" #'denote-markdown-convert-obsidian-links-to-denote-type))
(defadvice! my/org-ctrl-c-ctrl-c-note-fix (fn &rest args)
  :around #'org-ctrl-c-ctrl-c
  (if (string= (buffer-name) "*Org Note*")
      (org-store-log-note)
    (apply fn args)))
(when (featurep :system 'windows)
  (use-package! sis
    :demand t
    :config
    ;; Skip sis's auto-detect (runs too early, before the w32 frame exists,
    ;; so `(window-system)` is nil and `sis--ism` never gets set). Wire the
    ;; Windows IME API directly — with both functions set, `sis--init-ism`
    ;; flips `sis--ism` to t and the get/set path works from any frame.
    (setq sis-english-source nil
          sis-other-source   t
          sis-do-get         #'w32-get-ime-open-status
          sis-do-set         #'w32-set-ime-open-status)

    ;; Disable the 0.2 s idle poll timer. Enabling cursor-color / respect mode
    ;; auto-turns it on, and on Windows its high-frequency w32-get-ime-open-status
    ;; calls race with imm32.dll during buffer/window creation (SPC x → scratch)
    ;; and hard-crash Emacs. `after-focus-change-function` below covers the only
    ;; case we actually need resyncing for (focus returns from another app).
    (setq sis-auto-refresh-seconds nil)

    ;; Windows: use w32-get-ime-open-status as the single source of truth.
    ;; Rime's inline_ascii/commit_code don't touch the Windows IME API,
    ;; so sis--current can drift out of sync — poll the API directly.
    (defun sis-switch ()
      "Switch between English and other, driven by the Windows IME API."
      (interactive)
      (setq sis--for-buffer-locked nil)
      (if (w32-get-ime-open-status)
          (sis--set-english)
        (sis--set-other)))

    (sis-global-cursor-color-mode t)
    (when (fboundp 'modus-themes-get-color-value)
      (setq sis-other-cursor-color   (modus-themes-get-color-value 'fg-alt)
            sis-default-cursor-color (modus-themes-get-color-value 'border)))

    (sis-global-respect-mode t)
    (sis-global-context-mode t)
    (sis-global-inline-mode  t)

    (setq sis-respect-go-english-triggers (list #'org-agenda))

    ;; Resync IME state after Emacs frame regains focus, in case another
    ;; app toggled the system IME while Emacs was in the background.
    (add-function :after after-focus-change-function
                  (lambda () (sis--get)))

    :hook
    (org-capture-mode . sis-set-other))

  ;; Bind C-\ everywhere evil might grab keys first. `map!` without a state
  ;; modifier only binds global-map, which evil state maps can shadow.
  (define-key global-map (kbd "C-\\") #'sis-switch)
  (with-eval-after-load 'evil
    (define-key evil-normal-state-map (kbd "C-\\") #'sis-switch)
    (define-key evil-insert-state-map (kbd "C-\\") #'sis-switch)
    (define-key evil-motion-state-map (kbd "C-\\") #'sis-switch)
    (define-key evil-visual-state-map (kbd "C-\\") #'sis-switch)
    (define-key evil-emacs-state-map  (kbd "C-\\") #'sis-switch)))

;; Load secrets (org-gcal credentials etc.)
(load! "secrets" doom-user-dir t)
(use-package! ace-window
  :config
  (setq aw-keys '(?a ?s ?d ?f ?g ?h ?j ?k ?l)
        aw-scope 'frame
        aw-background t)

  ;; 覆盖默认的 other-window (C-x o)
  (global-set-key [remap other-window] #'ace-window)

  ;; 在 window 左上角显示编号（比 mode-line 更直观）
  (setq aw-display-mode-overlay t
        aw-leading-char-style 'char)

  ;; 配合 evil：在 motion/normal 态下也能用
  (after! evil
    (define-key evil-motion-state-map (kbd "C-w w") #'ace-window)
    (define-key evil-normal-state-map (kbd "C-w w") #'ace-window)))
(setq doom-scratch-default-major-mode 'org-mode)

(defun my/open-lisp-scratch ()
  "Open a lisp-interaction-mode scratch buffer for Elisp testing."
  (interactive)
  (let ((buf (get-buffer-create "*lisp-scratch*")))
    (with-current-buffer buf
      (unless (eq major-mode 'lisp-interaction-mode)
        (lisp-interaction-mode)))
    (switch-to-buffer buf)))
(require 'acp)
(require 'agent-shell)

(setq agent-shell-preferred-agent-config
      (agent-shell-anthropic-make-claude-code-config))

(setq agent-shell-anthropic-authentication
      (agent-shell-anthropic-make-authentication
       :api-key (lambda () my/athenai-api-key)))

(setq agent-shell-anthropic-claude-environment
      (agent-shell-make-environment-variables
       "ANTHROPIC_BASE_URL" "https://athenai.mihoyo.com/v1"
       "ANTHROPIC_MODEL" "claude-sonnet-4-6"
       "ANTHROPIC_SMALL_FAST_MODEL" "claude-sonnet-4-6"))

;; Keyboard: SPC o s → start Claude Code agent shell
;; Keyboard: SPC o c → start Codex agent shell

(setq agent-shell-openai-authentication
      (agent-shell-openai-make-authentication
       :api-key (lambda () my/athenai-api-key)))

(setq agent-shell-openai-codex-environment
      (agent-shell-make-environment-variables
       "OPENAI_BASE_URL" "https://athenai.mihoyo.com/v1"))

(map! :leader
      (:prefix ("o" . "open")
       :desc "Claude Code" "s" #'agent-shell-anthropic-start-claude-code
       :desc "Codex"       "c" #'agent-shell-openai-start-codex))
