-- SQL skript pro vytvoření základních objektů schématu databáze
--------------------------------------------------------------------------------
-- Autor: Lucia Makaiková <xmakai00@stud.fit.vutbr.cz>
-- Autor: Tadeáš Kachyňa  <xkachy00@stud.fit.vutbr.cz>

-------------------------------- SMAZÁNÍ TABULEK -------------------------------

DROP TABLE VSTUPENKA;
DROP TABLE REZERVACE;
DROP TABLE ZAKAZNIK;
DROP TABLE ZAMESTNANEC;
DROP TABLE PROMITANI;
DROP TABLE FILM;
DROP TABLE KINOSAL;
DROP TABLE MULTIKINO;
DROP TABLE VEDOUCI;

------------------------------- VYTVOŘENÍ TABULEK ------------------------------

CREATE TABLE vedouci
(
    id INT NOT NULL PRIMARY KEY
);

CREATE TABLE multikino
(
    id INT GENERATED AS IDENTITY NOT NULL PRIMARY KEY,
    jmeno VARCHAR(255) NOT NULL,
    mesto VARCHAR(255) NOT NULL,
    ulice VARCHAR(255) NOT NULL,
    cislo_domu INT NOT NULL,
    trzby NUMBER DEFAULT 0 NOT NULL,
    vedouci_id INT DEFAULT NULL UNIQUE,
    CONSTRAINT "vedouci_multikino_id_fk"
    	FOREIGN KEY (vedouci_id) REFERENCES vedouci (id)
	        ON DELETE SET NULL
);

CREATE TABLE kinosal
(
    cislo_salu INT GENERATED AS IDENTITY NOT NULL PRIMARY KEY,
    pocet_rad INT NOT NULL,
    pocet_sedadel INT NOT NULL,
    typ VARCHAR(16) DEFAULT '2D' NOT NULL,
    multikino_id INT NOT NULL,
    CONSTRAINT "multikino_id_fk"
    	FOREIGN KEY (multikino_id) REFERENCES multikino (id)
	        ON DELETE CASCADE
);

CREATE TABLE film
(
    id  INT GENERATED AS IDENTITY NOT NULL PRIMARY KEY,
    dabing  VARCHAR(255) NOT NULL,
    titulky VARCHAR(255) DEFAULT NULL,
    zanr  VARCHAR(255) NOT NULL
);

CREATE TABLE promitani
(
    id INT GENERATED AS IDENTITY NOT NULL PRIMARY KEY,
    delka_projekce INT NOT NULL,
    zacatek TIMESTAMP NOT NULL,
    konec TIMESTAMP  NOT NULL,
    cislo_salu INT NOT NULL,
    film_id INT NOT NULL,
    CONSTRAINT "cislo_salu_id_fk"
    	FOREIGN KEY (cislo_salu) REFERENCES kinosal (cislo_salu)
	        ON DELETE CASCADE,
    CONSTRAINT "film_id_fk"
        FOREIGN KEY (film_id) REFERENCES  film(id)
            ON DELETE CASCADE
);

CREATE TABLE zamestnanec
(
    id  INT GENERATED AS IDENTITY NOT NULL PRIMARY KEY,
    jmeno  VARCHAR(255) NOT NULL,
    prijmeni  VARCHAR(255) NOT NULL,
    mesto   VARCHAR(255) NOT NULL,
    ulice  VARCHAR(255) NOT NULL,
    cislo_domu INT NOT NULL,
    email VARCHAR(255)
	    CHECK(REGEXP_LIKE(
		    email, '^[a-z]+[a-z0-9\.]*@[a-z0-9\.-]+\.[a-z]{2,}$', 'i')),
    telcislo INT NOT NULL
        CHECK(REGEXP_LIKE(
            telcislo , '^((420|421)[0-9]{9})$', 'i')),
    multikino_id INT DEFAULT NULL,
    CONSTRAINT "multikino_id__fk"
    	FOREIGN KEY (multikino_id) REFERENCES multikino (id)
	        ON DELETE SET NULL,
    vedouci_id INT DEFAULT NULL, --ak null, zamestnanec neni vedouci
	CONSTRAINT "vedouci_zamestnanec_id__fk"
		FOREIGN KEY (vedouci_id) REFERENCES vedouci (id)
		    ON DELETE SET NULL
);

