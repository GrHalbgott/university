CREATE SCHEMA IF NOT EXISTS "u4";
SET search_path="u4", "public";

-- Aufgabe B
SELECT * FROM geometry_columns;
SELECT * FROM raster_columns;

-- Aufgabe C
-- Hinzufügen einer Geometriespalte "Centroid" mit Geometrietyp "Punkt" im CRS EPSG:25832
ALTER TABLE vectordata ADD COLUMN IF NOT EXISTS centroid geometry(POINT,25832);

-- Aufgabe D
-- Spalte "Centroid" wird gefüllt mit den Zentroiden der Vektordaten (2 Zentroiden, basierend auf der Geometrie des EDT-Datensatzes)
UPDATE vectordata SET centroid=ST_centroid(geom);

-- Aufgabe E
-- Hinzufügen einer weiteren Spalte "dgm_hoehe" mit Datentyp "float"
ALTER TABLE vectordata ADD COLUMN IF NOT EXISTS dgm_hoehe float8;

-- Aufgabe F
-- Lokalisieren der Zentroiden innerhalb eines Rastertiles (Coverage). Hier wird ein Abgleich zwischen Rastertile und Zentroid berechnet und beim Ergebnis die IDs zwischen Vektor und Vektoralias verglichen.
-- Spalte "dgm_hoehe" wird mit dem Höhenwert des DHM gefüllt.
UPDATE vectordata SET dgm_hoehe=(
	SELECT ST_value(rast, centroid) FROM vectordata vecdat
	JOIN dtm_25832_5m ON ST_intersects(rast, centroid)
	WHERE vectordata.id=vecdat.id
);
SELECT * FROM vectordata;

-- Aufgabe G
-- Hinzufügen einer weiteren Spalte "Centroid3D" mit PunktZgeometrien (3D-Punkte) im gleichen CRS
ALTER TABLE vectordata ADD COLUMN IF NOT EXISTS centroid3d geometry(POINTZ,25832);

-- Aufgabe H
-- Gerade erstellte Spalte "Centroid3D" wird mit einem Punkt gefüllt, der die Koordinaten des Zentroiden, aber den Höhendaten der dgm_hoehe addiert zur geb_hoehe enthält.
-- Damit werden zwei 3D-Zentroiden erschaffen.
UPDATE vectordata SET centroid3d=ST_MakePoint(ST_X(centroid), ST_Y(centroid), dgm_hoehe + geb_hoehe);

-- Aufgabe I
-- Aus dem DHM wird ein TIN erzeugt 
CREATE TABLE IF NOT EXISTS tin AS WITH points as(
	SELECT (ST_pixelascentroids(rast)).* FROM dtm_25832_5m), points3d AS (
	SELECT st_makepoint(ST_X(geom), ST_Y(geom), val) AS geom FROM points),
	multipoint3d as(
	SELECT ST_Union(geom) AS geom FROM points3d)
	SELECT st_delaunaytriangles(geom, flags=>2)::geometry(TINZ, 25832) AS geom
	FROM multipoint3d;
SELECT * FROM tin;

-- Aufgabe J
-- Zwischen den beiden 3D-Zentroiden wird eine Linie erzeugt (Line-of-Sight (los)). Diese wird darauf getestet, ob sie vom TIN intersected werden. 
-- Ergebnis: da keine Intersection von Los und TIN, ist der Dicke Turm von der EDT-Aussichtsplattform sichtbar.
WITH los as (
	SELECT ST_Makeline(centroid3d) as geom FROM vectordata)
	SELECT ST_3DIntersects(los.geom, tin.geom) FROM los, tin;
	
