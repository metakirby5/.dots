; Packages
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)
(defun pkg (p)
  (unless (require p nil t)
    (when (not package-archive-contents)
      (package-refresh-contents))
    (package-install p)
    (require p)))

(pkg 'evil) ; {{{
  ; Start in Evil mode
  (evil-mode 1)

  ; Swap ; and :
  (define-key evil-normal-state-map (kbd ";") 'evil-ex)
  (define-key evil-normal-state-map (kbd ":") 'evil-repeat-find-char)
; }}}

(pkg 'evil-leader) ; {{{
  (global-evil-leader-mode)
  (evil-leader/set-leader "<SPC>")
; }}}

(pkg 'helm) ; {{{
  (pkg 'helm-config)
  (helm-mode 1)
; }}}

; General {{{
  (menu-bar-mode -1) ; Disable toolbar
  (setq inhibit-startup-screen t) ; Disable splash screen
  (setq tab-width 2) ; Tab = 2 spaces
  (setq indent-tabs-mode nil) ; No tab indentation
; }}}
