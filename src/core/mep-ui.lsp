;; Genel kullanıcı sorgusu — domain-bağımsız. Modüller buradan türetir.

;; Pozitif sayı iste; iptal/boş veya <=0 -> nil.
(defun mep-ask-number (prompt-str / v)
  (setq v (getreal (strcat "\n" prompt-str)))
  (if (and v (> v 0.0)) v nil))

;; Serbest metin iste (boş kabul edilir).
(defun mep-ask-string (prompt-str)
  (getstring t (strcat "\n" prompt-str)))
