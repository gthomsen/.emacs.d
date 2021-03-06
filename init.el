;;;; PACKAGE REPOSITORIES ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(require 'package)

(setq package-archives '(
    ("gnu"          . "http://elpa.gnu.org/packages/")
    ;("marmalade"    . "http://marmalade-repo.org/packages/")
    ("melpa"        . "http://melpa.milkbox.net/packages/")))

(package-initialize)

;;;;; PACKAGES ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; TODO

(add-to-list 'load-path (concat user-emacs-directory "lib"))
(require 'livedown) ;; requires npm install -g livedown

;;;; DISPLAY ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Don't produce a bell sound on some event (like scroll-up at the top) but
;; do some visual gimmick instead.
(setq visible-bell t)

;; Display line numbers on the left of windows.
(global-linum-mode 1)

;; Display the column number in the mode line.
(setq column-number-mode t)

;; Make buffer names unique by including part of file path.
(require 'uniquify)
(setq uniquify-buffer-name-style 'post-forward)

;; Disable the menu bar, the toolbar (bar with big button), the startup screen
;; (buffer) and initial message in the scratch buffer.
(menu-bar-mode -1)
(tool-bar-mode -1)
(setq inhibit-startup-screen t)
(setq initial-scratch-message "")

;;;; BEHAVIOUR ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Disable version control support in emacs. Things now load much faster (esp.
;; on Windows).
(setq vc-handled-backends ())

(defadvice kill-new (before kill-push-clipboard activate)
  "Before putting new kill onto the kill-ring, add the clipboard/external
   selection to the kill ring."
  (let ((have-paste
         (and interprogram-paste-function
              ;; condition-case is necessary to prevent "empty or invalid
              ;; pasteboard type" messages from preventing us to use the
              ;; kill-ring before we copy some text from outside Emacs. (Note
              ;; the message will still display!)
              (condition-case nil
                  (funcall interprogram-paste-function)
                (quit nil)))))
    (when have-paste (push have-paste kill-ring))))

;; Automatically recompile .el files wich have already been compiled.
;; Does not do the initial compilation.
(defun auto-recompile-el-buffer ()
  (interactive)
  (when (and (eq major-mode 'emacs-lisp-mode)
             (file-exists-p (concat buffer-file-name "c")))
    (byte-compile-file buffer-file-name)))
(add-hook 'after-save-hook 'auto-recompile-el-buffer)

;; Ignore case in filename completion.
(setq read-file-name-completion-ignore-case t)

;; Don't ask confirmation to kill a buffer that has a process.
(setq kill-buffer-query-functions
  (delq 'process-kill-buffer-query-function kill-buffer-query-functions))

(defadvice save-buffers-kill-emacs (around no-query-kill-emacs activate)
  "Prevent \"Active processes exist\" queries when you quit
Emacs, by setting process-list to nil before exiting."
  (cl-flet ((process-list nil)) ad-do-it))

;; Disable the creation of .#filename lockfiles on some systems (such as OSX).
;; Lockfiles detect collision between multiple edits of the same file on access
;; rather than on save. Detecting on save is sufficient, and doesn't leave
;; garbage in the file system.
(setq create-lockfiles nil)

;; Files deleted in dired go to the trash bin.
(setq delete-by-moving-to-trash t)

;; Avoids recentering the screen when the point moves off-screen if the point is
;; up to 10k lines away.
(setq scroll-step 1)
(setq scroll-conservatively 10000)

(require 'undo-tree)
(global-undo-tree-mode)

;; Recenter the screen around the current search result when iterating through
;; them.
(defadvice
  isearch-repeat-forward
  (after isearch-repeat-forward-recenter activate)
  (recenter))
(defadvice
  isearch-repeat-backward
  (after isearch-repeat-backward-recenter activate)
  (recenter))

;; Search accross all whitespace types.
(setq search-whitespace-regexp "[ \t\r\n]+")

;; New buffers start in text-mode, not fundamental fill.
(setq-default major-mode 'text-mode)

;; Same for initial *scratch*.
(setq initial-major-mode 'text-mode)

;;;; COMPLETION ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Using ido and smex for minibuffer completion almost everywhere.

(ido-mode t)
(ido-everywhere t)                  ;; enhanced by package ido-ubiquitous
(ido-vertical-mode t)               ;; from package ido-vertical-mode
(ido-yes-or-no-mode t)              ;; from package ido-yes-or-no
(global-set-key (kbd "M-x") 'smex)  ;; from package smex

;; from package flx-ido
;; enables matching on words beginning (e.g. tcm for TeX-command-master)
(flx-ido-mode t)

(setq ido-vertical-define-keys 'C-n-and-C-p-only)

;; Don't switch to other visible frame when opening an already visible buffer.
;; (Not too sure about this one, keep the default for now.)
;; (setq ido-default-buffer-method 'selected-window)
;; (setq ido-default-file-method 'selected-window)

;; TODO try ivy (seems a bit better than ido)
;; ace-window (jump between window, not buffers)

;; TODO document
;; cycle with C-n / C-p
;; C-j force selection

;;;; TEXT ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Wrap text at column 80 with M-q or automatically (see below).
(setq-default fill-column 80)

;; Automatically wrap text.
(setq-default auto-fill-function 'do-auto-fill)

;; A sentence ends with a dot, then a *single* space.
(setq sentence-end-double-space nil)

;; Tabs are inserted as spaces.
(setq-default indent-tabs-mode nil)

;; Tab character has the same width as 4 spaces.
(setq-default tab-width 4)

;; Set tab stops to multiple of 4 (for 'tab-to-tab-stop).
(setq tab-stop-list '(4 8 12 16 20 24 28 32 36 40 44 48 52 56 60
                        64 68 72 76 80 84 88 92 96 100 104 108
                        112 116 120))

;;;; FONTS ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; This font is used notably in TeX's verbatim blocks.
(set-face-attribute 'fixed-pitch nil :height 90 :family "Courier New")

(when (eq system-type 'darwin)
   ;; GUI-only (but set to console font)
   (set-face-attribute 'default nil
                :family "Monaco" :height 120 :weight 'normal))

;;;; THEME ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(require 'color-theme)
(setq color-theme-is-global t)  ; Set color theme on all frames.
(color-theme-initialize)
(color-theme-billw)             ; My color theme of choice.

;; Spaces between text and window boundaries.
(set-face-attribute 'fringe nil
    :width 'ultra-condensed :background "black")

;; Border between windows.
(set-face-attribute 'vertical-border nil
    :width 'ultra-condensed :foreground "#333333")

;; Put a space to the left of the line number.
(setq linum-format " %d")

;;;; FUNCTIONS ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun set-80-columns ()
  "Set the selected window to 80 columns."
  (interactive)
  (enlarge-window-horizontally (- 80 (window-width))))

(defun select-minibuffer ()
  "Select the minbuffer. Useful to circumvent the dreaded
\"attempted to use minibuffer while in minibuffer\"."
  (interactive)
  (select-window (minibuffer-window)))

;; When booting Emacs, you'll sometimes be told a file has unsaved auto-save
;; data. If you want to inhibit the message, you can discard the data with this
;; function.
(defun discard-autosave-data ()
  "Discard the auto-save file for this buffer."
  (interactive)
  (delete-file (make-auto-save-file-name)))

(defun delete-file-and-buffer ()
  "Removes file connected to current buffer and kills buffer."
  (interactive)
  (let ((filename (buffer-file-name))
        (buffer (current-buffer))
        (name (buffer-name)))
    (if (not (and filename (file-exists-p filename)))
        (error "Buffer '%s' is not visiting a file!" name)
      (when (yes-or-no-p "Are you sure you want to remove this file? ")
        (delete-file filename)
        (kill-buffer buffer)
        (message "File '%s' successfully removed" filename)))))

;; source: http://steve.yegge.googlepages.com/my-dot-emacs-file
(defun rename-file-and-buffer (new-name)
  "Renames both current buffer and file it's visiting to NEW-NAME."
  (interactive "sNew name: ")
  (let ((name (buffer-name))
        (filename (buffer-file-name)))
    (if (not filename)
        (message "Buffer '%s' is not visiting a file!" name)
      (if (get-buffer new-name)
          (message "A buffer named '%s' already exists!" new-name)
        (progn
          (rename-file name new-name 1)
          (rename-buffer new-name)
          (set-visited-file-name new-name)
          (set-buffer-modified-p nil))))))

(defun yank-pop-forward ()
  "Like yank-pop (M-y) but in the other (forward) direction."
  (interactive)
  (yank-pop -1))

(defun reset-kill-ring ()
  "Resets the yank pointer to the begin of the kill ring."
  (interactive)
  (setq kill-ring-yank-pointer kill-ring))

(defun delete-kill-ring-entry ()
  "Deletes the kill-ring entry under the yank pointer (last thing
killed or yanked) from the kill ring."
  (interactive)
  (setq kill-ring (delete (car kill-ring-yank-pointer) kill-ring)))

(defun kill-next-window-and-buffer ()
  "Kill the buffer in the next window, then delete that window."
  (interactive)
  (kill-buffer (window-buffer (next-window)))
  (delete-window (next-window)))

(defun kill-this-window-and-buffer ()
  "Kill the buffer in the this window, then delete this window."
  (interactive)
  (kill-buffer (window-buffer (selected-window)))
  (delete-window (selected-window)))

(make-local-variable 'handle-trailing-whitespace)
(setq-default handle-trailing-whitespace nil)
(setq-default show-traling-whitespace nil)
(add-hook 'before-save-hook
          (lambda ()
            (if handle-trailing-whitespace
                (delete-trailing-whitespace))))

(defun toggle-trailing-whitespace-handling ()
  "Toggle trailing whitespace handling mode. When 'handled', trailing whitespace
  is highlighted and deleted on save."
  (interactive)
  (setq handle-trailing-whitespace (not handle-trailing-whitespace))
  (setq show-trailing-whitespace   (not show-trailing-whitespace))
  (force-window-update (window-buffer))
  (redisplay t))

(defun unfill-paragraph ()
  "Takes a multi-line paragraph and makes it into a single line of text."
  (interactive)
  (let ((fill-column (point-max)))
    (fill-paragraph)))

;;;; KEYBINDS ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; How to define a new prefix.
;;(define-prefix-command 'C-v-prefix)
;;(global-set-key (kbd "C-v") 'C-v-prefix)
;;(define-prefix-command 'C-c-h-prefix)
;;(norswap-key (kbd "C-c h") 'C-c-h-prefix)

(defvar norswap-keys (make-keymap) "norswap-keys-minor-mode keymap")
(define-minor-mode norswap-keys-minor-mode
  "A minor mode so that my key settings override annoying major modes."
  t "" norswap-keys)

;; Disable norswap-keys in the minibuffer.
(add-hook 'minibuffer-setup-hook (lambda () (norswap-keys-minor-mode 0)))

(defun norswap-key (key func)
  "Helper to define all-overriding custom keybinds."
  (define-key norswap-keys key func))

(norswap-key (kbd "C-x g")   'select-minibuffer)
(norswap-key (kbd "C-x y")   'set-80-columns)
(norswap-key (kbd "M-p")     'backward-paragraph)
(norswap-key (kbd "M-n")     'forward-paragraph)
(norswap-key (kbd "C-z")     'undo)
(norswap-key (kbd "C-S-z")   'undo-tree-redo)
(norswap-key (kbd "M-Q")     'unfill-paragraph)
(norswap-key (kbd "C-c t")   'toggle-trailing-whitespace-handling)
(norswap-key (kbd "C-c e")   'eval-print-last-sexp)
(norswap-key (kbd "C-c q")   'auto-fill-mode) ; toggle
(norswap-key (kbd "C-c TAB") 'indent-region)
(norswap-key (kbd "C-c SPC") 'ace-jump-mode)
(norswap-key (kbd "M-S-y")   'yank-pop-forward) ;; (osx)
(norswap-key (kbd "M-Y")     'yank-pop-forward) ;; (win)
(norswap-key (kbd "M-C-y")   'delete-kill-ring-entry)
(norswap-key (kbd "C-c C-<") 'reset-kill-ring)
(norswap-key (kbd "C-x 4 k") 'kill-next-window-and-buffer)
(norswap-key (kbd "C-x 4 j") 'kill-this-window-and-buffer)
(norswap-key (kbd "C-c C-c") 'comment-region)
(norswap-key (kbd "C-c C-v") 'uncomment-region)
(norswap-key (kbd "C-c w")   'delete-region)

;; Sane mouse scrolling (that does not accelerate to oblivion).
(norswap-key (kbd "<wheel-up>") (lambda () (interactive) (scroll-down 5)))
(norswap-key (kbd "<wheel-down>") (lambda () (interactive) (scroll-up 5)))

;;;; ENCODING ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; If the coding system of a file cannot be determined and utf-8 is a
;; possibility, assume the file is utf-8 with unix newlines. Also sets the
;; default for new buffers and IO.
(prefer-coding-system 'utf-8-unix)

;; Coding of text output to terminal.
(set-terminal-coding-system 'undecided-unix)

;; Coding system for keyboard terminal input.
(set-keyboard-coding-system 'utf-8-unix)

;; Coding for text received trough the X window system.
(setq x-select-request-type '(UTF8_STRING COMPOUND_TEXT TEXT STRING))

;;;; AUTO-SAVING ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(require 'desktop)

;; Save the session (open buffers) in a different directory for each machine.
;; Useful if your .emacs.d is on Dropbox.
(let ((dirname (concat user-emacs-directory "files-" (system-name)
                       "-" (user-real-login-name))))
  (unless (file-exists-p dirname)
    (make-directory dirname))
  (setq desktop-path `(,dirname)))


;; Save the session (open buffers) between emacs invocations.
(desktop-save-mode)

;; Autosave the desktop (don't wait untill emacs exits).
(add-hook 'auto-save-hook (lambda () (desktop-save-in-desktop-dir)))

;; Automatically save bookmarks changes.
(setq bookmark-save-flag 1)

;; All files are backed up in user-emacs-directory/backup.
(defvar backup-dir (expand-file-name (concat user-emacs-directory "backup/")))
(setq backup-directory-alist `(( ".*" . ,backup-dir)))

;; By default emacs makes a backup of a file the first time you save a file
;; after visiting it. Killing then reopening the buffer will create a new backup
;; when saving again (new file or overwrite, see below).

(setq
 backup-by-copying t    ;; presumably safer
 version-control t      ;; keep multiple versions
 delete-old-versions t  ;; rotate backups
 kept-old-versions 1    ;; keep the oldest version (e.g. pristine config)
 kept-new-versions 10   ;; keep 10 most recent versions
 )

;; All files are autosaved in user-emacs-directory/autosave.
(defvar autosave-dir
  (expand-file-name (concat user-emacs-directory "autosave/")))
(setq auto-save-list-file-prefix (concat autosave-dir "/"))
(setq auto-save-file-name-transforms `((".*" ,autosave-dir t)))

;; By default, saves after 30 seconds of idle time, only if there has been more
;; than 300 input events. (auto-save-timeout, auto-save-interval)

;;;; MAJOR-MODES ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Indents in C are 4 spaces.
(setq-default c-basic-offset 4)

;; Don't re-indent upon inserting special keys (like ';', '{', ')', ...).
(setq-default c-electric-flag nil)

;; Allow using 'a' (open file in same buffer) in Dired.
(put 'dired-find-alternate-file 'disabled nil)

;; Some settings for ps-print-buffer.
(custom-set-variables
 '(ps-print-header nil)
 '(ps-top-margin 72))

(setq lua-indent-level 4)
;; Indent multiline string like comments
(setq lua-indent-string-contents t)

;;;; LISP ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Jump to the definition of functions.
(define-key emacs-lisp-mode-map (kbd "C-c C-t") 'find-function)

;; Match the opening & closing parenthese with pretty colors.
(require 'highlight-parentheses)
(add-hook 'emacs-lisp-mode-hook     'highlight-parentheses-mode)
(add-hook 'lisp-mode-hook           'highlight-parentheses-mode)
(add-hook 'lisp-interaction-hook    'highlight-parentheses-mode)

;; for highlight-parentheses-mode
(set-variable 'hl-paren-colors
    '("LimeGreen" "firebrick1" "DodgerBlue1" "LightGoldenrod"))

;;;; ENCODING ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; If the coding system of a file cannot be determined and utf-8 is a
;; possibility, assume the file is utf-8 with unix newlines. Also sets the
;; default for new buffers and IO.
(prefer-coding-system 'utf-8-unix)

;; Coding of text output to terminal.
(set-terminal-coding-system 'undecided-unix)

;; Coding system for keyboard terminal input.
(set-keyboard-coding-system 'utf-8-unix)

;; Coding for text received trough the X window system.
(setq x-select-request-type '(UTF8_STRING COMPOUND_TEXT TEXT STRING))

;;;; WINDOWS ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defvar archive-zip-extract)
(defvar dired-mode-map)
;(defvar file-name-buffer-file-type-alist)
(when (eq system-type 'windows-nt)

  ;; Make unzip work also on Windows. unzip from gnuwin32 needs to be installed
  ;; and reachable from %PATH%. "-qq" is for the very quiet mode.
  (setq archive-zip-extract '("unzip" "-qq"))

  ;; Opening files with their Windows associated programs from whitin dired,
  ;; with the F3 key.
  (eval-after-load "dired"
    '(define-key dired-mode-map (kbd "<f3>")
       (lambda () (interactive)
	 (with-no-warnings (w32-shell-execute
	  1 (dired-replace-in-string "/" "\\" (dired-get-filename)))))))

  ;; Windows clipboard is UTF-16LE.
  (set-clipboard-coding-system 'utf-16le-dos)

  ;; Batch files need windows-style newlines.
  (push '("\\.bat$" . nil) file-coding-system-alist)

  (setq server-auth-dir (car desktop-path))

  (set-face-attribute 'default nil :font "Consolas 9"))

;;;; OSX ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(when (eq system-type 'darwin)

  ;; Inhibit warnings when compiling on other platforms.
  (defvar mac-command-modifier)
  (defvar mac-control-modifier)
  (defvar mac-option-modifier)
  (defvar mac-right-option-modifier)
  (defvar ns-pop-up-frames)

  ;; I configured OSX to invert the "command" and "contro"l key.
  ;; But I want to physical control key to act like "control" in Emacs.
  ;;
  ;; KEY:     the physical key
  ;; MAP:     what it is mapped to in OSX
  ;; EMACS:   what it is mapped to in Emacs
                                         ; KEY     | MAP     | EMACS
  (setq mac-command-modifier 'control)   ; control | command | control
  (setq mac-control-modifier nil)        ; command | control | not used
  (setq mac-option-modifier 'meta)       ; alt     | alt     | meta
  (setq mac-right-option-modifier nil)   ; r-alt   | r-alt   | not used

  ;; When dragging a file onto emacs, don't open a new window.
  (setq ns-pop-up-frames nil)

  ;; Sets $MANPATH, $PATH and exec-path from the shell.
  (exec-path-from-shell-initialize)

  ;; Disable GUI dialogs, which are unresponsive on OSX.
  (setq use-dialog-box nil)

  ;; OSX glitches with visible-bell. Blink the mode line instead.
  (setq visible-bell nil)
  (setq ring-bell-function
        (lambda ()
          (invert-face 'mode-line)
          (run-with-timer 0.1 nil 'invert-face 'mode-line))))

;;;; LATEX ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(add-hook 'LaTeX-mode-hook
          (lambda ()
            (local-set-key (kbd "C-c C-n") 'TeX-command-master)))

;; This is necessary for AucTeX to figure out it needs to run BibTeX.
(setq TeX-parse-self t) ; Enable parse on load.
(setq TeX-auto-save t)  ; Enable parse on save.

;; Also see C-c C-a (TeX-command-run-all) to get everything done.

;;;; WORKAROUNDS ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


(defun workaround-markdown-fontify-buffer-wiki-links-empty ()
  "Empty replacement for `markdown-fontify-buffer-wiki-links` due to hanging bug."
  (interactive))

(eval-after-load "markdown-mode"
  '(progn
     (fset 'markdown-fontify-buffer-wiki-links
           'workaround-markdown-fontify-buffer-wiki-links-empty)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Start the Emacs daemon, which allows opning all files in a single Emacs
;; instance.

(server-start)

;;;; MANUAL SETUP ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; Fix TRAMP on Windows
; M-x byte-compile-file, then enter:
; C:/Chocolatey/lib/Emacs.24.3/tools/emacs-24.3/lisp/net/tramp-sh.el
; and restart emacs
; use no method or plink

;;;; TODO ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; - Handle window splitting so that it is appropriate.
;;   Maybe touch upon the "C-x 4 k" & "C-x 4 j" keybinds?

;; I think the best to do it would be to use the info in
;; http://www.gnu.org/software/emacs/manual/html_node/elisp/Choosing-Window.html
;; and define my own action function override that would send buffers matching a
;; certain regex to a certain window. Multiple (regex, window) pairs would be
;; allowable and there would be a simple default action when the variable
;; corresponding to the buffers are undefined (e.g. put in bottom right buffer).

;; - A grid: divide the frame into an XxY invisible grid and allow to grow
;;   window to occupy multiple grid sections; also handle direction oriented
;;   movement in those grid in a way that feel natural. Allow moving anchor (or
;;   any corner?) of a window anywhere, and handle the re-positionning smartly
;;   (introducing empty windows as needed to fill the space.

;; - A way to group files into projects that can be closed and re-opened
;;   simultaneously.

;; - Look at Casey's .emacs, it might help.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Anything that could potentially appear below the following line was added by
;; Emacs custom system. Move it somewhere else!

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
