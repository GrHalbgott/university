CREATE SCHEMA IF NOT EXISTS "u6";
SET search_path = "u6", "u6_a2", "public";

-- Aufgabe 2
-- 1: korrekt (Self join)
SELECT 
	*
FROM
	status AS a
INNER JOIN status AS b ON 
	a.stat != b.stat
ORDER BY 
	a.stat ASC,
	b.stat ASC;

-- 2: korrekt (Inner join)
SELECT 
	error.*,
	country.countryname
FROM
	country
INNER JOIN error ON
	country.id = error.country;

-- 3: korrekt (Cross join)
SELECT 
	error.id,
	status.stat
FROM
	error
CROSS JOIN 
	status
ORDER BY 
	error.id ASC;

-- 4: korrekt (Natural join)
SELECT 
	error.kommentar AS common_comments
FROM
	error
NATURAL JOIN country;

-- 5: korrekt (Left join)
SELECT 
	error.id,
	country.countryname
FROM
	error
LEFT JOIN country ON
	error.country = country.id
ORDER BY
	error.id ASC NULLS LAST;

-- 6: korrekt (Right join)
SELECT 
	country.countryname,
	COUNT(error.country)
FROM
	error
RIGHT JOIN country ON
	error.country = country.id
GROUP BY country.countryname;

-- 7: korrekt (Full join)
SELECT 
	*
FROM 
	country
FULL JOIN error ON
	country.id = error.country
ORDER BY 
	error.id ASC NULLS LAST,
	country.id ASC;

-- Aufgabe 3
-- Erstelle Tabelle aus Query:
-- Generiere 3500 Zeilen mit zufälligen Zahlen zwischen -100 und 100 (random (also 0 bis 1) * Wertebereich (max - min) + niedrigster Wert) und runde die Zahlen jeweils auf eine Ganzzahl
CREATE TABLE IF NOT EXISTS random_nums AS
	(
	SELECT
		id,
		round(random()*(100-(-100))+(-100)) AS value
	FROM
		generate_series(1, 3500) AS id);
SELECT
	*
FROM
	random_nums;

-- Überprüfung der Wertebereiche
SELECT
	min(id) AS min_id,
	max(id) AS max_id,
	min(value) AS min_value,
	max(value) AS max_value
FROM
	random_nums;
-- Ergebnis: alles korrekt