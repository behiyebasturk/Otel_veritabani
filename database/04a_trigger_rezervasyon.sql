-- =====================================================================
-- 04_trigger_rezervasyon.sql
-- TRIGGER 1: Cakisan tarihli rezervasyonu engeller (INSERT + UPDATE)
-- TRIGGER 3: REZERVASYON ve ODEME degisikliklerini ISLEM_LOG'a yazar
-- CALISTIRMA SIRASI: 03'ten SONRA
-- =====================================================================
USE otel_db;

DROP TRIGGER IF EXISTS trg_rez_cakisma_ins;
DROP TRIGGER IF EXISTS trg_rez_cakisma_upd;
DROP TRIGGER IF EXISTS trg_rez_log_ins;
DROP TRIGGER IF EXISTS trg_rez_log_upd;
DROP TRIGGER IF EXISTS trg_rez_log_del;
DROP TRIGGER IF EXISTS trg_odeme_log_ins;
DROP TRIGGER IF EXISTS trg_odeme_log_upd;
DROP TRIGGER IF EXISTS trg_odeme_log_del;

DELIMITER $$

-- ---------------------------------------------------------------------
-- TRIGGER 1a: yeni rezervasyon eklenirken cakisma kontrolu
-- Cakisma kosulu: yeni_giris < mevcut_cikis  VE  mevcut_giris < yeni_cikis
-- (< kullanildigi icin biri cikarken digeri ayni gun girebilir)
-- Iptal edilmis rezervasyonlar odayi bloke etmez.
-- ---------------------------------------------------------------------
CREATE TRIGGER trg_rez_cakisma_ins
BEFORE INSERT ON REZERVASYON
FOR EACH ROW
BEGIN
  DECLARE v_say INT;

  IF NEW.durum <> 'iptal' THEN
    SELECT COUNT(*) INTO v_say
    FROM REZERVASYON
    WHERE oda_id = NEW.oda_id
      AND durum <> 'iptal'
      AND NEW.giris_tarihi < cikis_tarihi
      AND giris_tarihi < NEW.cikis_tarihi;

    IF v_say > 0 THEN
      SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Bu oda secilen tarihlerde zaten rezerve edilmis!';
    END IF;
  END IF;
END$$

-- ---------------------------------------------------------------------
-- TRIGGER 1b: rezervasyon guncellenirken cakisma kontrolu
-- Kendi kaydini saymamak icin rezervasyon_id <> NEW.rezervasyon_id
-- ---------------------------------------------------------------------
CREATE TRIGGER trg_rez_cakisma_upd
BEFORE UPDATE ON REZERVASYON
FOR EACH ROW
BEGIN
  DECLARE v_say INT;

  IF NEW.durum <> 'iptal' THEN
    SELECT COUNT(*) INTO v_say
    FROM REZERVASYON
    WHERE oda_id = NEW.oda_id
      AND durum <> 'iptal'
      AND rezervasyon_id <> NEW.rezervasyon_id
      AND NEW.giris_tarihi < cikis_tarihi
      AND giris_tarihi < NEW.cikis_tarihi;

    IF v_say > 0 THEN
      SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Bu oda secilen tarihlerde zaten rezerve edilmis!';
    END IF;
  END IF;
END$$

-- ---------------------------------------------------------------------
-- TRIGGER 3: REZERVASYON -> ISLEM_LOG (AFTER: islem basarili olduktan sonra)
-- ---------------------------------------------------------------------
CREATE TRIGGER trg_rez_log_ins
AFTER INSERT ON REZERVASYON
FOR EACH ROW
BEGIN
  INSERT INTO ISLEM_LOG (tablo_adi, kayit_id, islem_tipi, eski_deger, yeni_deger)
  VALUES ('REZERVASYON', NEW.rezervasyon_id, 'INSERT', NULL,
    JSON_OBJECT('misafir_id', NEW.misafir_id, 'oda_id', NEW.oda_id,
                'giris_tarihi', NEW.giris_tarihi, 'cikis_tarihi', NEW.cikis_tarihi,
                'kisi_sayisi', NEW.kisi_sayisi, 'durum', NEW.durum));
