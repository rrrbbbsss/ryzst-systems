(require 'use-package)

;; gui settings
(setq rrrbbbsss/font "DejaVu Sans M Nerd Font")
(set-frame-font (concat rrrbbbsss/font "-12") nil t)
(menu-bar-mode -1)
(scroll-bar-mode -1)
(tool-bar-mode -1)
(setq window-divider-default-bottom-width 4
      window-divider-default-right-width 4)
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

;; misc
(defalias 'yes-or-no-p 'y-or-n-p)
(global-auto-revert-mode t)

;; sticky buffers
(customize-set-variable
 'display-buffer-alist
 '(("\\*Help\\*" display-buffer-same-window)))

;; misc functions
(defun backward-kill-line (arg)
  "Kill ARG lines backward."
  (interactive "p")
  (kill-line (- 1 arg)))

;; theme
(use-package doom-themes
  :ensure t
  :init
  (setq doom-themes-enable-bold t
        doom-themes-enable-italic t)
  :config
  (load-theme 'doom-tomorrow-night)
  (set-face-attribute
   'mode-line-inactive t
   :background "#0f1011" :foreground "#5a5b5a" :box nil))

;; Core packages
(use-package evil
  :ensure t
  :demand t
  :init
  (setq evil-insert-state-message nil
        evil-visual-state-message nil)
  (setq evil-insert-state-map (make-sparse-keymap))
  (setq evil-undo-system 'undo-redo)
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
	("C-w" . evil-window-map)
        ("C-k" . backward-kill-line)
        ("C-S-k" . kill-visual-line))
  (:map evil-emacs-state-map
	("C-w" . evil-window-map))
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

(use-package pinentry
  :ensure t
  :init
  (setq epg-pinentry-mode 'loopback)
  :config
  (pinentry-start))

(use-package flycheck
  :ensure t
  :config)

(use-package company
  :ensure t
  :config
  (global-company-mode 1))

(use-package elec-pair
  :config
  (electric-pair-mode 1))

(use-package helm
  :ensure t
  :init
  (setq helm-split-window-inside-p t
	helm-echo-input-in-header-line t
	helm-mode-fuzzy-match t
	helm-completion-style 'helm-fuzzy)
  :config
  (helm-mode 1)
  :bind
  ("s-C-M-F" . helm-find-files)
  ("s-C-M-B" . helm-buffers-list)
  ("M-y" . helm-show-kill-ring)
  ("M-x" . helm-M-x)
  (:map helm-map
	("<tab>" . 'helm-execute-persistent-action)))

(use-package helm-projectile
  :ensure t
  :config
  (helm-projectile-on)
  :bind
  ("s-C-M-R" . helm-projectile-rg))

(use-package helm-rg
  :ensure t)

(use-package helm-descbinds
  :ensure t
  :config
  (helm-descbinds-mode 1))

(use-package helm-flyspell
  :ensure t
  :after flyspell
  :bind
  (:map flyspell-mode-map
	("C-M-i" . helm-flyspell-correct)))

(use-package projectile
  :ensure t
  :config)

(use-package direnv
  :ensure t)

(use-package treemacs
  :ensure t
  :init
  (setq treemacs-width 30)
  :bind
  ("<f2>" . treemacs))

(use-package treemacs-evil
  :ensure t)

(use-package doom-modeline
  :ensure t
  :init
  :config
  (column-number-mode 1)
  (doom-modeline-mode 1))

(use-package nerd-icons
  :ensure t
  :init
  (setq nerd-icons-font-family rrrbbbsss/font))

;; org mode
(use-package org
  :init
  (setq org-src-fontify-natively t
        org-catch-invisible-edits 'show-and-error
        org-footnote-auto-adjust t)
  :hook
  ((org-mode . turn-on-font-lock)
   (org-mode . org-indent-mode)
   (org-mode . flyspell-mode)))

(use-package org-bullets
  :ensure t
  :after org
  :hook (org-mode . org-bullets-mode))

;; languages: nix
(use-package nix-mode
  :ensure t
  :mode "\\.nix\\'")

;; misc packages
(use-package nov
  :ensure t
  :init
  (setq nov-text-width 120)
  :config
  (add-to-list 'auto-mode-alist '("\\.epub\\'" . nov-mode)))
