(require 'use-package)

;; gui settings
(setq rrrbbbsss/font "DejaVu Sans M Nerd Font")
(setq default-frame-alist `((font . ,(concat rrrbbbsss/font "-12"))))
(menu-bar-mode -1)
(scroll-bar-mode -1)
(tool-bar-mode -1)
(setq window-divider-default-bottom-width 4
      window-divider-default-right-width 4)
(window-divider-mode)
(fringe-mode '(12 . 12))
(add-hook 'prog-mode-hook
	  (lambda () (setq indicate-empty-lines t)))

;; auto-save & backup directories
(defconst backup-dir (expand-file-name "~/.local/state/emacs/backup/"))
(defconst autosave-dir (expand-file-name "~/.local/state/emacs/autosave/"))
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
  :custom-face
  (mode-line-inactive ((t (:background "#0f1011" :foreground "#5a5b5a"))))
  (window-divider ((t (:background "black"))))
  :config
  (load-theme 'doom-tomorrow-night t))

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
  (evil-set-initial-state 'vterm-mode 'emacs)
  :bind
  ("s-C-M-T" . vterm-other-window)
  (:map vterm-mode-map
	("<f2>" . nil)
	("C-q" . vterm-send-next-key)))

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
  ("s-C-M-H" . magit-log-buffer-file))

(use-package git-gutter
  :ensure t
  :config
  (global-git-gutter-mode 1))

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
  :demand t
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
  ("C-s" . helm-occur)
  (:map helm-map
	("<tab>" . helm-execute-persistent-action))
  (:map evil-normal-state-map
	("/" . helm-occur)))

(use-package helm-projectile
  :ensure t
  :config
  (helm-projectile-on)
  :bind
  ("s-C-M-R" . helm-projectile-rg)
  ("s-C-M-P" . helm-projectile-find-file))

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
  :ensure t
  :init
  (setq direnv-always-show-summary nil)
  :config
  (add-to-list 'direnv-non-file-modes 'vterm-mode)
  (direnv-mode 1)
  :hook
  (prog-mode . direnv-update-environment))

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

(use-package which-key
  :ensure t
  :init
  (setq which-key-idle-delay 2.0)
  :config
  (which-key-mode 1))

(use-package lsp-mode
  :ensure t
  :init
  ;; https://emacs-lsp.github.io/lsp-mode/page/performance/
  (setq gc-cons-threshold 100000000)
  (setq read-process-output-max (* 1024 1024))
  (setq max-lisp-eval-depth 5000)
  (setq lsp-keymap-prefix "s-C-M-L")
  :hook ((lsp-mode . lsp-enable-which-key-integration)))

(use-package helm-lsp
  :ensure t)

(use-package helm-xref
  :ensure t)

(use-package dap-mode
  :ensure t)

(use-package format-all
  :ensure t
  :hook
  ((prog-mode . format-all-mode)
   (format-all-mode . format-all-ensure-formatter)))

(use-package editorconfig
  :ensure t
  :config
  (editorconfig-mode 1))

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

;; nix
(use-package nix-mode
  :ensure t
  :requires lsp-mode
  :mode "\\.nix\\'"
  :hook ((nix-mode . lsp)))

;; rust
(use-package rustic
  :ensure t
  :init
  (setq rustic-lsp-server 'rust-analyzer
	lsp-inlay-hint-enable t)
  :hook ((rustic-mode . lsp)))

;; prolog
(use-package prolog-mode
  :ensure t
  :init
  (setq prolog-system 'swi)
  :mode "\\.pl\\'")

;; misc packages
(use-package nov
  :ensure t
  :init
  (setq nov-text-width 120)
  :config
  (add-to-list 'auto-mode-alist '("\\.epub\\'" . nov-mode)))

(use-package beacon
  :ensure t
  :init
  (setq beacon-size 20)
  (setq beacon-color "#81a2be")
  :config
  (beacon-mode 1))
