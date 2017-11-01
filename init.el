;;; This file bootstraps the configuration, which is divided into
;;; a number of other files.

(let ((minver "23.3"))
  (when (version<= emacs-version minver)
    (error "Your Emacs is too old -- this config requires v%s or higher" minver)))
(when (version<= emacs-version "24")
  (message "Your Emacs is old, and some functionality in this config will be disabled. Please upgrade if possible."))

(add-to-list 'load-path (expand-file-name "lisp" user-emacs-directory))
(require 'init-benchmarking) ;; Measure startup time

(defconst *spell-check-support-enabled* nil) ;; Enable with t if you prefer
(defconst *is-a-mac* (eq system-type 'darwin))

;;----------------------------------------------------------------------------
;; Temporarily reduce garbage collection during startup
;;----------------------------------------------------------------------------
(defconst sanityinc/initial-gc-cons-threshold gc-cons-threshold
  "Initial value of `gc-cons-threshold' at start-up time.")
(setq gc-cons-threshold (* 128 1024 1024))
(add-hook 'after-init-hook
          (lambda () (setq gc-cons-threshold sanityinc/initial-gc-cons-threshold)))

;;----------------------------------------------------------------------------
;; Bootstrap config
;;----------------------------------------------------------------------------
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(require 'init-compat)
(require 'init-utils)
(require 'init-site-lisp) ;; Must come before elpa, as it may provide package.el
;; Calls (package-initialize)
(require 'init-elpa)      ;; Machinery for installing required packages
(require 'init-exec-path) ;; Set up $PATH

;;----------------------------------------------------------------------------
;; Allow users to provide an optional "init-preload-local.el"
;;----------------------------------------------------------------------------
(require 'init-preload-local nil t)

;;----------------------------------------------------------------------------
;; Load configs for specific features and modes
;;----------------------------------------------------------------------------

(require-package 'wgrep)
(require-package 'project-local-variables)
(require-package 'diminish)
(require-package 'scratch)
(require-package 'mwe-log-commands)

(require 'init-frame-hooks)
(require 'init-xterm)
(require 'init-themes)
(require 'init-osx-keys)
(require 'init-gui-frames)
(require 'init-dired)
(require 'init-isearch)
(require 'init-grep)
(require 'init-uniquify)
(require 'init-ibuffer)
(require 'init-flycheck)

(require 'init-recentf)
(require 'init-smex)
;; If you really prefer ido to ivy, change the comments below. I will
;; likely remove the ido config in due course, though.
;; (require 'init-ido)
(require 'init-ivy)
(require 'init-hippie-expand)
(require 'init-company)
(require 'init-windows)
(require 'init-sessions)
(require 'init-fonts)
(require 'init-mmm)

(require 'init-editing-utils)
(require 'init-whitespace)
(require 'init-fci)

(require 'init-vc)
(require 'init-darcs)
(require 'init-git)
(require 'init-github)

(require 'init-projectile)

(require 'init-compile)
(require 'init-crontab)
(require 'init-textile)
(require 'init-markdown)
(require 'init-csv)
(require 'init-erlang)
(require 'init-php)
(require 'init-org)
(require 'init-nxml)
(require 'init-html)
(require 'init-css)
(require 'init-haml)
(require 'init-python-mode)
(unless (version<= emacs-version "24.3")
  (require 'init-haskell))
(require 'init-elm)
(require 'init-ruby-mode)
(require 'init-rails)
(require 'init-sql)

(require 'init-paredit)
(require 'init-lisp)
(require 'init-slime)
(unless (version<= emacs-version "24.2")
  (require 'init-clojure)
  (require 'init-clojure-cider))
(require 'init-common-lisp)

(when *spell-check-support-enabled*
  (require 'init-spelling))

(require 'init-misc)

(require 'init-folding)
(require 'init-dash)
(require 'init-ledger)
;; Extra packages which don't require any configuration

(require-package 'gnuplot)
(require-package 'lua-mode)
(require-package 'htmlize)
(require-package 'dsvn)
(when *is-a-mac*
  (require-package 'osx-location))
(require-package 'regex-tool)

;;----------------------------------------------------------------------------
;; Allow access from emacsclient
;;----------------------------------------------------------------------------
(require 'server)
(unless (server-running-p)
  (server-start))


;;----------------------------------------------------------------------------
;; Variables configured via the interactive 'customize' interface
;;----------------------------------------------------------------------------
(when (file-exists-p custom-file)
  (load custom-file))


;;----------------------------------------------------------------------------
;; Allow users to provide an optional "init-local" containing personal settings
;;----------------------------------------------------------------------------
(require 'init-local nil t)


;;----------------------------------------------------------------------------
;; Locales (setting them earlier in this file doesn't work in X)
;;----------------------------------------------------------------------------
(require 'init-locales)


(provide 'init)

;; alen theme and other settings
(global-linum-mode t)
;;
;; #############clean lang geekskool##############
;;(add-to-list 'load-path "~/.emacs.d/clean-mode")
;;(load "clean-mode")
;;(add-to-list 'auto-mode-alist '("\\.cl\\'" . clean-mode))

(defun global-disable-mode (mode-fn)
  "Disable `MODE-FN' in ALL buffers."
  (interactive "a")
  (dolist (buffer (buffer-list))
    (with-current-buffer buffer
      (funcall mode-fn -1))))


;;; webmode configs

(require 'web-mode)
(add-to-list 'auto-mode-alist '("\\.html\\'" . web-mode))
(defun my-web-mode-hook ()
  "Hooks for web-mode."
  (setq web-mode-code-indent-offset 2)
  (setq web-mode-markup-indent-offset 2)
  (setq web-mode-css-indent-offset 2)
  )
(add-hook 'web-mode-hook 'my-web-mode-hook)

;; enable flycheck globally
(use-package flycheck
  :ensure t
  :init (global-flycheck-mode))

(custom-set-variables
 '(inhibit-startup-buffer-menu t)
 '(inhibit-startup-screen t)
 '(js-indent-level 2)
 '(js2-strict-missing-semi-warning nil)
 '(scroll-bar-mode nil)
 '(tool-bar-mode nil))

(require 'rjsx-mode)
(add-to-list 'auto-mode-alist '("\\.js\\'" . rjsx-mode))
(add-to-list 'auto-mode-alist '("\\.jsx\\'" . rjsx-mode))


(defun lunaryorn-use-js-executables-from-node-modules ()
  "Set executables of JS checkers from local node modules."
  (-when-let* ((file-name (buffer-file-name))
               (root (locate-dominating-file file-name "node_modules"))
               (module-directory (expand-file-name "node_modules" root)))
    (pcase-dolist (`(,checker . ,module) '((javascript-jshint . "jshint")
                                           (javascript-eslint . "eslint")
                                           (javascript-standard . "standard")
                                           (javascript-jscs   . "jscs")))
      (let ((package-directory (expand-file-name module module-directory))
            (executable-var (flycheck-checker-executable-variable checker)))
        (when (file-directory-p package-directory)
          (set (make-local-variable executable-var)
               (expand-file-name (concat "bin/" module ".js")
                                 package-directory)))))))
;; Local Variables:
;; coding: utf-8
;; no-byte-compile: t
;;; init.el ends here
