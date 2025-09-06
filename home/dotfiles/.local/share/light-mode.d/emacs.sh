#!/usr/bin/env bash
# Switch Emacs to light theme

# Use emacsclient to evaluate elisp code in running Emacs instances
emacsclient --eval "(load-theme 'ef-light t)" 2>/dev/null || true