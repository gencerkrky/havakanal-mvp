;; Isı kaybı + radyatör hesabı — SAF, AutoCAD bağımsız.

(defun isi-ceil (x / f) (setq f (fix x)) (if (> x f) (1+ f) f))

;; İletim kaybı: Σ (U*A) * ΔT. elemanlar: ((U A) ...). dt = Tic - Tdis.
(defun isi-iletim (elemanlar dt / toplam)
  (setq toplam 0.0)
  (foreach e elemanlar
    (setq toplam (+ toplam (* (car e) (cadr e)))))
  (* toplam dt))

;; İletim kaybına zam (yön/kuşak yerine emniyet katsayısı).
(defun isi-iletim-zamli (q-iletim)
  (* q-iletim *isi-zam*))

;; Havalandırma/infiltrasyon kaybı: 0.34 * n * V * ΔT (W).
(defun isi-havalandirma (n v-m3 dt)
  (* *isi-hava-cp* n v-m3 dt))

;; Mahal toplam kaybı. Dönüş: (Q_iletim_zamli Q_hav Q_toplam).
(defun isi-mahal-kayip (elemanlar dt n v-m3 / qi qiz qh)
  (setq qi (isi-iletim elemanlar dt))
  (setq qiz (isi-iletim-zamli qi))
  (setq qh (isi-havalandirma n v-m3 dt))
  (list qiz qh (+ qiz qh)))

;; ΔT düzeltmesi: Q = Q0 * (dt_gercek/dt0)^1.3 (radyatör katalog koşulu farklıysa).
(defun isi-duzelt-dt (q0 dt-gercek dt0)
  (* q0 (expt (/ dt-gercek dt0) 1.3)))

;; Dilimli radyatör: gerekli ısı (W) / dilim gücü (W) -> dilim adedi (yukarı).
(defun isi-dilim-sayisi (q-w q-dilim-w)
  (isi-ceil (/ q-w q-dilim-w)))

;; Panel radyatör boyu (mm): Q (W) / metre-başı güç (W/m), ticari boya yuvarla.
(setq *isi-panel-boy-list* '(400 600 800 1000 1200 1400 1600 1800 2000 2400 3000))
(defun isi-panel-boy (q-w q-metre-w / ham result)
  (setq ham (* 1000.0 (/ q-w q-metre-w)))   ; m -> mm
  (setq result nil)
  (foreach b *isi-panel-boy-list*
    (if (and (null result) (>= b ham))
      (setq result b)))
  (if (null result) (last *isi-panel-boy-list*) result))