CREATE TABLE zakaznik
(
    rc INT NOT NULL PRIMARY KEY
        CHECK(REGEXP_LIKE(
		rc , '^(([0-9]{2})(((0[1-9])|10|11|12)|(5[1-9]|60|61|62))(0[1-9]|[12][0-9]|3[01])(((?!000)[0-9]{3})|[0-9]{4}))$', 'i'
		))
        CONSTRAINT RC_CHECK
            check(MOD(RC, 11) = 0),
    jmeno VARCHAR(255) NOT NULL,
    prijmeni VARCHAR(255) NOT NULL,
    mesto VARCHAR(255) NOT NULL,
    ulice VARCHAR(255)  NOT NULL,
    cislo_domu INT NOT NULL,
	email VARCHAR(255)
	    CHECK(REGEXP_LIKE(
		    email, '^[a-z]+[a-z0-9\.]*@[a-z0-9\.-]+\.[a-z]{2,}$', 'i')),
    telcislo INT NOT NULL
        CHECK(REGEXP_LIKE(
            telcislo , '^((420|421)[0-9]{9})$', 'i'))
);

CREATE TABLE rezervace
(
    id  INT GENERATED AS IDENTITY NOT NULL PRIMARY KEY,
    zpusob_platby VARCHAR(255) NOT NULL,
        CONSTRAINT zpusob_zaplaceni CHECK(zpusob_platby = 'Online' or zpusob_platby = 'Hotove'),
    zakaznik_id INT DEFAULT 0 NOT NULL,
    CONSTRAINT "zakaznik_id_fk"
    	FOREIGN KEY (zakaznik_id) REFERENCES zakaznik (rc)
	        ON DELETE CASCADE
);

CREATE TABLE vstupenka
(
    id INT GENERATED AS IDENTITY NOT NULL PRIMARY KEY,
    rada INT NOT NULL,
    sedadlo INT NOT NULL,
    tarif  VARCHAR(255) NOT NULL,
        CONSTRAINT tarif CHECK(tarif= 'Dospely' or tarif= 'Dite' or tarif= 'Student'),
    typ VARCHAR(255), --specializace online vstupenka
        CONSTRAINT typ CHECK(typ = 'Online' or typ = ''),
    stav_platby VARCHAR(255) NOT NULL,
        CONSTRAINT stav_platby CHECK(stav_platby= 'Zaplaceno' or stav_platby = 'Nezaplaceno'),
    rezervace_id INT DEFAULT NULL,
    zamestnanec_id INT DEFAULT NULL,
    promitani_id INT DEFAULT NULL, --pri zruseni promitani se uchovaji data o predanych vstupenkach
    CONSTRAINT "rezervace_id_fk"
    	FOREIGN KEY (rezervace_id) REFERENCES rezervace (id)
	        ON DELETE CASCADE,
    CONSTRAINT "zamestnanec_id_fk"
    	FOREIGN KEY (zamestnanec_id) REFERENCES zamestnanec (id)
	        ON DELETE SET NULL,
    CONSTRAINT "promitani_id_fk"
    	FOREIGN KEY (promitani_id) REFERENCES promitani (id)
	        ON DELETE SET NULL
);

------------------------------------ VLOZENI HODNOT --------------------------------------

INSERT INTO VEDOUCI (id)
VALUES (1);
INSERT INTO VEDOUCI (id)
VALUES (2);

INSERT INTO MULTIKINO (jmeno, mesto,ulice, cislo_domu, trzby, vedouci_id)
VALUES ('OC OLYMPIA' , 'Modřice', 'U Dálnice ', 3, '123456', 1);
INSERT INTO MULTIKINO (jmeno, mesto, ulice, cislo_domu, trzby, vedouci_id)
VALUES ('OC Velky Špalíček' , 'Brno', 'Mečová 695', 43, '456687', 2);

INSERT INTO KINOSAL (pocet_rad, pocet_sedadel, multikino_id)
VALUES (15, 250, 1);
INSERT INTO KINOSAL (pocet_rad, pocet_sedadel, typ, multikino_id)
VALUES (20, 300, '3D', 1);
INSERT INTO KINOSAL (pocet_rad, pocet_sedadel, typ, multikino_id)
VALUES (15, 250, '2D', 1);

