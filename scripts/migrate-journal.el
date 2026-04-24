;;; migrate-journal.el --- One-shot migration of ~/org/journal/ to denote -*- lexical-binding: t; -*-

;; Usage (inside a running Emacs, after Doom has loaded denote):
;;   M-x load-file RET ~/.doom.d/scripts/migrate-journal.el RET
;;   M-x my/migrate-old-journal-to-denote RET
;;
;; Renames every legacy YYYY-MM-DD.org file in ~/org/journal/ to denote
;; form:  <YYYYMMDDT090000>--<title-slug>__journal.org
;; Title matches denote-journal's 'day-date-month-year (e.g.
;; "Thursday 23 April 2026"). Idempotent: files already in denote form
;; are skipped.

(require 'denote)
(require 'cl-lib)

(defun my/migrate-old-journal--title-for-date (time)
  "Return the `day-date-month-year' style title string for TIME."
  (let ((s (format-time-string "%A %e %B %Y" time)))
    ;; %e is space-padded; collapse the double space for 1-9.
    (replace-regexp-in-string "  " " " s)))

(defun my/migrate-old-journal-to-denote ()
  "Rename legacy YYYY-MM-DD.org files under ~/org/journal/ to denote form."
  (interactive)
  (let* ((dir (expand-file-name "~/org/journal/"))
         (files (directory-files
                 dir t
                 "\\`[0-9]\\{4\\}-[0-9]\\{2\\}-[0-9]\\{2\\}\\.org\\'"))
         (renamed 0)
         (skipped 0)
         (errors '()))
    (dolist (file files)
      (condition-case err
          (let* ((base       (file-name-nondirectory file))
                 (date-str   (substring base 0 10))
                 (time       (date-to-time (concat date-str " 09:00:00")))
                 (title      (my/migrate-old-journal--title-for-date time))
                 (identifier (format-time-string "%Y%m%dT%H%M%S" time))
                 (new-path   (denote-rename-file
                              file title '("journal") nil nil identifier)))
            (if (string= (expand-file-name new-path) (expand-file-name file))
                (cl-incf skipped)
              (cl-incf renamed)))
        (error
         (push (cons file (error-message-string err)) errors))))
    (message "denote journal migration: renamed=%d skipped=%d errors=%d"
             renamed skipped (length errors))
    (when errors
      (with-current-buffer (get-buffer-create "*denote-journal-migration-errors*")
        (erase-buffer)
        (dolist (e errors)
          (insert (format "%s :: %s\n" (car e) (cdr e))))
        (display-buffer (current-buffer))))))

(defun my/migrate-journal-rewrite-front-matter ()
  "Rewrite front-matter of denote-renamed journal files in ~/org/journal/.
For each <ID>--<slug>__journal.org, set `#+title:' to the
day-date-month-year form and insert `#+date:' / `#+identifier:' when
missing. Safe to run multiple times."
  (interactive)
  (let* ((dir (expand-file-name "~/org/journal/"))
         (files (directory-files
                 dir t
                 "\\`[0-9]\\{8\\}T[0-9]\\{6\\}--.*__journal\\.org\\'"))
         (updated 0)
         (errors '()))
    (dolist (file files)
      (condition-case err
          (let* ((base     (file-name-nondirectory file))
                 (id       (substring base 0 15))               ; 20260423T090000
                 (date-iso (format "%s-%s-%s"
                                   (substring id 0 4)
                                   (substring id 4 6)
                                   (substring id 6 8)))
                 (hhmmss   (format "%s:%s:%s"
                                   (substring id 9 11)
                                   (substring id 11 13)
                                   (substring id 13 15)))
                 (time     (date-to-time (concat date-iso " " hhmmss)))
                 (title    (my/migrate-old-journal--title-for-date time))
                 (date-str (format-time-string "[%Y-%m-%d %a %H:%M]" time)))
            (with-current-buffer (find-file-noselect file)
              (unwind-protect
                  (save-excursion
                    (goto-char (point-min))
                    (if (re-search-forward "^#\\+title:.*$" nil t)
                        (replace-match (format "#+title:      %s" title) t t)
                      (goto-char (point-min))
                      (insert (format "#+title:      %s\n" title)))
                    (goto-char (point-min))
                    (unless (re-search-forward "^#\\+date:" nil t)
                      (goto-char (point-min))
                      (re-search-forward "^#\\+title:.*$")
                      (end-of-line)
                      (insert (format "\n#+date:       %s" date-str)))
                    (goto-char (point-min))
                    (unless (re-search-forward "^#\\+identifier:" nil t)
                      (goto-char (point-min))
                      (cond
                       ((re-search-forward "^#\\+filetags:.*$" nil t))
                       ((re-search-forward "^#\\+date:.*$" nil t))
                       (t (re-search-forward "^#\\+title:.*$" nil t)))
                      (end-of-line)
                      (insert (format "\n#+identifier: %s" id)))
                    (save-buffer))
                (kill-buffer (current-buffer))))
            (cl-incf updated))
        (error
         (push (cons file (error-message-string err)) errors))))
    (message "journal front-matter: updated=%d errors=%d" updated (length errors))
    (when errors
      (with-current-buffer (get-buffer-create "*denote-journal-fm-errors*")
        (erase-buffer)
        (dolist (e errors)
          (insert (format "%s :: %s\n" (car e) (cdr e))))
        (display-buffer (current-buffer))))))

(provide 'migrate-journal)
;;; migrate-journal.el ends here
