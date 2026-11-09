-- =====================================================================
-- 03_veri_rezervasyon.sql
-- 20 oda x 10 rezervasyon = 200 rezervasyon uretir.
-- CALISTIRMA SIRASI: 01 -> 01b -> 02 -> 02a -> 03 -> 04
-- (Trigger'lardan ONCE calistirilir.)
--
-- Mantik: Her oda icin rezervasyonlar ART ARDA dizilir. Her rezervasyonun
-- girisi, bir oncekinin cikisindan sonra (veya ayni gun) oldugu icin
-- cakisma matematiksel olarak olamaz.
-- =====================================================================
USE otel_db;

DROP PROCEDURE IF EXISTS sp_rezervasyon_uret;

DELIMITER $$

CREATE PROCEDURE sp_rezervasyon_uret()
BEGIN
  DECLARE o          INT DEFAULT 0;   -- kacinci oda (0'dan baslar)
  DECLARE r          INT;             -- odanin kacinci rezervasyonu
  DECLARE v_oda      INT;
  DECLARE v_kap      INT;
  DECLARE v_misafir  INT;
  DECLARE v_giris    DATE;
  DECLARE v_cikis    DATE;
  DECLARE v_kisi     INT;
  DECLARE v_durum    VARCHAR(20);
  DECLARE v_zar      DOUBLE;

  -- tablo doluysa tekrar ekleme
  IF (SELECT COUNT(*) FROM REZERVASYON) = 0 THEN

    WHILE o < 20 DO

      -- o. sıradaki odanin id'si
      SELECT oda_id INTO v_oda FROM ODA ORDER BY oda_id LIMIT o, 1;

      -- bu odanin kapasitesi (ODA + ODA_TIPI JOIN)
      SELECT t.kapasite INTO v_kap
      FROM ODA od
      JOIN ODA_TIPI t ON od.oda_tipi_id = t.oda_tipi_id
      WHERE od.oda_id = v_oda;

      -- odanin ilk rezervasyonu icin baslangic: Haziran-Temmuz 2026
      SET v_cikis = DATE_ADD('2026-06-01', INTERVAL FLOOR(RAND()*60) DAY);

      SET r = 1;
      WHILE r <= 10 DO
        SET v_giris = DATE_ADD(v_cikis, INTERVAL FLOOR(RAND()*31) DAY);      -- onceki cikistan 0-30 gun sonra
        SET v_cikis = DATE_ADD(v_giris, INTERVAL FLOOR(RAND()*7) + 1 DAY);   -- 1-7 gece
        SET v_kisi  = FLOOR(RAND()*v_kap) + 1;                               -- 1 .. kapasite

        SELECT misafir_id INTO v_misafir FROM MISAFIR ORDER BY RAND() LIMIT 1;

        -- durum: gecmis / suren / gelecek
        SET v_zar = RAND();
        IF v_cikis < CURDATE() THEN
          IF v_zar < 0.85 THEN SET v_durum = 'tamamlandi'; ELSE SET v_durum = 'iptal'; END IF;
        ELSEIF v_giris <= CURDATE() THEN
          SET v_durum = 'onayli';
        ELSE
          IF v_zar < 0.70 THEN SET v_durum = 'onayli'; ELSEIF v_zar < 0.90 THEN SET v_durum = 'beklemede'; ELSE SET v_durum = 'iptal'; END IF;
        END IF;

        INSERT INTO REZERVASYON
          (misafir_id, oda_id, giris_tarihi, cikis_tarihi, kisi_sayisi, durum, olusturma_tarihi)
        VALUES
          (v_misafir, v_oda, v_giris, v_cikis, v_kisi, v_durum,
           DATE_SUB(v_giris, INTERVAL FLOOR(RAND()*30) + 1 DAY));

        SET r = r + 1;
      END WHILE;

      SET o = o + 1;
    END WHILE;

  END IF;
END$$

DELIMITER ;

CALL sp_rezervasyon_uret();

-- KONTROL
SELECT COUNT(*) AS toplam FROM REZERVASYON;                       -- 200 olmali
SELECT durum, COUNT(*) FROM REZERVASYON GROUP BY durum;           -- her durumdan olmali
SELECT MIN(giris_tarihi), MAX(cikis_tarihi) FROM REZERVASYON;     -- 2026-2027 icinde olmali
