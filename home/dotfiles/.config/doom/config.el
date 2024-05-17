(use-package! general)

(setq ben/org-dir "~/org"
      ben/ref-dir (concat ben/org-dir "/ref")
      ben/bib (concat ben/ref-dir "/bib.bib")
      ben/papers (concat ben/ref-dir "/papers")
      ben/notes (concat ben/ref-dir "/notes"))

(defun ben/org-select-bullet-body ()
  (interactive)
  (beginning-of-line)
  (when (search-forward-regexp "^ ?+-" (line-end-position) t)
    (forward-char)
    (set-mark-command nil)
    (end-of-line)
    (backward-char)))

;; stolen from https://hungyi.net/posts/copy-org-mode-url/
(defun ben/org-yank-link ()
  (interactive)
  (let ((plain-url (url-get-url-at-point)))
    (if plain-url
        (progn
          (kill-new plain-url)
          (message (concat "Copied: " plain-url)))
      (let* ((link-info (assoc :link (org-context)))
             (text (when link-info
                     (buffer-substring-no-properties
                      (or (cadr link-info) (point-min))
                      (or (caddr link-info) (point-max))))))
        (if (not text)
            (error "Oops! Point isn't in an org link")
          (string-match org-link-bracket-re text)
          (let ((url (substring text (match-beginning 1) (match-end 1))))
            (kill-new url)
            (message (concat "Copied: " url))))))))

(defun ben/org-cliplink-without-domain-name ()
  (interactive)
  (org-cliplink-insert-transformed-title
   (org-cliplink-clipboard-content)  ;; take the URL from the clipboard
   (lambda (url title)
     (let* ((parsed-url (url-generic-parse-url url)) ;; parse the url
            (clean-title (replace-regexp-in-string ".*?: \\(.*\\)" "\\1" title)))
       ;; forward the title to the default org-cliplink transformer
       (org-cliplink-org-mode-link-transformer url clean-title)))))

(defun ben/evil-select-pasted ()
  (interactive)
  (let ((start-marker (evil-get-marker ?\[))
        (end-marker (evil-get-marker ?\])))
        (evil-visual-select start-marker end-marker)))

