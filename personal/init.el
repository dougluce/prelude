(setq package-archives '(("org"       . "http://orgmode.org/elpa/")
                         ("gnu"       . "http://elpa.gnu.org/packages/")
                         ("melpa"     . "http://melpa.milkbox.net/packages/")
                         ("tromey"    . "http://tromey.com/elpa/")
                         ("marmalade" . "http://marmalade-repo.org/packages/")))
(package-initialize)

; Make extra-wide windows not go side-by-side
(setq split-width-threshold nil)


(defvar autosave-list '("scratchmain" "diary" "org" "pw.gpg"))

(defun autosave()
  (save-some-buffers t (lambda () (member (buffer-name) autosave-list))))

(setq autosave-timer (timer-create))
(timer-set-time autosave-timer (current-time) 900)
(timer-set-function autosave-timer 'autosave)
(timer-activate autosave-timer)

(display-time)
(setq work-directory (expand-file-name "~/sync/work"))

(defun work-file (filename)
  (format "%s/%s" work-directory filename))

(defun pullorgfile ()
  "Pull up my org buffer"
  (interactive)
  (switch-to-buffer (find-file-noselect
		     (work-file "org")))
  (org-mode))


(defun date-header ()
  "Returns a datestring in a special header form"
  (format "--------->> %s <<---------\n" (date-string)))


(defun scratchtaskfile ()
  "Pull up the main scratch task file"
  (interactive)
  (switch-to-buffer (find-file-noselect
		     (format "%s/scratchmain" work-directory)))
  (setq auto-fill-function 'do-auto-fill) ; Auto-fill
  (widen)
  (newsubentry))


(defun newsubentry ()
  "Makes a new entry in the current buffer"
  (interactive)
					; This really should make sure we're in a task buffer...
					; Go to the end, attempt to find today's date in a marker.
  (goto-char (point-max))
  (if (search-backward (date-header) nil t)
      (progn   ; Success.  Go to end of buffer, insert timestamp.
	(goto-char (point-max))
	(insert-time))
					; Failure. insert new date string. and timestamp.
    (set-text-properties
     (point)
     (progn (insert (format "\n%s" (date-header)))
	    (point))
     (list 'dated 't 'dateis (date-string)))
    (insert-time)
    )
  )

(defun date-string ()
  "Returns the current date in a string (ISO-8601 year-month-day)."
  (let ((s (current-time-string)))
    (format "%04d-%02d-%02d"
	    (string-to-number (substring s 20 24))
	    (length (member (substring s 4 7)
			    '("Dec" "Nov" "Oct" "Sep" "Aug" "Jul"
			      "Jun" "May" "Apr" "Mar" "Feb" "Jan")))
	    (string-to-number (substring s 8 10))
	    )))

(defun insert-time ()
  "Insert current timestamp xx:xx am at the point"
  (insert "\n")
  (insert (substring (current-time-string) 11 16))
  (insert " "))


(global-set-key "\C-ct" 'scratchtaskfile)
(global-set-key "\C-cg" 'gpw)  ; generate and insert a new pw
(global-set-key "\C-c\C-g" 'gpw)  ; generate and insert a new 8-char pw
(global-set-key "\C-cc" 'compile)
(global-set-key "\C-c\C-c" 'compile)
(global-set-key "\C-c\C-r" 'pullorgfile)
(global-set-key "\C-c\C-p" 'pullpasswordfile)
(global-set-key "\M-g" 'goto-line)
(global-set-key "\M-i" 'ispell-buffer)
(global-set-key "\C-c\r" 'magit-status)

(setq kill-ring-max 100000)


(defun pdb ()
  (interactive)
  (insert "import pdb; pdb.set_trace()"))

;
; Prelude stufff.
;

(global-flycheck-mode nil)
(remove-hook 'prog-mode 'flycheck-mode)
(disable-theme 'zenburn)
; Stop silly quote auto-escaping.
(setq sp-autoescape-string-quote nil)
(add-hook 'prelude-prog-mode-hook (lambda () (smartparens-mode -1)) t)
(add-hook 'web-mode-hook (lambda() (local-set-key "\C-c\r" 'magit-status)))
(define-key prelude-mode-map "\C-ct" 'scratchtaskfile)
(ad-unadvise 'kill-region)


; Get rid of that highlighted line.
(global-hl-line-mode -1)
(require 'prelude-key-chord)


;
;Diff a couple dates.

(defun timediff (older newer)
  (insert
   (number-to-string
    (time-to-seconds
     (time-subtract
      (date-to-time newer)
      (date-to-time older))))))


(defun unfill-paragraph ()
  "Takes a multi-line paragraph and makes it into a single line of text."
  (interactive)
  (let ((fill-column (point-max)))
    (fill-paragraph nil)))


(defun unfill-region ()
  (interactive)
  (let ((fill-column (point-max)))
    (fill-region (region-beginning) (region-end) nil)))

;;; For gpg-agent, assumes i'm using tmux.

(defun pinentry-emacs (desc prompt ok error)
  (shell-command "tmux display-message 'Password needed'")
  (let ((str (with-selected-frame root-frame (read-passwd
         (concat
          (replace-regexp-in-string
           "%22" "\""
           (replace-regexp-in-string "%0A" "\n" desc)) prompt ": ")))))
    str))

(if (or (not (boundp 'root-frame))
        (not (terminal-live-p (frame-terminal root-frame))))
    (setq root-frame (selected-frame)))

(setq paradox-github-token "44292d6dcd17294a933b972a0bfe99000a9045b7")

(provide 'init)
;;; init.el ends here



(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-buffer-indent 2)
 '(indent-tabs-mode nil)
 '(org-confirm-babel-evaluate nil)
 '(org-cycle-include-plain-lists (quote integrate))
 '(org-display-custom-times t)
 '(org-modules (quote (org-bbdb org-bibtex org-docview org-gnus org-habit org-id org-info org-irc org-mhe org-rmail org-w3m)))
 '(org-return-follows-link nil)
 '(org-time-stamp-custom-formats (quote ("<%m/%d/%y>" . "<%m/%d/%y %a %H:%M>")))
 '(perl-indent-level 2)
 '(tab-width 2))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(diff-added ((t (:inherit diff-changed :foreground "blue"))))
 '(diff-added-face ((t (:inherit diff-changed :foreground "green"))) t))


;;
; My stuff
;

(setq load-path
      (cons (expand-file-name "~/lib/emacs") load-path))

(setq home-directory (expand-file-name "~"))
(setq work-directory (expand-file-name "~/sync/work"))

(defun work-file (filename)
  (format "%s/%s" work-directory filename))

(load "dougtasks")
(put 'set-goal-column 'disabled nil)
(defun gpw ()
  (interactive)
  (insert (substring (shell-command-to-string "gpw 1 12") 0 12)))


(defun pullpasswordfile ()
"Pull up my password stash"
  (interactive)
  (switch-to-buffer (find-file-noselect
                     (work-file "pw.gpg")))
  (goto-char (point-max))) ; go to the bottom.


(defun pullorgfile ()
"Pull up my org buffer"
  (interactive)
  (switch-to-buffer (find-file-noselect
                     (work-file "org")))
  (org-mode))

(setq numitor 1)

(defun numit (start end)
  (move-to-column start t)
  (insert (number-to-string numitor))
  (setq numitor (+ numitor 1)))

(defun number-rectangle (start end &optional prefix)
  (interactive
   (progn (barf-if-buffer-read-only)
          (list
           (region-beginning)
           (region-end)
           (prefix-numeric-value current-prefix-arg))))
  (if prefix
      (setq numitor prefix)
    (setq numitor 1))
  (apply-on-rectangle 'numit start end))


;
; My auto-save hack.  Like, periodically save the buffers I care about.
;
(defvar autosave-list '("scratchmain" "diary" "org" "pw.gpg"))

(defun autosave()
  (save-some-buffers t (lambda () (member (buffer-name) autosave-list))))

(setq autosave-timer (timer-create))
(timer-set-time autosave-timer (current-time) 900)
(timer-set-function autosave-timer 'autosave)
(timer-activate autosave-timer)

(display-time)


; Actually autosave.
(require 'real-auto-save)
(setq real-auto-save-interval 10) ;; in seconds
(add-hook 'text-mode-hook 'turn-on-real-auto-save)
(add-hook 'org-mode-hook 'turn-on-real-auto-save)

;;; from Stefan Monnier <foo@acm.org>.  The opposite of fill-paragraph
(defun unfill-paragraph ()
  "Takes a multi-line paragraph and makes it into a single line of text."
  (interactive)
  (let ((fill-column (point-max)))
    (fill-paragraph nil)))


(defun unfill-region ()
  (interactive)
  (let ((fill-column (point-max)))
    (fill-region (region-beginning) (region-end) nil)))
(put 'upcase-region 'disabled nil)

;(require 'org-exp-blocks)
(require 'ox-reveal)

(org-babel-do-load-languages
 'org-babel-load-languages
 '((ditaa . t)
   ))

;; gpg support

(defun pinentry-emacs (desc prompt ok error)
  (shell-command "tmux display-message 'Password needed'")
  (let ((str (with-selected-frame root-frame (read-passwd
              (concat
               (replace-regexp-in-string
                "%22" "\""
                (replace-regexp-in-string "%0A" "\n" desc)) prompt ": ")))))
    str))

(if (or (not (boundp 'root-frame))
     (not (terminal-live-p (frame-terminal root-frame))))
    (setq root-frame (selected-frame)))


(put 'downcase-region 'disabled nil)

(defun local-keybindings ()
  (local-set-key "\C-c\r" 'magit-status))


(add-hook 'c-mode-hook 
          (lambda() 
            (local-set-key "\C-cc" 'compile)
            (local-set-key "\C-c\C-c" 'compile)))

(add-hook 'c++-mode-hook 
          (lambda() 
            (local-set-key "\C-cc" 'compile)
            (local-set-key "\C-c\C-c" 'compile)))