INSERT INTO KINOSAL (pocet_rad, pocet_sedadel, typ, multikino_id)
VALUES (15, 250, '2D', 2);
INSERT INTO KINOSAL (pocet_rad, pocet_sedadel, typ, multikino_id)
VALUES (20, 300, '3D', 2);
INSERT INTO KINOSAL (pocet_rad, pocet_sedadel, typ, multikino_id)
VALUES (15, 250, '2D', 2);

INSERT INTO FILM (dabing, zanr)
VALUES ('český', 'komedie');
INSERT INTO FILM (dabing, titulky, zanr)
VALUES ('anglický', 'české', 'komedie');
INSERT INTO FILM (dabing, zanr)
VALUES ('český', 'drama');

INSERT INTO promitani( delka_projekce, zacatek, konec, cislo_salu, film_id)
VALUES (120, '21-12-2021 12:00:00', '21-12-2021 14:00:00', 2, 1);
INSERT INTO promitani( delka_projekce, zacatek, konec, cislo_salu, film_id)
VALUES (90, '21-12-2021 14:00:00', '21-12-2021 15:30:00', 4, 2);
INSERT INTO promitani( delka_projekce, zacatek, konec, cislo_salu, film_id)
VALUES (100, '22-12-2021 18:00:00', '22-12-2021 19:40:00', 5, 2);

INSERT INTO zamestnanec(jmeno, prijmeni, mesto, ulice, cislo_domu, email, telcislo, multikino_id, vedouci_id)
VALUES('Pan', 'A', 'Modřice', 'Husova', 33, 'vedouci@multikino2.cz', 420111111111, 2, 2);
INSERT INTO zamestnanec(jmeno, prijmeni, mesto, ulice, cislo_domu, email, telcislo, multikino_id, vedouci_id)
VALUES('Pan', 'B', 'Brno', 'Česká', 23, 'vedouci@multikino1.cz', 420111111111, 1, 1);
INSERT INTO zamestnanec(jmeno, prijmeni, mesto, ulice, cislo_domu, email, telcislo, multikino_id)
VALUES('Paní', 'C', 'Brno', 'Hlavní', 30, 'zamestnanec@multikino1.cz', 420111111111, 1);

INSERT INTO zakaznik(rc, jmeno, prijmeni, mesto, ulice, cislo_domu, email, telcislo)
VALUES(7204250999 ,'Pan', 'Y', 'Brno', 'Hlavní', 12, 'panx@seznam.cz', 420111111111);
INSERT INTO zakaznik(rc, jmeno, prijmeni, mesto, ulice, cislo_domu, email, telcislo)
VALUES(6162256386 ,'Paní', 'Y', 'Praha', 'Masarykova', 24, 'paniy@email.cz', 420222222222);

INSERT INTO rezervace(zpusob_platby, zakaznik_id)
VALUES ('Hotove', 7204250999);
INSERT INTO  rezervace(zpusob_platby, zakaznik_id)
VALUES ('Online', 7204250999);
INSERT INTO  rezervace(zpusob_platby, zakaznik_id)
VALUES ('Online', 6162256386);

INSERT INTO VSTUPENKA (rada, sedadlo, tarif, typ, stav_platby, rezervace_id, zamestnanec_id, promitani_id )
VALUES (4, 10, 'Dospely', '', 'Zaplaceno', 1, 3, 1);
INSERT INTO VSTUPENKA (rada, sedadlo, tarif, typ, stav_platby, rezervace_id,  promitani_id )
VALUES (5, 22, 'Dospely', 'Online', 'Zaplaceno', 2, 1);
INSERT INTO VSTUPENKA (rada, sedadlo, tarif, typ, stav_platby, rezervace_id, promitani_id )
VALUES (4, 23, 'Student', 'Online', 'Nezaplaceno', 3, 1);

------------------------------------ ZOBRAZENÍ TABULEK --------------------------------------

SELECT * FROM VEDOUCI;
SELECT * FROM MULTIKINO;
SELECT * FROM KINOSAL;
SELECT * FROM FILM;
SELECT * FROM PROMITANI;
SELECT * FROM ZAMESTNANEC;
SELECT * FROM REZERVACE;
SELECT * FROM VSTUPENKA;
SELECT * FROM ZAKAZNIK;
