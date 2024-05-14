;;; init.el -*- lexical-binding: t; -*-

(doom! :input

       :completion
       (company +tng)
       vertico

       :ui
       doom              ; what makes DOOM look the way it does
       doom-dashboard    ; a nifty splash screen for Emacs
       doom-quit         ; DOOM quit-message prompts when you quit Emacs
       (emoji +unicode)  ; 🙂
       hl-todo           ; highlight TODO/FIXME/NOTE/DEPRECATED/HACK/REVIEW
       indent-guides     ; highlighted indent columns
       ligatures         ; ligatures and symbols to make your code pretty again
       modeline          ; snazzy, Atom-inspired modeline, plus API
       nav-flash         ; blink cursor line after big motions
       ophints           ; highlight the region an operation acts on
       ; (popup +defaults)   ; tame sudden yet inevitable temporary windows
       (vc-gutter +pretty) ; vcs diff in the fringe
       vi-tilde-fringe   ; fringe tildes to mark beyond EOB
       (window-select +numbers)     ; visually switch windows
       workspaces        ; tab emulation, persistence & separate workspaces

       :editor
       (evil +everywhere); come to the dark side, we have cookies
       file-templates    ; auto-snippets for empty files
       fold              ; (nigh) universal code folding
       (format +onsave)  ; automated prettiness
       parinfer          ; turn lisp into python, sort of
       snippets          ; my elves. They type so I don't have to
       word-wrap         ; soft wrapping with language-aware indent

       :emacs
       (dired +icons)             ; making dired pretty [functional]
       electric          ; smarter, keyword-based electric-indent
       ibuffer         ; interactive buffer management
       undo              ; persistent, smarter undo for your inevitable mistakes
       vc                ; version-control and Emacs, sitting in a tree

       :term
       vterm             ; the best terminal emulation in Emacs

       :checkers
       syntax              ; tasing you for every semicolon you forget
       (spell +flyspell) ; tasing you for misspelling mispelling
       grammar           ; tasing grammar mistake every you make

       :tools
       lsp
       editorconfig      ; let someone else argue about tabs vs spaces
       (eval +overlay)     ; run code, run (also, repls)
       lookup              ; navigate your code and its documentation
       magit             ; a git porcelain for Emacs
       pass              ; password manager for nerds
       pdf               ; pdf enhancements
       rgb               ; creating color strings
       tree-sitter       ; syntax and parsing, sitting in a tree...

       :os
       (:if IS-MAC macos)  ; improve compatibility with macOS
       tty               ; improve the terminal Emacs experience

       :lang
       (cc +lsp)
       (csharp +lsp)
       data
       emacs-lisp
       ess
       json
       (javascript +lsp)
       (latex +cdlatex +latexmk +lsp)
       ledger
       lua
       markdown
       (org +roam2 +pretty +noter)
       (python +lsp)
       rest
       (rust +lsp)
       (sh +lsp)
       yaml

       :email
       (notmuch +afew +org)

       :app
       calendar
       irc               ; how neckbeards socialize
       (rss +org)        ; emacs as an RSS reader

       :config
       literate
       (default +bindings +smartparens))
