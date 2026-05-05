;;; init.el -*- lexical-binding: t; -*-

;; Doom Emacs module selection.
;; SPC h d m  to browse available modules and their flags.
;; doom/reload after editing, or run 'doom sync' from CLI.

(doom! :input

       :completion
       corfu
       (vertico +icons)

       :ui
       doom
       hl-todo
       modeline
       nav-flash
       ophints
       (popup +all +defaults)
       treemacs
       window-select
       unicode
       zen

       :editor
       (evil +everywhere)
       file-templates
       fold
       (format +onsave)
       snippets
       word-wrap
       multiple-cursors

       :emacs
       undo
       (ibuffer +icons)

       :checkers
       syntax

       :tools
       (eval +overlay)
       lookup
       magit
       pdf

       :os
       (:if (featurep :system 'windows) windows)

       :lang
       emacs-lisp
       markdown
       (org +dragndrop +present +noter +pandoc)
       (python +lsp)
       sh
       yaml

       :app
       (calendar +org-gcal)
       (rss +org)

       :config
       literate
       (default +bindings +smartparens))
