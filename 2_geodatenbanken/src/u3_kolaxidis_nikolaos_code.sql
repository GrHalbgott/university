CREATE SCHEMA IF NOT EXISTS u3;
SET search_path='u3', 'public';


/* Aufgabe 1c
Erstelle neue Tabelle mit Auswahl kompletter Tupel der alten Tabelle mit Where-Kondition
*/
CREATE TABLE IF NOT EXISTS ged171_deaths AS SELECT * FROM ged171_klein WHERE 
	deaths_a > 0 OR 
	deaths_b > 0 OR 
	deaths_civilians > 0 OR 
	deaths_unknown > 0;
	

/* Aufgabe 1d
Bilde die Summe der gezeigten vier Spalten und gruppiere sie (summiere) nach Region
*/
SELECT region, SUM(deaths_a + deaths_b + deaths_civilians + deaths_unknown) FROM ged171_deaths GROUP BY region;


/* Aufgabe 1e
Bilde die Summe der gezeigten vier Spalten, gruppiere sie nach Jahr und sortiere sie aufsteigend nach Jahr. Problem hierbei: Spaltenname "year" muss eingefasst werden in "", sonst wird es nicht als String erkannt
*/
SELECT "year", SUM(deaths_a + deaths_b + deaths_civilians + deaths_unknown) FROM ged171_deaths GROUP BY "year" ORDER BY "year" ASC;


/* Aufgabe 2b
Hinzufügen einer neuen Spalte per ALTER TABLE
Spalte wird gefüllt mit dem Jahr (YEAR) von STARTDATE, welches on-the-fly in das normale Datumsformat (timestamp) konvertiert wird
*/
ALTER TABLE scad_pt2_fr8 ADD COLUMN "year" integer;
UPDATE scad_pt2_fr8 SET "year"=EXTRACT(YEAR FROM startdate::timestamp);


/* Aufgabe 2c
Selektieren der Minima und Maxima der beiden Tabellen -> 2064 wahrscheinlich falsch, daher geändert in 1964 durch UPDATE und SET column mit WHERE-Condition
Danach selektieren der Minima und Maxima der beiden Tabellen, zusammenfügen per UNION ALL und daraus das maximale Min und das minimale Max festlegen -> überlappender (gemeinsamer) Zeitraum (1989-2010)
*/
SELECT MIN(year), MAX(year) FROM scad_pt2_fr8;
SELECT MIN(year), MAX(year) FROM ged171_klein;
UPDATE scad_pt2_fr8 SET "year"=1964 WHERE "year"=2064;
SELECT MAX(min), MIN(max) FROM 
	(SELECT MIN(year), MAX(year) FROM scad_pt2_fr8 UNION ALL 
	SELECT MIN(year), MAX(year) FROM ged171_klein) alias1;


/* Aufgabe 2d
Zählen der Einträge zwischen 1989 und 2010 für beide Tabellen (bei ged171 nur für Afrika selektieren), dann zusammenfügen und die resultierende Spalte "Count" summieren -> zusammen 16257 Einträge
*/
SELECT SUM(count) FROM 
	(SELECT COUNT(*) FROM ged171_klein WHERE "year">=1989 AND "year"<=2010 AND region='Africa' UNION ALL
	SELECT COUNT(*) FROM scad_pt2_fr8 WHERE "year">=1989 AND "year"<=2010) alias2;
	
