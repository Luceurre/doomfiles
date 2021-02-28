;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets.
(setq user-full-name "Pierre Glandon"
      user-mail-address "pglandon78@gmail.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom. Here
;; are the three important ones:
;;
;; + `doom-font'
;; + `doom-variable-pitch-font'
;; + `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;;
;; They all accept either a font-spec, font string ("Input Mono-12"), or xlfd
;; font string. You generally only need these two:
;; (setq doom-font (font-spec :family "monospace" :size 12 :weight 'semi-light)
;;       doom-variable-pitch-font (font-spec :family "sans" :size 13))
(setq doom-font "Source Code Pro 14")

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-one)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")
(after! org
  (setq org-file-apps (append org-file-apps '(("\\.mp4\\'" . "vlc \"%s\""))))
  )

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)


;; Here are some additional functions/macros that could help you configure Doom:
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.


(defun luceurre/org-agenda-process-inbox-item ()
  "Process a single item in the org-agenda."
  (interactive)
  (org-with-wide-buffer
   (org-agenda-set-tags)
   (org-agenda-priority)
   (org-agenda-set-effort)
   (org-agenda-refile nil nil t)))

(use-package! company
  :diminish
  :bind (("C-." . #'company-complete))
  :hook (prog-mode . company-mode)
  :custom
  (company-dabbrev-downcase nil "Don't downcase returned candidates.")
  (company-show-numbers t "Numbers are helpful.")
  (company-tooltip-limit 20 "The more the merrier.")
  (company-tooltip-idle-delay 0.4 "Faster!")
  (company-async-timeout 20 "Some requests can take a long time. That's fine.")
  :config

  ;; Use the numbers 0-9 to select company completion candidates
  (let ((map company-active-map))
    (mapc (lambda (x) (define-key map (format "%d" x)
                        `(lambda () (interactive) (company-complete-number ,x))))
          (number-sequence 0 9))))

(setq company-minimum-prefix-length 1
      company-idle-delay 0.0)


(use-package! japanese-vocabulary
  :config
  (luceurre/japanese-vocabulary-mode t))
(use-package! dbus-utils)

(map! :leader :desc "Quick selection" :n "C-s" 'er/expand-region)
(map! :desc "Quick selection" :v "C-s" 'er/expand-region)
(map! :desc "Quick selection" :i "C-s" 'er/expand-region)

(use-package! org-super-agenda
  :config
  (org-super-agenda-mode)
  (setq org-super-agenda-groups
        '((:name "Important"
           :and (:priority "A" :todo "TODO" :deadline future))
          (:name "Done"
           :discard (:todo "DONE"))
          (:name "Shame"
           :todo "KILL")
          (:name "Meeting"
           :scheduled t)
          (:name "To Refile"
           :file-path "inbox.org$")
          (:auto-category)
          )))

(use-package! treemacs-all-the-icons)

(use-package! treemacs
  :defer t
  :config
  (treemacs-load-theme "all-the-icons")
  :after treemacs-all-the-icons
  )

(use-package! skeletor)

(use-package! org-roam
  :config
  (setq org-roam-link-use-custom-faces t)
  (setq org-roam-dailies-capture-templates
        '(("d" "default" entry
           #'org-roam-capture--get-point
           "* %?"
           :file-name "daily/%<%Y-%m-%d>"
           :head "#+title: %<%Y-%m-%d>\n\n")))
  (setq org-roam-capture-templates
        '(
          ("d" "default" plain (function org-roam--capture-get-point)
           "%?"
           :file-name "%<%Y%m%d%H%M%S>-${slug}"
           :head "#+title: ${title}\n"
           :unnarrowed t)
          ))
  (setq org-roam-graph-exclude-matcher '("private" "daily"))
  )

(use-package! org-roam-protocol)

(map!
 :g "C-i" 'org-noter-insert-note)

(setq +notmuch-sync-backend 'mbsync)

(use-package org-gtd
  :load-path "~/Projects/Emacs/org-gtd.el/"
  :after org
  :config
  (setq
   org-gtd-directory "~/gtd/"
   org-edna-use-inheritance t)
  (org-edna-load)
  )

;; (load-library "find-lisp")
;; (setq org-agenda-files (find-lisp-find-files "~/org" "\.org$"))

(use-package org-agenda
  :after org-gtd
  :config
  (setq org-agenda-files `(,org-gtd-directory))
  )

(use-package! org-capture
  :after org-gtd
  :config
  (setq luceurre/org-agenda-directory "~/org/roam/daily/")
)

(setq org-capture-templates
      `(("i" "inbox" entry (file ,(concat luceurre/org-agenda-directory "%<%Y-%m-%d>"))
         "* TODO %?")
        ("e" "email" entry (file+headline ,(concat luceurre/org-agenda-directory "emails.org") "Emails")
         "* TODO [#A] Reply: %a :@home:@school:" :immediate-finish t)
        ("l" "link" entry (file ,(concat luceurre/org-agenda-directory "inbox.org"))
         "* TODO %(org-cliplink-capture)" :immediate-finish t)
        ("c" "org-protocol-capture" entry (file ,(concat luceurre/org-agenda-directory "inbox.org"))
         "* TODO [[%:link][%:description]]\n\n %i" :immediate-finish t)))
