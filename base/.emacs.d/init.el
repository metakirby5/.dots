;;; init.el --- Emacs configuration

;; Author: Ethan Chan <metakirby5@gmail.com

;;; Commentary:

;; Cool stuff ahead!

;;; Code:

;; Packages
(require 'package)
(setq-default package-enable-at-startup nil)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(defun pkg (p)
  "Requires a package, installing if necessary.
P: The quoted package."
  (unless (require p nil t)
    (package-refresh-contents)
    (package-install p)
    (require p)))

(progn (pkg 'saveplace)
       (setq-default save-place t))

(progn (pkg 'xclip)
       (xclip-mode 1))

(progn (pkg 'evil)
       (evil-mode 1)

       ;; Keep Vim ctrl-u
       (define-key evil-normal-state-map (kbd "C-u") 'evil-scroll-up)

       ;; Visually move up and down lines
       (define-key evil-normal-state-map
         (kbd "j") 'evil-next-visual-line)
       (define-key evil-normal-state-map
         (kbd "k") 'evil-previous-visual-line)
       (define-key evil-normal-state-map
         (kbd "<up>") 'evil-next-visual-line)
       (define-key evil-normal-state-map
         (kbd "<down>") 'evil-previous-visual-line)

       ;; Swap ; and :
       (define-key evil-normal-state-map (kbd ";") 'evil-ex)
       (define-key evil-normal-state-map (kbd ":") 'evil-repeat-find-char)

       ;; Swap 0 and ^, with visual move
       (define-key evil-normal-state-map
         (kbd "0") 'evil-first-non-blank-of-visual-line)
       (define-key evil-normal-state-map
         (kbd "^") 'evil-beginning-of-visual-line)
       (define-key evil-normal-state-map
         (kbd "$") 'evil-end-of-visual-line)

       ;; Backtab = jump backwards
       (define-key evil-normal-state-map (kbd "<backtab>") 'evil-jump-backward)

       ;; Split line
       (define-key evil-normal-state-map
         (kbd "K") (lambda () (interactive) (insert "\n")))

       ;; Preserve visual mode
       (define-key evil-visual-state-map (kbd "<")
         (lambda ()
           (interactive)
           (evil-shift-left (region-beginning) (region-end))
           (evil-normal-state)
           (evil-visual-restore)))
       (define-key evil-visual-state-map (kbd ">")
         (lambda ()
           (interactive)
           (evil-shift-right (region-beginning) (region-end))
           (evil-normal-state)
           (evil-visual-restore)))

       (progn (pkg 'evil-leader)
              (global-evil-leader-mode)
              (evil-leader/set-leader "<SPC>")
              (evil-leader/set-key
                ;; Split keybinds
                "s" 'evil-window-split
                "v" 'evil-window-vsplit
                "h" 'evil-window-left
                "j" 'evil-window-down
                "k" 'evil-window-up
                "l" 'evil-window-right
                "H" 'evil-window-move-far-left
                "J" 'evil-window-move-very-bottom
                "K" 'evil-window-move-very-top
                "L" 'evil-window-move-far-right))

       (progn (pkg 'evil-surround)
              (global-evil-surround-mode 1)
              (evil-define-key 'visual
                evil-surround-mode-map "s" 'evil-surround-region)
              (evil-define-key 'visual
                evil-surround-mode-map "gs" 'evil-Surround-region)
              (define-key evil-normal-state-map
                (kbd "s") 'evil-surround-edit)
              (define-key evil-normal-state-map
                (kbd "S") 'evil-Surround-edit))

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

(progn (pkg 'linum-relative)
       (linum-relative-on)
       (setq-default
        linum-relative-format "%3s "
        linum-relative-current-symbol "")
       (custom-set-faces
        '(linum-relative-current-face
          ((t (:background "brightblack" :foreground "white"))))))

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

       ;; Ivy binds
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
       (define-key read-expression-map (kbd "C-r") 'counsel-expression-history)
       (evil-leader/set-key
         ";" 'counsel-M-x
         "gz" 'counsel-git
         "gg" 'counsel-git-grep
         "a" 'counsel-ag
         "x" 'ivy-switch-buffer
         "y" 'counsel-yank-pop))

(progn (pkg 'which-key)
       (setq-default which-key-idle-delay 0.5)
       (which-key-mode))

(progn (pkg 'company)
       (progn (pkg 'company-flx)
              (with-eval-after-load 'company (company-flx-mode +1)))
       (add-hook 'after-init-hook 'global-company-mode)
       (setq-default
        company-idle-delay 0)
       (define-key company-active-map
         (kbd "TAB") 'company-select-next)
       (define-key company-active-map
         (kbd "<backtab>") 'company-select-previous)
       (custom-set-faces
        '(company-tooltip
          ((t (:background "brightblack" :foreground "brightwhite"))))
        '(company-tooltip-selection
          ((t (:background "brightblue" :foreground "brightwhite"))))
        '(company-scrollbar-fg
          ((t (:background "brightblue"))))
        '(company-scrollbar-bg
          ((t (:background "brightwhite"))))))

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
        '(git-gutter:unchanged-sign "  ")
        '(git-gutter:modified-sign "~ ")
        '(git-gutter:added-sign "+ ")
        '(git-gutter:deleted-sign "- "))
       (custom-set-faces
        '(git-gutter:unchanged ((t (:inherit default))))
        '(git-gutter:modified ((t (:inherit default :foreground "yellow"))))
        '(git-gutter:added ((t (:inherit default :foreground "green"))))
        '(git-gutter:removed ((t (:inherit default :foreground "red")))))
       (define-key evil-normal-state-map (kbd "]g") 'git-gutter:next-hunk)
       (define-key evil-normal-state-map (kbd "[g") 'git-gutter:previous-hunk)
       (evil-leader/set-key
         "ga" 'git-gutter:stage-hunk
         "gu" 'git-gutter:revert-hunk
         "go" 'git-gutter:popup-diff))

(progn (pkg 'aggressive-indent)
       (global-aggressive-indent-mode 1))

(progn (pkg 'highlight-indent-guides)
       (add-hook 'prog-mode-hook 'highlight-indent-guides-mode)
       (setq-default
        highlight-indent-guides-method 'character
        highlight-indent-guides-character ?\│))

(progn (pkg 'rainbow-delimiters)
       (add-hook 'emacs-lisp-mode-hook 'rainbow-delimiters-mode))

(progn (pkg 'autopair)
       (autopair-global-mode))

(progn (pkg 'dtrt-indent)
       (add-hook 'prog-mode-hook 'dtrt-indent-mode))

;; Languages
(progn (pkg 'company-jedi)
       (add-hook 'python-mode-hook
                 (lambda () (add-to-list 'company-backends 'company-jedi))))

(progn (pkg 'elm-mode)
       (add-hook 'elm-mode-hook
                 (lambda () (add-to-list 'company-backends 'company-elm))))

(progn (pkg 'coffee-mode))

;; General
(menu-bar-mode -1)
(global-linum-mode t)
(show-paren-mode t)
(global-whitespace-mode)

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
   ring-bell-function 'ignore

   ;; Appearance
   inhibit-startup-screen t
   initial-scratch-message ""
   scroll-step 1
   scroll-margin 5
   scroll-conservatively 0
   scroll-up-aggressively 0.01
   scroll-down-aggressively 0.01
   word-wrap t

   ;; Modeline
   mode-line-format
   (list " "
         'mode-line-buffer-identification
         '(mode-line-modified " [%+] / ")
         'mode-name)

   ;; Whitespace
   tab-width 2
   indent-tabs-mode nil
   whitespace-line-column 78
   whitespace-style '(face trailing tabs tab-mark lines-tail)
   whitespace-display-mappings '((tab-mark 9 [9474 9] [92 9]))

   ;; Return to last edit position
   save-place-file saveplacefile

   ;; Persistent undo
   undo-tree-auto-save-history t
   undo-tree-history-directory-alist `(("." . ,undodir))

   ;; Backups
   backup-directory-alist `((".*" . ,backupdir))
   auto-save-file-name-transforms `((".*" ,backupdir t))
   backup-by-copying t))

(custom-set-faces
 '(whitespace-tab ((t (:foreground "blue"))))
 '(region ((t (:inverse-video t))))
 '(linum ((t (:inherit default :foreground "brightblack")))))

;; Enable mouse
(xterm-mouse-mode t)
(global-set-key [mouse-4] (lambda ()
                            (interactive)
                            (scroll-down 1)))
(global-set-key [mouse-5] (lambda ()
                            (interactive)
                            (scroll-up 1)))
(setq-default mouse-sel-mode t)

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
;; (defadvice
;;     linum-update-window
;;     (around linum-dynamic activate)
;;   (let*
;;       ((w (length (number-to-string (count-lines (point-min) (point-max)))))
;;        (linum-format (concat "%" (number-to-string w) "d ")))
;;     ad-do-it))

(provide 'init)
;;; init.el ends here
