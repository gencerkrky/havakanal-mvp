;; Elektrik tesisatı standartları/tabloları — SAF, AutoCAD bağımsız.
;; Kaynak: Elektrik İç Tesisleri Yönetmeliği, TS HD 60364.
;; Akım tabloları döşeme koşuluna göre ±%10 değişir -> sabit lookup, override edilebilir.

(setq *elk-v-1faz* 230.0)
(setq *elk-v-3faz* 400.0)
(setq *elk-sqrt3* 1.7320508)
(setq *elk-rho-bakir* 0.0175)   ; Ω·mm²/m

;; Eş zamanlılık (talep) faktörü — tesis tipine göre.
(setq *elk-kes*
  '(("konut" . 0.5) ("ofis" . 0.7) ("magaza" . 0.8) ("kuvvet" . 0.8)))

;; cosφ tipik.
(setq *elk-cosfi* 0.85)

;; Standart kablo kesitleri (mm²).
(setq *elk-kesit-list* '(1.5 2.5 4 6 10 16 25 35 50 70 95))

;; Kesit -> akım taşıma kapasitesi (A), bakır, boru içinde ~30°C.
(setq *elk-kesit-akim*
  '((1.5 . 17.5) (2.5 . 24) (4 . 32) (6 . 41) (10 . 57)
    (16 . 76) (25 . 101) (35 . 125) (50 . 151) (70 . 192) (95 . 232)))

;; Standart sigorta/kesici anma akımları (A).
(setq *elk-sigorta-list* '(6 10 16 20 25 32 40 50 63 80 100 125))

;; Gerilim düşümü % limitleri (devre tipine göre).
(setq *elk-vdrop-limit*
  '(("aydinlatma" . 1.5) ("priz" . 3.0) ("kuvvet" . 5.0)))

;; W/m² aydınlatma yük değerleri (mahal tipine göre, LED).
(setq *elk-wm2*
  '(("konut" . 12.0) ("ofis" . 18.0) ("magaza" . 20.0) ("depo" . 8.0)))

;; Sorti kuralları.
(setq *elk-max-priz-sorti* 7)
(setq *elk-max-ayd-sorti* 9)
