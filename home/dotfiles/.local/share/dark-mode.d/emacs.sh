#!/usr/bin/env bash
# Switch Emacs to dark theme

# Use emacsclient to evaluate elisp code in running Emacs instances
emacsclient --eval "(load-theme 'ef-dark t)" 2>/dev/null || true