# Otel Rezervasyon ve Konaklama Yönetim Sistemi

Veritabanı Yönetim Sistemleri dersi (2026-2027) dönem projesi.

> **Not:** Bu README şu an bir **proje planıdır**. Aşağıda anlatılan dosya ve veritabanı nesneleri henüz yazılmamıştır; her birinin gerçek durumu [Durum](#durum) bölümünde takip edilir. Bir madde ancak ilgili dosya depoya eklendikten sonra "Tamamlandı" olarak işaretlenir.

## Grup Üyeleri

| Ad Soyad | Öğrenci No |
|---|---|
| Behiye Basturk | 455129 |
| Hayrunnisa Sancar | 455137 |

## Proje Amacı

Bir otelin oda, oda tipi, sezon fiyatı, misafir, rezervasyon, konaklama, ek hizmet, ödeme, temizlik ve personel süreçlerini yöneten bir sistem geliştirmek. Projede ilişkisel veritabanı tasarımı, normalizasyon, çok tablolu SQL, tarih aralığı kontrolü, TRIGGER, STORED PROCEDURE, VIEW, TRANSACTION ve indeksleme uygulamalı olarak çalışılacaktır.

En kritik iş kuralı: **aynı oda, çakışan tarihlerde iki kez rezerve edilemez.** Bu kural yalnızca uygulama kodunda değil, veritabanı seviyesinde (TRIGGER / kontrol prosedürü) uygulanacaktır.

## Planlanan Teknoloji

| Katman | Plan |
|---|---|
| Veritabanı | MySQL 8.0 |
| Arka uç | Spring Boot (Java) |
| Ön yüz | HTML, CSS, JavaScript |
| Kimlik doğrulama | JWT, rol bazlı yetkilendirme (misafir, resepsiyon, yönetici) |
| API testi | Postman veya Swagger |

## Planlanan Depo Yapısı

Aşağıdaki klasör ve dosyalar **henüz oluşturulmamıştır**; çalışma ilerledikçe eklenecektir.

```
.
├── README.md                # (mevcut)
├── docs/
│   └── er-diagram.md        # (planlanan) ER diyagramı ve normalizasyon notları
├── database/
│   ├── otel_db.sql          # (planlanan) tablolar, trigger, prosedür, view, transaction, indeks, örnek veri
│   └── test_senaryolari.sql # (planlanan) çakışma, check-in/out, ROLLBACK, indeks testleri
├── backend/                 # (planlanan) REST API: Entity, Repository, Service, Controller
├── frontend/                # (planlanan) misafir, resepsiyon ve yönetici ekranları
└── postman/                 # (planlanan) API koleksiyonu
```

## Planlanan Veritabanı Tasarımı

### Tablolar (en az 13)

OdaTipi, Oda, SezonFiyati, Misafir, Kullanici, Personel, Rezervasyon, Konaklama, EkHizmet, KonaklamaHizmeti, Odeme, TemizlikKaydi, IslemLog.

Tüm tablolar en az 3NF olacak şekilde tasarlanacaktır. ER diyagramı ve normalizasyon adımları `docs/er-diagram.md` dosyasında yer alacaktır.

### Sabit değerler (ENUM) taslağı

- Oda durumu: `bos`, `dolu`, `temizlikte`, `bakimda`
- Rezervasyon durumu: `beklemede`, `onayli`, `iptal`, `tamamlandi`
- Ödeme türü: `nakit`, `kart`
- Rol: `misafir`, `resepsiyon`, `yonetici`

### Planlanan Trigger'lar (en az 3)

1. Çakışan tarihli rezervasyonu engelleme (ekleme ve güncelleme için).
2. Check-in'de odayı `dolu`, check-out'ta `temizlikte` yapma.
3. Rezervasyon ve ödeme işlemlerini `IslemLog` tablosuna yazma.

Çakışma kontrol mantığı, trigger'ların çağıracağı bir prosedürde toplanması düşünülmektedir. Çıkış günü ile başka bir rezervasyonun giriş gününün aynı olabilmesi, kapasite kontrolü ve eş zamanlı rezervasyon (satır kilitleme) durumları tasarım aşamasında netleştirilecektir.

### Planlanan Saklı Prosedürler (en az 3)

1. Tarih aralığı ve oda tipine göre boş odaları listeleme.
2. Konaklama toplam tutarı (gecelik sezon fiyatları + ek hizmetler, ödenen ve kalan).
3. Aylık doluluk oranı ve gelir raporu.

Ek olarak check-in ve check-out işlemleri için prosedürler yazılması planlanmaktadır. Check-out tek bir transaction içinde yapılacak, bir adım başarısız olursa `ROLLBACK` çalışacaktır.

### Planlanan View'lar (en az 2)

1. Bugün giriş ve çıkış yapacak misafirler.
2. Oda bazında güncel durum ve son temizlik tarihi.

### Planlanan İndeksler

Rezervasyon tarihleri, oda numarası ve misafir e-postası üzerinde indeks oluşturulacak; indeksli ve indekssiz sorgu süreleri karşılaştırılıp raporda gösterilecektir.

### Planlanan Örnek Veri

En az 20 oda, 50 misafir ve 200 rezervasyon. Sezon fiyatları 2026-2028 için tanımlanacaktır.

## Planlanan Arka Uç ve Ön Yüz

- **REST API:** GET/POST/PUT/DELETE; katmanlı mimari (Entity, Repository, Service, Controller); JWT ve rol bazlı yetkilendirme. Saklı prosedürler ve view'lar API üzerinden çağrılacaktır.
- **Misafir ekranı:** kayıt/giriş, boş oda arama, rezervasyon yapma/iptal, geçmiş konaklamalar.
- **Resepsiyon ekranı:** günlük giriş/çıkış listesi, check-in/check-out, ek hizmet ve ödeme.
- **Yönetici ekranı:** oda, oda tipi, sezon fiyatı, ek hizmet ve personel CRUD işlemleri, aylık rapor.

## Görev Dağılımı

| Görev | Sorumlu | Hedef Tarih |
|---|---|---|
| ER diyagramı taslağı (`docs/er-diagram.md`) | [...] | [...] |
| Tabloların yazılması (`otel_db.sql`) | [...] | [...] |
| Trigger'lar ve çakışma kontrol prosedürü | [...] | [...] |
| Diğer prosedürler, view'lar, transaction | [...] | [...] |
| Örnek veri | [...] | [...] |
| Test senaryoları ve indeks karşılaştırması | [...] | [...] |
| Arka uç API | [...] | [...] |
| Ön yüz | [...] | [...] |
| Rapor, Postman koleksiyonu, tanıtım videosu | [...] | [...] |

## Durum

Son güncelleme: 16 Ekim 2026

| Madde | Durum |
|---|---|
| README (proje planı) | Tamamlandı |
| ER diyagramı ve normalizasyon notları | Başlanmadı |
| `database/otel_db.sql` (tablolar) | Başlanmadı |
| Trigger'lar | Başlanmadı |
| Saklı prosedürler | Başlanmadı |
| View'lar | Başlanmadı |
| Transaction (check-out) | Başlanmadı |
| İndeksler | Başlanmadı |
| Örnek veri | Başlanmadı |
| `database/test_senaryolari.sql` | Başlanmadı |
| Arka uç API | Başlanmadı |
| Ön yüz | Başlanmadı |
| Postman koleksiyonu, rapor, tanıtım videosu | Başlanmadı |

