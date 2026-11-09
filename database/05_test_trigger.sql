-- =====================================================================
-- 05_test_trigger.sql  (videoda gosterilecek testler)
-- ONEMLI: Hepsini TEK SEKMEDE ve SIRAYLA calistir. Her satiri ayri ayri
-- calistir (imleci komutun uzerine koy, Ctrl+Enter). HATA BEKLENEN
-- testlerde kirmizi hata gormek DOGRU sonuctur.
-- @a ve @d degiskenleri ayni oturumda (sekmede) kalir.
-- =====================================================================
USE otel_db;

-- T1 (BASARILI): oda 1, 10-15 Aralik 2027
INSERT INTO REZERVASYON (misafir_id, oda_id, giris_tarihi, cikis_tarihi, kisi_sayisi, durum)
VALUES ((SELECT MIN(misafir_id) FROM MISAFIR), 1, '2027-12-10', '2027-12-15', 1, 'onayli');
SET @a = LAST_INSERT_ID();

-- T2 (HATA BEKLENIR): ayni oda, ayni tarihler -> tamamen cakisma
INSERT INTO REZERVASYON (misafir_id, oda_id, giris_tarihi, cikis_tarihi, kisi_sayisi, durum)
VALUES ((SELECT MIN(misafir_id) FROM MISAFIR), 1, '2027-12-10', '2027-12-15', 1, 'onayli');

-- T3 (HATA BEKLENIR): ayni oda, 13-18 Aralik -> kismi cakisma
INSERT INTO REZERVASYON (misafir_id, oda_id, giris_tarihi, cikis_tarihi, kisi_sayisi, durum)
VALUES ((SELECT MIN(misafir_id) FROM MISAFIR), 1, '2027-12-13', '2027-12-18', 1, 'onayli');

-- T4 (BASARILI): biri 15'inde cikiyor, digeri 15'inde giriyor
INSERT INTO REZERVASYON (misafir_id, oda_id, giris_tarihi, cikis_tarihi, kisi_sayisi, durum)
VALUES ((SELECT MIN(misafir_id) FROM MISAFIR), 1, '2027-12-15', '2027-12-20', 1, 'onayli');
SET @d = LAST_INSERT_ID();

-- T5 (BASARILI): farkli oda, ayni tarihler
INSERT INTO REZERVASYON (misafir_id, oda_id, giris_tarihi, cikis_tarihi, kisi_sayisi, durum)
VALUES ((SELECT MIN(misafir_id) FROM MISAFIR), 2, '2027-12-10', '2027-12-15', 1, 'onayli');

-- T6 (HATA BEKLENIR): UPDATE ile T4 rezervasyonunun girisini 12 Aralik'a cekmek -> T1 ile cakisir
UPDATE REZERVASYON SET giris_tarihi = '2027-12-12' WHERE rezervasyon_id = @d;

-- T7 (BASARILI): kendi cikis tarihini uzatmak (baska rezervasyonla cakismiyor)
UPDATE REZERVASYON SET cikis_tarihi = '2027-12-22' WHERE rezervasyon_id = @d;

-- T8 (BASARILI): T1'i iptal et, ayni tarihlere yeni rezervasyon yapilabilmeli
UPDATE REZERVASYON SET durum = 'iptal' WHERE rezervasyon_id = @a;
INSERT INTO REZERVASYON (misafir_id, oda_id, giris_tarihi, cikis_tarihi, kisi_sayisi, durum)
VALUES ((SELECT MIN(misafir_id) FROM MISAFIR), 1, '2027-12-10', '2027-12-15', 1, 'onayli');

-- LOG KONTROLU (Trigger 3): son islemler gorunmeli
SELECT log_id, tablo_adi, kayit_id, islem_tipi, eski_deger, yeni_deger, islem_zamani
FROM ISLEM_LOG ORDER BY log_id DESC LIMIT 10;

-- TEMIZLIK: test kayitlarini sil (Aralik 2027 oda 1 ve 2)
DELETE FROM REZERVASYON WHERE giris_tarihi >= '2027-12-01' AND oda_id IN (1, 2);
