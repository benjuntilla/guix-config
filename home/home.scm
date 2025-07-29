(use-modules (gnu)
             (gnu home)
             (gnu packages)
             (gnu services)
             (home services maestral)
             (guix gexp)
             (guix channels)
             (gnu home services)
             (gnu home services shells)
             (gnu home services shepherd)
             (gnu home services gnupg)
             (gnu home services desktop)
             (gnu home services pm)
             (gnu home services sound)
             (gnu home services dotfiles)
             (gnu home services guix))
(use-package-modules gnupg emacs)

(define (home-emacs-profile-service config)
  (list emacs-next-pgtk))

;; (define (home-emacs-shepherd-service config)
;;   (list (shepherd-service
;;          (provision '(emacs-next-pgtk))
;;          (documentation "Run emacs.")
;;          (start #~(make-forkexec-constructor '("emacs" "--fg-daemon")))
;;          (stop #~(make-kill-destruct)))))

(define home-emacs-service-type
  (service-type (name 'home-emacs)
                (extensions
                 (list (service-extension
                        home-profile-service-type
                        home-emacs-profile-service)))
                       ;(service-extension
                       ; home-shepherd-service-type
                       ; home-emacs-shepherd-service)))
                (default-value #f)
                (description "Emacs :)")))

(home-environment
 (services
  (list
   (simple-service 'environment-variables
                   home-environment-variables-service-type
                   '(("PNPM_HOME" . "~/.pnpm")
                     ("PATH" . "$PNPM_HOME:~/.bun/bin:~/.sst/bin:~/.config/emacs-doom/bin:~/.local/share/gem/ruby/2.0.0/bin:~/.config/rofi/bin:/usr/bin:$GOPATH/bin:~/.dotnet/tools:~/.cargo/bin:~/.local/bin:$PATH")
                     ("TERMCMD" . "wezterm start")
                     ("TERMINAL" . "wezterm")
                     ("EDITOR" . "nvim")
                     ("PAGER" . "less -R")
                     ("BROWSER" . "~/.guix-profile/bin/firefox")
                     ("GDK_BACKEND" . "wayland")
                     ("ALTERNATE_EDITOR" . "nvim")
                     ("SDL_VIDEO_MINIMIZE_ON_FOCUS_LOSS" . "0")
                     ("DOTNET_CLI_TELEMETRY_OPTOUT" . "1")
                     ("XDG_SCREENSHOTS_DIR" . "~/Downloads")
                     ("XDG_DESKTOP_DIR" . "~/Downloads/Desktop")
                     ("XDG_DATA_DIRS" . "/var/lib/flatpak/exports/share:/home/ben/.local/share/flatpak/exports/share:$XDG_DATA_DIRS")
                     ("GOPATH" . "~/.local/share/go")
                     ("DELTA_FEATURES" . "side-by-side")
                     ("LEDGER_FILE" . "~/org/.hledger.journal")
                     ("GLIBC_TUNABLES" . "glibc.rtld.dynamic_sort=2")
                     ("AWS_VAULT_BACKEND" . "pass")
                     ("AWS_VAULT_PASS_PREFIX" . "aws-vault/")
                     ("PYTHON_KEYRING_BACKEND" . "keyring.backends.null.Keyring")
                     ("GTK_IM_MODULE" . "fcitx")
                     ("QT_IM_MODULE" . "fcitx")
                     ("QT4_IM_MODULE" . "fcitx")
                     ("SDL_IM_MODULE" . "fcitx")
                     ("INPUT_METHOD" . "fcitx")
                     ("XMODIFIERS" . "@im=fcitx")
                     ("GLFW_IM_MODULE" . "ibus")
                     ("GPG_TTY" . "$(tty)")
                     ("NIXPKGS_ALLOW_UNFREE" . "1")))
   (service home-fish-service-type (home-fish-configuration
                                    (config
                                     (list (plain-file "config.fish"
                                                       "set -U fish_greeting 🐟\nbass source /run/current-system/profile/etc/profile.d/nix.sh\n")))
                                    (aliases
                                     '(("g" . "git")))))
   (service home-maestral-service-type)
   (service home-pipewire-service-type)
   (service home-dbus-service-type)
   (service home-batsignal-service-type)
   (service home-emacs-service-type)
   (simple-service 'extra-channels-service
                   home-channels-service-type
                   (list (channel
                          (name 'guix)
                          (url "https://git.savannah.gnu.org/git/guix.git")
                          (branch "master")
                          (introduction
                           (make-channel-introduction
                            "9edb3f66fd807b096b48283debdcddccfea34bad"
                            (openpgp-fingerprint
                             "BBB0 2DDF 2CEA F6A8 0D1D  E643 A2A0 6DF2 A33A 54FA"))))
                         (channel
                          (name 'ben-guix)
                          (url (string-append "file://" (getenv "HOME") "/src/ben-guix"))
                          (branch "main"))
                          (channel
                           (name 'rustup)
                           (url "https://github.com/declantsien/guix-rustup")
                           (introduction
                            (make-channel-introduction
                             "325d3e2859d482c16da21eb07f2c6ff9c6c72a80"
                             (openpgp-fingerprint
                              "F695 F39E C625 E081 33B5  759F 0FC6 8703 75EF E2F5"))))
                         (channel
                          (name 'efraim-dfsg)
                          (url "https://git.sr.ht/~efraim/my-guix")
                          (branch "master")
                          (introduction
                           (make-channel-introduction
                            "61c9f87404fcb97e20477ec379b643099e45f1db"
                            (openpgp-fingerprint
                             "A28B F40C 3E55 1372 662D  14F7 41AA E7DC CA3D 8351"))))
                         (channel
                          (name 'guix-gaming-games)
                          (url "https://gitlab.com/guix-gaming-channels/games.git")
                          ;; Enable signature verification:
                          (introduction
                           (make-channel-introduction
                            "c23d64f1b8cc086659f8781b27ab6c7314c5cca5"
                            (openpgp-fingerprint
                             "50F3 3E2E 5B0C 3D90 0424  ABE8 9BDC F497 A4BB CC7F"))))
                         (channel
                          (name 'nonguix)
                          (url "https://gitlab.com/nonguix/nonguix")
                          (branch "master")
                          (introduction
                           (make-channel-introduction
                            "897c1a470da759236cc11798f4e0a5f7d4d59fbc"
                            (openpgp-fingerprint
                             "2A39 3FFF 68F4 EF7A 3D29  12AF 6F51 20A0 22FB B2D5"))))))
   (service home-gpg-agent-service-type
            (home-gpg-agent-configuration
             (pinentry-program
              (file-append pinentry-rofi "/bin/pinentry-rofi"))
             ;; make cache times functionally infinite
             (default-cache-ttl 34560000)
             (max-cache-ttl 34560000)
             (default-cache-ttl-ssh 34560000)
             (max-cache-ttl-ssh 34560000)
             ;; enable ssh support
             (ssh-support? #t)
             (extra-content "allow-emacs-pinentry\nenable-ssh-support")))

   ;; link dotfiles
   (service home-dotfiles-service-type
            (home-dotfiles-configuration
             (layout 'plain)
             (directories '("./dotfiles")))))))
