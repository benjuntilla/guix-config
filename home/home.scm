(define-module (home home))
(use-modules (gnu)
             (gnu home)
             (gnu packages)
             (gnu services)
             (home services maestral)
             (abbe packages golang)
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
             (gnu home services guix)
             (home packages))
(use-package-modules gnupg emacs)

(home-environment
 (services
  (list
   (simple-service 'environment-variables
                   home-environment-variables-service-type
                   '(("PNPM_HOME" . "$HOME/.pnpm")
                     ("XDG_DESKTOP_PORTAL_DIR" . "$HOME/.local/share/xdg-desktop-portal/portals")
                     ("GOPATH" . "$HOME/.local/share/go")
                     ("PATH" . "$PNPM_HOME:$HOME/.bun/bin:$HOME/.sst/bin:$HOME/.config/emacs-doom/bin:$HOME/.local/share/gem/ruby/2.0.0/bin:$HOME/.config/rofi/bin:/usr/bin:$GOPATH/bin:$HOME/.dotnet/tools:$HOME/.cargo/bin:$HOME/.local/bin:$PATH")
                     ("TERMCMD" . "wezterm start")
                     ("TERMINAL" . "wezterm")
                     ("EDITOR" . "hx")
                     ("PAGER" . "less -R")
                     ("BROWSER" . "zen")
                     ("GDK_BACKEND" . "wayland")
                     ("ALTERNATE_EDITOR" . "nvim")
                     ("SDL_VIDEO_MINIMIZE_ON_FOCUS_LOSS" . "0")
                     ("DOTNET_CLI_TELEMETRY_OPTOUT" . "1")
                     ("XDG_SCREENSHOTS_DIR" . "$HOME/Downloads")
                     ("XDG_DESKTOP_DIR" . "$HOME/Downloads/Desktop")
                     ("XDG_DATA_DIRS" . "/home/ben/.local/share:/var/lib/flatpak/exports/share:/home/ben/.local/share/flatpak/exports/share:$XDG_DATA_DIRS")
                     ("DELTA_FEATURES" . "side-by-side")
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
                                     (list (plain-file "config.fish" "
function fish_greeting
    fish_logo
end
funcsave fish_greeting >/dev/null

source /run/current-system/profile/etc/profile.d/nix.fish

# Auto-launch compositor
if status is-login
    and test (tty) = \"/dev/tty1\"
    exec niri --session
end

# required since we use pinentry-tty
set GPG_TTY (tty)
")))
                                    (aliases
                                     '(("g" . "git")
                                       ("c" . "claude")
                                       ("l" . "lsd")
                                       ("ll" . "lsd -l")
                                       ("la" . "lsd -A")
                                       ("lla" . "lsd -lA")))))
   (simple-service 'emacs-daemon
                   home-shepherd-service-type
                   (list (shepherd-service
                          (provision '(emacs))
                          (start #~(make-forkexec-constructor
                                    (list #$(file-append emacs-next-pgtk "/bin/emacs")
                                          "--fg-daemon")
                                    #:log-file (string-append (getenv "HOME") "/.local/state/log/emacs-daemon.log")))
                          (stop #~(make-kill-destructor))
                          (respawn? #t))))
   (simple-service 'ydotoold
                   home-shepherd-service-type
                   (list (shepherd-service
                          (provision '(ydotoold))
                          (start #~(make-forkexec-constructor
                                    (list "ydotoold")))
                          (stop #~(make-kill-destructor))
                          (respawn? #t))))
   (simple-service 'voxbolt
                   home-shepherd-service-type
                   (list (shepherd-service
                          (provision '(voxbolt))
                          (start #~(make-forkexec-constructor
                                    (list "/home/ben/src/voxbolt/target/release/voxbolt")))
                          (stop #~(make-kill-destructor))
                          (respawn? #t))))
   (simple-service 'my-packages
                   home-profile-service-type
                   my-packages)
   (service home-maestral-service-type)
   (service home-pipewire-service-type)
   (service home-dbus-service-type)
   (service home-batsignal-service-type)
   (simple-service
    'darkman-service
    home-shepherd-service-type
    (list (shepherd-service
           (provision '(darkman))
           (documentation "Dark/light mode daemon (darkman)")
           (start #~(make-forkexec-constructor
                     (list #$(file-append darkman "/bin/darkman") "run")))
           (stop #~(make-kill-destructor))
           (auto-start? #t))))
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
                          (name 'abbe)
                          (url "https://codeberg.org/group/guix-modules.git")
                          (branch "mainline")
                          (introduction
                           (make-channel-introduction
                            "8c754e3a4b49af7459a8c99de130fa880e5ca86a"
                            (openpgp-fingerprint
                             "F682 CDCC 39DC 0FEA E116  20B6 C746 CFA9 E74F A4B0"))))
                         (channel
                          (name 'saayix)
                          (branch "entropy")
                          (url "https://codeberg.org/look/saayix")
                          (introduction
                           (make-channel-introduction
                            "12540f593092e9a177eb8a974a57bb4892327752"
                            (openpgp-fingerprint
                             "3FFA 7335 973E 0A49 47FC  0A8C 38D5 96BE 07D3 34AB"))))
                         (channel
                          (name 'rosenthal)
                          (url "https://codeberg.org/hako/rosenthal.git")
                          (branch "trunk")
                          (introduction
                           (make-channel-introduction
                            "7677db76330121a901604dfbad19077893865f35"
                            (openpgp-fingerprint
                             "13E7 6CD6 E649 C28C 3385  4DF5 5E5A A665 6149 17F7"))))
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
                             "2A39 3FFF 68F4 EF7A 3D29  12AF 6F51 20A0 22FB B2D5"))))
                         ))
   (service home-gpg-agent-service-type
            (home-gpg-agent-configuration
             (pinentry-program
              (file-append pinentry-rofi "/bin/pinentry-rofi"))
             (ssh-support? #t)))

   ;; link dotfiles
   (service home-dotfiles-service-type
            (home-dotfiles-configuration
             (layout 'plain)
             (directories '("./dotfiles")))))))
