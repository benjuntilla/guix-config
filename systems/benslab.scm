(use-modules (gnu) (nongnu packages linux) (nongnu packages firmware) (gnu system nss))
(use-service-modules base cups desktop networking ssh xorg pm dbus virtualization security-token)
(use-package-modules wm shells security-token cups gnome)

(define %disable-internal-webcam-rules
  (udev-rule
    "40-disable-internal-webcam.rules"
    (string-append "ACTION==\"add\", "
                   "ATTR{idVendor}==\"5986\", "
                   "ATTR{idProduct}==\"2113\", "
                   "RUN=\"/usr/bin/env sh -c 'echo 1>/sys/\\$devpath/remove'\"")))

(operating-system
 (kernel linux)
 (firmware (list linux-firmware))
 (locale "en_US.utf8")
 (timezone "America/Phoenix")
 (keyboard-layout (keyboard-layout "us"))
 (host-name "benslab")

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
   (udev-rules-service 'disable-internal-webcam %disable-internal-webcam-rules)
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
