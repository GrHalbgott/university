-- Aufgabe 1
CREATE SCHEMA IF NOT EXISTS u2;
SET search_path='u2', 'public';
CREATE TABLE IF NOT EXISTS u2.person (
	id INTEGER PRIMARY KEY,
	name VARCHAR(40),
	fach TEXT,
	studiengang TEXT);

-- Aufgabe 2
INSERT INTO u2.person VALUES (1, 'Markus', 'Geographie', 'master');
INSERT INTO u2.person VALUES (2, 'Ben', 'Geographie', 'master');
INSERT INTO u2.person VALUES (3, 'Adelheid', 'Informatik', 'bachelor');
INSERT INTO u2.person VALUES (4, 'Sabrina', 'Mathematik', 'bachelor');
INSERT INTO u2.person VALUES (5, 'Peter', 'Geschichte', 'master');
INSERT INTO u2.person VALUES (6, 'Elif', 'Informatik', 'bachelor');
INSERT INTO u2.person VALUES (7, 'Lena', 'Geschichte', 'bachelor');

-- Aufgabe 3
SELECT * FROM u2.person;
SELECT name FROM u2.person;
INSERT INTO u2.person VALUES (8, 'Niko', 'Geographie', 'master');
UPDATE u2.person SET name='Mario' WHERE id=2;
SELECT * FROM u2.person ORDER BY id;
SELECT COUNT(*) FROM u2.person WHERE fach='Geographie';
SELECT COUNT(*) FROM u2.person WHERE fach!='Geographie';
SELECT COUNT(*) FROM u2.person WHERE fach='Informatik' OR fach='Mathematik';
SELECT COUNT(*) FROM u2.person WHERE fach='Informatik' AND studiengang='bachelor';
ALTER TABLE u2.person ADD mint bool;
UPDATE u2.person SET mint=true WHERE fach='Informatik' OR fach='Mathematik' OR fach='Geographie' ;
DELETE FROM u2.person WHERE id=8;

-- Aufgabe 4
/**	Einstellen hat geklappt.
	Die Datenbank in DBeaver zeigt nun ein Tupel mehr an mit den in QGIS eingegebenen Daten.
	Durch den gleichzeitigen Zugriff werden auch die Einträge der anderen Teilnehmer*innen angezeigt.
*/