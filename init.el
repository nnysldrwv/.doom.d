;;; init.el -*- lexical-binding: t; -*-

;; Doom Emacs module selection.
;; SPC h d m  to browse available modules and their flags.
;; doom/reload after editing, or run 'doom sync' from CLI.

(doom! :input

       :completion
       (company +childframe)
       (vertico +icons)


       :ui
       doom
       doom-dashboard
       hl-todo
       modeline
       nav-flash
       ophints
       (popup +all)
       treemacs
       (vc-gutter +pretty)
       vi-tilde-fringe
       (window-select)
       workspaces
       ;; (emoji +ascii +github +unicode)
       unicode

       :editor
       (evil +everywhere)
       file-templates
       fold
       snippets
       word-wrap

       :emacs
       dired
       electric
       undo
       vc
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
       javascript
       markdown
       (org +dragndrop +present +noter +pandoc +pretty)
       (python +lsp)
       sh
       web
       yaml
       cc

       :app
       (calendar +org-gcal)
       (rss +org)
       :config
       (default +bindings +smartparens))
