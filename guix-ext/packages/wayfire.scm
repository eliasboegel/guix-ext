(define-module (guix-ext packages wayfire)
  #:use-module (guix download)
  #:use-module (guix git-download)
  #:use-module (guix build-system meson)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix utils) ;; for substitute-keyword-arguments
  #:use-module (guix packages)
  #:use-module (gnu packages)
  #:use-module (gnu packages gtk)
  #:use-module (gnu packages glib)
  #:use-module (gnu packages pulseaudio)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages maths)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages freedesktop)
  #:use-module (gnu packages gtk)
  #:use-module (gnu packages xdisorg)
  #:use-module (gnu packages gl)
  #:use-module (gnu packages xorg)
  #:use-module (gnu packages xml)
  #:use-module (gnu packages gcc)
  #:use-module (gnu packages graphviz)
  #:use-module (gnu packages bash) ;; for use by wrap-program
  #:use-module (gnu packages wm)) ;; for wlroots


(define* (add-configure-flag package configure-flag)
  (substitute-keyword-arguments (package-arguments package)
                                ((#:configure-flags cf)
                                 `(cons ,configure-flag ,cf))))


(define-public wf-config
  (package
   (name "wf-config")
   (version "0.7.1")
   (source (origin
            (method url-fetch)
            (uri "https://github.com/WayfireWM/wf-config/releases/download/v0.7.1/wf-config-0.7.1.tar.xz")
            (sha256
             (base32
              "1w75yxhz0nvw4mlv38sxp8k8wb5h99b51x3fdvizc3yaxanqa8kx"))))
   (build-system meson-build-system)
   (native-inputs
    (append (package-native-inputs wlroots)
            `(("pkg-config" ,pkg-config))))
   (inputs
    (append (package-inputs wlroots)
            `(("wlroots" ,wlroots)
              ("libevdev" ,libevdev)
	            ("glm" ,glm)
              ("libxml2" ,libxml2))))
   (home-page "https://wayfire.org")
   (synopsis "Config library for Wayfire")
   (description "synopsis")
   (license license:expat)))

(define-public wf-shell
  ;;FIXME: unbundle gtk-layer-shell and gvc
  (package
   (name "wf-shell")
   (version "0.7.0")
   (source (origin
            (method url-fetch)
            (uri "https://github.com/WayfireWM/wf-shell/releases/download/v0.7.0/wf-shell-0.7.0.tar.xz")
            (sha256
             (base32
              "1isybm9lcpxwyf6zh2vzkwrcnw3q7qxm21535g4f08f0l68cd5bl"))))
   (build-system meson-build-system)
   (native-inputs
    (append
     (package-native-inputs wlroots)
     `(("pkg-config" ,pkg-config))))
   (inputs
      (append
          (package-inputs wf-config)
          (package-inputs wayfire)
          `(("gtkmm" ,gtkmm)
          ;("gobject-introspection" ,gobject-introspection)
          ("libpulse" ,pulseaudio)
          ("alsa-lib" ,alsa-lib)
          ("wf-config" ,wf-config)
          ("wayfire" ,wayfire)
          ;("wayland-client" ,wayland)
          ;("wayland-protocols" ,wayland-protocols)
          ("libgvc" ,graphviz)
          ("gtk-layer-shell" ,gtk-layer-shell))
      )
   )
   (arguments
     `(#:meson ,meson-next))
   (home-page "https://wayfire.org")
   (synopsis "Panel, dock and background applications for wayfire")
   (description synopsis)
   (license license:expat)))



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
            (sha256
             (base32
              "0cnq06fyzvhbf9a8vs6ifhjjkvqgjjh2d39x58chiv84cm3wza6d"))))
   (build-system meson-build-system)
   (native-inputs
    `(("gcc" ,gcc-8) ;; For <filesystem> include: https://github.com/loot/libloot/issues/56#issuecomment-498404104
                     ;; Also could avoid this input and specify c++17 maybe: https://stackoverflow.com/a/39231488
      ("pkg-config" ,pkg-config)))
   (inputs
    `(("bash" ,bash)
      ("glm" ,glm)
      ("wayland" ,wayland)
      ("wayland-protocols" ,wayland-protocols)
      ("cairo" ,cairo)
      ("libdrm" ,libdrm)
      ("mesa" ,mesa)
      ("libinput" ,libinput)
      ("libxkbcommon" ,libxkbcommon)
      ("libevdev" ,libevdev)
      ("wlroots" ,wlroots)
      ("libxml2" ,libxml2) ;; wf-config (git submodule)
      ("bash" ,bash)
      ;;("wf-config" ,wf-config)
      ))
;;   (arguments
;;    `(#:configure-flags `(,(string-append "-Dcpp_args=-I" (assoc-ref %build-inputs "wf-config") "/include/wayfire")
;;                          ,(string-append "-Dcpp_link_args=-ldl " (assoc-ref %build-inputs "wlroots") "/lib/libwlroots.so " (assoc-ref %build-inputs "wf-config") "/lib/libwf-config.so"))))
   (arguments
    `(#:tests? #f ;; file-parsing test fails for wf-config
      #:phases (modify-phases %standard-phases
                              (add-after 'unpack 'patch-shell-path
                               (lambda* (#:key inputs #:allow-other-keys)
                                 (substitute* "src/meson.build"
                                              (("/bin/sh") (string-append (assoc-ref inputs "bash") "/bin/bash")))
                                 (substitute* "src/core/core.cpp"
                                              (("/bin/sh") (string-append (assoc-ref inputs "bash") "/bin/bash"))))))))
   (home-page "https://wayfire.org")
   (synopsis "Wayland compositor")
   (description "Wayland compositor extendable with plugins.")
   (license license:expat)))
