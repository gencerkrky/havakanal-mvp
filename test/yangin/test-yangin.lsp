;; Yangın sprinkler testleri.

;; ceil yardımcısı
(hk-assert-equal "ceil 3.2 -> 4" 4 (yng-ceil 3.2))
(hk-assert-equal "ceil 3.0 -> 3" 3 (yng-ceil 3.0))

;; spacing: OH -> min(4.0, sqrt(12)=3.464) = 3.464
(hk-assert-close "OH spacing" 3.4641 (yng-spacing "OH"))
;; LH -> min(4.6, sqrt(21)=4.583) = 4.583
(hk-assert-close "LH spacing" 4.5826 (yng-spacing "LH"))

;; sprinkler debisi: OH -> 5.0 * 12.0 = 60 L/dk
(hk-assert-close "OH debi" 60.0 (yng-sprinkler-debi "OH"))
;; LH -> 2.25 * 21 = 47.25
(hk-assert-close "LH debi" 47.25 (yng-sprinkler-debi "LH"))

;; sprinkler sayısı: 10x10 m OH, s=3.464 -> ceil(10/3.464)=3 her eksen -> 9
(hk-assert-equal "10x10 OH count" 9 (yng-sprinkler-count 10.0 10.0 "OH"))

;; pipe schedule: OH, 8 sprinkler -> DN50 (<=10)
(hk-assert-equal "OH 8 spr -> DN50" 50 (yng-pipe-dn "OH" 8))
;; OH, 25 sprinkler -> DN65 (<=20? hayir) -> DN80 (<=40)
(hk-assert-equal "OH 25 spr -> DN80" 80 (yng-pipe-dn "OH" 25))
;; LH, 25 sprinkler -> DN65 (<=30)
(hk-assert-equal "LH 25 spr -> DN65" 65 (yng-pipe-dn "LH" 25))
;; OH cok buyuk -> tablo disi nil
(hk-assert-true "OH 500 spr -> nil" (null (yng-pipe-dn "OH" 500)))

;; grid: 1 eksen, boyut 10 m, s 3.464 -> n=ceil(10/3.464)=3 nokta
(setq xs (yng-axis-coords 10.0 3.4641))
(hk-assert-equal "axis 3 nokta" 3 (length xs))
;; grid noktaları: 10x10, origin (0 0), s 3.464 -> 9 nokta
(setq pts (yng-grid-points '(0.0 0.0) 10.0 10.0 3.4641))
(hk-assert-equal "grid 9 nokta" 9 (length pts))
