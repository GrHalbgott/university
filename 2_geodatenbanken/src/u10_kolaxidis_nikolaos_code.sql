CREATE SCHEMA IF NOT EXISTS u10;
SET search_path="u10", "public";

-- Aufgabe 3.1.1
-- Gruppieren nach den Labeln zeigt alle möglichen Werte, die in der Spalte stehen - damit sind es unique values
SELECT "3_Auspraegung_Label" 
	FROM cars 
	GROUP BY "3_Auspraegung_Label" 
	ORDER BY "3_Auspraegung_Label" ASC NULLS LAST;

SELECT "2_Auspraegung_Label" 
	FROM cars 
	GROUP BY "2_Auspraegung_Label" 
	ORDER BY "2_Auspraegung_Label" ASC NULLS LAST;

-- Aufgabe 3.1.2
/*-- Überprüfen was gelöscht werden soll
SELECT 
(
	SELECT count(*) FROM cars
),
(
	SELECT count(*) FROM cars WHERE 
	"3_Auspraegung_Label" = 'Insgesamt' OR 
	"PKW001__Personenkraftwagen__Anzahl" = NULL OR
	"PKW001__Personenkraftwagen__Anzahl" = '-'
);
*/

-- Bereinigung des Datensatzes cars mit einfacher Where-Klausel mit 3 Optionen
DELETE FROM cars WHERE 
	"3_Auspraegung_Label" = 'Insgesamt' OR 
	"2_Auspraegung_Label" = 'Insgesamt' OR 
	"PKW001__Personenkraftwagen__Anzahl" = NULL OR
	"PKW001__Personenkraftwagen__Anzahl" = '-';
	
-- Aufgabe 3.2
-- Aufzeigen der Datentypen der für uns wichtigen Spalten, dann Anpassung an richtige Datenformate
-- Tabelle cars
SELECT column_name, data_type 
	FROM information_schema.columns 
	WHERE table_name='cars' AND column_name = 'PKW001__Personenkraftwagen__Anzahl';
ALTER TABLE cars 
	ALTER COLUMN "PKW001__Personenkraftwagen__Anzahl" 
	TYPE integer 
	USING "PKW001__Personenkraftwagen__Anzahl"::integer;

-- Tabelle streets
SELECT column_name, data_type 
	FROM information_schema.columns 
	WHERE table_name='streets' AND column_name = 'Zeitpunkt' OR column_name = 'Laenge_m';
ALTER TABLE streets 
	ALTER COLUMN "Laenge_m" 
	TYPE numeric
	USING "Laenge_m"::numeric;

-- Aufgabe 3.3.4 - Bereinigung
WITH new_geoms AS 
(
    SELECT ars AS a, st_multi
    (
    	st_union(geom)
    ) AS g
    FROM vg250_krs vk2
    GROUP BY ars
)
	UPDATE vg250_krs
	SET geom = g
	FROM new_geoms
	WHERE ars = a;

DELETE FROM vg250_krs AS a
	USING vg250_krs b
	WHERE a.id < b.id AND a.ars = b.ars;

ALTER TABLE vg250_krs 
	ADD CONSTRAINT uniq_krs
	UNIQUE (ars);

-- "Ars" als Primary Key definieren (Zusatz zu 3.3.4)
ALTER TABLE vg250_krs 
	ADD PRIMARY KEY (ars);
-- Spalte "id" entfernen, da nicht mehr nötig (PK ersetzt durch ars)
ALTER TABLE vg250_krs 
	DROP COLUMN "id";

-- Aufgabe 3.4
-- Definieren von FKs, die beide zum PK ars von vg250_krs referenzieren
ALTER TABLE cars 
	ADD FOREIGN KEY ("1_Auspraegung_Code") 
	REFERENCES vg250_krs (ars);
ALTER TABLE streets 
	ADD FOREIGN KEY ("LKS_ARS") 
	REFERENCES vg250_krs (ars);

-- Aufgabe 4.1
/*-- Vorschritt: View der maximalen Straßenlängen je Ort zum nachprüfen
SELECT vg250_krs.gen, max(s."Laenge_m")
	FROM streets AS s 
	LEFT JOIN vg250_krs 
	ON s."LKS_ARS" = vg250_krs.ars 
	GROUP BY vg250_krs.gen;
*/

