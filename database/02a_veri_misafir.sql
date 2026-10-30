USE otel_db;

DROP PROCEDURE IF EXISTS sp_misafir_uret;

DELIMITER $$

CREATE PROCEDURE sp_misafir_uret()
BEGIN
  DECLARE i INT DEFAULT 1;

  -- tablo doluysa tekrar ekleme (UNIQUE hatasi almamak icin)
  IF (SELECT COUNT(*) FROM MISAFIR) = 0 THEN
    WHILE i <= 50 DO
      INSERT INTO MISAFIR (ad, soyad, telefon, eposta, tc_no, dogum_tarihi)
      VALUES (
        ELT(1 + FLOOR(RAND()*10), 'Ahmet','Mehmet','Ayşe','Fatma','Ali','Zeynep','Mustafa','Elif','Emre','Selin'),
        ELT(1 + FLOOR(RAND()*10), 'Yılmaz','Kaya','Demir','Çelik','Şahin','Yıldız','Aydın','Öztürk','Arslan','Doğan'),
        CONCAT('053', LPAD(i, 8, '0')),
        CONCAT('misafir', i, '@ornek.com'),
        CONCAT('1', LPAD(i, 10, '0')),
        DATE_ADD('1960-01-01', INTERVAL FLOOR(RAND()*14000) DAY)
      );
      SET i = i + 1;
    END WHILE;
  END IF;
END$$

DELIMITER ;

CALL sp_misafir_uret();

SELECT COUNT(*) FROM MISAFIR;   -- 50 olmali