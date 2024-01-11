;; This is an operating system configuration generated
;; by the graphical installer.
;;
;; Once installation is complete, you can learn and modify
;; this file to tweak the system configuration, and pass it
;; to the 'guix system reconfigure' command to effect your
;; changes.


;; Indicate which modules to import to access the variables
;; used in this configuration.
(use-modules (gnu) (nongnu packages linux))
(use-service-modules cups desktop networking ssh xorg pm dbus)
(use-package-modules wm shells security-token cups)

(operating-system
  (kernel linux)
  (firmware (list linux-firmware))
  (locale "en_US.utf8")
  (timezone "America/Phoenix")
  (keyboard-layout (keyboard-layout "us"))
  (host-name "benslab")

  ;; The list of user accounts ('root' is implicit).
  (users (cons* (user-account
                  (name "ben")
                  (comment "Ben")
                  (group "users")
                  (home-directory "/home/ben")
		  (shell (file-append zsh "/bin/zsh"))
                  (supplementary-groups '("wheel" "netdev" "audio" "video" "plugdev")))
                %base-user-accounts))

  ;; Packages installed system-wide.  Users can also install packages
  ;; under their own account: use 'guix search KEYWORD' to search
  ;; for packages and 'guix install PACKAGE' to install a package.
  (packages (append (list (specification->package "emacs")
                          (specification->package "nss-certs"))
                    %base-packages))

  (services 
   (cons* (service openssh-service-type)
          (service cups-service-type
		           (cups-configuration
					 (web-interface? #t)
					 (extensions
    					 (list cups-filters hplip-minimal))))
		  (udev-rules-service 'fido2 libfido2 #:groups '("plugdev"))
          (service screen-locker-service-type
                   (screen-locker-configuration
                    (name "swaylock")
                    (program (file-append swaylock "/bin/swaylock"))
                    (using-pam? #t)
                    (using-setuid? #f)))
          (service tlp-service-type
                   (tlp-configuration
                    (cpu-scaling-governor-on-ac (list "performance"))
                    (sched-powersave-on-bat? #t)))
          (service bluetooth-service-type)
;;          (set-xorg-configuration
;;           (xorg-configuration (keyboard-layout keyboard-layout)))
          (modify-services %desktop-services
                           (delete gdm-service-type)
                           (guix-service-type config => (guix-configuration
                                                         (inherit config)
                                                         (substitute-urls
                                                          (append (list "https://substitutes.nonguix.org")
                                                                  %default-substitute-urls))
                                                         (authorized-keys
                                                          (append (list (local-file "./nonguix-signing-key.pub"))
                                                                  %default-authorized-guix-keys)))))))

  (bootloader (bootloader-configuration
               (bootloader grub-efi-bootloader)
               (targets (list "/boot/efi"))
               (keyboard-layout keyboard-layout)))
  (mapped-devices (list (mapped-device
                         (source (uuid
                                  "55a0d1ee-fda8-4db4-82d2-1aa41fbf06b4"))
                         (target "cryptroot")
                         (type luks-device-mapping))))

  ;; The list of file systems that get "mounted".  The unique
  ;; file system identifiers there ("UUIDs") can be obtained
  ;; by running 'blkid' in a terminal.
  (file-systems (cons* (file-system
                         (mount-point "/boot/efi")
                         (device (uuid "E342-DBD5"
                                       'fat32))
                         (type "vfat"))
                       (file-system
                         (mount-point "/")
                         (device "/dev/mapper/cryptroot")
                         (type "ext4")
                         (dependencies mapped-devices)) %base-file-systems)))
