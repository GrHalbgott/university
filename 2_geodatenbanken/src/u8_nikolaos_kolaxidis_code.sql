CREATE SCHEMA IF NOT EXISTS "u8";
SET search_path="u8", "public";

-- Aufgabe 1
SELECT (
	SELECT 
		ST_relate(toporel.basispolygon, toporel.vergleichspolygon) AS "Polygon/Polygon"
	FROM 
		toporel
	),
	(			
	SELECT 
		ST_relate(toporel.basispolygon, toporel.vergleichslinie) AS "Polygon/Line"
	FROM 
		toporel
	),
	(
	SELECT 
		ST_relate(toporel.basispolygon, toporel.vergleichspunkt) AS "Polygon/Point"
	FROM 
		toporel);
	
-- Aufgabe 3a
SELECT 
	b.geom, fz.geom, fz.risk
FROM
	buildings AS b
JOIN
	floodzones AS fz
ON
	ST_intersects(b.geom, fz.geom)
WHERE 
	fz.risk = 'low';
	
-- Aufgabe 3b
SELECT 
	b.geom, fz_u.geom
FROM
	buildings AS b
JOIN 
(
	SELECT 
		ST_union(geom) AS geom
	FROM 
		floodzones
) AS fz_u
ON 
	ST_disjoint(b.geom, fz_u.geom);

-- Aufgabe 3c
-- Ergebnis ist keines, da kein Haus nur touches erfüllt.
SELECT 
	b.geom, fz.geom, fz.risk
FROM
	buildings AS b
JOIN
	floodzones AS fz
ON 
	ST_touches(b.geom, fz.geom)
WHERE
	fz.risk = 'high';

-- Daher probieren mit overlaps, hier werden einige wenige Gebäude als Ergebnis ausgegeben
SELECT 
	b.geom, fz.geom, fz.risk
FROM
	buildings AS b
JOIN
	floodzones AS fz
ON 
	ST_overlaps(b.geom, fz.geom)
WHERE
	fz.risk = 'high';
	
-- Aufgabe 4
SELECT
	ST_srid(geom)
FROM 
	allotments;

-- Aufgabe 4a
SELECT 
	ST_area(i.geog) AS "lies in high risk area (in sqm)"
FROM 
(
	SELECT 
		ST_transform
		(
			ST_intersection
			(
				a.geom,
				(
					SELECT 
						geom
					FROM 
						floodzones 
					WHERE 
						risk = 'high'
				)
			)::geometry, 4326
		)::geography geog
	FROM 
		allotments AS a
) AS i;

-- Aufgabe 4b
SELECT 
	ST_area(i.geog) AS "lies not in risk area (in sqm)"
FROM 
(
	SELECT 
		ST_transform
		(
			ST_difference
			(
				a.geom,
				(
					SELECT 
						ST_union(geom)
					FROM 
						floodzones 
				)
			)::geometry, 4326
		)::geography geog
	FROM 
		allotments AS a
) AS i;