-- Zuerst maximale Straßenlänge erreicht - Feststellen der maximalen Straßenlänge, dann die Zeitpunkte ASC sortieren und den zugehörigen ARS als Namen (durch einen Join) ausgeben lassen
SELECT gen AS "Landkreis", "Zeitpunkt" --, "Laenge_m" 
	FROM streets AS s
	INNER JOIN
	    (SELECT "LKS_ARS", max("Laenge_m") AS max_length
	    	FROM streets
	    	GROUP BY "LKS_ARS"
	    ) AS m
		ON s."LKS_ARS" = m."LKS_ARS" AND s."Laenge_m" = m.max_length
	INNER JOIN vg250_krs 
		ON s."LKS_ARS" = vg250_krs.ars
	ORDER BY "Zeitpunkt" ASC
	LIMIT 1;

-- Zuletzt maximale Straßenlänge erreicht - Feststellen der maximalen Straßenlänge, dann die Zeitpunkte DESC sortieren und den zugehörigen ARS als Namen (durch einen Join) ausgeben lassen
SELECT gen AS "Landkreis", "Zeitpunkt" --, "Laenge_m" 
	FROM streets AS s
	INNER JOIN
	    (SELECT "LKS_ARS", max("Laenge_m") AS max_length
	    	FROM streets
	    	GROUP BY "LKS_ARS"
	    ) AS m
		ON s."LKS_ARS" = m."LKS_ARS" AND s."Laenge_m" = m.max_length
	INNER JOIN vg250_krs 
		ON s."LKS_ARS" = vg250_krs.ars
	ORDER BY "Zeitpunkt" DESC
	LIMIT 1;

-- Aufgabe 4.2
/*-- Vorbereitendes
-- Einwohner je Landkreis
SELECT ars, ewz
	FROM vg250_krs AS v
	ORDER BY ars;

-- Summen der PKWs nach ARS
SELECT "1_Auspraegung_Code", SUM(c."PKW001__Personenkraftwagen__Anzahl")
	FROM cars AS c
	GROUP BY "1_Auspraegung_Code"
	ORDER BY "1_Auspraegung_Code" ASC NULLS LAST;

-- Ignorieren der Null-Werte hat nicht geklappt, daher neue Tabelle ohne ewz = 0
CREATE TABLE IF NOT EXISTS u10.vg250_krs2 
(
	geom public.geometry(multipolygon, 25832) NULL,
	ade int4 NULL,
	gf int4 NULL,
	bsg int4 NULL,
	ars varchar(12) NOT NULL,
	ags varchar(8) NULL,
	sdv_ars varchar(12) NULL,
	gen varchar(60) NULL,
	bez varchar(75) NULL,
	ibz int4 NULL,
	bem varchar(75) NULL,
	nbd varchar(4) NULL,
	sn_l varchar(2) NULL,
	sn_r varchar(1) NULL,
	sn_k varchar(2) NULL,
	sn_v1 varchar(2) NULL,
	sn_v2 varchar(2) NULL,
	sn_g varchar(3) NULL,
	fk_s3 varchar(2) NULL,
	nuts varchar(5) NULL,
	ars_0 varchar(12) NULL,
	ags_0 varchar(8) NULL,
	wsk date NULL,
	ewz int4 NULL,
	kfl float8 NULL,
	debkg_id varchar(16) NULL,
	CONSTRAINT uniq_krs UNIQUE (ars),
	CONSTRAINT vg250krs2_pk PRIMARY KEY (ars)
);

INSERT INTO vg250_krs2
	SELECT * FROM vg250_krs;

DELETE FROM vg250_krs2 
	WHERE ewz = 0;
*/

-- Rechne Summe der PKWs je Landkreis durch Einwohner je Landkreis, joine Landkreislayer für die Namen der ARS und den Geometrien (für die Darstellung als Shapefile)
CREATE TABLE IF NOT EXISTS "pkw_per_capita" AS 
	SELECT "1_Auspraegung_Code" AS "ARS", gen AS "Landkreis", SUM("PKW001__Personenkraftwagen__Anzahl")/ewz::numeric AS "PKWs pro Einwohner", geom AS "Geometrien"
		FROM cars AS c
		INNER JOIN vg250_krs2 AS v
			ON c."1_Auspraegung_Code" = v.ars
		GROUP BY gen, "1_Auspraegung_Code", ewz, geom
		ORDER BY "1_Auspraegung_Code" ASC NULLS LAST;