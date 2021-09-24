(define-module (guix-ext packages wayfire)
  #:use-module (guix download)
  #:use-module (guix git-download)
  #:use-module (guix build-system meson)
  #:use-module (gnu packages build-tools)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix utils)
  #:use-module (guix packages)
  #:use-module (gnu packages)
  #:use-module (gnu packages gtk)
  #:use-module (gnu packages glib)
  #:use-module (gnu packages pulseaudio)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages maths)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages freedesktop)
  #:use-module (gnu packages xdisorg)
  #:use-module (gnu packages gl)
  #:use-module (gnu packages xorg)
  #:use-module (gnu packages xml)
  #:use-module (gnu packages gcc)
  #:use-module (gnu packages gnome)
  #:use-module (gnu packages graphics)
  #:use-module (gnu packages image)
  #:use-module (gnu packages graphviz)
  #:use-module (gnu packages bash)
  #:use-module (gnu packages commencement)
  #:use-module (gnu packages wm))


(define* (add-configure-flag package configure-flag)
  (substitute-keyword-arguments (package-arguments package)
                                ((#:configure-flags cf)
                                 `(cons ,configure-flag ,cf))))


(define-public wayfire
  (package
   (name "wayfire")
   (version "0.7.0")
   (source (origin
            (method git-fetch)
            (uri (git-reference
                  (url (string-append "https://github.com/WayfireWM/wayfire"))
                  (recursive? #t)
                  (commit (string-append "v" version))))
            (sha256 (base32 "0cnq06fyzvhbf9a8vs6ifhjjkvqgjjh2d39x58chiv84cm3wza6d"))
            )
   )
   (build-system meson-build-system)
   (native-inputs
    `(("gcc" ,gcc-8)
      ("pkg-config" ,pkg-config)))
   (inputs
    `(("bash" ,bash)
      ("glm" ,glm)
      ("wayland_server" ,wayland)
      ("wayland_client" ,wayland)
      ("wayland_cursor" ,wayland)
      ("wayland-protocols" ,wayland-protocols)
      ("egl" ,egl-wayland)
      ("cairo" ,cairo)
      ("libdrm" ,libdrm)
      ("mesa" ,mesa)
      ("libinput" ,libinput)
      ("libnotify" ,libnotify)
      ("xkbcommon" ,libxkbcommon)
      ("libevdev" ,libevdev)
      ("wlroots" ,wlroots)
      ("pixman-1" ,pixman)
      ("libjpeg" ,libjpeg-turbo)
      ("libpng" ,libpng)
      ("libxml2" ,libxml2)
      ("bash" ,bash)
      ))
   (arguments
    `(#:tests? #f
      #:phases (modify-phases %standard-phases
                              (add-after 'unpack 'patch-shell-path
                               (lambda* (#:key inputs #:allow-other-keys)
                                 (substitute* "src/meson.build"
                                              (("/bin/sh") (string-append (assoc-ref inputs "bash") "/bin/bash")))
                                 (substitute* "src/core/core.cpp"
                                              (("/bin/sh") (string-append (assoc-ref inputs "bash") "/bin/bash"))))))
      ;#:configure-flags `(,(string-append "-Dcpp_args=-I" (assoc-ref %build-inputs "wf-config") "/include/wayfire")
      ;                    ,(string-append "-Dcpp_link_args=-ldl " (assoc-ref %build-inputs "wlroots") "/lib/libwlroots.so " (assoc-ref %build-inputs "wf-config") "/lib/libwf-config.so"))
      )                                        
   )

   (home-page "https://wayfire.org")
   (synopsis "Wayland compositor")
   (description "Wayland compositor extendable with plugins.")
   (license license:expat)))



;(define-public wayfire-config
;  (package
;   (name "wayfire-config")
;   (version "0.7.1")
;   (source (origin
;            (method url-fetch)
;            (uri "https://github.com/WayfireWM/wf-config/releases/download/v0.7.1/wf-config-0.7.1.tar.xz")
;            (sha256 (base32 "1w75yxhz0nvw4mlv38sxp8k8wb5h99b51x3fdvizc3yaxanqa8kx"))
;            )
;   )
;   (build-system meson-build-system)
;   (native-inputs
;    (append (package-native-inputs wlroots)
;            `(("pkg-config" ,pkg-config))))
;   (inputs
;    (append (package-inputs wlroots)
;            `(("wlroots" ,wlroots)
;              ("libevdev" ,libevdev)
;	            ("glm" ,glm)
;              ("libxml2" ,libxml2))))
;   (home-page "https://wayfire.org")
;   (synopsis "Configuration library for Wayfire")
;   (description "synopsis")
;   (license license:expat))
;)



(define-public wayfire-shell
  (package
   (name "wayfire-shell")
   (version "0.7.0")
   (source (origin
            (method url-fetch)
            (uri "https://github.com/WayfireWM/wf-shell/releases/download/v0.7.0/wf-shell-0.7.0.tar.xz")
            (sha256 (base32 "1isybm9lcpxwyf6zh2vzkwrcnw3q7qxm21535g4f08f0l68cd5bl"))
            )
   )
   (build-system meson-build-system)
   (native-inputs
    (append
     (package-native-inputs wlroots)
     `(("pkg-config" ,pkg-config))))
   (inputs
      (append
          (package-inputs wayfire)
          `(("gtkmm" ,gtkmm)
          ("libpulse" ,pulseaudio)
          ("alsa-lib" ,alsa-lib)
          ("wayfire" ,wayfire)
          ("libgvc" ,graphviz)
          ("gtk-layer-shell" ,gtk-layer-shell))
      )
   )
   (arguments
     `(#:meson ,meson-next))
   (home-page "https://wayfire.org")
   (synopsis "Panel, dock and background applications for Wayfire")
   (description synopsis)
   (license license:expat)))

(define-public swayfire
  (package
   (name "swayfire")
   (version "23-09-2021")
   (source (origin
            (method git-fetch)
            (uri (git-reference
                (url "https://github.com/Javyre/swayfire.git")
                (commit "a5c38cf50659665cd98599392a993731b13fa8aa"))
            )
            (file-name (git-file-name name version))
            (sha256
                 (base32 "0xpqjivnnmr7n7i8fm7cix83x9xrr8g9r1v98mj330djr3gmk8rn")
            )
   ))
   (native-inputs
    (append
     (package-native-inputs wayfire)
     `(("pkg-config" ,pkg-config)
      ("gcc", gcc-toolchain)
     ))
   )
   (build-system meson-build-system)
   (inputs
      (append
          (package-inputs wayfire)
          `(("wayfire" ,wayfire)
          ("wlroots" ,wlroots-2021-09-24)
          ("pixman-1" ,pixman)
          ("cairo" ,cairo))
      )
   )
   (arguments
     `(
      #:meson ,meson-next
      #:build-type ,"release"
      )
   )
   (home-page "https://github.com/Javyre/swayfire")
   (synopsis "Sway/I3 inspired tiling window manager for Wayfire")
   (description synopsis)
   (license license:gpl3)
  )
)



(define-public wlroots-2021-09-24
  (package (inherit wayfire)
    (name "wayfire-2021-09-24")
    (version "2021-09-24")
    (source (origin
              (method git-fetch)
            (uri (git-reference
                (url "https://github.com/swaywm/wlroots.git")
                (commit "d96d2f5f23e1096ed70dbbf286d5f9480957f667"))
            )
            (file-name (git-file-name name version))
              (sha256
               (base32
                "1b98qx6l1d4xnhjka68gbhmbfdcj48d0kw3wd1f05kg8d74qlqcr"))))
))

(define-public wayfire-2021-09-24
  (package (inherit wayfire)
    (name "wayfire-2021-09-24")
    (version "2021-09-24")
    (source (origin
              (method git-fetch)
            (uri (git-reference
                (url "https://github.com/Javyre/swayfire.git")
                (commit "5754aeb9765617e0eb296cac5303aaa82f69257e"))
            )
            (file-name (git-file-name name version))
              (sha256
               (base32
                "0mgli9n0xal4dyxjpjlnsjnayip0gylq438db5plkk4dajik0hrn"))))
))

(define-public swayfire-2021-09-24
  (package
   (name "swayfire-2021-09-24")
   (version "24-09-2021")
   (source (origin
            (method git-fetch)
            (uri (git-reference
                (url "https://github.com/Javyre/swayfire.git")
                (commit "8c2cda501a4c801406e6361f74c61e0e21ed99d3"))
            )
            (file-name (git-file-name name version))
            (sha256
                 (base32 "0gjjn7k1qqa8f0fsyyk4qabc3p2w39fx4zcigfsya85xgn587shl")
            )
   ))
   (native-inputs
    (append
     (package-native-inputs wayfire-2021-09-24)
     `(("pkg-config" ,pkg-config)
      ("gcc", gcc-toolchain)
     ))
   )
   (build-system meson-build-system)
   (inputs
      (append
          (package-inputs wayfire-2021-09-24)
          `(("wayfire" ,wayfire-2021-09-24)
          ("wlroots" ,wlroots-2021-09-24)
          ("pixman-1" ,pixman)
          ("cairo" ,cairo))
      )
   )
   (arguments
     `(
      #:meson ,meson-next
      #:build-type ,"release"
      )
   )
   (home-page "https://github.com/Javyre/swayfire")
   (synopsis "Sway/I3 inspired tiling window manager for Wayfire")
   (description synopsis)
   (license license:gpl3)
  )
)