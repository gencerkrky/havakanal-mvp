;; Isı kaybı komutları. core (mep-*) araçlarını kullanır.

;; ISIKAYBI: tek mahal için elle girdiyle ısı kaybı + radyatör.
;; (Çizimden alan/duvar otomatik okuma v2; MVP elle girdi + opsiyonel alan okuma.)
(defun c:ISIKAYBI ( / bolge il mahal tic tdis dt
                    duvar-a pencere-a cati-a doseme-a yukseklik alan v-m3
                    durum n elemanlar res q-dilim dilim)
  (setq bolge (fix (mep-ask-number "TS825 bolge (1-6): ")))
  (setq il (mep-ask-string "Il (orn ankara): "))
  (setq mahal (mep-ask-string "Mahal tipi (salon/yatak/banyo...): "))
  (setq tic (isi-get-tic mahal))
  (setq tdis (isi-get-tdis (strcase il nil)))
  (setq dt (- tic tdis))
  (princ (strcat "\n  Tic=" (rtos tic 2 0) " Tdis=" (rtos tdis 2 0)
                 " dT=" (rtos dt 2 0) " K"))
  (setq alan (mep-ask-number "Taban alani (m2): "))
  (setq yukseklik (mep-ask-number "Kat yuksekligi (m) <2.7>: "))
  (if (null yukseklik) (setq yukseklik 2.7))
  (setq v-m3 (* alan yukseklik))
  (setq duvar-a (mep-ask-number "Dis duvar alani (m2): "))
  (setq pencere-a (mep-ask-number "Pencere alani (m2) <0>: "))
  (if (null pencere-a) (setq pencere-a 0.0))
  (setq cati-a (mep-ask-number "Cati alani (m2) <0>: "))
  (if (null cati-a) (setq cati-a 0.0))
  (setq doseme-a (mep-ask-number "Doseme alani (m2) <0>: "))
  (if (null doseme-a) (setq doseme-a 0.0))
  (setq durum (mep-ask-string "Infiltrasyon (sizdirmaz/normal/kose/mutfak) <normal>: "))
  (if (or (null durum) (= durum "")) (setq durum "normal"))
  (setq n (isi-get-n durum))
  ;; eleman listesi: (U A)
  (setq elemanlar
    (list (list (isi-u-deger bolge 'duvar) duvar-a)
          (list (isi-u-deger bolge 'pencere) pencere-a)
          (list (isi-u-deger bolge 'cati) cati-a)
          (list (isi-u-deger bolge 'doseme) doseme-a)))
  (setq res (isi-mahal-kayip elemanlar dt n v-m3))
  (princ (strcat "\n--- ISI KAYBI ---"
    "\n  Iletim (zamli): " (rtos (car res) 2 0) " W"
    "\n  Havalandirma:   " (rtos (cadr res) 2 0) " W"
    "\n  TOPLAM:         " (rtos (caddr res) 2 0) " W"
    " (" (rtos (isi-watt-to-kcal (caddr res)) 2 0) " kcal/h)"))
  ;; radyatör (panel, varsayılan 22 PKKP 500: ~2226 W/m @dT60)
  (princ (strcat "\n  Panel radyator (22/500) boyu: "
                 (itoa (isi-panel-boy (caddr res) 2226.0)) " mm"))
  (princ))
