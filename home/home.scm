(define-module (home home))
(use-modules (gnu)
             (gnu home)
             (gnu packages)
             (gnu services)
             (home services maestral)
             (guix gexp)
             (guix channels)
             (gnu home services)
             (gnu home services niri)
             (gnu home services shells)
             (gnu home services shepherd)
             (gnu home services gnupg)
             (gnu home services desktop)
             (gnu home services ssh)
             (gnu home services pm)
             (gnu home services sound)
             (gnu home services dotfiles)
             (gnu home services guix)
             (home packages))
(use-package-modules gnupg emacs package-management xdisorg bash)

(home-environment
 (services
  (list
   (simple-service 'environment-variables
                   home-environment-variables-service-type
                   '(("PNPM_HOME" . "$HOME/.pnpm")
                     ("XDG_DESKTOP_PORTAL_DIR" . "$HOME/.local/share/xdg-desktop-portal/portals")
                     ("GOPATH" . "$HOME/.local/share/go")
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
fish_add_path $HOME/.bun/bin $PNPM_HOME $GOPATH/bin $HOME/.cargo/bin $HOME/.local/bin $HOME/.opencode/bin

function fish_greeting
    fish_logo
end
funcsave fish_greeting >/dev/null

source /run/current-system/profile/etc/profile.d/nix.fish

# required since we use pinentry-tty
set GPG_TTY (tty)

# Ctrl+o: fzf directory selection and cd
function __fzf_select_dir_and_cd
    set selected (find ~/src -mindepth 1 -maxdepth 1 -type d | sed 's|^~/|~|' | fzf --height 40% --reverse --preview 'ls -la {}')
    if test -n \"$selected\"
        cd $selected
        commandline -f repaint
    end
end
bind \\co '__fzf_select_dir_and_cd'

# Ctrl+e: open helix editor in current directory
bind \\ce 'hx .'
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
                          (respawn? #t)
                          (auto-start? #t))))
   (service home-openssh-service-type
         (home-openssh-configuration
          (hosts
           (list (openssh-host
                  (name "soda")
                  (host-name "77.37.74.136")
                  (user "root"))))))
   (simple-service 'ydotoold
                   home-shepherd-service-type
                   (list (shepherd-service
                          (provision '(ydotoold))
                          (start #~(make-forkexec-constructor
                                    (list "ydotoold")))
                          (stop #~(make-kill-destructor))
                          (respawn? #t)
                          (auto-start? #t))))
   (simple-service 'voxbolt
                   home-shepherd-service-type
                   (list (shepherd-service
                          (provision '(voxbolt))
                          (start #~(make-forkexec-constructor
                                    (list "fish" "-c" "source ~/.env.local && voxbolt")))
                          (stop #~(make-kill-destructor))
                          (respawn? #t)
                          (auto-start? #t))))
   (simple-service 'dropbox
                   home-shepherd-service-type
                   (list (shepherd-service
                          (provision '(dropbox))
                          (documentation "Dropbox file sync daemon.")
                          (start #~(make-forkexec-constructor
                                    (list (string-append (getenv "HOME") "/.local/bin/dropbox") "start")
                                    #:pid-file (string-append (getenv "HOME") "/.dropbox/dropbox.pid")))
                          (stop #~(make-kill-destructor))
                          (respawn? #t)
                          (auto-start? #t))))
   (simple-service 'my-packages
                   home-profile-service-type
                   my-packages)
   (service home-niri-service-type)
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
           (respawn? #t)
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
                           (name 'emacs)
                           (url "https://github.com/garrgravarr/guix-emacs")
                           (introduction
                            (make-channel-introduction
                             "d676ef5f94d2c1bd32f11f084d47dcb1a180fdd4"
                             (openpgp-fingerprint
                              "2DDF 9601 2828 6172 F10C  51A4 E80D 3600 684C 71BA"))))
                         (channel
                          (name 'saayix)
                          (branch "main")
                          (url "https://codeberg.org/look/saayix")
                          (introduction
                           (make-channel-introduction
                            "12540f593092e9a177eb8a974a57bb4892327752"
                            (openpgp-fingerprint
                             "3FFA 7335 973E 0A49 47FC  0A8C 38D5 96BE 07D3 34AB"))))
                         (channel
                          (name 'pantherx)
                          (url "https://codeberg.org/gofranz/panther.git")
                          ;; Enable signature verification
                          (introduction
                           (make-channel-introduction
                            "54b4056ac571611892c743b65f4c47dc298c49da"
                            (openpgp-fingerprint
                             "A36A D41E ECC7 A871 1003  5D24 524F EB1A 9D33 C9CB"))))
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
