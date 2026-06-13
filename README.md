# MEP Eklenti Paketi

AutoCAD için **MEP (Mekanik–Elektrik–Tesisat)** eklenti paketi (AutoLISP).
Düz AutoCAD'de çizen mühendislerin tekrarlayan işini (boyutlandırma, hesap, metraj, Excel raporu) otomatikleştirir.

> Durum: MVP. Şu an **Havalandırma** modülü çalışıyor. Mimari çok-modüllü kurulu; su/elektrik/yangın/ısı modülleri eklenecek.

## Modüller

| Modül | Durum | Komutlar |
|-------|-------|----------|
| **Havalandırma** (hava kanalı boyutlandırma + metraj) | ✅ MVP | `HKBOYUT`, `HKMETRAJ` |
| Su tesisatı | ⏳ planlı | — |
| Elektrik tesisatı | ⏳ planlı | — |
| Yangın tesisatı | ⏳ planlı | — |
| Isı kaybı/kazancı hesabı | ⏳ planlı | — |

## Kurulum (AutoCAD)

1. Bu depoyu indirin (**Code → Download ZIP** veya `git clone`).
2. ZIP'i bir klasöre açın (örn. `C:\MEP\`).
3. AutoCAD'i açın, komut satırına şunu yazın (yolu kendinize göre düzeltin):
   ```
   (load "C:/MEP/src/mep-load.lsp")
   ```
   > Windows yollarında `\` yerine `/` kullanın.
4. `=== MEP Paketi yuklendi. ===` mesajını görmelisiniz. Tüm modüllerin komutları hazırdır.

**Sadece bir modül** yüklemek isterseniz (örn. sadece havalandırma):
```
(load "C:/MEP/src/modules/havalandirma/hva-load.lsp")
```
Modül, çekirdeği (core) otomatik bulup yükler.

**Her açılışta otomatik:** `APPLOAD` → **Startup Suite** → `src/mep-load.lsp` ekleyin.

## Havalandırma Modülü Kullanımı

### HKBOYUT (kanal boyutlandırma)
1. `HKBOYUT` → kanal polyline'larını seç.
2. Yöntem: **Surtunme** (eşit sürtünme, Pa/m) veya **Hiz** (sabit hız, m/s).
3. Uygulama: **Ofis / Konut / Endustri** (hız uyarı eşiği).
4. Debi Q (m³/h), hedef ve en-boy oranını gir.
5. Cam kutu sonucu (boyut + V + Pa/m + mmSS/m + De + uyarılar) → **Kabul** veya **Degistir**.
6. Boyut çizime etiketlenir.

### HKMETRAJ (metraj)
1. `HKMETRAJ` → polyline'ları seç.
2. Fitting fire % gir (varsayılan %15).
3. Her segmentin boyutunu gir (örn. `400x300`).
4. CSV kayıt yerini seç → Excel'de açılır.

**Cam kutu yaklaşımı:** Hesap kara kutu değil — hız, basınç kaybı (Pa/m ve mmSS/m), eşdeğer çap, en-boy oranı görünür; sonuç override edilebilir.

## Mimari

```
src/
  core/                      Domain-bağımsız ortak araçlar (tüm modüller paylaşır)
    mep-units.lsp            birim dönüşümü (Pa<->mmSS)
    mep-csv.lsp              CSV yazma
    mep-ui.lsp               genel kullanıcı sorgusu
    mep-cad.lsp              genel CAD I/O (uzunluk, seçim, metin)   [AutoCAD]
    mep-core-load.lsp        core yükleyici
  modules/
    havalandirma/            Havalandırma modülü
      hva-standards.lsp      TS EN 1505 kademe, sac kalınlığı, parse
      hva-sizing.lsp         boyutlandırma
      hva-takeoff.lsp        metraj
      hva-rules.lsp          uyarı kuralları
      hva-commands.lsp       HKBOYUT, HKMETRAJ + modül UI
      hva-load.lsp           modül yükleyici (core'u garanti eder)
  mep-load.lsp               ANA yükleyici (core + tüm modüller)
test/                        Saf çekirdek testleri (core + havalandırma)
docs/superpowers/            Tasarım (spec) ve uygulama planları
```

**Yeni modül eklemek:** `modules/<disiplin>/` klasörü aç, `<önek>-*.lsp` dosyalarını ve `<önek>-load.lsp` yükleyicisini yaz, `mep-load.lsp`'ye bir `(load ...)` satırı ekle. Core'u (CSV, UI, birim, CAD) hazır kullanırsın.

## Doğrulama / Test

Saf çekirdek (boyutlandırma, metraj, yuvarlama, kurallar, birim, CSV) AutoCAD'siz test edilebilir:
```
(load "test/run-all-tests.lsp")
```
Sonuç: `=== SONUC: N PASS, 0 FAIL ===`

> ⚠️ **Mühendis kabul testi gerekli:** Havalandırma sürtünme katsayısı (`*hva-friction-k*`, `src/modules/havalandirma/hva-sizing.lsp`) yaklaşık bir bağıntıdır. Gerçek ductulator/nomogram sonuçlarıyla kalibre edilmelidir. Hız eşikleri ve sac kalınlığı tablosu da makine mühendisi onayı bekler.

## Yol Haritası (sonraki sürümler)

- Su / elektrik / yangın / ısı modülleri (her biri kendi domain araştırması + mühendis onayıyla)
- Havalandırmada: dirsek/T/redüksiyon fitting hesabı, yuvarlak kanal, tüm-ağ basınç toplama, .xlsx çıktı
- Lisanslama (ticarileşme aşaması)
- AutoCAD menü/ribbon

## Lisans

Henüz belirlenmedi (ticarileşme aşamasında eklenecek).
