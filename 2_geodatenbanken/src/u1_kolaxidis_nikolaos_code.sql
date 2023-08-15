SELECT (9-2)=7;
	-- true
SELECT (2+9-1)=12;
	-- false
SELECT 10*2.5;
	-- 25.0
SELECT now();
-- 2022-05-05 13:38:53.002 +0200 – gibt aktuelle Uhrzeit und Zeitzone aus
SELECT sqrt(169);
	-- 13.0 – gibt Wurzel aus
SELECT abs(-31);
	-- 31 – gibt die genannte absolute Zahl aus (Betrag)
SELECT round(2.46431,2);
	-- 2.46 – rundet auf zwei Nachkommastellen
SELECT floor(8.62489);
	-- 8 – rundet zur nächsten höheren ganzen Zahl auf
SELECT ceil(5.234);
	-- 6 – rundet zur nächsten kleineren ganzen Zahl ab
SELECT trunc(5.45698987,4);
-- 5.4569 – gibt nur 4 Nachkommastellen aus (kein Runden!)