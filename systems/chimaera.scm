(define-module (systems chimaera))
(use-modules (gnu) (nongnu packages linux) (gnu system nss) (gnu system accounts))
(use-service-modules base cups desktop networking ssh xorg pm dbus security-token shepherd nix containers)
(use-package-modules wm shells security-token cups gnome linux python package-management)

(define %wooting-rules
  (udev-rule
    "70-wooting.rules"
    (string-append "SUBSYSTEM==\"hidraw\", ATTRS{idVendor}==\"03eb\", ATTRS{idProduct}==\"ff01\", TAG+=\"uaccess\"\n"
                   "SUBSYSTEM==\"usb\", ATTRS{idVendor}==\"03eb\", ATTRS{idProduct}==\"ff01\", TAG+=\"uaccess\"\n"
                   "SUBSYSTEM==\"hidraw\", ATTRS{idVendor}==\"03eb\", ATTRS{idProduct}==\"2402\", TAG+=\"uaccess\"\n"
                   "SUBSYSTEM==\"hidraw\", ATTRS{idVendor}==\"03eb\", ATTRS{idProduct}==\"ff02\", TAG+=\"uaccess\"\n"
                   "SUBSYSTEM==\"usb\", ATTRS{idVendor}==\"03eb\", ATTRS{idProduct}==\"ff02\", TAG+=\"uaccess\"\n"
                   "SUBSYSTEM==\"hidraw\", ATTRS{idVendor}==\"03eb\", ATTRS{idProduct}==\"2403\", TAG+=\"uaccess\"\n"
                   "SUBSYSTEM==\"hidraw\", ATTRS{idVendor}==\"31e3\", TAG+=\"uaccess\"\n"
                   "SUBSYSTEM==\"usb\", ATTRS{idVendor}==\"31e3\", TAG+=\"uaccess\"")))

(define %uinput-rules
  (udev-rule
    "90-uinput.rules"
    "KERNEL==\"uinput\", GROUP=\"input\", MODE=\"0660\", TAG+=\"uaccess\""))

(define %sudoers-file
  (plain-file "sudoers-file" "root ALL=(ALL) ALL
%wheel ALL=(ALL) NOPASSWD: ALL"))

(define fan-control-service-type
  (service-type
    (name 'fan-control)
    (description "Run the Framework laptop fan control utility")
    (extensions
     (list (service-extension shepherd-root-service-type
                             (lambda _
                               (list (shepherd-service
                                      (provision '(fan-control))
                                      (documentation "Run Framework laptop fan control daemon")
                                      (requirement '(user-processes))
                                      (start #~(make-forkexec-constructor
                                                (list #$(file-append python "/bin/python3")
                                                     "/usr/bin/fw-fanctrl" "run")
                                                #:log-file "/var/log/fw-fanctrl.log"
                                                #:environment-variables
                                                '("PATH=/usr/bin:/run/current-system/profile/bin:/bin")))
                                      (stop #~(make-kill-destructor))
                                      (respawn? #t)))))))
    (default-value '())))

(operating-system
 (kernel linux)
 (kernel-loadable-modules (list v4l2loopback-linux-module))
 (firmware (cons* linux-firmware amdgpu-firmware radeon-firmware amd-microcode %base-firmware))
 (locale "en_US.utf8")
 (timezone "America/Phoenix")
 (keyboard-layout (keyboard-layout "us"))
 (host-name "chimaera")
 (sudoers-file %sudoers-file)

 (name-service-switch %mdns-host-lookup-nss)

 ;; The list of user accounts ('root' is implicit).
 (users (cons* (user-account
                (name "ben")
                (comment "Ben")
                (group "users")
                (home-directory "/home/ben")
                (shell (file-append fish "/bin/fish"))
                (supplementary-groups '("cgroup" "render" "wheel" "netdev" "audio" "video" "plugdev" "kvm" "input")))
               %base-user-accounts))

 ;; Define the render group for ROCm/GPU compute access
 (groups (cons (user-group (system? #t) (name "render"))
               %base-groups))

 (packages (append (list nix)
                   %base-packages))

 (services
  (cons*
   (service nix-service-type
            (nix-configuration
             (sandbox #t)))
   (simple-service 'fw-fanctrl-config etc-service-type
                  `(("fw-fanctrl/config.json" ,(local-file "fw-fanctrl-config.json"))))
   (service fan-control-service-type)
   (service iptables-service-type)  ;; required for podman
   (service rootless-podman-service-type
            (rootless-podman-configuration
             (subgids
              (list (subid-range (name "ben"))))
             (subuids
              (list (subid-range (name "ben"))))))
   (udev-rules-service 'wooting %wooting-rules)
   (udev-rules-service 'uinput %uinput-rules)
   (simple-service 'ratbagd dbus-root-service-type (list libratbag))
   (service openssh-service-type)
   (service pcscd-service-type)
	 ;; (service libvirt-service-type
   ;;          (libvirt-configuration
   ;;           (unix-sock-group "libvirt")))
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
             (cpu-scaling-governor-on-ac (list "powersave"))
             (cpu-scaling-governor-on-bat (list "powersave"))))
   (service bluetooth-service-type
            (bluetooth-configuration
             (auto-enable? #t)))
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
