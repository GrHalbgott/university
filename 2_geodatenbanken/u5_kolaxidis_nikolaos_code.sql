CREATE SCHEMA IF NOT EXISTS "u5";
SET search_path="u5", "public";

-- Aufgabe 1c

-- Tabelle Fachgebiet mit PK id, darf nicht leer sein, damit Projekt immer die 1..* erfüllen kann
CREATE TABLE IF NOT EXISTS fachgebiet (
	id integer NOT NULL,	
	name_fachgebiet VARCHAR(100),
	PRIMARY KEY (id)
	);

-- Tabelle Projekt mit PK kassenzeichen, FK fachgebiet_id darf nicht leer sein, damit Projekt immer die 1..* erfüllen kann
CREATE TABLE IF NOT EXISTS projekt (
	kassenzeichen integer,
	name VARCHAR(250),
	aktiv boolean,
	fachgebiet_id integer NOT NULL,
	PRIMARY KEY (kassenzeichen),
    FOREIGN KEY (fachgebiet_id) REFERENCES fachgebiet(id)
	);
	
-- Tabelle Person, FK projekt_kassenzeichen darf nicht leer sein, damit keine Personen ohne Projekt existieren 
-- (kein Projekt = nicht angestellt)
CREATE TABLE IF NOT EXISTS person (
	name_person VARCHAR(100),
	personalnummer integer,
	projekt_kassenzeichen integer NOT NULL,
	FOREIGN KEY (projekt_kassenzeichen) REFERENCES projekt(kassenzeichen)
	);
	
-- Aufgabe 2

-- Tabellen füllen, damit der Join evaluiert werden kann
INSERT INTO fachgebiet VALUES (1, 'Geographie');
INSERT INTO fachgebiet VALUES (2, 'Geoinformatik');
INSERT INTO projekt VALUES (123456, 'Line of Sight Analyse Dicker Turm vs. Energiespeicher', TRUE, 1);
INSERT INTO projekt VALUES (654321, 'TIN-Generierung Heidelberger Neckar', FALSE, 2);
INSERT INTO person VALUES ('Hans-Peter Baxxter', 4017666, 123456);
INSERT INTO person VALUES ('Prince Charles', 6969556, 123456);

-- Erstellen einer View mit einer Join-Abfrage
-- Spezifizierung der gewünschten Spalten, anschließend Join von FK (person) zu PK (projekt) auf Grundlage des Kassenzeichens
CREATE VIEW projektuebersicht AS
	SELECT projekt.kassenzeichen, projekt.name, projekt.aktiv, person.name_person, person.personalnummer 
	FROM projekt
	INNER JOIN person ON 
		projekt.kassenzeichen = person.projekt_kassenzeichen;