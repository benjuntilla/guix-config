;; This is an operating system configuration generated
;; by the graphical installer.
;;
;; Once installation is complete, you can learn and modify
;; this file to tweak the system configuration, and pass it
;; to the 'guix system reconfigure' command to effect your
;; changes.


;; Indicate which modules to import to access the variables
;; used in this configuration.
(use-modules (gnu) (nongnu packages linux) (nongnu packages firmware) (gnu system nss))
(use-service-modules base cups desktop networking ssh xorg pm dbus virtualization security-token)
(use-package-modules wm shells security-token cups gnome)

(operating-system
 (kernel linux)
 (firmware (list linux-firmware))
 (locale "en_US.utf8")
 (timezone "America/Phoenix")
 (keyboard-layout (keyboard-layout "us"))
 (host-name "chimaera")

 (name-service-switch %mdns-host-lookup-nss)

 ;; The list of user accounts ('root' is implicit).
 (users (cons* (user-account
                (name "ben")
                (comment "Ben")
                (group "users")
                (home-directory "/home/ben")
                (shell (file-append zsh "/bin/zsh"))
                (supplementary-groups '("wheel" "netdev" "audio" "video" "plugdev" "libvirt" "kvm")))
               %base-user-accounts))

 (services
  (cons*
   (udev-rules-service 'disable-internal-webcam %disable-internal-webcam-rule)
   (simple-service 'ratbagd dbus-root-service-type (list libratbag))
   (simple-service 'fwupd-dbus dbus-root-service-type
                   (list fwupd-nonfree))
   (service openssh-service-type)
   (service pcscd-service-type)
	 (service libvirt-service-type
            (libvirt-configuration
             (unix-sock-group "libvirt")))
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
                                 "cfb5f4cf-34c9-44cc-9374-324c8172a9cc"))
                        (target "cryptroot")
                        (type luks-device-mapping))))

 ;; The list of file systems that get "mounted".  The unique
 ;; file system identifiers there ("UUIDs") can be obtained
 ;; by running 'blkid' in a terminal.
 (file-systems (cons* (file-system
                       (mount-point "/boot/efi")
                       (device (uuid "5834-78CC"
                                     'fat32))
                       (type "vfat"))
                      (file-system
                       (mount-point "/")
                       (device "/dev/mapper/cryptroot")
                       (type "ext4")
                       (dependencies mapped-devices)) %base-file-systems)))
