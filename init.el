;;; init.el -*- lexical-binding: t; -*-

;; Doom Emacs module selection.
;; SPC h d m  to browse available modules and their flags.
;; doom/reload after editing, or run 'doom sync' from CLI.

(doom! :input

       :completion
       company
       (vertico +icons)


       :ui
       doom
       doom-dashboard
       hl-todo
       modeline
       ophints
       (popup +defaults)
       treemacs
       (vc-gutter +pretty)
       vi-tilde-fringe
       (window-select +numbers)
       workspaces

       :editor
       (evil +everywhere)
       file-templates
       fold
       snippets

       :emacs
       dired
       electric
       undo
       vc

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
       (org +roam2 +journal +dragndrop +present)
       (python +lsp)
       sh
       web
       yaml
       cc

       :config
       (default +bindings +smartparens))