(add-hook 'after-save-hook
  'executable-make-buffer-file-executable-if-script-p)

(map! :leader
      :desc "Open inbox"
      "n i" (lambda () (interactive) (find-file (concat ben/org-dir "/inbox.org"))))

(map! :leader
      :desc "Open routine"
      "n R" (lambda () (interactive) (find-file (concat ben/org-dir "/routine.org"))))

(map! :leader
      :desc "Select pasted region"
      "v" #'ben/evil-select-pasted)

(setq bookmark-save-flag 1)

(setq delete-selection-mode t)

(global-auto-revert-mode)
(setq global-auto-revert-non-file-buffers t)

(setq delete-by-moving-to-trash t)

(setq user-full-name "Ben Juntilla"
      user-mail-address "benthejun@gmail.com")

(after! org
  (add-to-list 'org-tags-exclude-from-inheritance "todo")
  (setq org-root-dir "~/org"
        org-ref-dir (concat org-root-dir "/ref")
        org-directory "~/org"
        org-roam-directory "~/org"
        org-hide-drawer-startup nil
        org-cite-global-bibliography `(,ben/bib)
        org-use-property-inheritance t
        org-attach-method 'mv
        org-attach-use-inheritance t
        org-attach-store-link-p 'attached
        org-attach-directory "~/org/attach"
        org-attach-auto-tag nil
        org-roam-extract-new-file-path "${slug}.org"
        org-enforce-todo-checkbox-dependencies t
        org-todo-keywords '((sequence "TODO(t)" "NEXT(n)" "WAIT(w@/!)" "|" "DONE(d)" "CANC(c@)"))
        org-todo-keyword-faces '(("[-]" . +org-todo-active)
                                 ("NEXT" . +org-todo-active)
                                 ("STRT" . +org-todo-active)
                                 ("[?]" . +org-todo-onhold)
                                 ("WAIT" . +org-todo-onhold)
                                 ("HOLD" . +org-todo-onhold)
                                 ("PROJ" . +org-todo-project)
                                 ("NO" . +org-todo-cancel)
                                 ("CANC" . +org-todo-cancel))
        org-file-apps '((remote . emacs) (auto-mode . emacs) (directory . system) ("\\.mm\\'" . default)
                        ("\\.x?html?\\'" . default) ("\\.pdf\\'" . default))
        org-capture-templates '(("b" "Bookmark" entry (file+headline "~/org/inbox.org" "Reading List")
                                 "* TODO %(org-cliplink-capture) %?")
                                ("t" "Todo" entry (file "~/org/inbox.org")
                                 "* TODO %?" :prepend :jump-to-captured))
        org-roam-capture-templates '(("d" "default" plain "%?"
                                      :if-new (file+head "${slug}.org" "#+title: ${title}\n#+filetags: %^{prompt|personal|technology|politics}\n\n")
                                      :unnarrowed t)
                                     ("r" "ravenfield" plain "%?"
                                      :if-new (file+head "${slug}.org" "#+title: ${title}\n#+filetags: ravenfield\n\n* Tasks\n\n* Current Changelog")
                                      :unnarrowed t))))

(defun my/org-modes ()
  (interactive)
  (adaptive-wrap-prefix-mode)
  (olivetti-mode)
  (mixed-pitch-mode))
(add-hook! 'org-mode-hook #'my/org-modes)
(add-hook! 'org-mode-hook #'org-appear-mode)

(defun vulpea-todo-p ()
  "Return non-nil if current buffer has any todo entry.

TODO entries marked as done are ignored, meaning the this
function returns nil if current buffer contains only completed
tasks."
  (seq-find                                 ; (3)
   (lambda (type)
     (eq type 'todo))
   (org-element-map                         ; (2)
       (org-element-parse-buffer 'headline) ; (1)
       'headline
     (lambda (h)
       (org-element-property :todo-type h)))))

(defun vulpea-todo-update-tag ()
    "Update TODO tag in the current buffer."
    (when (and (not (active-minibuffer-window))
               (vulpea-buffer-p))
      (save-excursion
        (goto-char (point-min))
        (let* ((tags (vulpea-buffer-tags-get))
               (original-tags tags))
          (if (vulpea-todo-p)
              (setq tags (cons "todo" tags))
            (setq tags (remove "todo" tags)))

          ;; cleanup duplicates
          (setq tags (seq-uniq tags))

          ;; update tags if changed
          (when (or (seq-difference tags original-tags)
                    (seq-difference original-tags tags))
            (apply #'vulpea-buffer-tags-set tags))))))

(defun vulpea-buffer-p ()
  "Return non-nil if the currently visited buffer is a note."
  (and buffer-file-name
       (string-prefix-p
        (expand-file-name (file-name-as-directory org-roam-directory))
        (file-name-directory buffer-file-name))))

(defun vulpea-todo-files ()
    "Return a list of note files containing 'todo' tag." ;
    (seq-uniq
     (seq-map
      #'car
      (org-roam-db-query
       [:select [nodes:file]
        :from tags
        :left-join nodes
        :on (= tags:node-id nodes:id)
        :where (like tag (quote "%\"todo\"%"))]))))

(defun vulpea-agenda-files-update (&rest _)
  "Update the value of `org-agenda-files'."
  (setq org-agenda-files (vulpea-todo-files)))

(add-hook 'find-file-hook #'vulpea-todo-update-tag)
(add-hook 'before-save-hook #'vulpea-todo-update-tag)

(advice-add 'org-agenda :before #'vulpea-agenda-files-update)
(advice-add 'org-todo-list :before #'vulpea-agenda-files-update)

(after! org-agenda
  (add-to-list 'org-agenda-custom-commands
    '("u" "TODOs with no set schedule or deadline" tags "-DEADLINE={.+}-SCHEDULED={.+}/!+TODO")))

(defun ben/org-roam-pull ()
  "Pull from the git repository's upstream."
  (let ((default-directory org-roam-directory))
    (shell-command "git pull --ff-only")))

(add-hook 'org-roam-find-file-hook #'ben/org-roam-pull)

(use-package! org-recur
  :demand t
  :hook ((org-mode . org-recur-mode)
         (org-agenda-mode . org-recur-agenda-mode))

  :custom
  (org-recur-finish-done t)
  (org-recur-finish-archive t)

  :config
  (define-key org-recur-mode-map (kbd "C-c d") 'org-recur-finish)
  ;; Rebind the 'd' key in org-agenda (default: `org-agenda-day-view').
  (define-key org-recur-agenda-mode-map (kbd "d") 'org-recur-finish)
  (define-key org-recur-agenda-mode-map (kbd "C-c d") 'org-recur-finish))

(defun org-agenda-refresh ()
  "Refresh all `org-agenda' buffers."
  (dolist (buffer (buffer-list))
    (with-current-buffer buffer
      (when (derived-mode-p 'org-agenda-mode)
        (org-agenda-maybe-redo)))))

(defadvice org-schedule (after refresh-agenda activate)
  "Refresh org-agenda."
  (org-agenda-refresh))

;; Log time a task was set to DONE.
(setq org-log-done (quote time))

;; Don't log the time a task was rescheduled or redeadlined.
(setq org-log-redeadline nil)
(setq org-log-reschedule nil)

(setq org-read-date-prefer-future 'time)

(use-package! vulpea
  :hook ((org-roam-db-autosync-mode . vulpea-db-autosync-enable))
  :demand t)

(use-package! org-cliplink
  :config
  (global-set-key (kbd "C-c l") 'org-cliplink))

(use-package! org-krita
  :hook (org-mode . org-krita-mode))

(use-package! org-appear
  :custom
  (org-hide-emphasis-markers t)
  (org-appear-autoemphasis t)
  (org-appear-autolinks t)
  (org-appear-autosubmarkers t)
  (org-appear-autoentities t)
  (org-appear-autokeywords t)
  (org-appear-inside-latex t)
  :hook (org-mode . org-appear-mode))

(use-package! org-contacts
  :after org
  :custom
  (org-contacts-files `(,(concat ben/org-dir "/contacts.org"))))

(use-package! org-ref
  :custom
  (bibtex-completion-bibliography `(,ben/bib))
  (bibtex-completion-notes-path ben/notes)
  (bibtex-completion-library-path `(,ben/papers))
  (bibtex-completion-pdf-field "file")
  ;; helm configuration
  (org-ref-insert-link-function 'org-ref-insert-link-hydra/body)
  (org-ref-insert-cite-function 'org-ref-cite-insert-helm)
  (org-ref-insert-label-function 'org-ref-insert-label-link)
  (org-ref-insert-ref-function 'org-ref-insert-ref-link)
  (org-ref-cite-onclick-function (lambda (_) (org-ref-citation-hydra/body))))

(setq ediff-keep-variants nil
      ediff-split-window-function #'split-window-horizontally
      ediff-window-setup-function #'ediff-setup-windows-plain)

(add-hook! 'LaTeX-mode-hook '(#'olivetti-mode #'display-line-numbers-mode #'TeX-source-correlate-mode #'outline-minor-mode))

(use-package! auctex-latexmk
  :config (auctex-latexmk-setup))

(setq mu4e-change-filenames-when-moving t)

(setq doom-modeline-enable-word-count t)

(use-package! zoom
  :config (zoom-mode))

(use-package! olivetti
  :commands (olivetti-mode))

(blink-cursor-mode)

(setq doom-theme 'doom-one)

(setq display-line-numbers-type t)

(setq doom-font (font-spec :family "Fira Code" :size 16)
      doom-variable-pitch-font (font-spec :family "Libertinus Serif" :size 20))

(use-package! mixed-pitch
  :custom (mixed-pitch-set-height t)
  :config
  (setq mixed-pitch-fixed-pitch-faces (append mixed-pitch-fixed-pitch-faces '(org-column org-column-title treemacs-tags-face treemacs-file-face treemacs-root-face treemacs-directory-face)))
  ;; Default fonts
  ;; (set-face-attribute 'default nil :family "Iosevka" :height 160)
  ;; (set-face-attribute 'variable-pitch nil :family "Libertinus Serif" :height 1.2)
  ;; Size different org elements
  (set-face-attribute 'org-document-title nil :height 1.5)
  (set-face-attribute 'org-level-1 nil :height 1.3)
  (set-face-attribute 'org-level-2 nil :height 1.15)
  (set-face-attribute 'org-level-3 nil :height 1.075)
  (mixed-pitch-mode))

(with-eval-after-load 'dired
  (require 'dired-x))

(use-package yankpad
  :general (:prefix "C-c y"
            "m" 'yankpad-map
            "e" 'yankpad-expand
            "i" 'yankpad-insert
            "f" 'yankpad-edit
            "r" 'yankpad-reload))

(after! avy
  (defun avy-action-embark (pt)
    (unwind-protect
        (save-excursion
          (goto-char pt)
          (embark-act))
      (select-window
       (cdr (ring-ref avy-ring 0))))
    t)
  (setf (alist-get ?. avy-dispatch-alist) 'avy-action-embark)
  (defun avy-action-helpful (pt)
    (save-excursion
      (goto-char pt)
      (helpful-at-point))
    (select-window
     (cdr (ring-ref avy-ring 0)))
    t)
  (setf (alist-get ?H avy-dispatch-alist) 'avy-action-helpful))

(setq reb-re-syntax 'string)

(use-package! ctrlf
  :config (ctrlf-mode))

(use-package! typo
  :config (typo-global-mode)
  :hook (text-mode . typo-mode))

(setq evil-org-special-o/O '(table-row item))

(use-package! evil-mc
  :config
  (global-evil-mc-mode)
  (add-to-list 'evil-mc-incompatible-minor-modes 'typo-mode))

(use-package! hydra)

(after! hydra
  (defhydra hydra-window-management ()
    "window"
    ("h" windmove-left "left")
    ("l" windmove-right "right")
    ("j" windmove-down "down")
    ("k" windmove-up "up")
    ("c" ace-window "change")
    ("C" ace-swap-window "swap")
    ("s" (progn (split-window-right) (windmove-right)) "split vertically")
    ("S" (progn (split-window-below) (windmove-down)) "split horizontally")
    ("[" my/move-splitter-left "adjust <-")
    ("]" my/move-splitter-right "adjust ->")
    ("=" my/move-splitter-up "adjust up")
    ("-" my/move-splitter-down "adjust down")
    ("b" balance-windows "balance")
    ("x" delete-window "delete")
    ("d" ace-delete-window "delete other")
    ("D" delete-other-windows "delete all others")
    ("q" nil "quit" :color blue)))

(after! hydra
  (defhydra hydra-hunk-management ()
    "hunk"
    ("h" (progn (goto-char (point-min)) (diff-hl-next-hunk)) "first")
    ("j" diff-hl-next-hunk "next")
    ("k" diff-hl-previous-hunk "prev")
    ("l" (progn (goto-char (point-max)) (diff-hl-previous-hunk)) "last")
    ("J" diff-hl-show-hunk-next "show next")
    ("L" diff-hl-show-hunk-previous "show prev")
    ("RET" diff-hl-show-hunk "show" :color blue)
    ("d" diff-hl-diff-goto-hunk "diff" :color blue)
    ("DEL" diff-hl-revert-hunk "revert")
    ("q" nil "quit" :color blue)))

(use-package! magit-todos
   :config (magit-todos-mode))

(use-package! git-link
  :custom
  (git-link-open-in-browser t)
  :config
  (global-set-key (kbd "C-c g l") 'git-link))

(use-package! democratize
  :demand t
  :config
  (democratize-enable-examples-in-help)
  (democratize-enable-examples-in-helpful))
