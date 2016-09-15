;; Packages
(require 'package)

;; Define repos
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)

;; Activate packages
(package-initialize)

;; Helper to install and require
(defun pkg (p)
  (unless (require p nil t)
    (package-refresh-contents)
    (package-install p)
    (require p)))

(progn (pkg 'mouse)
       (xterm-mouse-mode t)
       (global-set-key [mouse-4] (lambda ()
                                   (interactive)
                                   (scroll-down 1)))
       (global-set-key [mouse-5] (lambda ()
                                   (interactive)
                                   (scroll-up 1)))
       (defun track-mouse (e))
       (setq-default mouse-sel-mode t))

(progn (pkg 'saveplace)
       (setq-default save-place t))

(progn (pkg 'evil)
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
       (define-key evil-visual-state-map (kbd "<") 'evil-shift-left-visual)

       (progn (pkg 'evil-leader)
              (global-evil-leader-mode)
              (evil-leader/set-leader "<SPC>"))

       (progn (pkg 'evil-surround)
              (global-evil-surround-mode 1))

       (progn (pkg 'evil-mc)
              (global-evil-mc-mode 1))

       (progn (pkg 'evil-commentary)
              (evil-commentary-mode))

       (progn (pkg 'evil-terminal-cursor-changer)
              (evil-terminal-cursor-changer-activate)
              (setq-default
               blink-cursor-mode t
               evil-motion-state-cursor 'box
               evil-visual-state-cursor 'box
               evil-normal-state-cursor 'box
               evil-insert-state-cursor 'bar
               evil-emacs-state-cursor  'hbar)))

(progn (pkg 'ivy) (pkg 'ivy-hydra) (pkg 'counsel) (pkg 'swiper) (pkg 'flx)
       (ivy-mode 1)
       (setq-default
        ivy-use-virtual-buffers t ;; Add virtual buffers
        ivy-initial-inputs-alist nil ;; No start anchor
        ;; Fuzzy
        ivy-re-builders-alist '((ivy-switch-buffer . ivy--regex-plus)
                                (t . ivy--regex-fuzzy)))
       ;; Folder navigation
       (define-key ivy-minibuffer-map (kbd "C-j") 'ivy-immediate-done)
       (define-key ivy-minibuffer-map (kbd "RET") 'ivy-alt-done)

       ;; Counsel binds
       (define-key evil-normal-state-map "\C-s" 'swiper)
       (define-key evil-normal-state-map (kbd "C-c C-r") 'ivy-resume)
       (define-key evil-normal-state-map (kbd "<f6>") 'ivy-resume)
       (define-key evil-normal-state-map (kbd "M-x") 'counsel-M-x)
       (define-key evil-normal-state-map (kbd "C-x C-f") 'counsel-find-file)
       (define-key evil-normal-state-map (kbd "<f1> f") 'counsel-describe-function)
       (define-key evil-normal-state-map (kbd "<f1> v") 'counsel-describe-variable)
       (define-key evil-normal-state-map (kbd "<f1> l") 'counsel-load-library)
       (define-key evil-normal-state-map (kbd "<f2> i") 'counsel-info-lookup-symbol)
       (define-key evil-normal-state-map (kbd "<f2> u") 'counsel-unicode-char)
       (define-key evil-normal-state-map (kbd "C-c g") 'counsel-git)
       (define-key evil-normal-state-map (kbd "C-c j") 'counsel-git-grep)
       (define-key evil-normal-state-map (kbd "C-c k") 'counsel-ag)
       (define-key evil-normal-state-map (kbd "C-x l") 'counsel-locate)
       (define-key evil-normal-state-map (kbd "C-S-o") 'counsel-rhythmbox)
       (define-key read-expression-map (kbd "C-r") 'counsel-expression-history))

(progn (pkg 'which-key)
       (setq-default which-key-idle-delay 0.5)
       (which-key-mode))

(progn (pkg 'auto-complete) (pkg 'fuzzy)
       (ac-config-default)
       (setq-default ac-use-fuzzy t)
       (define-key ac-mode-map (kbd "TAB") 'auto-complete)
       (define-key ac-mode-map (kbd "<backtab>") 'ac-previous))

(progn (pkg 'flycheck)
       (global-flycheck-mode))

(progn (pkg 'smart-mode-line)
       (setq-default
        sml/no-confirm-load-theme t
        sml/theme 'respectful)
       (sml/setup))

(progn (pkg 'git-gutter)
       (global-git-gutter-mode t)
       (git-gutter:linum-setup)
       (custom-set-variables
        '(git-gutter:modified-sign "~ ")
        '(git-gutter:added-sign "+ ")
        '(git-gutter:deleted-sign "- ")))

(progn (pkg 'rainbow-delimiters)
       (add-hook 'emacs-lisp-mode-hook 'rainbow-delimiters-mode))

;; General
(menu-bar-mode -1) ;; Disable toolbar
(global-linum-mode t) ;; Line numbers

;; Aliases
(defalias 'yes-or-no-p 'y-or-n-p)

;; Settings
(let
    ((backupdir (concat user-emacs-directory "backups/"))
     (undodir (concat user-emacs-directory "undo/"))
     (saveplacefile (concat user-emacs-directory "places")))

  ;; Make required directories
  (mapc
   (lambda (dir)
     (unless (file-exists-p dir)
       (make-directory dir)))
   `(,backupdir ,undodir))

  (setq-default
   ;; System
   vc-follow-symlinks t

   ;; Appearance
   inhibit-startup-screen t
   scroll-step 1
   scroll-margin 5

   ;; Whitespace
   tab-width 2
   indent-tabs-mode nil

   ;; Return to last edit position
   save-place-file saveplacefile

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
