;; Packages
(require 'package)

;; Define repos
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)

;; Activate packages
(package-initialize)

;; Fetch packages
(or (file-exists-p package-user-dir) (package-refresh-contents))

;; Helper to install and require
(defun pkg (p &rest body)
  (unless (require p nil t)
    (package-install p)
    (require p))
  body)

(pkg 'mouse
     (xterm-mouse-mode t)
     (global-set-key [mouse-4] (lambda ()
				 (interactive)
				 (scroll-down 1)))
     (global-set-key [mouse-5] (lambda ()
				 (interactive)
				 (scroll-up 1)))
     (defun track-mouse (e))
     (setq mouse-sel-mode t))

(pkg 'evil
     (evil-mode 1)

     ;; Keep Vim ctrl-u
     (define-key evil-normal-state-map (kbd "C-u") 'evil-scroll-up)

     ;; Swap ; and :
     (define-key evil-normal-state-map (kbd ";") 'evil-ex)
     (define-key evil-normal-state-map (kbd ":") 'evil-repeat-find-char)

     ;; Backtab = jump backwards
     (define-key evil-normal-state-map (kbd "<backtab>") 'evil-jump-backward)

     ;; Preserve visual mode
     (defun evil-shift-left-visual ()
       (interactive)
       (evil-shift-left (region-beginning) (region-end))
       (evil-normal-state)
       (evil-visual-restore))

     (defun evil-shift-right-visual ()
       (interactive)
       (evil-shift-right (region-beginning) (region-end))
       (evil-normal-state)
       (evil-visual-restore))

     (define-key evil-visual-state-map (kbd ">") 'evil-shift-right-visual)
     (define-key evil-visual-state-map (kbd "<") 'evil-shift-left-visual))

(pkg 'evil-leader
     (global-evil-leader-mode)
     (evil-leader/set-leader "<SPC>"))

(pkg 'helm
     (pkg 'helm-config)
     (helm-mode 1)

     ;; Replace keybinds with helm equivalents
     (global-set-key (kbd "M-x") 'helm-M-x)
     (global-set-key (kbd "C-x r b") 'helm-filtered-bookmarks)
     (global-set-key (kbd "C-x C-f") 'helm-find-files)

     ;; Fuzzy all the things
     (setq
      helm-mode-fuzzy-match t
      helm-completion-in-region-fuzzy-match t
      helm-recentf-fuzzy-match t
      helm-buffers-fuzzy-matching t
      helm-recentf-fuzzy-match t
      helm-buffers-fuzzy-matching t
      helm-locate-fuzzy-match t
      helm-M-x-fuzzy-match t
      helm-semantic-fuzzy-match t
      helm-imenu-fuzzy-match t
      helm-apropos-fuzzy-match t
      helm-lisp-fuzzy-completion t))

(pkg 'auto-complete
     (setq ac-delay 0
	   ac-quick-help-delay 0
	   ac-auto-show-menu t)
     (global-set-key (kbd "<backtab>") 'ac-previous)
     (ac-config-default))

(pkg 'smart-mode-line
     (setq
      sml/no-confirm-load-theme t
      sml/theme 'respectful)
     (sml/setup))

(pkg 'git-gutter
     (global-git-gutter-mode t)
     (git-gutter:linum-setup))

;; General
(menu-bar-mode -1) ;; Disable toolbar
(global-linum-mode t) ;; Line numbers

;; Aliases
(defalias 'yes-or-no-p 'y-or-n-p)

;; Settings
(let
    ((backupdir (concat user-emacs-directory "backups/"))
     (undodir (concat user-emacs-directory "undo/")))

  ;; Make required directories
  (mapc
   (lambda (dir)
     (unless (file-exists-p dir)
       (make-directory dir)))
   `(,backupdir ,undodir))

  (setq
   ;; System
   vc-follow-symlinks t

   ;; Appearance
   inhibit-startup-screen t
   scroll-step 1
   scroll-margin 5

   ;; Whitespace
   tab-width 2
   indent-tabs-mode nil

   ;; Persistent undo
   undo-tree-auto-save-history t
   undo-tree-history-directory-alist `(("." . ,undodir))

   ;; Backups
   backup-directory-alist `((".*" . ,backupdir))
   auto-save-file-name-transforms `((".*" ,backupdir t))
   backup-by-copying t))

;; Create parent directory if it doesn't exist
(defadvice
    find-file
    (before make-directory-maybe (filename &optional wildcards) activate)
  "Create parent directory if not exists while visiting file."
  (unless (file-exists-p filename)
    (let ((dir (file-name-directory filename)))
      (unless (file-exists-p dir)
	(make-directory dir)))))

;; Right-aligned linum
(defadvice
    linum-update-window
    (around linum-dynamic activate)
  (let*
      ((w (length (number-to-string (count-lines (point-min) (point-max)))))
       (linum-format (concat "%" (number-to-string w) "d ")))
    ad-do-it))
