;; emacs kicker --- kick start emacs setup

;; common lisp goodies, loop
(require 'cl)

(add-to-list 'load-path "~/.emacs.d/el-get/el-get")

(unless (require 'el-get nil t)
  (with-current-buffer
      (url-retrieve-synchronously
       "https://github.com/dimitri/el-get/raw/master/el-get-install.el")
    (goto-char (point-max))
    (eval-print-last-sexp)))

;; now either el-get is `require'd already, or have been `load'ed by the
;; el-get installer.

;; now set our own packages
(setq
 my:el-get-packages
 '(el-get		    ; el-get is self-hosting
   buffer-move              ; throw buffers around
   smex                     ; better M-x
   goto-last-change         ; moves pointer to last change
   switch-window	    ; takes over C-x o
   auto-complete	    ; complete as you type with overlays
   key-chord                ; make simple keybinds with any button
   ace-jump-mode            ; jump around the buffer easily
   expand-region            ; expands selection to  quotes, stetements, blocks, ...
   python-mode              ; something to help editing python files a bit
   jedi                     ; jedi based autocompletion for python files
   web-mode                 ; handy for editing web page templates
   php-mode-improved        ; basic mode for PHP
   markdown-mode            ; markdown is a must these days
   clojure-mode             ; edit clojure files in emacs
   cider                    ; clojure IDE and REPL integration
   ))

;;
;; some recipes require extra tools to be installed
;;
;; Note: el-get-install requires git, so we know we have at least that.
;;
;; (when (ignore-errors (el-get-executable-find "cvs"))
;;   (add-to-list 'my:el-get-packages 'emacs-goodies-el)) ; the debian addons for emacs

(when (ignore-errors (el-get-executable-find "svn"))
  (loop for p in '(psvn    		; M-x svn-status
		   )
	do (add-to-list 'my:el-get-packages p)))

(setq my:el-get-packages
      (append
       my:el-get-packages
       (loop for src in el-get-sources collect (el-get-source-name src))))

;; install new packages and init already installed packages
(el-get 'sync my:el-get-packages)



;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; PACKAGE SETTINGS ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;

;; setting for emacs-jedi
(add-hook 'python-mode-hook 'jedi:setup)
(setq jedi:complete-on-dot t)

;; smex setup
(setq smex-save-file "~/.emacs.d/.smex-items")



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; EMACS BUILT-INS SETTINGS ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; on to the visual settings
(setq inhibit-splash-screen t)		; no splash screen, thanks
(line-number-mode 1)			; have line numbers and
(column-number-mode 1)			; column numbers in the mode line

(tool-bar-mode -1)			; no tool bar with icons
(scroll-bar-mode -1)			; no scroll bars
(unless (string-match "apple-darwin" system-configuration)
  ;; on mac, there's always a menu bar drown, don't have it empty
  (menu-bar-mode -1))

;; show directory name when using same filenames for different files
(require 'uniquify)
(setq uniquify-buffer-name-style 'forward)

;; choose your own fonts, in a system dependant way
(if (string-match "apple-darwin" system-configuration)
    (set-face-font 'default "Monaco-13")
  (set-face-font 'default "Liberation Mono-13"))

;; theme to use
(load-theme 'adwaita)

;; add line numbers on the left
(global-linum-mode 1)

;; avoid compiz manager rendering bugs
(add-to-list 'default-frame-alist '(alpha . 100))

;; use the clipboard, pretty please, so that copy/paste "works"
(setq x-select-enable-clipboard t)

;; navigate windows with M-<arrows>
(windmove-default-keybindings 'meta)
(setq windmove-wrap-around t)

;; save the place where pointer was when killing a buffer
;; and return when opening the same file
(require 'saveplace)
(setq-default save-place t)

;; winner-mode provides C-<left> to get back to previous window layout
(winner-mode 1)

;; whenever an external process changes a file underneath emacs, and there
;; was no unsaved changes in the corresponding buffer, just revert its
;; content to reflect what's on-disk.
(global-auto-revert-mode 1)

;; M-x shell is a nice shell interface to use, let's make it colorful.  If
;; you need a terminal emulator rather than just a shell, consider M-x term
;; instead.
;; (autoload 'ansi-color-for-comint-mode-on "ansi-color" nil t)
;; (add-hook 'shell-mode-hook 'ansi-color-for-comint-mode-on)

;; if you do use M-x term, you will notice there's line mode that acts like
;; emacs buffers, and there's the default char mode that will send your
;; input char-by-char, so that curses application see each of your key
;; strokes.
;;
;; The default way to toggle between them is C-c C-j and C-c C-k, let's
;; better use just one key to do the same.
(require 'term)
(define-key term-raw-map  (kbd "C-'") 'term-line-mode)
(define-key term-mode-map (kbd "C-'") 'term-char-mode)

;; have C-y act as usual in term-mode, to avoid C-' C-y C-'
;; well the real default would be C-c C-j C-y C-c C-k.
(define-key term-raw-map  (kbd "C-y") 'term-paste)

;; use ido for minibuffer completion
(require 'ido)
(ido-mode t)
(setq ido-save-directory-list-file "~/.emacs.d/.ido.last")
(setq ido-enable-flex-matching t)
(setq ido-use-filename-at-point 'guess)
(setq ido-show-dot-for-dired t)
(setq ido-default-buffer-method 'selected-window)

;; default key to switch buffer is C-x b, but that's not easy enough
;;
;; when you do that, to kill emacs either close its frame from the window
;; manager or do M-x kill-emacs.  Don't need a nice shortcut for a once a
;; week (or day) action.
(global-set-key (kbd "C-x C-b") 'ido-switch-buffer)
(global-set-key (kbd "C-x C-c") 'ido-switch-buffer)
(global-set-key (kbd "C-x b") 'ibuffer)

;; have vertical ido completion lists
(setq ido-decorations
      '("\n-> " "" "\n   " "\n   ..." "[" "]"
	" [No match]" " [Matched]" " [Not readable]" " [Too big]" " [Confirm]"))

;; C-x C-j opens dired with the cursor right on the file you're editing
(require 'dired-x)

;; full screen
(defun fullscreen ()
  (interactive)
  (set-frame-parameter nil 'fullscreen
		       (if (frame-parameter nil 'fullscreen) nil 'fullboth)))
(global-set-key [f11] 'fullscreen)

;; use y and n to answer prompts
(fset 'yes-or-no-p 'y-or-n-p)

;; show battery status (Laptop only)
(display-battery-mode 1)

;; remove scratch buffer message
(setq initial-scratch-message "")

;; set scroll step to one line
(setq scroll-step 1)

;; disable sound warnings, only flash screen on error
(setq visible-bell t)

;; set the default width and height of the frame
(add-to-list 'default-frame-alist '(width . 85))
(add-to-list 'default-frame-alist '(height . 25))

;; disable blinking cursor
(blink-cursor-mode -1)

;; linum mode number format
(setq linum-format "%4d ")

;; force Emacs to use UTF-8
(prefer-coding-system 'utf-8)
(set-default-coding-systems 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)

;; default tab size
(setq tab-width 4)

;; C-n past end of file adds new lines
(setq next-line-add-newlines 1)

;; kill whole line(remove the new line too)
(setq kill-whole-line t)

;; delete the selected text by typing something else
(delete-selection-mode 1)

;; add parents, brackets ... in pairs
(electric-pair-mode 1)

;; show matching parens
(show-paren-mode 1)

;; delete the white space before saving the file
(add-hook 'before-save-hook 'delete-trailing-whitespace)

;; disable creating of backup files
(setq make-backup-files nil)

;; disable creation of auto-save files
(setq auto-save-default nil)

;; disable file locks
(setq create-lockfiles nil)



;;;;;;;;;;;;;;;;;;
;;;; KEYBINDS ;;;;
;;;;;;;;;;;;;;;;;;

;; comment and uncomment region
(global-set-key (kbd "C-x C-;") 'comment-or-uncomment-region)

;; kill region
(global-set-key (kbd "C-x C-k") 'kill-region)

;; change the  window size verticaly
(global-set-key (kbd "<f9>") 'shrink-window)
(global-set-key (kbd "S-<f9>") 'enlarge-window)

;; shrink the window size horizontaly
(global-set-key (kbd "<f10>") 'shrink-window-horizontally)
(global-set-key (kbd "S-<f10>") 'enlarge-window-horizontally)

;; expand region
(global-set-key (kbd "C-x e") 'er/expand-region)

;; use switch window instead classic C-x o
(global-set-key (kbd "C-x o") 'switch-window)

;; center the cursor on the middle of the screen
(global-set-key (kbd "M-c") 'recenter)

;; buffer move keybinds
(global-set-key (kbd "<M-up>")     'buf-move-up)
(global-set-key (kbd "<M-down>")   'buf-move-down)
(global-set-key (kbd "<M-left>")   'buf-move-left)
(global-set-key (kbd "<M-right>")  'buf-move-right)

;; smex
(global-set-key (kbd "M-x") 'smex)
(global-set-key (kbd "M-X") 'smex-major-mode-commands)

;; goto-last-change
(global-set-key (kbd "C-c l") 'goto-last-change)

;; hippie expand instead of abbrev
(global-set-key (kbd "M-/") 'hippie-expand)


;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; KEY-CHORD BINDS ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;

;; we need to enable key-chord mode first
(key-chord-mode 1)

;; ace jump mode keybinds
(key-chord-define-global "qj" 'ace-jump-mode)
(key-chord-define-global "ql" 'ace-jump-line-mode)
(key-chord-define-global "qc" 'ace-jump-char-mode)



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; VARS ADDED BY CONFIG UTILITY ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(python-shell-interpreter "python3"))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
