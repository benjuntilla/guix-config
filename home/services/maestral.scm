(define-module (home services maestral)
  #:use-module (gnu home services)
  #:use-module (gnu home services shepherd)
  #:use-module (guix gexp)
  #:export (home-maestral-service-type))

(define (home-maestral-shepherd-service _)
  (list
   (shepherd-service
    (provision '(maestral))
    (documentation "Run Maestral Dropbox client.")
    (start #~(make-forkexec-constructor '("maestral" "start")))
    (stop #~(make-kill-destructor)))))

(define home-maestral-service-type
  (service-type
   (name 'home-maestral)
   (extensions
    (list (service-extension home-shepherd-service-type
                            home-maestral-shepherd-service)))
   (default-value #t)
   (description "Start the Maestral Dropbox client.")))
