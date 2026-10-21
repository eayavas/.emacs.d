(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(require 'use-package)
(setq use-package-always-ensure t)

(electric-pair-mode 1)
(setq electric-pair-open-newline-between-pairs t)

(set-face-attribute 'default nil
                    :font "SF Mono"
                    :height 120)


(use-package doric-themes
  :ensure t
  :demand t
) 

;; Custom themes folder
(add-to-list 'custom-theme-load-path "~/.emacs.d/themes/")

;; Sync theme with macOS system appearance
(add-hook 'ns-system-appearance-change-functions
          (lambda (appearance)
            (mapc #'disable-theme custom-enabled-themes)
            (pcase appearance
              ('light (load-theme 'minimal-light t))
              ('dark  (load-theme 'doric-obsidian t)))))

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
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   '("06fb105dd2579d705c27265d300a8dddab5e8d16562788c0b0a5c629af969079"
     "d6d4e0512dcaae663f7bd304557d6bc8b78c576be5af9c0b62b8447fb79b5fde"
     "a88cbf5f51d1021c5cb82a89136f5c65e60b117fc7893e4087a55a1617675210"
     "5f843ef0d18f55ef9b1e72ac9aaa59efdd698ee31781a86f7a054047a036bd08"
     "d3ebccab28ecb41dfb9a97cdb90212b301f7568dc89407cd508fca2ac3d29de9"
     "b243ec44629b75034c83be3fa411662f89582223012e8f4110a82dc40bf8561a"
     "d6d569756b04beb0fc7c9ca83d18f61f18875849f4b9a9d34fca0b69056dc4de"
     default))
 '(package-selected-packages '(auto-dark doric-themes evil-collection tidal)))

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

(add-hook 'emacs-startup-hook
          (lambda ()
            (message "Emacs started in %s seconds." (emacs-init-time))))

(defun eay/live-coding-setup ()
  (interactive)
  (require 'tidal)
  (require 'sclang)

  (let ((tidal-file "~/LiveCoding/tidal_cycles")
        (sc-file "~/LiveCoding/supercollider"))

    (with-current-buffer (find-file-noselect sc-file)
      (sclang-mode)
      (unless (sclang-get-process)
        (save-window-excursion (sclang-start))))

    (with-current-buffer (find-file-noselect tidal-file)
      (tidal-mode)
      (unless (get-buffer "*tidal*")
        (save-window-excursion (tidal-start-haskell))))

    (find-file tidal-file)
    (delete-other-windows)))

(defun eay/live-coding-setup-with-panes ()
  (interactive)
  (require 'tidal)
  (require 'sclang)
  (delete-other-windows)
  
  (let ((tidal-file "~/LiveCoding/tidal_cycles")
        (sc-file "~/LiveCoding/supercollider"))
        
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
