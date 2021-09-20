(define-module (guix-ext packages theme)
  #:use-module (guix download)
  #:use-module (guix build-system gnu)
  #:use-module (gnu packages build-tools)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages)
  #:use-module (gnu packages gtk)
  #:use-module (gnu packages glib)
  #:use-module (gnu packages python)
  )


(define-public oomox
  (package
   (name "oomox")
   (version "1.13.3")
   (source (origin
            (method url-fetch)
            (uri "https://github.com/themix-project/oomox/archive/refs/tags/1.13.3.tar.gz")
            (sha256 (base32 "142w4046vqvv3zdxmvbk4cxqlpdycg6n3n8qwva60pp3b0x6sbg9"))
            )
   )
   (build-system gnu-build-system)
   (inputs
      (append
        `(("gtk3" ,gtk+)
        ("python3" ,python)
        ("python3-gobject" ,pygobject)
        ("gdk-pixbuf2" ,gdk-pixbuf)
        )
      )
   )
   (home-page "https://wayfire.org")
   (synopsis "Configuration Manager for Wayfire")
   (description synopsis)
   (license gpl3)
  )
)