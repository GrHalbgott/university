CREATE SCHEMA IF NOT EXISTS "u9";
SET search_path="u9", "public";

-- Aufgabe 1c
-- Active Connection setzen auf das Geopackage
SELECT 
	b.building_type, 
	b.geom, 
	area/avg(b.area) OVER (PARTITION BY b.building_type) AS rel_size,
	avg(b.area) OVER (PARTITION BY b.building_type) AS avg_area	
FROM buildings AS b;

-- Aufgabe 2 Vorbereitung
-- Kopiere buildings aus u8 komplett in u9

CREATE TABLE IF NOT EXISTS buildings (
	id serial4 NOT NULL,
	geom public.geometry(polygon, 4326) NULL,
	CONSTRAINT buildings_pkey PRIMARY KEY (id)
);

INSERT INTO u9.buildings 
SELECT *
FROM u8.buildings;

-- Aufgabe 2a
-- Active Connection setzen auf Datenbank "nkolaxidis"
-- Berechnen der mittleren Fläche der Gebäude
SELECT avg(ST_area(b.geom::geography))
FROM u9.buildings AS b;
	
-- Aufgabe 2b: gibt Error aus
/*
SELECT *
FROM u9.buildings b
WHERE st_area(b.geom::geography) > avg(st_area(b.geom::geography));
*/

-- Aufgabe 2c: Korrektur von 2b durch Subquery
SELECT *
FROM u9.buildings AS b
WHERE st_area(b.geom::geography) > 
(
	SELECT avg(ST_area(b.geom::geography))
	FROM u9.buildings AS b
);
		
-- Aufgabe 2d: Umformen der Subquery in ein CTE, dadurch bei vielen Subqueries höhere Lesbarkeit des Scripts
WITH average AS 
(
	SELECT avg(ST_area(b.geom::geography))
	FROM u9.buildings AS b
)
SELECT *
FROM buildings AS b
JOIN average ON TRUE;

-- Aufgabe 2e
EXPLAIN ANALYZE --2c
SELECT *
FROM u9.buildings AS b
WHERE st_area(b.geom::geography) > 
(	
	SELECT 
		avg(ST_area(b.geom::geography))
	FROM 
		u9.buildings AS b
);
	
EXPLAIN ANALYZE -- 2d
WITH average AS 
(
	SELECT avg(ST_area(b.geom::geography))
	FROM u9.buildings AS b
)
SELECT *
FROM u9.buildings AS b
JOIN average ON TRUE;


-- Aufgabe 3 Vorbereitung
-- Spalte hinzufügen zum überprüfen welche Zeile geändert wurde
ALTER TABLE buildings
ADD COLUMN updated boolean;

UPDATE buildings 
SET updated = FALSE;

-- Aufgabe 3a
-- Selektiere eine random Zeile von buildings und füge neue Zeile mit gleicher id und einer Null-Geometrie ein
-- Gibt Error aus 'ERROR: duplicate key value violates unique constraint "buildings_pkey"'
/*
INSERT INTO u9.buildings
VALUES 
(
	(
		SELECT id FROM
		(
			SELECT *
			FROM u9.buildings
			ORDER BY random()
			LIMIT 1
		) AS random_id
	),
	NULL, TRUE
);
*/

-- Aufgabe 3b
-- Selektiere eine random Zeile von buildings und ersetze die geom-Spalte mit NULL
INSERT INTO u9.buildings
VALUES 
(
	(
		SELECT id FROM
		(
			SELECT *
			FROM u9.buildings
			ORDER BY random()
			LIMIT 1
		) AS random_id
	),
	NULL, TRUE
)
ON CONFLICT (id) 
DO UPDATE SET 
	geom = NULL, 
	updated = TRUE;

-- Aufgabe 3c
-- Selektiere eine random Zeile von buildings und erstelle einen 10 Meter-Buffer um die Geometrie (dazu nötig eine Projektion in ETRS89/UTM32N)
	
ALTER TABLE buildings 
ALTER COLUMN geom 
	TYPE Geometry(Polygon, 25832) 
	USING ST_Transform(geom, 25832);

INSERT INTO u9.buildings AS b
VALUES 
(
	(
		SELECT id FROM
		(
			SELECT *
			FROM u9.buildings
			ORDER BY random()
			LIMIT 1
		) AS random_id
	),
	NULL, TRUE
)
ON CONFLICT (id) 
DO UPDATE SET 
	geom = ST_buffer(b.geom, 10.0),
	updated = TRUE;