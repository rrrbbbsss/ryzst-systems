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
(setq select-enable-clipboard t
      select-enable-primary t)

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
(setq native-comp-async-report-warnings-errors nil)
(setq default-input-method "TeX")

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
  (load-theme 'doom-tomorrow-night t)
  :config
  (custom-set-faces
   `(helm-buffer-saved-out
     ((t (:foreground ,(doom-color 'red)))))
   `(helm-ff-file-extension
     ((t (:foreground ,(doom-color 'magenta)))))
   `(helm-header-line-left-margin
     ((t (:background ,(doom-color 'yellow)))))
   `(helm-ff-invalid-symlink
     ((t (:background ,(doom-color 'red)))))
   `(helm-ff-suid
     ((t (:background ,(doom-color 'red)))))
   `(helm-ff-pipe
     ((t (:foreground ,(doom-color 'yellow)))))
   `(helm-delete-async-message
     ((t (:foreground ,(doom-color 'yellow)))))
   `(helm-ff-denied
     ((t (:foreground ,(doom-color 'red)))))
   `(helm-ff-dotted-symlink-directory
     ((t (:foreground ,(doom-color 'orange) :background ,(doom-color 'base4)))))
   `(helm-ff-socket
     ((t (:foreground ,(doom-color 'dark-cyan)))))
   `(mode-line-inactive
     ((t (:background ,(doom-color 'modeline-bg) :foreground ,(doom-color 'grey)))))
   `(window-divider
     ((t (:foreground ,(doom-color 'modeline-bg)))))
   `(org-block-begin-line
     ((t (:background "black"))))
   `(org-block-end-line
     ((t (:background "black"))))))

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
  (setq vterm-timer-delay nil)
  :config
  (evil-set-initial-state 'vterm-mode 'emacs)
  (add-to-list 'beacon-dont-blink-major-modes 'vterm-mode)
  (evil-define-key 'emacs 'vterm-mode-map (kbd "C-z")
    '(lambda ()
       (interactive)
       (progn
	 (vterm-send-escape)
	 (evil-motion-state))))
  (evil-define-key 'motion 'vterm-mode-map (kbd "<escape>")
    '(lambda ()
       (interactive)
       (progn (evil-emacs-state)
	      (vterm--self-insert))))
  (evil-define-key 'motion 'vterm-mode-map (kbd "i")
    '(lambda ()
       (interactive)
       (progn (evil-emacs-state)
	      (vterm--self-insert))))
  (evil-define-key 'motion 'vterm-mode-map (kbd "p")
    '(lambda ()
       (interactive)
       (progn (evil-emacs-state)
	      (vterm-send-string (concat "ddi" (current-kill 0))))))
  :bind
  ("s-C-M-T" . vterm-other-window)
  (:map vterm-mode-map
	("<f2>" . nil)
	("C-q" . vterm-send-next-key)))

(use-package form-feed
  :ensure t
  :config
  (global-form-feed-mode))

(use-package magit
  :ensure t
  :init
  (setq transient-display-buffer-action '(display-buffer-below-selected))
  :bind
  ("s-C-M-G" . magit-status)
  ("s-C-M-H" . magit-log-buffer-file))

(use-package magit-todos
  :ensure t
  :after magit
  :config
  (magit-todos-mode 1))

(use-package hl-todo
  :ensure t
  :config
  (global-hl-todo-mode 1))

(use-package git-gutter
  :ensure t
  :init
  (setq-default left-margin-width 1)
  (setq git-gutter:update-interval 2)
  (setq git-gutter:disabled-modes '(image-mode))
  :config
  (add-to-list 'git-gutter:update-hooks 'focus-in-hook)
  (add-to-list 'git-gutter:update-commands 'other-window)
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
  :init
  (setq ispell-alternate-dictionary
	(expand-file-name "~/.local/share/emacs/wordlist.txt")
	ispell-grep-command "rg")
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
  ("C-h a" . helm-apropos)
  (:map helm-map
	("C-z" . helm-select-action)
	("<tab>" . helm-execute-persistent-action))
  (:map evil-normal-state-map
	("/" . helm-occur))
  (:map evil-motion-state-map
	("/" . helm-occur)))

(use-package helm-projectile
  :ensure t
  :config
  (helm-projectile-on)
  :bind
  ("s-C-M-R" . helm-projectile-grep)
  ("s-C-M-P" . helm-projectile-find-file))

(use-package helm-descbinds
  :ensure t
  :init
  (setq helm-descbinds-disable-which-key nil)
  (setq helm-descbinds-window-style 'split-window)
  :config
  (helm-descbinds-mode 1))

(use-package helm-flyspell
  :ensure t
  :after flyspell
  :bind
  (:map flyspell-mode-map
	("C-M-i" . helm-flyspell-correct)))

(use-package helm-pass
  :ensure t
  :config
  (advice-add
   'password-store-clear :after
   (lambda (x)
     (call-process "wl-copy" nil nil nil "--clear")
     (call-process "wl-copy" nil nil nil "--clear" "--primary"))))

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
  (setq treemacs-width 30
	treemacs-read-string-input 'from-minibuffer)
  :bind
  ("<f2>" . treemacs))

(use-package treemacs-evil
  :ensure t
  :config
  (setq evil-treemacs-state-cursor evil-normal-state-cursor)
  :hook
  (treemacs-mode . evil-treemacs-state))

(use-package doom-modeline
  :ensure t
  :init
  :config
  (column-number-mode 1)
  (doom-modeline-mode 1)
  (doom-modeline-def-modeline 'main
    '(eldoc bar workspace-name window-number modals matches follow buffer-info
	    remote-host buffer-position word-count parrot selection-info)
    '(compilation objed-state misc-info persp-name battery grip irc mu4e gnus
		  github debug repl lsp minor-modes input-method indent-info
		  buffer-encoding major-mode process vcs check time " "))
  (doom-modeline-def-modeline 'minimal
    '(bar window-number modals matches buffer-info-simple)
    '(media-info major-mode time " "))
  (doom-modeline-def-modeline 'vcs
    '(bar window-number modals matches buffer-info remote-host buffer-position
	  parrot selection-info)
    '(compilation misc-info battery irc mu4e gnus github debug minor-modes
		  buffer-encoding major-mode process time " "))
  (doom-modeline-def-modeline 'info
    '(bar window-number modals buffer-info info-nodes buffer-position parrot selection-info)
    '(compilation misc-info buffer-encoding major-mode time " ")))

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
  (setq lsp-use-plists t)
  (setq gc-cons-threshold 100000000
	read-process-output-max (* 1024 1024)
	max-lisp-eval-depth 5000)
  (setq lsp-keymap-prefix "s-C-M-L"
	lsp-headerline-breadcrumb-enable nil
	lsp-signature-auto-activate nil
	lsp-signature-render-documentation nil)
  (setq lsp-copilot-enabled nil
	lsp-copilot-applicable-fn (-const nil))
  :config
  ;; https://github.com/blahgeek/emacs-lsp-booster?tab=readme-ov-file#configure-lsp-mode
  (defun lsp-booster--advice-json-parse (old-fn &rest args)
    "Try to parse bytecode instead of json."
    (or
     (when (equal (following-char) ?#)
       (let ((bytecode (read (current-buffer))))
	 (when (byte-code-function-p bytecode)
           (funcall bytecode))))
     (apply old-fn args)))
  (advice-add (if (progn (require 'json)
			 (fboundp 'json-parse-buffer))
                  'json-parse-buffer
		'json-read)
              :around
              #'lsp-booster--advice-json-parse)
  (defun lsp-booster--advice-final-command (old-fn cmd &optional test?)
    "Prepend emacs-lsp-booster command to lsp CMD."
    (let ((orig-result (funcall old-fn cmd test?)))
      (if (and (not test?)                             ;; for check lsp-server-present?
               (not (file-remote-p default-directory)) ;; see lsp-resolve-final-command, it would add extra shell wrapper
               lsp-use-plists
               (not (functionp 'json-rpc-connection))  ;; native json-rpc
               (executable-find "emacs-lsp-booster"))
          (progn
            (message "Using emacs-lsp-booster for %s!" orig-result)
            (cons "emacs-lsp-booster" orig-result))
	orig-result)))
  (advice-add 'lsp-resolve-final-command :around #'lsp-booster--advice-final-command)
  :hook ((lsp-mode . lsp-enable-which-key-integration)))

(use-package lsp-ui
  :ensure t
  :init
  (setq lsp-ui-doc-delay 0.5
	lsp-ui-doc-position 'top
	lsp-ui-sideline-enable nil)
  :after
  (lsp-mode)
  :hook
  (lsp-mode . lsp-ui-mode))

(use-package helm-lsp
  :ensure t)

(use-package helm-xref
  :ensure t)

(use-package dap-mode
  :ensure t)

(use-package treesit-auto
  :ensure t
  :init
  (setq treesit-auto-install nil)
  :config
  (global-treesit-auto-mode))

(use-package format-all
  :ensure t
  :config
  (setf (alist-get "TOML" format-all-default-formatters nil nil #'equal)
	'(taplo-fmt))
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

(use-package conf-mode
  :requires lsp-mode
  :hook (conf-toml-mode . lsp))

(use-package js-json-mode
  :requires lsp-mode
  :hook (js-json-mode . lsp))

;; nix
(use-package nix-mode
  :ensure t
  :requires lsp-mode
  :init
  (setq lsp-nix-nil-auto-eval-inputs nil)
  :config
  (advice-add
   'nix-repl :around
   (lambda (original)
     (when-let ((root (vc-root-dir)))
       (cd root))
     (funcall original)))
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
  (setopt prolog-program-name '(((getenv "EPROLOG") (eval (getenv "EPROLOG")))
				(eclipse "eclipse")
				(mercury nil)
				(sicstus "sicstus")
				(swi "swipl")
				(gnu "gprolog")
				(yap "yap")
				(xsb "xsb")
				(t "swipl")))
  (setq prolog-system 'swi)
  :mode "\\.pl\\'")

;; scheme
(use-package geiser-chez
  :ensure t
  :after format-all
  :init
  (define-format-all-formatter scheme-fmt
    (:executable)
    (:install)
    (:languages "Scheme")
    (:features region)
    (:format
     (format-all--buffer-native
      'scheme-mode
      (if region
          (lambda () (indent-region (car region) (cdr region)))
	(lambda () (indent-region (point-min) (point-max)))))))
  (add-to-list 'format-all-default-formatters '("Scheme" scheme-fmt)))

;; yuck
(use-package yuck-mode
  :ensure t)

;; souffle
(use-package souffle-ts-mode
  :ensure t
  :after format-all lsp-mode
  :mode "\\.dl\\'"
  :init
  ;; formatting
  (define-format-all-formatter souffle-fmt
    (:executable)
    (:install)
    (:languages "Soufflé")
    (:features region)
    (:format
     (format-all--buffer-native
      'souffle-ts-mode
      (if region
          (lambda () (indent-region (car region) (cdr region)))
	(lambda () (indent-region (point-min) (point-max)))))))
  (add-to-list 'format-all-default-formatters '("Soufflé" souffle-fmt))
  (add-to-list 'language-id--definitions '("Soufflé" souffle-ts-mode))
  ;; lsp
  (add-to-list 'lsp-language-id-configuration '(souffle-ts-mode . "Soufflé"))
  (lsp-register-client
   (make-lsp-client
    :new-connection (lsp-stdio-connection "souffle-lsp-plugin")
    :activation-fn (lsp-activate-on "Soufflé" )
    :priority -1
    :server-id 'souffle-lsp-plugin))
  :hook
  (souffle-ts-mode . lsp))

;; go
(use-package go-ts-mode
  :init
  (setq go-ts-mode-indent-offset 4)
  :mode "\\.go\\'"
  :hook
  (go-ts-mode . lsp)
  (go-ts-mode . (lambda () (setq tab-width 4))))

;; python
(use-package lsp-pyright
  :ensure t
  :hook
  (python-ts-mode . lsp))

;; yaml
(use-package yaml-ts-mode
  :mode "\\.yml\\'"
  :hook
  (yaml-ts-mode . format-all-mode)
  (yaml-ts-mode . lsp))

;; erlang
(use-package erlang
  :ensure t
  :hook
  (erlang-mode . lsp))


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
