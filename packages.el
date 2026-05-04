;; -*- no-byte-compile: t; -*-
;;; $DOOMDIR/packages.el
(package! cal-china-x)
;; (package! org-superstar)

(package! nov)
(package! powershell)
(package! sis)

;; denote
(package! denote)
(package! denote-org)
(package! denote-journal)
(package! denote-markdown)
(package! consult-notes
  :recipe (:host github :repo "mclear-tools/consult-notes"))

;; agent shell
(package! shell-maker)
(package! acp)
(package! agent-shell)

;; 性能增强
(package! gcmh)

(package! ef-themes)

;; A simple Emacs minor mode for a nice writing environment.
(package! olivetti)

;; 鼠标放到加粗字符上, 可编辑修饰符, 离开即显示加粗后的效果
(package! org-appear
  :recipe (:host github :repo "awth13/org-appear"))

;; 中英文字符之间自动插入空格, 增加可阅读性
(package! pangu-spacing)

;; 每个标识符显示一个颜色, 花里胡哨的开始
(package! rainbow-identifiers)

;; increases the padding or spacing of frames and windows on demand
(package! spacious-padding)

;; ultra-scroll: scroll emacs like lightning
(package! ultra-scroll
  :recipe (:host github :repo "jdtsmith/ultra-scroll"))

;; dired-narrow: narrow dired to matching files
(package! dired-narrow)

;; 完美解决中英文字符在表格中对齐的问题
;; (package! valign)
