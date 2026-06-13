# HavaKanal MVP

AutoCAD için havalandırma (hava kanalı) **boyutlandırma + metraj** eklentisi (AutoLISP).
Düz AutoCAD'de tek çizgi (polyline) ile çizen makine mühendisleri için.

> Durum: MVP. Hesap formülleri mühendis testiyle doğrulanma aşamasında (bkz. [Doğrulama](#doğrulama)).

## Ne yapar?

İki komut:

| Komut | İşlev |
|-------|-------|
| `HKBOYUT` | Polyline(leri) seç → debi (m³/h) + yöntem gir → dikdörtgen kanal boyutunu hesaplar, TS EN 1505 standardına yuvarlar, çizime etiketler |
| `HKMETRAJ` | Polyline(leri) seç → boyut + uzunluktan yüzey alanı (m²) ve sac ağırlığı (kg) hesaplar → CSV'ye döker |

**Cam kutu yaklaşımı:** Hesap "kara kutu" değil — hız (V), basınç kaybı (Pa/m ve mmSS/m), eşdeğer çap (De) ve en-boy oranı her zaman gösterilir. Sonucu kabul edebilir veya elle değiştirebilirsiniz (override).

**Uyarılar:** En-boy oranı > 4:1, aşırı hız (uygulama tipine göre) gibi durumlarda sarı bayrak gösterir (engellemez).

## Kurulum (AutoCAD)

1. Bu depoyu indirin (GitHub'da **Code → Download ZIP** veya `git clone`).
2. ZIP'i bir klasöre açın (örn. `C:\HavaKanal\`).
3. AutoCAD'i açın.
4. Komut satırına şunu yazın (yolu kendi klasörünüze göre düzeltin):
   ```
   (load "C:/HavaKanal/src/hk-load.lsp")
   ```
   > Windows yollarında `\` yerine `/` kullanın veya `\\` yazın.
5. Şu mesajı görmelisiniz: `HavaKanal MVP yuklendi. Komutlar: HKBOYUT, HKMETRAJ`
6. Artık `HKBOYUT` ve `HKMETRAJ` komutlarını kullanabilirsiniz.

**Her açılışta otomatik yükleme** isterseniz: AutoCAD'de `APPLOAD` → **Startup Suite** → `src/hk-load.lsp` ekleyin.

## Kullanım

### HKBOYUT (boyutlandırma)
1. `HKBOYUT` yazın.
2. Kanal polyline'larını seçin.
3. Yöntem seçin: **Surtunme** (eşit sürtünme, Pa/m hedefi) veya **Hiz** (sabit hız, m/s hedefi).
4. Uygulama tipi: **Ofis / Konut / Endustri** (hız uyarı eşiği için).
5. Debi Q (m³/h), hedef (Pa/m veya m/s) ve en-boy oranını girin.
6. Sonucu inceleyin (cam kutu) → **Kabul** veya **Degistir**.
7. Boyut çizime etiketlenir.

### HKMETRAJ (metraj)
1. `HKMETRAJ` yazın.
2. Polyline'ları seçin.
3. Fitting fire yüzdesini girin (varsayılan %15).
4. Her segment için boyutu girin (örn. `400x300`).
5. CSV kayıt yerini seçin → metraj Excel'de açılır.

## Doğrulama

Saf hesap çekirdeği (boyutlandırma, metraj, yuvarlama, kurallar) AutoCAD'den bağımsız test edilebilir:

```
(load "test/run-all-tests.lsp")
```
Sonuç: `=== SONUC: N PASS, 0 FAIL ===`

> ⚠️ **Mühendis kabul testi gerekli:** Sürtünme katsayısı (`*hk-friction-k*`, `src/hk-core-sizing.lsp`) yaklaşık bir bağıntıdır. Gerçek ductulator/nomogram sonuçlarıyla karşılaştırılıp kalibre edilmelidir. Hız eşikleri ve sac kalınlığı tablosu da makine mühendisi onayı bekler.

## Mimari

```
src/
  hk-standards.lsp     TS EN 1505 kademeler, yuvarlama, sac kalınlığı, Pa↔mmSS, boyut parse
  hk-core-sizing.lsp   Boyutlandırma (alan, eşdeğer çap, sabit hız, eşit sürtünme)
  hk-core-takeoff.lsp  Metraj (yüzey alanı, ağırlık, fire %)
  hk-rules.lsp         Uyarı kuralları
  hk-export-csv.lsp    CSV yazma
  hk-cad-read.lsp      AutoCAD okuma (uzunluk, seçim)   [AutoCAD gerekir]
  hk-cad-write.lsp     AutoCAD yazma (etiket)            [AutoCAD gerekir]
  hk-ui.lsp            Komut satırı etkileşimi
  hk-commands.lsp      HKBOYUT, HKMETRAJ
  hk-load.lsp          Yükleyici (giriş noktası)
test/                  Saf çekirdek testleri
docs/superpowers/      Tasarım (spec) ve uygulama planı
```

## Kapsam (MVP) ve sonraki sürümler

**Bu sürüm:** Düz dikdörtgen kanal, eşit sürtünme / sabit hız, standart yuvarlama, metraj, CSV, uyarılar.

**Sonraki (v2):** Dirsek/T/redüksiyon fitting hesabı, yuvarlak/spiral kanal, tüm-ağ basınç toplama, .xlsx çıktı, lisanslama, doğrudan etiket↔segment eşleme.

## Lisans

Henüz belirlenmedi (ticarileşme aşamasında eklenecek).
