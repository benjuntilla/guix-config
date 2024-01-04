; !!!!!!!!!!!!       TODO     !!!!!!!!!!!!!!!!

; https://www.reddit.com/r/GUIX/comments/127kml7/comment/kajwlop/?utm_source=reddit&utm_medium=web2x&context=3

;(define-public desktop-services
  ;(list
    ;(simple-service 'gtk-config
                   ;home-files-service-type
                   ;`(("config/gtk-3.0/settings.ini"
                      ;,(local-file "../files/gtk3.ini"))
                     ;("config/gtk-3.0/gtk.css"
                      ;,(local-file "../files/gtk3.css"))))))          

(use-modules (gnu)
			 (gnu home)
             (gnu packages)
             (gnu services)
             (guix gexp)
             (guix channels)
             (gnu home services)
             (gnu home services shells)
             (gnu home services shepherd)
			 (gnu home services gnupg)
			 (gnu home services desktop)
			 (gnu home services pm)
			 (gnu home services guix))
(use-package-modules gnupg emacs)

(define (home-emacs-profile-service config)
  (list emacs-next))

(define (home-emacs-files-service config)
  (list `(".config/emacs/config.org" ,(local-file "files/emacs/config.org"))
        `(".config/emacs/templates" ,(local-file "files/emacs/templates"))
		`(".config/emacs/init.el" ,(local-file "files/emacs/init.el"))
		`(".config/emacs/early-init.el" ,(local-file "files/emacs/early-init.el"))))

(define (home-emacs-shepherd-service config)
  (list (shepherd-service
		  (provision '(emacs-next))
		  (documentation "Run emacs.")
		  (start #~(make-forkexec-constructor '("emacs" "--fg-daemon")))
		  (stop #~(make-kill-destructor)))))

(define home-emacs-service-type
  (service-type (name 'home-emacs)
				(extensions
				  (list (service-extension
						  home-profile-service-type
						  home-emacs-profile-service)
						;(service-extension
						  ;home-shepherd-service-type
						  ;home-emacs-shepherd-service)
						(service-extension
						  home-files-service-type
						  home-emacs-files-service)))
				(default-value #f)
				(description "Emacs :)")))

(home-environment
  ;; Below is the list of packages that will show up in your
  ;; Home profile, under ~/.guix-home/profile.
  (packages (specifications->packages (list "swaylock"
                                            "swayidle"
                                            "mupdf"
                                            "imagemagick"
                                            "libheif"
                                            "stapler"
                                            "bc"
                                            "lemonbar"
                                            "icedove-wayland"
                                            "ffmpeg"
                                            "gammastep"
                                            "tlpui"
                                            "usbmuxd"
                                            "libimobiledevice"
                                            "blueman"
                                            "bluez"
                                            "bluez-qt"
                                            "grimshot"
                                            "cppcheck"
                                            "xdot"
                                            "xournalpp"
                                            "nomacs"
                                            "grim"
                                            "dotnet"
                                            "python"
                                            "aspell"
                                            "hunspell"
                                            "libvterm"
                                            "libtool"
                                            "cmake"
                                            "ghostscript"
                                            "tesseract-ocr"
                                            "wireplumber"
                                            "git-filter-repo"
                                            "pipewire"
                                            "i3-autotiling"
                                            "flatpak-xdg-utils"
                                            "xdg-desktop-portal-wlr"
                                            "xdg-desktop-portal"
                                            "shotcut"
                                            "obs-vkcapture"
                                            "obs-wlrobs"
                                            "obs"
                                            "winetricks"
                                            "wine"
                                            "dbus"
                                            "xset"
                                            "gnome"
                                            "gocryptfs"
                                            "qdirstat"
                                            "sdl2"
                                            "libpng"
                                            "automake"
                                            "autoconf"
                                            "wl-clipboard"
                                            "wtype"
                                            "fontforge"
                                            "gtk"
                                            "fcitx5-gtk4"
                                            "fcitx5-chinese-addons:gui"
                                            "fcitx5-gtk:gtk3"
                                            "fcitx5-gtk:gtk2"
                                            "emacs-straight-el"
                                            "anki"
                                            "node"
                                            "brillo"
                                            "clipman"
                                            "wlogout"
                                            "dunst"
                                            "playerctl"
                                            "pulsemixer"
                                            "ponymix"
                                            "dex"
                                            "emacs-next-pgtk"
                                            "python-pip"
                                            "epiphany"
                                            "fcitx5"
                                            "fcitx5-chinese-addons"
                                            "fcitx5-configtool"
                                            "fcitx5-qt"
                                            "fcitx5-gtk"
                                            "fcitx5-rime"
                                            "zoom"
                                            "libreoffice"
                                            "nautilus"
                                            "pavucontrol"
                                            "zathura-pdf-mupdf"
                                            "zathura"
                                            "trash-cli"
                                            "tessen"
                                            "rofi-wayland"
                                            "git-lfs"
                                            "waybar"
                                            "ungoogled-chromium"
                                            "krita"
                                            "gnome-tweaks"
                                            "flatpak"
                                            "gnome-console"
                                            "emacs-magit"
                                            "pinentry"
                                            "password-store"
                                            "xdg-utils"
                                            "firefox"
                                            "mpv"
                                            "qbittorrent"
                                            "icecat"
                                            "texlive"
                                            "vscodium"
                                            "kitty"
                                            "gnome-shell-extensions"
                                            "anytype"
                                            "git"
                                            "sway"
                                            "curl"
                                            "xclip"
                                            "setxkbmap"
                                            "xkbutils"
                                            "alacritty"
                                            "icedtea"
                                            "openjdk"
                                            "pass-otp"
                                            "prismlauncher"
                                            "bat"
                                            "btop"
                                            "libfido2"
                                            "pam-u2f"
                                            "qpdf"
                                            "librime"
                                            "iwd"
                                            "hwinfo"
                                            "acpi"
                                            "jq"
                                            "swayr"
                                            "zoxide"
                                            "lf"
                                            "fd"
                                            "ripgrep"
                                            "rust"
                                            "gcc-toolchain"
                                            "opendoas"
                                            "rust-cargo"
                                            "perl-file-mimeinfo"
                                            "file"
                                            "bash"
                                            "ncurses"
                                            "perl"
                                            "fzf"
                                            "zsh"
                                            "go"
                                            "neovim"
                                            "pandoc"
                                            "thinkfan"
                                            "vim"
                                            "make"
                                            "htop"
                                            "shellcheck"
                                            "neofetch"
                                            "check"
                                            "flameshot"
                                            "tomb"
                                            "egl-wayland"
                                            "ninja"
                                            "meson"
                                            "recutils"
                                            "brightnessctl"
                                            "font-awesome"
                                            "gcc-toolchain:static"
                                            "patchelf"
                                            "glibc"
                                            "aspell-dict-en"
                                            "hunspell-dict-en-us"
                                            "font-fira-code"
                                            "font-ibm-plex"
                                            "font-google-noto-emoji"
                                            "rime-data"
                                            "zsh-autosuggestions"
                                            "fcitx5-material-color-theme"
                                            "zsh-syntax-highlighting"
                                            "zsh-autopair"
                                            "zsh-completions"
                                            "font-iosevka"
                                            "font-google-noto-sans-cjk"
                                            "font-google-noto-serif-cjk"
                                            "font-microsoft-web-core-fonts"
                                            "gnome-shell-extension-vitals")))

  ;; Below is the list of Home services.  To search for available
  ;; services, run 'guix home search KEYWORD' in a terminal.
  (services
   (list
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
                         (name 'guix-gaming-games)
                         (url "https://gitlab.com/guix-gaming-channels/games.git")
                         ;; Enable signature verification:
                         (introduction
                          (make-channel-introduction
                           "c23d64f1b8cc086659f8781b27ab6c7314c5cca5"
                           (openpgp-fingerprint
                            "50F3 3E2E 5B0C 3D90 0424  ABE8 9BDC F497 A4BB CC7F"))))
                        (channel
                         (name 'small-guix)
                         (url "https://gitlab.com/orang3/small-guix")
                         ;; Enable signature verification:
                         (introduction
                          (make-channel-introduction
                           "f260da13666cd41ae3202270784e61e062a3999c"
                           (openpgp-fingerprint
                            "8D10 60B9 6BB8 292E 829B  7249 AED4 1CC1 93B7 01E2"))))
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
              (ssh-support? #t)))
    (service home-zsh-service-type
             (home-zsh-configuration
              (zshrc (list (local-file "files/dot_zshrc" "zshrc")))
              (zshenv (list (local-file "files/dot_zshenv" "zshenv")))
              (zprofile (list (local-file "files/dot_zprofile" "zprofile"))))))))
