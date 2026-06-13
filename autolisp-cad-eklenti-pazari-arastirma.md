# AutoLISP & CAD Eklenti Geliştirme — Pazar ve Teknoloji Araştırması

> Hazırlanma tarihi: 13 Haziran 2026
> Konu: MTYCAD benzeri AutoCAD eklentileri geliştirip satmak mümkün mü? Pazar nasıl, nasıl geliştirilir, MCP/CLI seçenekleri var mı?

---

## 1. İncelenen Kaynaklar (referans noktamız)

### MTYCAD (mtycad.com)
İncelenen iki kaynak da **MTYCAD** adlı bir Türk ürününe ait. Bu, AutoCAD üzerine kurulu, **MEP (Mekanik–Elektrik–Tesisat)** odaklı bir eklenti/LISP paketi. Sattığı modüller:

| Modül | Ne yapıyor |
|-------|-----------|
| Elektrik Tesisatı | Blok/layer kütüphanesi, armatür-priz-buat yerleştirme, güçleri Excel'e aktarma |
| Su Tesisatı | Temiz/pis/yağmur suyu, kat planı + otomatik kolon şeması |
| Isı Hesaplama | Tek tuşla ısı kaybı/kazancı hesabı → Excel |
| Radyatör & Yerden Isıtma | Simetri ve kopyalama araçları |
| Yangın Tesisatı | Otomatik/manuel çap verme, hızlı sprinkler yerleşimi |
| Havalandırma / Fancoil / VRF | Boru metrajı, kanal hesabı → Excel |
| Mimari Temizleme | Dosya optimizasyonu, layer yönetimi |

**Çıkarılan ders:** Bu tür ürünlerin değeri "CAD çizmek" değil, **mühendisin tekrarlayan işini (metraj, hesap, blok yerleştirme, Excel raporu) otomatikleştirmek**. YouTube videosu da (PVC boru gerçek ölçüde çizim + metraj + maliyet) tam bu hikayeyi anlatıyor. Yani satılan şey *zaman tasarrufu + hata azaltma*.

**Sonuç: Evet, bu tarz uygulamalar geliştirilip satılabilir — hatta bunun kurulu bir pazarı var.**

---

## 2. Bu Tür Uygulamalar Geliştirilebilir mi? (Teknoloji)

AutoCAD'i genişletmenin 4 ana yolu var. Hangisini seçeceğin işin büyüklüğüne bağlı.

### 2.1 AutoLISP / Visual LISP
- AutoCAD'i özelleştirmek için tasarlanmış, **en yaygın ve en kolay** dil.
- Tekrarlayan işleri otomatikleştirme, özel komut yaratma, basit uygulamalar için ideal.
- **Düşük giriş bariyeri** — MTYCAD gibi MEP araçlarının çoğunun çekirdeği budur.
- Zayıf yönü: büyük, karmaşık, lisanslı ticari ürün için tek başına sınırlı kalır.

### 2.2 .NET API (C# / VB.NET)
- Daha sağlam ve karmaşık uygulamalar için. Profesyonel ürün geliştirmenin standart yolu.
- LISP'e göre daha çok altyapı bilgisi ister ama "profesyonel ürün" potansiyeli çok daha yüksek.
- **Lisanslama, lisans anahtarı, kullanıcı yönetimi** gibi ticari özellikler için pratikte gerekli.

### 2.3 ObjectARX (C++)
- En güçlü ama **en zor** API. AutoCAD process'inin içine giren Windows DLL'leri.
- Hedef kitle: profesyonel/kurumsal yazılım geliştiriciler. Küçük ekip için aşırı ağır.

### 2.4 Python (pyautocad / COM otomasyonu)
- Hızlı prototip, script otomasyonu ve veri işleme için pratik.
- Ticari masaüstü eklenti dağıtımı için LISP/.NET kadar olgun değil; daha çok iç araç/otomasyon.

### 2.5 AutoCAD OEM (ayrı bir seçenek — "kendi CAD'ini sat")
- AutoCAD'in **beyaz etiketli (white-label)** versiyonu. Kendi markanla, kendi standalone uygulamanı yapıp **Autodesk'ten tamamen bağımsız**, kendi koşullarınla satabilirsin.
- Büyümek ve eklentiden öteye geçip kendi ürününü satmak isteyen için yol.

