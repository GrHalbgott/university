CREATE SCHEMA IF NOT EXISTS "u7";
SET search_path="u7", "public";

-- Aufgabe 2a
-- Zeige zwei Queries in einer Tabelle an
SELECT 
-- Zähle alle Features von AX
(
	SELECT 
		COUNT(*) AS AX_count
	FROM 
		"AX_KommunalesGebiet"
), 
-- Zähle alle Features von WT
(
	SELECT
		COUNT(*) AS WT_count
	FROM
		osm_wind_turbines
);

SELECT 
-- Zähle alle Features von AX
(
	SELECT 
		COUNT("name") AS AX_count
	FROM 
		"AX_KommunalesGebiet"
), 
-- Zähle alle Features von WT (weniger, da die meisten Punkte keinen Eintrag in "name" haben)
(
	SELECT
		COUNT("name") AS WT_count
	FROM
		osm_wind_turbines
);

-- Aufgabe 2b
-- Zeige Query Plan der vorigen Query
EXPLAIN SELECT 
(
	SELECT 
		COUNT(*) AS AX_count
	FROM 
		"AX_KommunalesGebiet"
), 
(
	SELECT
		COUNT(*) AS WT_count
	FROM
		osm_wind_turbines
);

-- Zeige Query Plan der vorigen Query
EXPLAIN SELECT 
(
	SELECT 
		COUNT("name") AS AX_count
	FROM 
		"AX_KommunalesGebiet"
), 
(
	SELECT
		COUNT("name") AS WT_count
	FROM
		osm_wind_turbines
);

-- Aufgabe 3a
-- Spatial Join mit der Abfrage, wie viele Punkte in einem Polygon liegen
SELECT
	AX.name,
	COUNT(WT.*)
FROM 
	osm_wind_turbines AS WT
JOIN
	"AX_KommunalesGebiet" AS AX
ON
	ST_Within(WT.geom, AX.geom)
GROUP BY 
	AX.name
ORDER BY
	AX.name;

-- Aufgabe 3b
-- Zeige Query Plan der vorigen Query
EXPLAIN SELECT
	AX.name,
	COUNT(WT.*)
FROM 
	osm_wind_turbines AS WT
JOIN
	"AX_KommunalesGebiet" AS AX
ON
	ST_Within(WT.geom, AX.geom)
GROUP BY 
	AX.name
ORDER BY
	AX.name;
	
-- Aufgabe 3c

/*
-- Kopiere Tabelle AX (damit einmal mit einmal ohne Spatial Index)
SELECT 
	*
INTO
	"AX_KommunalesGebiet_index"
FROM
	"AX_KommunalesGebiet";

-- Kopiere Tabelle WT (damit einmal mit einmal ohne Spatial Index)
SELECT 
	*
INTO
	osm_wind_turbines_index
FROM
	osm_wind_turbines owt ;

-- Erstelle Spatial Index für beide neuen/kopierten Tabellen
CREATE INDEX 
	"AX_KommunalesGebiet_geom_idx"
ON
	"AX_KommunalesGebiet_index"
USING
	GIST(geom);
	
CREATE INDEX 
	osm_wind_turbines_geom_idx
ON
	osm_wind_turbines_index
USING
	GIST(geom);
*/

-- Zeige Query Plan der vorigen Query
EXPLAIN SELECT
	AXx.name,
	COUNT(WTx.*)
FROM 
	osm_wind_turbines_index AS WTx
JOIN
	"AX_KommunalesGebiet_index" AS AXx
ON
	ST_Within(WTx.geom, AXx.geom)
GROUP BY 
	AXx.name
ORDER BY
	AXx.name;