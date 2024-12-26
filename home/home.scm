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
                          (name 'efraim-dfsg)
                          (url "https://git.sr.ht/~efraim/my-guix")
                          (branch "master")
                          (introduction
                           (make-channel-introduction
                            "61c9f87404fcb97e20477ec379b643099e45f1db"
                            (openpgp-fingerprint
                             "A28B F40C 3E55 1372 662D  14F7 41AA E7DC CA3D 8351"))))
                         (channel
                          (name 'guixrus)
                          (url "https://git.sr.ht/~whereiseveryone/guixrus")
                          (introduction
                           (make-channel-introduction
                            "7c67c3a9f299517bfc4ce8235628657898dd26b2"
                            (openpgp-fingerprint
                             "CD2D 5EAA A98C CB37 DA91  D6B0 5F58 1664 7F8B E551"))))
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