**Hızlı öneri:** Başlangıç için **AutoLISP** (hızlı değer üret), ticarileşince **.NET** ekle (lisanslama + UI), gerçekten ölçeklenirse **OEM** düşün.

---

## 3. Pazar Nasıl? (Talep & Rekabet)

### Talep var ve gerçek
- MEP/HVAC alanında **MagiCAD, FINE MEP, ALCAD, Allplan** gibi ciddi oyuncular var — yani mühendisler bu araçlara **para ödüyor**.
- FINE MEP'in **Türkçe dahil 12 dilde** olması, yazılım üreticilerinin **Türk pazarını dikkate aldığını** gösteriyor.
- Fiyat referansları (rakip CAD/HVAC yazılımı): ZWCAD ~320 $/yıl veya 899 $ ömürlük, Trimble MEP ~622 $/yıl. Yani **abonelik + ömürlük lisans** ikisi de pazarda kabul görüyor.

### Niş avantajı (MTYCAD'in oynadığı oyun)
- MagiCAD gibi global devler pahalı ve genel. **Yerel kurallara/standartlara uyarlanmış, Türkçe, uygun fiyatlı** bir araç ciddi bir boşluğu doldurur.
- Türkiye'de mimar + inşaat mühendisi + MEP tasarımcısı geniş bir kitle. Yerel yönetmelik (yangın, tesisat, ısı yalıtımı) ve Excel/metraj formatlarına uyum, global ürünlerin atladığı yer.

### Pazara giriş açısı
- **Dikey odak seç** (sadece yangın, ya da sadece elektrik). Genel "CAD aracı" yapma; spesifik bir mühendislik iş akışını uçtan uca çöz.
- Değer önerisi net olmalı: "X işini 2 saatte değil 5 dakikada yap + hatasız metraj + hazır Excel raporu".

---

## 4. Nasıl Satılır / Para Kazanılır? (Dağıtım & Lisanslama)

### 4.1 Autodesk App Store (resmi mağaza)
- Eklentini **ücretsiz / deneme (trial) / ücretli** olarak yayınlayabilirsin.
- Ödeme altyapısı **PayPal** üzerinden; satış yapacaksan PayPal hesabı şart (sadece ücretsiz/trial için gerekmez).
- Başvuru: uygulama başlığı, tipi (masaüstü/web), tür (add-on/extension/plugin), OS ve görseller → gönder, **24 saat içinde** yanıt.
- **Komisyon:** Autodesk şu an satışlardan **%0 komisyon** alıyor; ileride **%30'a kadar** komisyon alabileceğini belirtiyor. (Apple/Google'ın 70/30'una benzer bir gelecek senaryosu.)
- **ADN (Autodesk Developer Network)** üyeliği: neredeyse tüm Autodesk yazılımına geliştirme amaçlı erişim + destek.

### 4.2 App Store'un sınırı + akıllı çözüm
- App Store'un yerleşik lisanslama modeli **sınırlı**; özellikle **abonelik (SaaS)** modeli desteklenmiyor.
- **Pratik yöntem:** Eklentini App Store'a **ücretsiz** koy, ama tüm özellikleri açmak için kullanıcıdan **ayrı bir lisans anahtarı** al. Lisanslamayı kendin yönetirsin (örn. Cryptolens gibi üçüncü parti lisans servisleri AutoCAD eklentileri için kullanılıyor).
- Bu sayede **abonelik, deneme süresi, makine başı lisans** gibi modelleri sen kontrol edersin.

### 4.3 Kendi kanalından satış (MTYCAD modeli)
- Autodesk'e hiç bağlı olmadan, **kendi siteni** kur, lisans anahtarıyla sat (MTYCAD bunu yapıyor).
- Avantaj: %0 komisyon, fiyatı sen belirlersin, müşteri ilişkisi sende.
- Dezavantaj: pazarlama/güven/tahsilat tamamen senin sorumluluğunda.

**Önerilen model:** Kendi siteni + lisans anahtarı sistemini kur (gelirin tamamı sende), App Store'u da **ücretsiz vitrin/keşif kanalı** olarak kullan.

---

## 5. MCP / CLI / AI Entegrasyonu Var mı? (2025–2026 Güncel)

Bu en heyecan verici ve **yeni** kısım. Cevap: **Evet, hem MCP hem AI ile LISP üretimi aktif bir alan.**

