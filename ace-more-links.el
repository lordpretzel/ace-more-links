;;; ace-more-links.el --- Support for ace-links in more modes -*- lexical-binding: t -*-

;; Author: Boris Glavic <lordpretzel@gmail.com>
;; Maintainer: Boris Glavic <lordpretzel@gmail.com>
;; Version: 0.1
;; Package-Requires: ((avy "0.5") (ace-link "0.4.0") (emacs "25.1") (markdown-mode "2.5") (dash "2.19") (lsp-mode "9.0"))
;; Homepage: https://github.com/lordpretzel/ace-more-links
;; Keywords: convenience


;; This file is not part of GNU Emacs

;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; For a full copy of the GNU General Public License
;; see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; Add support for ace-link in more modes.

;;; Code:

;; ********************************************************************************
;; IMPORTS
(require 'seq)
(require 'avy)
(require 'ace-link)
(require 'mu4e nil t)
(require 'markdown-mode)
(require 'dash)
(require 'imenu)
(require 'lsp-mode)

;; ********************************************************************************
;; FUNCTIONS

(defun ace-more-links-regex-search-in-range (beg end regex)
  "Search for regular expression REGEX within range BEG to END."
  (let (res)
    (goto-char beg)
    (while (re-search-forward regex end t)
      (push
       (cons
        (buffer-substring-no-properties
         (match-beginning 0)
         (match-end 0))
        (match-beginning 0))
       res))
    res))

;; ********************************************************************************
;; support links in markdown

(defun ace-more-links-ace-link--md-collect ()
  "Collects links on the visible part of the markdown buffer."
  (let ((end (window-end))
        res)
    (save-excursion
      (setq res (ace-more-links-regex-search-in-range (window-start) end markdown-regex-link-inline))
      (setq res (append res (ace-more-links-regex-search-in-range (window-start) end markdown-regex-link-reference)))
      ;;TODO reactivate these, but then need to remove dupes
      ;; (setq res (append res (ace-more-links-regex-search-in-range (window-start) end  markdown-regex-uri)))
      ;; (setq res (append res (ace-more-links-regex-search-in-range (window-start) end markdown-regex-angle-uri)))
      (sort res (lambda (a b) (< (cdr a) (cdr b)))))))

(defun ace-more-links-ace-link--md-action (pt)
  "Action when link is selected at PT in `markdown-mode' through `ace-link'."
  (when (numberp pt)
    (goto-char pt)
    (call-interactively 'markdown-follow-thing-at-point)))

(defun ace-more-links-ace-link-md ()
  "Open a visible link in an `markdown-mode' buffer."
  (interactive)
  (require 'org)
  (let ((pt (avy-with ace-more-links-ace-link-md
              (avy-process
               (mapcar #'cdr (ace-more-links-ace-link--md-collect))
               (avy--style-fn avy-style)))))
    (ace-more-links-ace-link--md-action pt)
    pt))

;; ********************************************************************************
;; ********************************************************************************************
;; lsp-mode / eglot (use imenu symbols as proxy)

(defun ace-more-links-ace-link--lsp-collect ()
  "Collects symbols in the visible part of the buffer using imenu."
  (save-excursion
    (let ((end (window-end))
          (start (window-start))
          (symbols (imenu-default-create-index-function)))
      (->> symbols
           (--map (cons (car it) (marker-position (cdr it))))
           (--filter (and (<= start (cdr it)) (>= end (cdr it))))
           (--map (lambda (x) (cons (car x) (cdr x))))))))

(defun ace-more-links-ace-link--lsp-action (pt)
  "Action when link is selected at PT in LSP-enabled buffer."
  (when (numberp pt)
    (goto-char pt)
    (call-interactively 'xref-find-definitions)))

(defun ace-more-links-ace-link-lsp ()
  "Open a visible LSP symbol in the current buffer."
  (interactive)
  (let ((pt (avy-with ace-more-links-ace-link-lsp
              (avy-process
               (mapcar #'cdr (ace-more-links-ace-link--lsp-collect))
               (avy--style-fn avy-style)))))
    (ace-more-links-ace-link--lsp-action pt)
    pt))

;; ***********************************************************************************
;; imenu-list-major-mode (jump to entries listed in imenu)


(defun ace-more-links-ace-link--imenu-action (pt)
  "Action when when link is selected at PT in `imenu-list' through `ace-link'."
  (when (numberp pt)
    (goto-char pt)
    (call-interactively 'imenu-list-goto-entry)))

(defun ace-more-links-ace-link--imenu-collect ()
  "Select leaf items as link targets."
  (let ((end (window-end))
        res)
    (save-excursion
      (setq res (ace-more-links-regex-search-in-range (window-start) end "^[^+].*$"))
      (sort res (lambda (a b) (< (cdr a) (cdr b)))))))

(defun ace-more-links-ace-link-imenu-list ()
  "Open a visible link in an `imenu-list-major-mode' side window."
  (interactive)
  (require 'imenu-list)
  (let ((pt (avy-with ace-more-links-ace-link-imenu-list
              (avy-process
               (mapcar #'cdr (ace-more-links-ace-link--imenu-collect))
               (avy--style-fn avy-style)))))
    (ace-more-links-ace-link--imenu-action pt)
    pt))


;; ********************************************************************************
;; bookmark-list-mode (jump to entries in bookmarks-list)

(defun ace-more-links-ace-link--bookmark-action (pt)
  "Action when link is selected at PT in `bookmarks-list-mode' through `ace-link'."
  (when (numberp pt)
    (goto-char pt)
    (call-interactively 'bookmark-bmenu-this-window)))

;; each line except the groups (starting with +) is a candidate
(defun ace-more-links-ace-link--bookmark-collect ()
  "Identify links in `bookmark-list'."
  (let ((end (window-end))
        res)
    (save-excursion
      (setq res (ace-more-links-regex-search-in-range (window-start) end "^[^+].*$"))
      (sort res (lambda (a b) (< (cdr a) (cdr b)))))))

;; link handline for bookmark
(defun ace-more-links-ace-link-bookmark ()
  "Open a visible link in the bookmarks list (`bookmark-bmenu-mode')."
  (interactive)
  (let ((pt (avy-with ace-more-links-ace-link-bookmark
              (avy-process
               (mapcar #'cdr (ace-more-links-ace-link--bookmark-collect))
               (avy--style-fn avy-style)))))
    (ace-more-links-ace-link--bookmark-action pt)
    pt))

;; ********************************************************************************
;; ibuffer-mode (switch to buffers in ibuffer)

(defun ace-more-links-ace-link--ibuffer-action (pt)
  "Action when link is selected at `PT' in `ibuffer-mode' through `ace-link'."
  (when (numberp pt)
    (goto-char pt)
    (call-interactively 'ibuffer-visit-buffer)))

(defun ace-more-links-ace-link--ibuffer-collect ()
  "Each line except the groups (not starting with [) is a candidate for a link."
  (let ((end (window-end))
        start
        res)
    (save-excursion
      (goto-char (point-min))
      (setq start (line-beginning-position 3))
      (setq res (ace-more-links-regex-search-in-range start end "^[^[].*$"))
      (sort res (lambda (a b) (< (cdr a) (cdr b)))))))

(defun ace-more-links-ace-link-ibuffer ()
  "Switch to a buffer in the ibuffers list (`ibuffer-mode')."
  (interactive)
  (let ((pt (avy-with ace-more-links-ace-link-ibuffer
              (avy-process
               (mapcar #'cdr (ace-more-links-ace-link--ibuffer-collect))
               (avy--style-fn avy-style)))))
    (ace-more-links-ace-link--ibuffer-action pt)
    pt))

;; ********************************************************************************
;; reftex-toc-mode

(defun ace-more-links-ace-link--reftex-toc-action (pt)
  "Action when link is selected at `PT' in `reftex-toc' through `ace-link'."
  (when (numberp pt)
    (goto-char pt)
    (call-interactively 'reftex-toc-goto-line-and-hide)))

(defun ace-more-links-ace-link--reftex-toc-collect ()
  "Every line except for the header is a link target."
  (let ((end (window-end))
        start
        res)
    (save-excursion
      (goto-char (point-min))
      (setq start (line-beginning-position 3))
      (setq res (ace-more-links-regex-search-in-range start end "^[ ]+.*$"))
      (sort res (lambda (a b) (< (cdr a) (cdr b)))))))

;; link handling for reftex-toc
(defun ace-more-links-ace-link-reftex-toc ()
  "Switch to a buffer in the reftex-tocs list (`reftex-toc-mode')."
  (interactive)
  (let ((pt (avy-with ace-more-links-ace-link-reftex-toc
              (avy-process
               (mapcar #'cdr (ace-more-links-ace-link--reftex-toc-collect))
               (avy--style-fn avy-style)))))
    (ace-more-links-ace-link--reftex-toc-action pt)
    pt))


;; ********************************************************************************
;; mu4e-main
(declare-function #'mu4e-bookmarks "mu4e-bookmarks" nil t)
(declare-function #'mu4e-search "mu4e-search" nil t)

(defun ace-more-links-ace-link--mu4e-main-action (pt)
  "Action when link is selected at `PT' in `mu4e-main-mode' through `ace-link'."
  (when (numberp pt)
    (goto-char pt)
    (let* ((shortcut (string-to-char (buffer-substring (+ pt 2) (+ pt 3))))
           (bookmark (car (seq-filter (lambda (x) (eq (plist-get x :key) shortcut)) (mu4e-bookmarks))))
           (query    (plist-get bookmark :query)))
      (message "search %s %s" query shortcut)
      (mu4e-search query))))

(defun ace-more-links-ace-link--mu4e-main-collect ()
  "All bookmarked queries are targets."
  (let ((end (window-end))
        start
        res)
    (save-excursion
      (goto-char (point-min))
      (setq start (line-beginning-position 3))
      (setq res (ace-more-links-regex-search-in-range start end "[[][b][a-z][]]"))
      (sort res (lambda (a b) (< (cdr a) (cdr b)))))))

(defun ace-more-links-ace-link-mu4e-main ()
  "Switch to a bookmark in `mu4e-main-mode'."
  (interactive)
  (let ((pt (avy-with ace-more-links-ace-link-mu4e-main
              (avy-process
               (mapcar #'cdr (ace-more-links-ace-link--mu4e-main-collect))
               (avy--style-fn avy-style)))))
    (ace-more-links-ace-link--mu4e-main-action pt)
    pt))

;; ********************************************************************************
;; elisp

(defun ace-more-links-ace-link--elisp-action (pt)
  "Action when link is selected at `PT' in `mu4e-main-mode' through `ace-link'."
  (when (numberp pt)
    (goto-char pt)))

(defun ace-more-links-ace-link--elisp-collect ()
  "All elisp functions and variables."
  (save-excursion
    (let ((end (window-end))
          (start (window-start))
          (elisp-elements (imenu-default-create-index-function)))
      (->> elisp-elements
           (--map (cons (car it) (marker-position (cdr it))))
           (--filter (and (<= start (cdr it)) (>= end (cdr it))))))))

(defun ace-more-links-ace-link-elisp ()
  "Jump to function in `emacs-lisp-mode'."
  (interactive)
  (let ((pt (avy-with ace-more-links-ace-link-elisp
              (avy-process
               (mapcar #'cdr (ace-more-links-ace-link--elisp-collect))
               (avy--style-fn avy-style)))))
    (ace-more-links-ace-link--elisp-action pt)
    pt))

;; ********************************************************************************
;; elfeed
(defun ace-more-links-ace-link--elfeed-action (pt)
  "Action when link is selected at `PT' in `elfeed' through `ace-link'."
  (when (numberp pt)
    (goto-char pt)
    (call-interactively 'lordpretzel/elfeed-open-entry-in-xwidgets)))

(defun ace-more-links-ace-link--elfeed-collect ()
  "Every line except for the header is a link target."
  (let ((end (window-end))
        start
        res)
    (save-excursion
      (goto-char (point-min))
      (setq start (line-beginning-position 1))
      (setq res (ace-more-links-regex-search-in-range start end "^."))
      (sort res (lambda (a b) (< (cdr a) (cdr b)))))))

;; link handling for elfeed
(defun ace-more-links-ace-link-elfeed ()
  "Switch to a buffer in the elfeeds list (`elfeed-mode')."
  (interactive)
  (let ((pt (avy-with ace-more-links-ace-link-elfeed
              (avy-process
               (mapcar #'cdr (ace-more-links-ace-link--elfeed-collect))
               (avy--style-fn avy-style)))))
    (ace-more-links-ace-link--elfeed-action pt)
    pt))

;; ********************************************************************************
;; dashboard
;;;###autoload
(defun ace-more-links-dashboard ()
  "Open a visible link in an `Dashboard-mode' buffer."
  (interactive)
  (let ((pt (avy-with ace-link-dashboard
              (avy-process
               (ace-more-links--dashboard-collect)
               (avy--style-fn avy-style)))))
    (ace-more-links--dashboard-action pt)))

(defun ace-more-links--dashboard-action (pt)
  "Move to PT and press button."
  (when (number-or-marker-p (car pt))
    (let* ((btn (button-at (point))))
      (button-activate btn)
      t)))

(defun ace-more-links--dashboard-collect ()
  "Collect the positions of visible links in the current `Dashboard-mode' buffer."
  (let (buttons)
    (save-excursion
      (save-restriction
        (let ((pos (point-min))
              btn)
          (save-excursion
            (while (< pos (point-max))
              (goto-char pos)
              (when (setq btn (button-at pos))
                (push (cons btn pos) buttons)
                ;; Jump to end of this button to avoid re-matching same area
                (setq pos (or (button-start btn) (1+ pos))))
              (setq pos (next-property-change pos (current-buffer))
                    pos (if (or (null pos) (= pos (point-max)))
                            (point-max)
                          pos))))
          (nreverse buttons))))))

;; keep byte compiler quiet if we do not have vui action (not on melpa)
(declare-function ace-link-vui-action nil t)
                  
;; ********************************************************************************
;; global dispatcher to select right jump method
(defun ace-more-links-ace-link-global-handler ()
  "Call the `ace-link' function for the current `major-mode'."
  (interactive)
  (cond ((eq major-mode 'markdown-mode)
         (ace-more-links-ace-link-md))
        ((eq major-mode 'imenu-list-major-mode)
         (ace-more-links-ace-link-imenu-list))
        ((eq major-mode 'bookmark-bmenu-mode)
         (ace-more-links-ace-link-bookmark))
        ((eq major-mode 'ibuffer-mode)
         (ace-more-links-ace-link-ibuffer))
        ((eq major-mode 'reftex-toc-mode)
         (ace-more-links-ace-link-reftex-toc))
        ((eq major-mode 'mu4e-main-mode)
         (ace-more-links-ace-link-mu4e-main))
        ((eq major-mode 'emacs-lisp-mode)
         (ace-more-links-ace-link-elisp))
        ((eq major-mode 'elfeed-search-mode)
         (ace-more-links-ace-link-elfeed))
        ((eq major-mode 'dashboard-mode)
         (ace-more-links-dashboard))
        ((and (derived-mode-p 'vui-mode) (fboundp 'ace-link-vui))
         (ace-link-vui-action)
         t)
        ;; if it is not a specific buffer type, then if the current buffer has
        ;; lsp-mode active, use lsp-find-definition
        (lsp-mode
         (ace-more-links-ace-link-lsp))
        ;; ((eq major-mode 'lsp-mode)
        ;;  (ace-more-links-ace-link-lsp))
        ;; ((eq major-mode 'eglot)
        ;;  (ace-more-links-ace-link-lsp))
        ;; unknown mode -> error
        (t
         (error
          "%S isn't supported"

          major-mode))))

;;;###autoload
(defun ace-more-links-activate ()
  "Activate additional link types for `ace-link'."
  (setq ace-link-fallback-function #'ace-more-links-ace-link-global-handler))

(provide 'ace-more-links)

;;; ace-more-links.el ends here
