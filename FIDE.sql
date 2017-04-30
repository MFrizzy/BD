DROP TABLE Ligues CASCADE CONSTRAINT;
DROP TABLE Clubs CASCADE CONSTRAINT;
DROP TABLE Joueurs CASCADE CONSTRAINT;
DROP TABLE Tournois CASCADE CONSTRAINT;
DROP TABLE Participer CASCADE CONSTRAINT;
DROP TABLE Parties CASCADE CONSTRAINT;

-- creation des tables

CREATE TABLE Ligues
(idLigue VARCHAR(5), nomLigue VARCHAR(25), zoneLigue VARCHAR(25), nbJoueursLigue NUMBER,
CONSTRAINT pk_Ligues PRIMARY KEY (idLigue)) ;

CREATE TABLE Clubs
(idClub VARCHAR(5), nomClub VARCHAR(25), idLigue VARCHAR(5),
CONSTRAINT pk_Clubs PRIMARY KEY (idClub),
CONSTRAINT fk_Club_idLigue FOREIGN KEY (idLigue) REFERENCES Ligues(idLigue));

CREATE TABLE Joueurs
(idJoueur VARCHAR(5), nomJoueur VARCHAR(25), prenomJoueur VARCHAR(25), sexeJoueur VARCHAR(1), dateNaissanceJoueur DATE, eloJoueur NUMBER, idClub VARCHAR(5), 
CONSTRAINT pk_Joueurs PRIMARY KEY (idJoueur),
CONSTRAINT fk_Joueurs_idClub FOREIGN KEY (idClub) REFERENCES Clubs(idClub));

CREATE TABLE Tournois
(idTournoi VARCHAR(5), nomTournoi VARCHAR(25), lieuTournoi VARCHAR(25), nbRondesTournoi NUMBER, nbParticipantsTournoi NUMBER,
CONSTRAINT pk_Tournois PRIMARY KEY (idTournoi));

CREATE TABLE Participer
(idTournoi VARCHAR(5), idJoueur VARCHAR(5),
CONSTRAINT pk_Participer PRIMARY KEY (idTournoi, idJoueur),
CONSTRAINT fk_Participer_idTournoi FOREIGN KEY (idTournoi) REFERENCES Tournois(idTournoi),
CONSTRAINT fk_Participer_idJoueur FOREIGN KEY (idJoueur) REFERENCES Joueurs(idJoueur));

CREATE TABLE Parties
(idPartie VARCHAR(5), idTournoi VARCHAR(5), numRonde NUMBER, numTable NUMBER, idJoueurBlancs VARCHAR(5), idJoueurNoirs VARCHAR(5), resultatPartie VARCHAR(3),
CONSTRAINT pk_Parties PRIMARY KEY (idPartie),
CONSTRAINT fk_Parties_idJoueurBlancs FOREIGN KEY (idTournoi, idJoueurBlancs) REFERENCES Participer(idTournoi, idJoueur),
CONSTRAINT fk_Parties_idJoueurNoirs FOREIGN KEY (idTournoi, idJoueurNoirs) REFERENCES Participer(idTournoi, idJoueur));

--insertion de données dans les tables

INSERT INTO Ligues (idLigue, nomLigue, zoneLigue, nbJoueursLigue) (SELECT * FROM Palleja.FIDE_Ligues);
INSERT INTO Clubs (idClub, nomClub, idLigue)(SELECT * FROM Palleja.FIDE_Clubs);
INSERT INTO Joueurs (idJoueur, nomJoueur, prenomJoueur, sexeJoueur, dateNaissanceJoueur, eloJoueur, idClub)(SELECT * FROM Palleja.FIDE_Joueurs);
INSERT INTO Tournois (idTournoi, nomTournoi, lieuTournoi, nbRondesTournoi, nbParticipantsTournoi)(SELECT * FROM Palleja.FIDE_Tournois);
INSERT INTO Participer (idTournoi, idJoueur)(SELECT * FROM Palleja.FIDE_Participer);
INSERT INTO Parties (idPartie, idTournoi, numRonde, numTable, idJoueurBlancs, idJoueurNoirs, resultatPartie)(SELECT * FROM Palleja.FIDE_Parties);

COMMIT;