### 5.1 AutoCAD için MCP (Model Context Protocol) Sunucuları
- **Autodesk resmi olarak MCP'yi destekliyor.** Autodesk, MCP'yi kurumsal güvenlik için olgunlaştıran taraflardan biri (2025 sonunda **CIMD** spesifikasyona dahil edildi → kurumsal kullanıma hazır hale geldi).
- **Autodesk Platform Services (APS) + MCP**: AI'ın tasarım verilerine ve projelere erişmesini sağlıyor (Autodesk University 2025 oturumu).
- **Topluluk MCP sunucuları mevcut:**
  - `ahmetcemkaraca/AutoCAD_MCP` — AutoCAD 2025 için 2D/3D DWG üretimi + VS Code'da kodlama. (Bir Türk geliştirici!)
  - `vigneshpbmenon/autocad-mcp-server` — doğal dille çizim, layer yönetimi, çizim analizi.
  - İlk MCP sunucuları AutoCAD 2025'i **doğal dil** ile kontrol ediyor: 7 çalışan araç production-ready, 25+ bileşen geliştirme aşamasında.
- **AutoCAD LT** bile MCP üzerinden, **AutoLISP kodu üretip çalıştırarak** doğal dille kontrol edilebiliyor — mühendislik çizimleri, P&ID diyagramları, teknik dokümantasyon.

**Fırsat:** Senin eklentine bir **MCP katmanı** eklersen, kullanıcı "3 katlı binaya yangın sprinkleri yerleştir ve metrajı çıkar" gibi doğal dil komutuyla aracı kullanabilir. Bu, klasik LISP eklentilerine göre **büyük bir farklılaşma**.

### 5.2 AI ile AutoLISP Kod Üretimi (CLI'ya en yakın pratik)
- **ChatGPT / Claude / Copilot ile AutoLISP üretmek** artık olgun bir pratik — Udemy/Skillshare kursları, IMAGINiT/GrabCAD tutorial'ları var.
- Tipik akış: AI'a istek → LISP kodu üret → Notepad++/AutoCAD komut satırında test et → düzelt.
- Yaygın otomasyonlar: layer oluşturma, toplu purge, dosya temizleme, layout import, elemanlar arası döngüyle blok yerleştirme.
- **"Kodlama bilmeden LISP üretme"** kursları popüler → yani pazarın bir kısmı *kendi LISP'ini AI ile yazmak isteyen mühendisler*. Bu hem rakip hem fırsat (onlara hazır, test edilmiş, desteklenen ürün satabilirsin).

### 5.3 CLI tarafı
- AutoCAD'in doğrudan "resmi public CLI"si yok; otomasyon **AutoCAD komut satırı + script (.scr) + LISP** ya da **APS Design Automation API** (bulutta başsız/headless AutoCAD çalıştırma) ile yapılır.
- **APS Design Automation**: Sunucuda/bulutta AutoCAD'i kullanıcı arayüzü olmadan çalıştırıp toplu işlem yaptırma — SaaS ürün kurmak istersen asıl güçlü yol burası.

---

## 6. Strateji Önerisi (Sıfırdan başlayan biri için yol haritası)

1. **Niş seç.** Tek bir mühendislik iş akışı (örn. yangın tesisatı metrajı veya elektrik yük hesabı). Genel CAD aracı yapma.
2. **MVP'yi AutoLISP ile yap.** Bir mühendisin 2 saatini 5 dakikaya indiren tek bir "tek tuş" özelliği. Çıktı = Excel raporu/metraj (MTYCAD'in kazandığı nokta).
3. **Lisanslamayı ekle.** .NET + üçüncü parti lisans servisi (örn. Cryptolens) ile anahtar tabanlı kilit. Deneme süresi koy.
4. **İki kanaldan dağıt.** Kendi sitende sat (gelir %100 sende) + Autodesk App Store'da ücretsiz vitrin (keşif).
5. **AI/MCP ile farklılaş.** Aracına doğal dil katmanı (MCP server) ekle → "Claude'a söyle, çizimi yapsın". 2026'da bu, rakiplerin çoğunda yok.
6. **Yerelleştir.** Türkçe arayüz + Türk yönetmeliklerine (yangın, ısı yalıtımı, tesisat) uygun hesap = global devlerin atladığı boşluk.

