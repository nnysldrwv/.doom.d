;;; config.el -*- lexical-binding: t; -*-

(use-package! gcmh
  :init
  (setq gcmh-idle-delay 5
        gcmh-high-cons-threshold (* 256 1024 1024))  ; 256MB during idle
  :config
  (gcmh-mode 1))
(setq user-full-name "Sean Yuan"
      user-mail-address "yuanxiang424@gmail.com")
(load! "secrets" doom-user-dir t)
(setq confirm-kill-emacs nil       ; 关闭 emacs 时无需额外确认
      system-time-locale "C"       ; 设置系统时间显示方式
      scroll-margin 2)             ; 保留少量滚动边距

;; 删除文件先进垃圾筒
(setq delete-by-moving-to-trash t)

(setq word-wrap-by-category t)

;; 在 Org mode 中禁用自适应换行缩进，实现左对齐
(add-hook 'org-mode-hook (lambda () (adaptive-wrap-prefix-mode -1)))

(setq initial-major-mode 'org-mode)
(setq initial-scratch-message nil)

;; Smooth mouse scrolling
(setq mouse-wheel-scroll-amount '(2 ((shift) . 1))
      mouse-wheel-progressive-speed nil
      mouse-wheel-follow-mouse t
      scroll-step 1)
(prefer-coding-system 'utf-8)
(set-default-coding-systems 'utf-8)
(setq default-buffer-file-coding-system 'utf-8)
(setq byte-compile-warnings '(not obsolete))
(setq warning-suppress-log-types '((comp) (bytecomp)))
(setq native-comp-async-report-warnings-errors 'silent)
(setq inhibit-startup-echo-area-message (user-login-name))
(setq visible-bell t)
(setq ring-bell-function 'ignore)
(setq set-message-beep 'silent)
;; J 合并行时，中文之间不插入多余空格
(defun my/evil-join-cjk-advice (&rest _)
  "Remove unwanted space between CJK characters after evil-join."
  (save-excursion
    (beginning-of-line)
    (while (re-search-forward "\\(\\cc\\) \\(\\cc\\)" (line-end-position) t)
      (replace-match "\\1\\2"))))

(advice-add 'evil-join :after #'my/evil-join-cjk-advice)
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
  ;; resolves to C:\Windows\System32\FIND.EXE — a completely different tool.
  (let ((gnu-find "C:/Program Files/Git/usr/bin/find.exe"))
    (when (file-executable-p gnu-find)
      (setq find-program gnu-find))))
(setq doom-theme 'ef-day)

(use-package! doom-modeline
  :custom
  (doom-modeline-buffer-encoding nil)
  (doom-modeline-enable-word-count nil)
  ;; (doom-modeline-height 10)
)

;; 全局 visual line
(global-visual-line-mode)

(setq display-line-numbers-type nil
      use-short-answers t)

(fringe-mode '(0 . 0)) ;; No fringe

;; 指定启动时的窗口位置和大小
(setq initial-frame-alist '((top . 10)
                            (left . 1200)
                            (width . 500)
                            (height . 240)))

;; 新开窗口时默认是左右结构
(setq split-height-threshold nil)
(setq split-width-threshold 0)

(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)

(setq-default x-stretch-cursor t
              x-underline-at-descent-line t)
(defun my/first-available-font (candidates)
  "Return the first font family from CANDIDATES that is available."
  (catch 'found
    (dolist (font candidates)
      (when (find-font (font-spec :family font))
        (throw 'found font)))
    nil))

(setq doom-font (font-spec :family "Maple Mono NF CN" :size 24)
      doom-variable-pitch-font (font-spec :family "LXGW WenKai Screen" :size 26)
      doom-big-font (font-spec :family "Maple Mono NF CN" :size 30))

;; CJK font override — must run AFTER unicode-fonts-setup (depth -90)
(defvar my/cjk-mono-font "Maple Mono NF CN"
  "CJK font for monospace contexts (code, fixed-pitch).")

(defun my/setup-cjk-fonts (&optional _frame)
  "Force CJK characters to use a specific font."
  (when (display-graphic-p)
    (let ((font-family (or my/cjk-mono-font
                           (my/first-available-font
                            '("Maple Mono NF CN" "Sarasa Mono SC"
                              "霞鹜文楷等宽" "LXGW WenKai Mono"
                              "Noto Sans CJK SC")))))
      (when font-family
        (dolist (charset '(kana han cjk-misc bopomofo))
          (set-fontset-font t charset (font-spec :family font-family) nil 'prepend))))))

;; Depth 0 = runs after unicode-fonts (depth -90), so prepend wins
(add-hook 'after-setting-font-hook #'my/setup-cjk-fonts 0)
(use-package! dired-narrow
  :after dired
  :config
  (evil-define-key 'normal dired-mode-map (kbd "/") #'dired-narrow))
(use-package! ace-window
  :config
  (setq aw-keys '(?a ?s ?d ?f ?g ?h ?j ?k ?l)
        aw-scope 'frame
        aw-background t)

  ;; 覆盖默认的 other-window (C-x o)
  (global-set-key [remap other-window] #'ace-window)

  (setq aw-display-mode-overlay t
        aw-leading-char-style 'char)

  (after! evil
    (define-key evil-motion-state-map (kbd "C-w w") #'ace-window)
    (define-key evil-normal-state-map (kbd "C-w w") #'ace-window)))
(setq org-directory "~/org")

(after! org
  (require 'org-protocol)
  (require 'org-habit)

  (setq org-habit-graph-column 50
        org-habit-preceding-days 21
        org-habit-following-days 7
        org-habit-show-habits-only-for-today nil)

  ;; ---- TODO keywords ----
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

  ;; ---- Display ----
  (setq org-confirm-babel-evaluate nil
        org-return-follows-link t
        org-startup-folded 'content
        org-hide-emphasis-markers t
        org-ellipsis " ▾")

  ;; Inline images
  (setq image-use-external-converter t
        org-image-actual-width '(600))

  (custom-set-variables '(org-startup-indented nil)))
(after! org
  (use-package! spacious-padding
    :custom (line-spacing 3)
    :init (spacious-padding-mode 1))

  (use-package! pangu-spacing
    :config
    (global-pangu-spacing-mode 1)
    (setq pangu-spacing-real-insert-separtor t))

  (use-package! olivetti
    :hook (org-mode . olivetti-mode)
    :config (setq olivetti-body-width 92))

  (use-package! ultra-scroll
    :init
    (setq scroll-conservatively 101
          scroll-margin 0)
    :config
    (ultra-scroll-mode 1))

  (use-package! org-appear
    :hook (org-mode . org-appear-mode)
    :config
    (setq org-appear-autoemphasis t
          org-appear-autosubmarkers t
          org-appear-autolinks nil)))
(after! org
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
  (advice-add 'org-attach-attach :after #'my/org-attach-store-link-decoded))
(after! org
  ;; @Eli 帮忙写的解决标记符号前后空格问题的代码
  (setq org-emphasis-regexp-components '("-[:space:]('\"{[:nonascii:]"
                                         "-[:space:].,:!?;'\")}\\[[:nonascii:]"
                                         "[:space:]"
                                         "."
                                         1))
  (setq org-match-substring-regexp
        (concat
         "\\([0-9a-zA-Zα-γΑ-Ω]\\)\\([_^]\\)\\("
         "\\(?:" (org-create-multibrace-regexp "{" "}" org-match-sexp-depth) "\\)"
         "\\|"
         "\\(?:" (org-create-multibrace-regexp "(" ")" org-match-sexp-depth) "\\)"
         "\\|"
         "\\(?:\\*\\|[+-]?[[:alnum:].,\\]*[[:alnum:]]\\)\\)"))
  (org-set-emph-re 'org-emphasis-regexp-components org-emphasis-regexp-components)
  (org-element-update-syntax)

  ;; 标记字符前后空格优化问题
  (defun eli/org-do-emphasis-faces (limit)
    "Run through the buffer and emphasize strings."
    (let ((quick-re (format "\\([%s]\\|^\\)\\([~=*/_+]\\)"
                            (car org-emphasis-regexp-components))))
      (catch :exit
        (while (re-search-forward quick-re limit t)
          (let* ((marker (match-string 2))
                 (verbatim? (member marker '("~" "="))))
            (when (save-excursion
                    (goto-char (match-beginning 0))
                    (and
                     (not (save-excursion
                            (forward-char 1)
                            (get-pos-property (point) 'org-emphasis)))
                     (not (org-match-line
                           "^[    ]*:\\(\\(?:\\w\\|[-_]\\)+\\):[      ]*"))
                     (not (and (equal marker "+")
                               (org-match-line
                                "[ \t]*\\(|[-+]+|?\\|\\+[-+]+\\+\\)[ \t]*$")))
                     (not (and (equal marker "*")
                               (save-excursion
                                 (forward-char)
                                 (skip-chars-backward "*")
                                 (looking-at-p org-outline-regexp-bol))))
                     (looking-at (if verbatim? org-verbatim-re org-emph-re))
                     (not (string-match-p org-element-paragraph-separate
                                          (match-string 2)))
                     (not (and (save-match-data (org-match-line "[ \t]*|"))
                               (string-match-p "|" (match-string 4))))))
              (pcase-let ((`(,_ ,face ,_) (assoc marker org-emphasis-alist))
                          (m (if org-hide-emphasis-markers 4 2)))
                (font-lock-prepend-text-property
                 (match-beginning m) (match-end m) 'face face)
                (when verbatim?
                  (org-remove-flyspell-overlays-in
                   (match-beginning 0) (match-end 0))
                  (when (and (org-fold-core-folding-spec-p 'org-link)
                             (org-fold-core-folding-spec-p 'org-link-description))
                    (org-fold-region (match-beginning 0) (match-end 0) nil 'org-link)
                    (org-fold-region (match-beginning 0) (match-end 0) nil 'org-link-description))
                  (remove-text-properties (match-beginning 2) (match-end 2)
                                          '(display t invisible t intangible t)))
                (add-text-properties (match-beginning 2) (match-end 2)
                                     '(font-lock-multiline t org-emphasis t))
                (when (and org-hide-emphasis-markers
                           (not (org-at-comment-p)))
                  (add-text-properties (match-end 4) (match-beginning 5)
                                       '(invisible t))
                  (add-text-properties (match-beginning 3) (match-end 3)
                                       '(invisible t)))
                (throw :exit t))))))))

  (advice-add #'org-do-emphasis-faces :override #'eli/org-do-emphasis-faces)

  (defun eli/org-element--parse-generic-emphasis (mark type)
    "Parse emphasis object at point, if any."
    (save-excursion
      (let ((origin (point)))
        (unless (bolp) (forward-char -1))
        (let ((opening-re
               (rx-to-string
                `(seq (or line-start (any space ?- ?\( ?' ?\" ?\{ nonascii))
                  ,mark
                  (not space)))))
          (when (looking-at opening-re)
            (goto-char (1+ origin))
            (let ((closing-re
                   (rx-to-string
                    `(seq
                      (not space)
                      (group ,mark)
                      (or (any space ?- ?. ?, ?\; ?: ?! ?? ?' ?\" ?\) ?\} ?\\ ?\[
                               nonascii)
                          line-end)))))
              (when (re-search-forward closing-re nil t)
                (let ((closing (match-end 1)))
                  (goto-char closing)
                  (let* ((post-blank (skip-chars-forward " \t"))
                         (contents-begin (1+ origin))
                         (contents-end (1- closing)))
                    (list type
                          (append
                           (list :begin origin
                                 :end (point)
                                 :post-blank post-blank)
                           (if (memq type '(code verbatim))
                               (list :value
                                     (and (memq type '(code verbatim))
                                          (buffer-substring
                                           contents-begin contents-end)))
                             (list :contents-begin contents-begin
                                   :contents-end contents-end)))))))))))))

  (advice-add #'org-element--parse-generic-emphasis :override #'eli/org-element--parse-generic-emphasis))
(after! org
  (setq org-agenda-inhibit-startup t
        org-agenda-tags-column 'auto
        org-agenda-files '("~/org/inbox.org"
                           "~/org/notes/20260101T000010--habits-hub__habit_index.org"
                           "~/org/append-note.org"
                           "~/org/.calendar")
        org-default-notes-file "~/org/inbox.org")

  ;; Archive
  (setq org-archive-location
        (concat (expand-file-name ".archive/" org-directory)
                "%s_archive.org::"))

  ;; Time grid
  (setq org-agenda-use-time-grid t
        org-agenda-show-current-time-in-grid t
        org-agenda-time-grid
        '((daily today)
          (600 800 1000 1200 1400 1600 1800 2000 2200)
          " ┄┄┄┄┄ " "┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄")
        org-agenda-current-time-string
        "◀── now ─────────────────────")

  ;; Hide redundant tags in agenda
  (setq org-agenda-hide-tags-regexp "personal\\|habit\\|index")

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
                   (org-agenda-sorting-strategy '(category-keep)))))))))
(after! org
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
              name today time repeat-val today time end-time))))
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
         (id (format-time-string "%Y%m%dT%H%M%S"))
         (slug (replace-regexp-in-string "[^a-zA-Z0-9一-鿿]+" "-"
                                         (downcase (string-trim title)) t t))
         (slug (replace-regexp-in-string "^-\\|-$" "" slug))
         (file (expand-file-name (format "notes/%s--%s__read.org" id slug) org-directory)))
    (set-buffer (org-capture-target-buffer file))
    (when (= (buffer-size) 0)
      (insert (format "#+title: %s\n#+date: [%s]\n#+filetags: :read:\n#+identifier: %s\n\n* Source\n%s\n\n* Summary\n\n* My Notes\n"
                      title (format-time-string "%Y-%m-%d %a") id url)))
    (goto-char (point-max))
    (or (re-search-backward "^\\* My Notes" nil t) (goto-char (point-max)))
    (forward-line 1)))

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
         (id    (format-time-string "%Y%m%dT%H%M%S"))
         (file  (expand-file-name (format "notes/%s--%s__read.org" id slug) org-directory)))
    (set-buffer (org-capture-target-buffer file))
    (when (= (buffer-size) 0)
      (insert (format "#+title: %s\n#+date: [%s]\n#+filetags: :read:\n#+identifier: %s\n\n* Source\n%s\n\n* Summary\n\n* My Notes\n"
                      title (format-time-string "%Y-%m-%d %a") id url)))
    (goto-char (point-max))
    (or (re-search-backward "^\\* My Notes" nil t) (goto-char (point-max)))
    (forward-line 1)))
(after! org
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
           (file+olp "~/org/notes/20260101T000010--media-collection__index.org" "影视动漫" "电影" "想看")
           "**** TODO %^{片名}\n:PROPERTIES:\n:添加时间: %U\n:END:\n%?"
           :empty-lines 1 :jump-to-captured t)
          ("mM" "电影 · 看完" entry
           (file+olp "~/org/notes/20260101T000010--media-collection__index.org" "影视动漫" "电影" "看完")
           "**** DONE %^{片名}\n:PROPERTIES:\n:完成日期: %<[%Y-%m-%d]>\n:END:\n%?"
           :empty-lines 1 :jump-to-captured t)
          ("mt" "电视剧 · 想看" entry
           (file+olp "~/org/notes/20260101T000010--media-collection__index.org" "影视动漫" "电视剧" "想看")
           "**** TODO %^{片名}\n:PROPERTIES:\n:添加时间: %U\n:END:\n%?"
           :empty-lines 1 :jump-to-captured t)
          ("mT" "电视剧 · 看完" entry
           (file+olp "~/org/notes/20260101T000010--media-collection__index.org" "影视动漫" "电视剧" "看完")
           "**** DONE %^{片名}\n:PROPERTIES:\n:完成日期: %<[%Y-%m-%d]>\n:END:\n%?"
           :empty-lines 1 :jump-to-captured t)
          ("ma" "动漫 · 想看" entry
           (file+olp "~/org/notes/20260101T000010--media-collection__index.org" "影视动漫" "动漫" "想看")
           "**** TODO %^{片名}\n:PROPERTIES:\n:添加时间: %U\n:END:\n%?"
           :empty-lines 1 :jump-to-captured t)
          ("mA" "动漫 · 看完" entry
           (file+olp "~/org/notes/20260101T000010--media-collection__index.org" "影视动漫" "动漫" "看完")
           "**** DONE %^{片名}\n:PROPERTIES:\n:完成日期: %<[%Y-%m-%d]>\n:END:\n%?"
           :empty-lines 1 :jump-to-captured t)
          ("b" "Books")
          ("bb" "书 · 待阅读" entry
           (file+olp "~/org/notes/20260101T000010--reading-list__read_index.org" "待阅读")
           "*** TODO %^{书名}\n:PROPERTIES:\n:作者: %^{作者}\n:类型: %^{类型|小说|非虚构|理财|网文|漫画|其他}\n:来源: %^{来源|微信读书|豆瓣|Z-Library|实体书|其他}\n:添加时间: %U\n:END:\n%?"
           :empty-lines 1 :jump-to-captured t)
          ("bB" "书 · 阅读中" entry
           (file+olp "~/org/notes/20260101T000010--reading-list__read_index.org" "阅读中")
           "*** READING %^{书名}\n:PROPERTIES:\n:作者: %^{作者}\n:类型: %^{类型|小说|非虚构|理财|网文|漫画|其他}\n:来源: %^{来源|微信读书|豆瓣|Z-Library|实体书|其他}\n:添加时间: %U\n:END:\n%?"
           :empty-lines 1 :jump-to-captured t)
          ("w" "w · 精读笔记 [ref/]" plain (function my/capture-web-article-target)
           "%?"
           :empty-lines 1 :jump-to-captured t)
          ("h" "Habit" entry (file "~/org/notes/20260101T000010--habits-hub__habit_index.org")
           (function my/org-capture-habit)
           :empty-lines 1)
          ("pl" "Protocol: Read later" entry (file "~/org/inbox.org")
           "* TODO %:annotation\n:PROPERTIES:\n:CREATED: %U\n:END:\n%i\n"
           :immediate-finish t :jump-to-captured t)
          ("pn" "Protocol: Note → references/" plain
           (function my/protocol-note-target)
           "#+begin_quote\n%i\n#+end_quote\n%?"
           :jump-to-captured t))))
(after! org
  (defun my/org-top-level-org-files (dir)
    "Return top-level non-hidden .org files in DIR."
    (let ((dir (expand-file-name dir))
          result)
      (dolist (path (directory-files dir t "^[^.].*\\.org$") (nreverse result))
        (when (file-regular-p path)
          (push path result)))))

  (defun my/org-notes-files () (my/org-top-level-org-files "~/org/notes/"))

  (setq org-refile-targets
        '(("~/org/inbox.org" :maxlevel . 1)
          ("~/org/append-note.org" :maxlevel . 1)
          (my/org-notes-files :maxlevel . 2)))
  (setq org-refile-use-outline-path 'file
        org-outline-path-complete-in-steps nil
        org-refile-allow-creating-parent-nodes 'confirm
        org-refile-use-cache nil)

  ;; ---- Tags ----
  (setq org-tag-alist '((:startgroup)
                        ("work" . ?w) ("personal" . ?p) ("learning" . ?l)
                        (:endgroup)
                        ("projectS" . ?s) ("ai" . ?a) ("hiring" . ?h)
                        ("@office" . ?o) ("@home" . ?H) ("@phone" . ?P))))
(after! org
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
                    (funcall orig-fn prefix suffix))))))

;; ---- Force org-babel shell blocks to use Git bash on Windows ----
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
(after! org
  (defun my/media-org-file-p ()
    "Return non-nil when visiting the media library file."
    (and (buffer-file-name)
         (file-equal-p (expand-file-name "~/org/notes/20260101T000010--media-collection__index.org")
                       (expand-file-name (buffer-file-name)))))

  (defun my/media-org-target-section-for-state (state)
    "Map TODO STATE to a media library section name."
    (pcase state
      ((or "TODO" "NEXT") "想看")
      ("PROG" "在看")
      ("DONE" "看完")
      ("FAIL" "已放弃")
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

  (add-hook 'org-after-todo-state-change-hook #'my/media-org-rebucket-current-entry))
(after! org
  (defun my/books-org-file-p ()
    "Return non-nil when visiting the books collection file."
    (and (buffer-file-name)
         (file-equal-p (expand-file-name "~/org/notes/20260101T000010--reading-list__read_index.org")
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

  (add-hook 'org-after-todo-state-change-hook #'my/books-org-rebucket-current-entry))
(after! org
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
                 count (file-name-nondirectory (buffer-file-name)))))))
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
  "Rewrite FILENAME to denote style: <id>--<slug><ext>."
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
          org-download-file-format-function #'my/org-download-denote-file-format
          org-download-link-format-function
          (lambda (filename)
            (format "[[file:%s]]\n"
                    (org-link-escape
                     (file-relative-name filename default-directory)))))

    ;; Fix: org-download-dnd-fallback for Emacs 30+
    (when (fboundp 'dnd-handle-multiple-urls)
      (defun org-download-dnd-fallback (uri action)
        (let ((dnd-protocol-alist
               (rassq-delete-all
                'org-download-dnd
                (copy-alist dnd-protocol-alist))))
          (dnd-handle-multiple-urls
           (selected-window) (list uri) action))))

    ;; Fix: Full percent-decoding for non-ASCII filenames + Windows local paths.
    (defun org-download--fullname (link &optional ext)
      "Return the file name where LINK will be saved to.
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

    ;; Fix: org-download-clipboard on Windows ignores user's screenshot-method.
    (when (featurep :system 'windows)
      (defadvice! my/org-download-clipboard-use-powershell (&optional basename)
        :override #'org-download-clipboard
        (org-id-get-create)
        (org-download-screenshot basename)))))
(defun my/org-dnd-copy-to-data (uri _action)
  "Copy locally-dropped file URI into ~/org/data/ with a denote-style name."
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

(defun my/org-prepend-flat-dnd-handler ()
  "Make our flat-data DnD handler win over Org's builtin file: handlers."
  (setq-local dnd-protocol-alist
              (cons '("^file:" . my/org-dnd-copy-to-data)
                    dnd-protocol-alist)))
(add-hook 'org-mode-hook #'my/org-prepend-flat-dnd-handler)
(defconst my/markdown-image-extensions
  '("png" "jpg" "jpeg" "gif" "svg" "webp" "bmp" "avif")
  "Extensions treated as images for markdown DnD insertion.")

(defun my/markdown-dnd-copy-to-data (uri _action)
  "Copy locally-dropped file URI into ~/org/data/ with denote-style name."
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
  :demand t
  :init
  (make-directory (expand-file-name "denote/" org-directory) t)
  :config
  (setq denote-directory (expand-file-name "notes/" org-directory)
        denote-file-type 'org
        denote-known-keywords  '(;; 工作/生活分界
                                 "work"
                                 ;; 领域
                                 "gamedev" "emacs" "ai" "pkm" "investment"
                                 "health" "habit" "read" "hire"
                                 ;; 跨域特殊标记
                                 "idea" "memo" "tool" "project" "index"
                                 ;; 形态标记
                                 "journal" "document")
        denote-infer-keywords nil
        denote-sort-keywords t
        denote-prompts '(title keywords)
        denote-date-prompt-use-org-read-date t
        denote-excluded-directories-regexp
        (rx (or (seq bos ".")
                (seq bos (or "data" "investment" "templates" "tmp") eos)))
        denote-rename-confirmations nil
        denote-dired-directories (list denote-directory)
        denote-dired-directories-include-subdirectories t)

  ;; Windows-safe replacement for `denote-dired-mode-in-directories'.
  (defun my/denote-dired-mode-maybe ()
    "Enable `denote-dired-mode' when current dired buffer is under a
denote-dired directory, matching case-insensitively."
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
                                   t))))))
               denote-dired-directories)
          (when (bound-and-true-p diredfl-mode)
            (diredfl-mode -1))
          (denote-dired-mode 1)
          (font-lock-flush)))))

  (add-hook 'after-change-major-mode-hook #'my/denote-dired-mode-maybe t)

  ;; Strip newlines from the complete filename.
  (advice-add 'denote-format-file-name :filter-return
              (lambda (filename) (replace-regexp-in-string "[\n\r]" "" filename))))
(after! dirvish
  (dirvish-override-dired-mode -1))

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
(use-package! consult-notes
  :after (consult denote)
  :commands (consult-notes consult-notes-search-in-all-notes)
  :config
  (setq consult-notes-file-dir-sources
        `(("Notes"   ?n ,(expand-file-name "notes/"   org-directory))
          ("Journal" ?j ,(expand-file-name "journal/" org-directory))))

  (setq consult-notes-org-headings-files
        (list (expand-file-name "inbox.org"       org-directory)
              (expand-file-name "append-note.org" org-directory)))
  (consult-notes-org-headings-mode)

  (when (locate-library "denote")
    (consult-notes-denote-mode))

  (setq consult-notes-denote-files-function
        (lambda () (denote-directory-files nil t t))))

(after! consult-notes
  (consult-customize consult-notes :sort nil)
  (setq consult-notes-denote-files-function
        (lambda ()
          (sort (denote-directory-files)
                (lambda (a b)
                  (time-less-p
                   (file-attribute-modification-time (file-attributes b))
                   (file-attribute-modification-time (file-attributes a))))))))
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
Before 03:00 falls back to the previous day."
  (let* ((now  (decode-time))
         (hour (nth 2 now))
         (time (if (< hour 3)
                   (time-subtract (current-time) (seconds-to-time 86400))
                 (current-time))))
    (denote-journal-path-to-new-or-existing-entry
     (format-time-string "%Y-%m-%d" time))))
(defvar my/weather-location "上海"
  "wttr.in 查询地点。")

(defun my/get-weather ()
  "从 wttr.in 获取天气，返回单行字符串。"
  (let ((coding-system-for-read 'utf-8))
    (string-trim
     (shell-command-to-string
      (format "curl -s --max-time 5 \"https://wttr.in/%s?format=3\""
              (url-hexify-string my/weather-location))))))

(defun my/insert-weather ()
  "在光标处插入当前天气。"
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
(after! pdf-view
  (setq-default pdf-view-display-size 'fit-page)
  (setq pdf-view-midnight-colors '("#ffffff" . "#1e1e2e"))
  (map! :map pdf-view-mode-map
        "C-c C-a h" #'pdf-annot-add-highlight-markup-annotation
        "C-c C-a t" #'pdf-annot-add-text-annotation
        "C-c C-a d" #'pdf-annot-add-strikeout-markup-annotation))
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
(after! org-noter
  :commands org-noter
  :config
  (setq org-noter-notes-search-path '("~/org/notes/")
        org-noter-default-notes-file-names '("notes.org")
        org-noter-auto-save-last-location t
        org-noter-notes-window-location 'horizontal-split
        org-noter-highlight-selected-text t)

  (defun my/org-noter-create-session-in-references (&optional arg document-file-name)
    "Create org-noter session, always placing notes in ~/org/notes/."
    (let* ((document-file-name (or (run-hook-with-args-until-success
                                    'org-noter-get-buffer-file-name-hook major-mode)
                                   document-file-name))
           (document-path (or document-file-name buffer-file-truename
                              (error "This buffer does not seem to be visiting any file")))
           (document-name (file-name-nondirectory document-path))
           (document-base (file-name-base document-name))
           (notes-dir (expand-file-name "~/org/notes/"))
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
(use-package! elfeed
  :commands elfeed
  :config
  (require 'subr-x)
  (setq elfeed-db-directory (expand-file-name "~/org/.elfeed")
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
    (or (elfeed-meta feed :title)
        (elfeed-feed-title feed)
        (elfeed-feed-url feed)
        "Unknown feed"))

  (defun my/elfeed-url-origin (url)
    (when (and url (string-match "\\`\\(https?://[^/]+\\)" url))
      (concat (match-string 1 url) "/")))

  (defun my/elfeed-guess-homepage (feed-url)
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
    (when-let* ((feed (elfeed-entry-feed entry))
                (feed-url (elfeed-feed-url feed)))
      (let* ((entry-url (elfeed-entry-link entry))
             (feed-origin (my/elfeed-url-origin feed-url))
             (entry-origin (my/elfeed-url-origin entry-url)))
        (cond
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
  (setq rmh-elfeed-org-files (list (expand-file-name "~/org/notes/20260101T000010--elfeed__emacs_index.org"))))
(when (boundp 'my/athenai-api-key)
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

  ;; Buffer-local Evil-friendly bindings
  (map! :map agent-shell-mode-map
        :i "RET"   #'newline
        :i "S-RET" #'shell-maker-submit
        :n "RET"   #'shell-maker-submit
        :n "q"     #'quit-window
        :nv "gr"   #'agent-shell-send-dwim)

  ;; Diff buffer auto enters emacs-state
  (add-hook 'diff-mode-hook
            (lambda ()
              (when (string-match-p "\\*agent-shell-diff\\*" (buffer-name))
                (evil-emacs-state))))
  ;; Viewport auto emacs-state
  (with-eval-after-load 'evil
    (evil-set-initial-state 'agent-shell-viewport-view-mode 'emacs)))
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
(map! :leader
      ;; Gcal
      (:prefix ("G" . "gcal")
       :desc "Sync"   "s" #'org-gcal-sync
       :desc "Fetch"  "f" #'org-gcal-fetch
       :desc "Delete" "d" #'org-gcal-delete-at-point
       :desc "Push"   "p" #'my/org-gcal-auto-post)

      ;; Open
      (:prefix ("o" . "open")
       :desc "Elfeed"      "e" #'elfeed
       :desc "Claude Code" "s" #'agent-shell-anthropic-start-claude-code
       :desc "Codex"       "c" #'agent-shell-openai-start-codex)

      ;; Notes / Denote
      (:prefix ("n" . "notes")
       :desc "Consult notes (pick)"   "s" #'consult-notes
       :desc "Consult notes (search)" "S" #'consult-notes-search-in-all-notes
       (:prefix ("d" . "denote")
        :desc "New note"                       "n" #'denote
        :desc "New note (choose type)"         "N" #'denote-type
        :desc "New note in subdir"             "D" #'denote-subdirectory
        :desc "Open or create"                 "f" #'denote-open-or-create
        :desc "Insert link"                    "i" #'denote-link-or-create
        :desc "Insert link (region → title)"   "I" #'denote-link
        :desc "Add links (search)"             "L" #'denote-add-links
        :desc "Backlinks"                      "b" #'denote-backlinks
        :desc "Rename file"                    "r" #'denote-rename-file
        :desc "Rename from front-matter"       "R" #'denote-rename-file-using-front-matter
        :desc "Add keywords"                   "k" #'denote-keywords-add
        :desc "Remove keywords"                "K" #'denote-keywords-remove
        :desc "Dired in denote dir"            "d" #'denote-dired
        :desc "Today's journal"                "j" #'denote-journal-new-or-existing-entry))

      :desc "org-noter" "N" #'org-noter)
(map! :after org
      :map org-mode-map
      :localleader
      (:prefix ("i" . "image")
       :desc "Toggle inline"  "t" #'org-toggle-inline-images
       :desc "Paste clipboard" "p" #'org-download-clipboard
       :desc "Screenshot"     "s" #'org-download-screenshot
       :desc "Yank"           "y" #'org-download-yank
       :desc "Delete"         "d" #'org-download-delete)
      (:prefix ("d" . "denote")
       :desc "Insert link"            "i" #'denote-link-or-create
       :desc "Backlinks"              "b" #'denote-backlinks
       :desc "Add keywords"           "k" #'denote-keywords-add
       :desc "Rename (front-matter)"  "r" #'denote-rename-file-using-front-matter
       :desc "Link to heading"        "h" #'denote-org-link-to-heading
       :desc "Backlinks for heading"  "H" #'denote-org-backlinks-for-heading
       :desc "Extract subtree to note" "x" #'denote-org-extract-org-subtree
       (:prefix ("o" . "dblock")
        :desc "Links (by regexp)"     "l" #'denote-org-dblock-insert-links
        :desc "Backlinks"             "b" #'denote-org-dblock-insert-backlinks
        :desc "Missing links"         "m" #'denote-org-dblock-insert-missing-links
        :desc "Files"                 "f" #'denote-org-dblock-insert-files
        :desc "Files as headings"     "F" #'denote-org-dblock-insert-files-as-headings))
      :desc "TODO state"        "t" #'org-todo
      :desc "Paste rich text"   "V" #'my/org-paste-rich
      :desc "Archive done tasks" "A" #'my/org-archive-done-tasks)
(map! :after markdown-mode
      :map markdown-mode-map
      :localleader
      (:prefix ("d" . "denote")
       :desc "Insert link"              "i" #'denote-link-or-create
       :desc "Backlinks"                "b" #'denote-backlinks
       :desc "Rename (front-matter)"    "r" #'denote-rename-file-using-front-matter
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
    ;; Skip sis's auto-detect; wire Windows IME API directly.
    (setq sis-english-source nil
          sis-other-source   t
          sis-do-get         #'w32-get-ime-open-status
          sis-do-set         #'w32-set-ime-open-status)

    ;; Disable 0.2s idle poll (races imm32.dll on buffer creation).
    (setq sis-auto-refresh-seconds nil)

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

    ;; Resync after frame regains focus
    (add-function :after after-focus-change-function
                  (lambda () (sis--get)))

    :hook
    (org-capture-mode . sis-set-other))

  ;; Bind C-\ everywhere evil might grab keys first.
  (define-key global-map (kbd "C-\\") #'sis-switch)
  (with-eval-after-load 'evil
    (define-key evil-normal-state-map (kbd "C-\\") #'sis-switch)
    (define-key evil-insert-state-map (kbd "C-\\") #'sis-switch)
    (define-key evil-motion-state-map (kbd "C-\\") #'sis-switch)
    (define-key evil-visual-state-map (kbd "C-\\") #'sis-switch)
    (define-key evil-emacs-state-map  (kbd "C-\\") #'sis-switch)))
