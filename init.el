(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(require 'use-package)
(setq use-package-always-ensure t)

;; Sync theme with macOS system appearance
(add-hook 'ns-system-appearance-change-functions
          (lambda (appearance)
            (mapc #'disable-theme custom-enabled-themes)
            (pcase appearance
              ('light (load-theme 'modus-operandi t))
              ('dark  (load-theme 'modus-vivendi t)))))

(set-face-attribute 'default nil
                    :font "SF Mono"
                    :height 120)

(setq mac-option-modifier 'none)
(setq mac-command-modifier 'meta)

(use-package evil
  :init
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)
  :config
  (evil-mode 1))

(use-package evil-collection
  :after evil
  :config
  (evil-collection-init))

(use-package org
  :defer t
  :config
  (setq org-hide-emphasis-markers t))

(add-hook 'org-mode-hook 'visual-line-mode)

(add-to-list 'exec-path (expand-file-name "~/.ghcup/bin"))
(setenv "PATH" (concat (expand-file-name "~/.ghcup/bin") ":" (getenv "PATH")))

(use-package haskell-mode)

(defvar eay/tidal-is-hushed t)

(defun eay/tidal-hush ()
  (interactive)
  (tidal-send-string "hush")
  (setq eay/tidal-is-hushed t)
  (message "Hushed. Next eval will resetCycles."))

(defun eay/tidal-maybe-reset-cycles (&rest _)
  (when eay/tidal-is-hushed
    (tidal-send-string "resetCycles")
    (setq eay/tidal-is-hushed nil)))

(advice-add 'tidal-run-multiple-lines :before #'eay/tidal-maybe-reset-cycles)
(advice-add 'tidal-run-line :before #'eay/tidal-maybe-reset-cycles)

(use-package tidal
  :after evil
  :config
  (setq tidal-interpreter "ghci")
  (evil-define-key 'normal tidal-mode-map (kbd "RET") 'tidal-run-multiple-lines)
  (evil-define-key 'normal tidal-mode-map (kbd "S-RET") 'tidal-run-line)
  (evil-define-key '(normal insert visual) tidal-mode-map (kbd "C-.") 'eay/tidal-hush))

(use-package sclang
  :ensure nil
  :load-path "~/Library/Application Support/SuperCollider/downloaded-quarks/scel/el"
  :mode ("\\.scd\\'" . sclang-mode)
  :init
  (add-to-list 'exec-path "/Applications/SuperCollider.app/Contents/MacOS")
  (setenv "PATH" (concat "/Applications/SuperCollider.app/Contents/MacOS:" (getenv "PATH")))
  :config
  (setq sclang-executable "/Applications/SuperCollider.app/Contents/MacOS/sclang")
  (setq sclang-auto-scroll-post-buffer t))

(custom-set-variables
 '(package-selected-packages nil))

(custom-set-faces)

(add-hook 'emacs-startup-hook
          (lambda ()
            (message "Emacs started in %s seconds." (emacs-init-time))))

(defun eay/live-coding-setup ()
  (interactive)
  (delete-other-windows)
  
  (let ((tidal-file "~/Documents/TidalCycles")
        (sc-file "~/Documents/supercollider"))
        
    (find-file tidal-file)
    (split-window-right)
    
    (other-window 1)
    (find-file sc-file)
    
    (unless (get-buffer "*tidal*")
      (save-window-excursion (tidal-start-haskell))
      (save-window-excursion (tidal-mode))
      )
    (unless (sclang-get-process)
      (save-window-excursion (sclang-start))
      (save-window-excursion (sclang-mode))
      )
    
      
    (other-window -1)
    (split-window-below)
    (other-window 1)
    (switch-to-buffer "*tidal*")
    
    (other-window 1)
    (split-window-below)
    (other-window 1)
    (if (fboundp 'sclang-get-post-buffer)
        (switch-to-buffer (sclang-get-post-buffer))
      (switch-to-buffer "*SCLang:Workspace*"))
      
    (balance-windows)
    (other-window -3)))
