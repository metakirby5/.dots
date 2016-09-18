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

;; Helpers
(defun pkg (p)
  "Require a package, installing if necessary.
P: The quoted package."
  (unless (require p nil t)
    (package-refresh-contents)
    (package-install p)
    (require p)))

(defun bind (map key cmd &rest bindings)
  "Bind a list of keybindings to a keymap.
MAP: the keymap.
KEY: the key.
CMD: the action.
BINDINGS: extra keybindings."
  (while key
    (if map
        (define-key map (kbd key) cmd)
      (global-set-key (kbd key) cmd))
    (setq key (pop bindings)
          cmd (pop bindings))))

(progn (pkg 'exec-path-from-shell)
       (exec-path-from-shell-initialize))

(progn (pkg 'saveplace)
       (setq-default save-place t))

(progn (pkg 'xclip)
       (xclip-mode 1))

(progn (pkg 'evil)
       (evil-mode 1)

       (bind evil-normal-state-map
             ;; Keep Vim ctrl-u
             "C-u" 'evil-scroll-up

             ;; Visually move up and down lines
             "j" 'evil-next-visual-line
             "k" 'evil-previous-visual-line
             "<up>" 'evil-previous-visual-line
             "<down>" 'evil-next-visual-line

             ;; Swap ; and :
             ";" 'evil-ex
             ":" 'evil-repeat-find-char

             ;; Swap 0 and ^, with visual move
             "0" 'evil-first-non-blank-of-visual-line
             "^" 'evil-beginning-of-visual-line
             "$" 'evil-end-of-visual-line

             ;; Backtab = jump backwards
             "<backtab>" 'evil-jump-backward

             ;; K = split line
             "K" (lambda () (interactive) (insert "\n")))

       (bind evil-visual-state-map

             ;; Visually move up and down lines
             "j" 'evil-next-visual-line
             "k" 'evil-previous-visual-line
             "<up>" 'evil-previous-visual-line
             "<down>" 'evil-next-visual-line

             ;; Swap ; and :
             ";" 'evil-ex
             ":" 'evil-repeat-find-char

             ;; Swap 0 and ^, with visual move
             "0" 'evil-first-non-blank-of-visual-line
             "^" 'evil-beginning-of-visual-line
             "$" 'evil-end-of-visual-line

             ;; Preserve visual mode
             "<" (lambda ()
                   (interactive)
                   (evil-shift-left (region-beginning) (region-end))
                   (evil-normal-state)
                   (evil-visual-restore))
             ">" (lambda ()
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
              (evil-define-key 'normal evil-surround-mode-map
                "s" 'evil-surround-edit
                "S" 'evil-Surround-edit)
              (evil-define-key 'visual evil-surround-mode-map
                "s" 'evil-surround-region
                "S" 'evil-Surround-region))

       (progn (pkg 'evil-mc)
              (global-evil-mc-mode 1))

       (progn (pkg 'evil-commentary)
              (evil-commentary-mode))

       (if (not (display-graphic-p))
           (progn (pkg 'evil-terminal-cursor-changer)
                  (evil-terminal-cursor-changer-activate)
                  (setq-default
                   blink-cursor-mode t
                   evil-motion-state-cursor 'box
                   evil-visual-state-cursor 'box
                   evil-normal-state-cursor 'box
                   evil-insert-state-cursor 'bar
                   evil-emacs-state-cursor  'hbar))))

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
       (bind ivy-minibuffer-map
             "C-j" 'ivy-immediate-done
             "RET" 'ivy-alt-done)

       ;; Ivy binds
       (bind evil-normal-state-map
             "C-s" 'swiper
             "C-c C-r" 'ivy-resume
             "<f6>" 'ivy-resume
             "M-x" 'counsel-M-x
             "C-x C-f" 'counsel-find-file
             "<f1> f" 'counsel-describe-function
             "<f1> v" 'counsel-describe-variable
             "<f1> l" 'counsel-load-library
             "<f2> i" 'counsel-info-lookup-symbol
             "<f2> u" 'counsel-unicode-char
             "C-c g" 'counsel-git
             "C-c j" 'counsel-git-grep
             "C-c k" 'counsel-ag
             "C-x l" 'counsel-locate
             "C-c r" 'counsel-rhythmbox
             "C-c h" 'counsel-expression-history)

       (evil-leader/set-key
         ";" 'counsel-M-x
         "gz" 'counsel-git
         "gg" 'counsel-git-grep
         "a" 'counsel-ag
         "x" 'ivy-switch-buffer
         "y" 'counsel-yank-pop))

(progn (pkg 'projectile) (pkg 'counsel-projectile)
       (add-hook 'prog-mode-hook 'projectile-mode)
       (counsel-projectile-on)
       (evil-leader/set-key
         "z" 'counsel-projectile-find-file))

(progn (pkg 'which-key)
       (setq-default which-key-idle-delay 0.5)
       (which-key-mode))

(progn (pkg 'company)
       (progn (pkg 'company-flx)
              (with-eval-after-load 'company (company-flx-mode +1)))
       (add-hook 'after-init-hook 'global-company-mode)
       (setq-default
        company-idle-delay 0)
       (bind company-active-map
             "TAB" 'company-select-next
             "<backtab>" 'company-select-previous)
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
       (bind evil-normal-state-map
             "[g" 'git-gutter:previous-hunk
             "]g" 'git-gutter:next-hunk)
       (evil-leader/set-key
         "ga" 'git-gutter:stage-hunk
         "gu" 'git-gutter:revert-hunk
         "go" 'git-gutter:popup-diff))

(progn (pkg 'aggressive-indent)
       (add-hook 'emacs-lisp-mode-hook 'aggressive-indent-mode))

(progn (pkg 'highlight-indent-guides)
       (add-hook 'prog-mode-hook 'highlight-indent-guides-mode)
       (setq-default
        highlight-indent-guides-method 'character
        highlight-indent-guides-character ?\│))

(progn (pkg 'rainbow-delimiters)
       (add-hook 'emacs-lisp-mode-hook 'rainbow-delimiters-mode)
       (custom-set-faces
        '(rainbow-delimiters-depth-1-face ((t (:foreground "brightgreen"))))
        '(rainbow-delimiters-depth-2-face ((t (:foreground "brightyellow"))))
        '(rainbow-delimiters-depth-3-face ((t (:foreground "brightblue"))))
        '(rainbow-delimiters-depth-4-face ((t (:foreground "brightmagenta"))))
        '(rainbow-delimiters-depth-5-face ((t (:foreground "brightcyan"))))
        '(rainbow-delimiters-depth-6-face ((t (:foreground "brightgreen"))))
        '(rainbow-delimiters-depth-7-face ((t (:foreground "brightyellow"))))
        '(rainbow-delimiters-depth-8-face ((t (:foreground "brightblue"))))
        '(rainbow-delimiters-depth-9-face ((t (:foreground "brightmagenta"))))))

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
(progn (pkg 'markdown-mode))
(progn (pkg 'yaml-mode))
(progn (pkg 'jade-mode))
(progn (pkg 'stylus-mode))

;; General
(if (display-graphic-p)
    (progn (tool-bar-mode -1)
           (scroll-bar-mode -1)
           (set-fringe-mode 0)))
(menu-bar-mode -1)
(global-linum-mode t)
(show-paren-mode t)
(global-whitespace-mode)
(add-hook 'shell-mode-hook 'ansi-color-for-comint-mode-on)

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

   ;; Parens
   show-paren-delay 0
   show-paren-style 'expression

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

   ;; (No) backups
   auto-save-default nil
   backup-directory-alist `((".*" . ,backupdir))
   auto-save-file-name-transforms `((".*" ,backupdir t))
   backup-by-copying t))

;; Theme
(if (display-graphic-p)
    ;; Theme for graphical
    (progn (pkg 'moe-theme)
           (moe-dark))
  ;; Custom faces for terminal
  (custom-set-faces
   '(whitespace-tab ((t (:foreground "blue"))))
   '(region ((t (:inverse-video t))))
   '(show-paren-match ((t (:background "brightblack"))))
   '(vertical-border ((t (:background "black" :foreground "black"))))
   '(linum ((t (:inherit default :foreground "gray"))))))

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
