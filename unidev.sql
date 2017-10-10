

-- Question 4

CREATE OR REPLACE PROCEDURE AjouterJourneeTravail (
  p_codeSalarie TRAVAILLER.codeSalarie%TYPE,
  p_codeProjet TRAVAILLER.codeProjet%TYPE,
  p_dateTravail Travailler.DATETRAVAIL%TYPE
) IS

  BEGIN
    INSERT INTO TRAVAILLER VALUES (p_codeSalarie,p_dateTravail,p_codeProjet);
    UPDATE SALARIES
      SET NBTOTALJOURNEESTRAVAIL=NBTOTALJOURNEESTRAVAIL+1;
  END;;

--

Call AJOUTERJOURNEETRAVAIL('S2','P3','10/01/2014');

SELECT NBTOTALJOURNEESTRAVAIL
FROM SALARIES
WHERE CODESALARIE='S2';

-- Question 5

CREATE OR REPLACE PROCEDURE AffecterSalarieEquipe (
  p_codeSalarie ETREAFFECTE.codeSalarie%TYPE,
  p_codeEquipe ETREAFFECTE.codeEquipe%TYPE
) IS
    v_nbAffectation NUMBER;
    Erreur EXCEPTION;
  BEGIN
    SELECT count(codeSalarie) INTO v_nbAffectation
    FROM ETREAFFECTE
    WHERE CODESALARIE=p_codeSalarie;
    IF v_nbAffectation<3 THEN
      INSERT INTO ETREAFFECTE VALUES (p_codeSalarie,p_codeEquipe);
      ELSE
      RAISE Erreur;
    END IF;
    EXCEPTION
    WHEN Erreur THEN
      RAISE_APPLICATION_ERROR(-20001, 'Le salarié est déjà affecté à au moins 3 équipes');
  END;;

--

CALL AFFECTERSALARIEEQUIPE('S1','E3');

SELECT *
FROM ETREAFFECTE
WHERE CODESALARIE = 'S1' AND CODEEQUIPE='E3';

CALL AFFECTERSALARIEEQUIPE('S8','E1');

SELECT *
FROM ETREAFFECTE
WHERE CODEEQUIPE='E1' AND CODESALARIE='S8';

-- Exercice 6

ALTER TABLE EQUIPES ADD
CONSTRAINT VerifSalarieChefEstDansEquipe FOREIGN KEY (codeEquipe,codeSalarieChef) REFERENCES ETREAFFECTE(CODEEQUIPE,CODESALARIE);

--

UPDATE EQUIPES
SET CODESALARIECHEF='S3'
WHERE CODEEQUIPE='E4';

SELECT CODESALARIECHEF
FROM EQUIPES
Where CODEEQUIPE = 'E3';

UPDATE EQUIPES
SET CODESALARIECHEF='S4'
WHERE CODEEQUIPE='E3';

-- Exercice 7

CREATE OR REPLACE PROCEDURE AjouterJourneeTravail (
  p_codeSalarie TRAVAILLER.codeSalarie%TYPE,
  p_codeProjet TRAVAILLER.codeProjet%TYPE,
  p_dateTravail Travailler.DATETRAVAIL%TYPE
) IS
    vb NUMBER;
  BEGIN
    SELECT CODEEQUIPE INTO vb
    FROM PROJETS
    WHERE CODEPROJET=p_codeProjet;
    SELECT CODEEQUIPE INTO vb
    FROM ETREAFFECTE
    WHERE CODESALARIE=p_codeSalarie AND CODEEQUIPE=vb;

    SELECT count(CODESALARIE) into vb
    FROM PROJETS P
    JOIN ETREAFFECTE E ON E.CODEEQUIPE=P.CODEEQUIPE
    WHERE P.CODEPROJET=p_codeProjet AND e.CODESALARIE=p_codeSalarie;
    if vb=0 THEN
    INSERT INTO TRAVAILLER VALUES (p_codeSalarie,p_dateTravail,p_codeProjet);
    UPDATE SALARIES
      SET NBTOTALJOURNEESTRAVAIL=NBTOTALJOURNEESTRAVAIL+1;
    END IF;
    EXCEPTION
    WHEN No_data_found THEN
    RAISE_APPLICATION_ERROR(-20001,'Le salarié doit faire partie de l équipe qui réalise le projet');
  END;;

--

CALL AJOUTERJOURNEETRAVAIL('S2','P3','11/01/2014');

SELECT NBTOTALJOURNEESTRAVAIL
FROM SALARIES
WHERE CODESALARIE='S2';

-- Exercice 8