END$$

CREATE TRIGGER trg_rez_log_upd
AFTER UPDATE ON REZERVASYON
FOR EACH ROW
BEGIN
  INSERT INTO ISLEM_LOG (tablo_adi, kayit_id, islem_tipi, eski_deger, yeni_deger)
  VALUES ('REZERVASYON', NEW.rezervasyon_id, 'UPDATE',
    JSON_OBJECT('misafir_id', OLD.misafir_id, 'oda_id', OLD.oda_id,
                'giris_tarihi', OLD.giris_tarihi, 'cikis_tarihi', OLD.cikis_tarihi,
                'kisi_sayisi', OLD.kisi_sayisi, 'durum', OLD.durum),
    JSON_OBJECT('misafir_id', NEW.misafir_id, 'oda_id', NEW.oda_id,
                'giris_tarihi', NEW.giris_tarihi, 'cikis_tarihi', NEW.cikis_tarihi,
                'kisi_sayisi', NEW.kisi_sayisi, 'durum', NEW.durum));
END$$

CREATE TRIGGER trg_rez_log_del
AFTER DELETE ON REZERVASYON
FOR EACH ROW
BEGIN
  INSERT INTO ISLEM_LOG (tablo_adi, kayit_id, islem_tipi, eski_deger, yeni_deger)
  VALUES ('REZERVASYON', OLD.rezervasyon_id, 'DELETE',
    JSON_OBJECT('misafir_id', OLD.misafir_id, 'oda_id', OLD.oda_id,
                'giris_tarihi', OLD.giris_tarihi, 'cikis_tarihi', OLD.cikis_tarihi,
                'kisi_sayisi', OLD.kisi_sayisi, 'durum', OLD.durum),
    NULL);
END$$

-- ---------------------------------------------------------------------
-- TRIGGER 3: ODEME -> ISLEM_LOG
-- ---------------------------------------------------------------------
CREATE TRIGGER trg_odeme_log_ins
AFTER INSERT ON ODEME
FOR EACH ROW
BEGIN
  INSERT INTO ISLEM_LOG (tablo_adi, kayit_id, islem_tipi, eski_deger, yeni_deger)
  VALUES ('ODEME', NEW.odeme_id, 'INSERT', NULL,
    JSON_OBJECT('konaklama_id', NEW.konaklama_id, 'tutar', NEW.tutar,
                'odeme_yontemi', NEW.odeme_yontemi, 'odeme_durumu', NEW.odeme_durumu));
END$$

CREATE TRIGGER trg_odeme_log_upd
AFTER UPDATE ON ODEME
FOR EACH ROW
BEGIN
  INSERT INTO ISLEM_LOG (tablo_adi, kayit_id, islem_tipi, eski_deger, yeni_deger)
  VALUES ('ODEME', NEW.odeme_id, 'UPDATE',
    JSON_OBJECT('konaklama_id', OLD.konaklama_id, 'tutar', OLD.tutar,
                'odeme_yontemi', OLD.odeme_yontemi, 'odeme_durumu', OLD.odeme_durumu),
    JSON_OBJECT('konaklama_id', NEW.konaklama_id, 'tutar', NEW.tutar,
                'odeme_yontemi', NEW.odeme_yontemi, 'odeme_durumu', NEW.odeme_durumu));
END$$

CREATE TRIGGER trg_odeme_log_del
AFTER DELETE ON ODEME
FOR EACH ROW
BEGIN
  INSERT INTO ISLEM_LOG (tablo_adi, kayit_id, islem_tipi, eski_deger, yeni_deger)
  VALUES ('ODEME', OLD.odeme_id, 'DELETE',
    JSON_OBJECT('konaklama_id', OLD.konaklama_id, 'tutar', OLD.tutar,
                'odeme_yontemi', OLD.odeme_yontemi, 'odeme_durumu', OLD.odeme_durumu),
    NULL);
END$$

DELIMITER ;

SHOW TRIGGERS;   -- 8 trigger gorunmeli