### Risk/Dikkat
- AutoCAD sürüm uyumu (her yıl yeni sürüm) bakım yükü getirir.
- Lisans kırma riski → lisans servisini ciddiye al.
- Global rakipler (MagiCAD vb.) güçlü; **fiyat + yerellik + AI** ile ayrış, kafa kafaya gitme.

---

## 6.5. Pazar Hacmi, Fiyatlar ve Gelir Tahmini (Sayılarla)

> Eklenme tarihi: 13 Haziran 2026. Aşağıdaki pazar ve kitle verileri kaynaklıdır; gelir senaryosu bu verilerden **türetilmiş tahmindir**, doğrulanmış benchmark değildir.

### Global pazar büyüklüğü

| Metrik | Değer | Kaynak |
|--------|-------|--------|
| Global MEP yazılım pazarı (2026) | **~1,6 milyar $** | market.us |
| 2035 projeksiyonu | ~4,1 milyar $ (CAGR %10,9) | market.us |
| Daha geniş MEP mühendislik yazılımı (2024) | 3,5–6,5 milyar $ | GMInsights / VerifiedMarketReports |
| Yıllık büyüme | **%8–11** | çoğu rapor mutabık |

Pazar küçülmüyor; çift haneli büyüyor. Sizin nişiniz (Türkiye + tek disiplin) bunun küçük bir parçası ama o parça için bile kitle yeterli.

### Türkiye hedef kitlesi (TAM)

31 Aralık 2025 itibarıyla TMMOB üyesi:
- İnşaat mühendisi: **164.234**
- Mimar: **98.872**
- TMMOB toplam: **729.401** (+ Makine + Elektrik mühendisleri = MEP çekirdeği)

**Gerçekçi hedef havuz:** Aktif proje çizen MEP/mekanik/elektrik tasarımcısı ≈ **15.000–40.000 kişi**. Bunun **%1–3'ünü** kapmak (≈150–1.200 müşteri) anlamlı bir gelir tabanıdır.

### Fiyat referansları

| Ürün | Fiyat modeli |
|------|--------------|
| ZWCAD | ~320 $/yıl veya 899 $ ömürlük |
| Trimble MEP | ~622 $/yıl |
| MagiCAD | Fiyatı gizli/teklif usulü, modül başı abonelik (3–36 ay) — premium segment |
| **Önerilen konum (yerel/uygun)** | **modül başı 3.000–8.000 TL/yıl** veya **8.000–20.000 TL ömürlük** |

### Kaba gelir senaryosu (türetilmiş tahmin)

200 müşteri × 5.000 TL/yıl ≈ **1.000.000 TL/yıl** tekrarlayan gelir. Kendi sitenizden satışta komisyon yok (gelir %100 sizde); Autodesk App Store şu an %0 komisyon. Tek geliştiriciyle döner; 500+ müşteride küçük ekip işi.

⚠️ Tekil eklenti geliştiricilerinin Autodesk App Store kazançları **kamuya açık değildir** (Autodesk yayınlamıyor). Yukarıdaki rakam pazar + kitle + rakip fiyatından türetilmiş senaryodur.

---

## 7. Özet Cevaplar

| Soru | Cevap |
|------|-------|
| Bu tür uygulamalar geliştirilebilir mi? | **Evet.** AutoLISP/.NET/ObjectARX/Python/OEM seçenekleri var. Başlangıç için AutoLISP. |
| Pazar var mı? | **Var.** MEP/HVAC araçlarına ödeme yapılıyor; Türkçe + yerel + uygun fiyat bir boşluk. |
| Nasıl satılır? | Kendi siten + lisans anahtarı (gelir %100) **ve/veya** Autodesk App Store (şu an %0 komisyon, ileride ≤%30). |
| MCP var mı? | **Evet.** Autodesk resmi destekliyor; topluluk MCP sunucuları (biri Türk geliştirici) çıkmış. Doğal dille AutoCAD kontrolü mümkün. |
| CLI var mı? | Resmi public CLI yok; ama script + LISP + **APS Design Automation API** (bulutta headless AutoCAD) ile otomasyon yapılır. |
| AI ile LISP üretilir mi? | **Evet**, ChatGPT/Claude ile olgun bir pratik. Hem rakip hem fırsat. |

---

## Kaynaklar

