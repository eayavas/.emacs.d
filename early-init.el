;; Arayüz yüklenmeden önce gereksiz görsel elemanları kapat
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)

;; Pencere sıçramasını engelle
(setq frame-inhibit-implied-resize t)

;; İlk açılış boyutlarını ve fontu sabitle
(setq default-frame-alist
      '(
        (width . 110)
        (height . 45)
        (top . 50)
        (left . 100)))

(setq initial-frame-alist default-frame-alist)

;; Açılışta bellek limitini maksimuma (sonsuz) çıkar
(setq gc-cons-threshold most-positive-fixnum)

;; Uzak dosya kontrolünü (RegEx) açılış boyunca kapat
(defvar my-default-file-name-handler-alist file-name-handler-alist)
(setq file-name-handler-alist nil)
