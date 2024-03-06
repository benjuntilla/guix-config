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
			 (gnu home services sound)
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
  (services
   (list
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
              (ssh-support? #t)
              (default-cache-ttl 34560000)
              (max-cache-ttl 34560000)
              (extra-content "allow-emacs-pinentry")))
    (service home-zsh-service-type
             (home-zsh-configuration
              (zshrc (list (local-file "files/dot_zshrc" "zshrc")))
              (zshenv (list (local-file "files/dot_zshenv" "zshenv")))
              (zprofile (list (local-file "files/dot_zprofile" "zprofile"))))))))