- [MTYCAD Ürünler](https://www.mtycad.com/p/urunler.html)
- [MTYCAD Tanıtım Videosu (YouTube)](https://www.youtube.com/watch?v=Sg_yWZczDsM)
- [AutoCAD Plugin Software Licensing — Cryptolens](https://cryptolens.io/2019/01/autocad-plugin-software-licensing/)
- [How to sell Design Automation Software based on AutoCAD APIs — Autodesk Community](https://forums.autodesk.com/t5/visual-lisp-autolisp-and-general/how-to-sell-design-automation-software-developed-based-on/td-p/8348279)
- [Developing an AutoCAD Plug-in vs. AutoCAD OEM — TechSoft3D](https://www.techsoft3d.com/resources/blog/developing-an-autocad-plug-in-vs-developing-with-autocad-oem/)
- [AutoLISP and Visual LISP — Autodesk ObjectARX Help](https://help.autodesk.com/view/OARX/2024/ENU/?guid=GUID-49AAEA0E-C422-48C4-87F0-52FCA491BF2C)
- [AutoLisp vs ObjectARX vs .NET — CADTutor Forum](https://www.cadtutor.net/forum/topic/48543-autolisp-visual-lisp-and-vba-vs-objectarx-and-net/)
- [ObjectARX — Wikipedia](https://en.wikipedia.org/wiki/ObjectARX)
- [Autodesk App Store — Publisher FAQ (PDF)](https://damassets.autodesk.net/content/dam/autodesk/www/adn/pdf/frequently-asked-questions.pdf)
- [Autodesk App Store Publisher Center — APS](https://aps.autodesk.com/app-store/publisher-center)
- [Autodesk App Store Product Guidelines](https://apps.autodesk.com/Publisher/ProductGuidelines)
- [AutoCAD_MCP — GitHub (ahmetcemkaraca)](https://github.com/ahmetcemkaraca/AutoCAD_MCP)
- [AutoCAD MCP Server — LobeHub](https://lobehub.com/mcp/vigneshpbmenon-autocad-mcp-server)
- [Autodesk MCP Servers — Autodesk AI](https://www.autodesk.com/solutions/autodesk-ai/autodesk-mcp-servers)
- [How Autodesk helped make MCP enterprise-ready — Autodesk News](https://adsknews.autodesk.com/en/views/how-autodesk-helped-make-the-model-context-protocol-enterprise-ready/)
- [Equip AI with Access to Your Design Data (MCP + APS) — Autodesk University](https://www.autodesk.com/autodesk-university/class/Equip-AI-with-Access-to-Your-Design-Data-and-Projects-Model-Context-Protocol-Autodesk-Platform-Services-2025)
- [9 MCP Servers for CAD with AI — Snyk](https://snyk.io/articles/9-mcp-servers-for-computer-aided-drafting-cad-with-ai/)
- [Use ChatGPT to Create AutoLISP Code (YouTube)](https://www.youtube.com/watch?v=cSbwZ98fO3w)
- [Using ChatGPT to Write AutoCAD LISP Routines — IMAGINiT](https://resources.imaginit.com/support-blog/using-chatgpt-to-write-autocad-lisp-routines-from-idea-to-execution)
- [FINE MEP (Türkçe dahil 12 dil) — Wikipedia](https://en.wikipedia.org/wiki/FINE_MEP)
- [Top HVAC Design Software 2026 — ZWSOFT](https://www.zwsoft.com/blog/hvac-design-software)
- [MEP Software Market Size (CAGR %10,9) — market.us](https://market.us/report/mep-software-market/)
- [MEP Engineering Software Market — VerifiedMarketReports](https://www.verifiedmarketreports.com/product/mep-engineering-software-market/)
- [MEP Software Market — GMInsights](https://www.gminsights.com/industry-analysis/mechanical-electrical-and-plumbing-mep-software-market)
- [TMMOB Üye Sayısı 729.401 (2025 sonu)](http://www.tmmob.org.tr/icerik/tmmobye-bagli-odalarin-uye-sayisi-660-bin-oldu)
- [2026 Mühendis ve Mimar Sayıları — The Şantiye](https://thesantiye.com/2026-yili-mimar-ve-muhendis-sayilari/)
- [MagiCAD Fiyat Teklifi (modül başı abonelik)](https://www.magicad.com/get-a-quote/)
- [Autodesk App Store Publisher FAQ](https://apps.autodesk.com/en/Public/FAQ)
