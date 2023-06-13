(require 'use-package)

;; gui settings
(set-frame-font "DejaVu Sans Mono-12" nil t)
(load-theme 'wombat)
(menu-bar-mode -1)
(scroll-bar-mode -1)
(tool-bar-mode -1)
(setq window-divider-default-bottom-width 2
      window-divider-default-right-width 2)
(window-divider-mode)
(set-face-attribute 'window-divider nil :foreground "#212526" )
(fringe-mode '(8 . 8))

;; auto-save & backup directories
(defconst backup-dir (expand-file-name "~/.local/share/emacs/backup/"))
(defconst autosave-dir (expand-file-name "~/.local/share/emacs/autosave/"))
(setq backup-directory-alist `((".*" . ,backup-dir)))
(setq auto-save-list-file-prefix autosave-dir)
(setq auto-save-file-name-transforms `((".*" ,autosave-dir t)))
(setq delete-old-versions t)

;; custom functions
(defun backward-kill-line (arg)
  "Kill ARG lines backward."
  (interactive "p")
  (kill-line (- 1 arg)))

;; packages
(use-package evil
  :ensure t
  :demand t
  :init
  (setq evil-insert-state-message nil
        evil-visual-state-message nil)
  (setq evil-insert-state-map (make-sparse-keymap))
  :config
  (evil-mode 1)
  :bind
  (:map evil-normal-state-map
        (":" . eval-expression)
        ("j" . evil-next-visual-line)
        ("k" . evil-previous-visual-line)
        ("M-." . nil)
        ("M-," . nil)
        ("C-n" . nil) 
        ("C-p" . nil)
        ("C-f" . nil)
        ("C-b" . nil))
  (:map evil-insert-state-map
        ("<escape>" . evil-normal-state)
        ("C-k" . backward-kill-line)
        ("C-S-k" . kill-visual-line))

  (:map evil-motion-state-map
        ("SPC" . nil)
        ("TAB" . nil)
        ("RET" . nil)
        ("C-f" . nil)
        ("C-b" . nil)))

(use-package avy
  :ensure t
  :requires evil
  :bind
  (:map evil-visual-state-map
        ("SPC" . avy-goto-char))
  (:map evil-normal-state-map
        ("SPC" . avy-goto-char)))

(use-package vterm
  :ensure t
  :requires evil
  :init
  (setq vterm-min-window-width 80)
  :config
  (evil-set-initial-state 'vterm-mode 'emacs))

(use-package form-feed
  :ensure t
  :config
  (set-face-attribute 'form-feed-line nil
                      :stipple (list 1 1 (string 1))
                      :foreground "#212526")
  (global-form-feed-mode)
  :custom-face
  (form-feed-line
   ((t :foreground "#ffffff"))))

(use-package magit
  :ensure t
  :init
  (setq transient-display-buffer-action '(display-buffer-below-selected))
  :bind
  ("s-C-M-G" . magit-status)
  ("s-C-M-L" . magit-log-buffer-file))
