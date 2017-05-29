
-- 1

declare
	v_nbJoueurs number;
begin 
	select count(*) into v_nbJoueurs
	from Joueurs 
	where idClub='C1';
	DBMS_OUTPUT.put_Line('Il y a ' || v_nbJoueurs || ' joueur(s) dans le club C1');
End;

-- 2

Accept s_idclub prompt 'Entrez l identifiant du club : '
declare
	v_idclub Clubs.idclub%TYPE;
	v_nbJoueurs number;
begin
	v_idclub:='&s_idclub';
	select count(*) into v_nbJoueurs
	from Joueurs 
	where idClub=v_idclub;
	DBMS_OUTPUT.put_Line('Il y a ' || v_nbJoueurs || ' joueur(s) dans le club ' || v_idclub);
End;

-- 3

Accept s_idclub prompt 'Entrez l identifiant du club : '
declare
	v_idclub Clubs.idclub%TYPE;
	v_nbJoueurs number;
	v_nbclub number;
begin
	v_idclub:='&s_idclub';
	select count(*) into v_nbclub
	from Clubs
	where idclub=v_idclub;
	if v_nbclub=0 then
		DBMS_OUTPUT.put_Line('Il n y a pas de club ' || v_idclub);
	else
		select count(*) into v_nbJoueurs
		from Joueurs 
		where idClub=v_idclub;
		DBMS_OUTPUT.put_Line('Il y a ' || v_nbJoueurs || ' joueur(s) dans le club ' || v_idclub);
	End if;
End;

-- 4

Accept s_idclub prompt 'Entrez l identifiant du club : '
declare
	v_idclub Clubs.idclub%TYPE;
	v_nbJoueurs number;
	v_nbclub Clubs.idclub%TYPE;
begin
	v_idclub:='&s_idclub';
	
	select idclub into v_nbclub
	from Clubs
	where idclub=v_idclub;
	
	select count(*) into v_nbJoueurs
	from Joueurs 
	where idClub=v_idclub;
	
	DBMS_OUTPUT.put_Line('Il y a ' || v_nbJoueurs || ' joueur(s) dans le club ' || v_idclub);
Exception
	when No_data_found then
		DBMS_OUTPUT.put_Line('Il n y a pas de club ' || v_idclub);
end;

-- 5

declare
	v_idTournoi Tournois.idTournoi%TYPE;
	rty_ligne Tournois%ROWTYPE;
begin
	v_idTournoi:='T1';
	select * into rty_ligne
	from Tournois
	where idTournoi=v_idTournoi;
	DBMS_OUTPUT.put_Line('Identifiant du tournoi : ' || rty_ligne.idTournoi);
	DBMS_OUTPUT.put_Line('Nom du tournoi : ' || rty_ligne.nomTournoi);
	DBMS_OUTPUT.put_Line('Lieu du tournoi : ' || rty_ligne.lieuTournoi);
	DBMS_OUTPUT.put_Line('Nombre de rondes du tournoi : ' || rty_ligne.nbRondesTournoi);
end;

-- 6

Create or replace Function nbJoueursParClub(
	p_idClub in Clubs.idClub%TYPE) RETURN number is
	v_nbJoueurs number;
	v_nbclub Clubs.idclub%TYPE;
begin	
	select idclub into v_nbclub
	from Clubs
	where idclub=p_idclub;
	
	select count(*) into v_nbJoueurs
	from Joueurs 
	where idClub=p_idclub;
	
	return v_nbJoueurs;
Exception
	when No_data_found then
		Return Null;
end;

select nbJoueursParClub('C1')
from dual;

-- 7

create or replace Function nbJoueursParLigue(
	p_idLigue In Ligues.idLigue%TYPE) Return Number is
	retourn number;
begin
	select sum(nbJoueursParClub(idClub)) into retourn
	from Clubs
	where idLigue=p_idLigue;
	return retourn;
end;

select nbJoueursParLigue('LAN')
from dual;	

-- 7.1

UPDATE Ligues
SET  nbJoueursLigue=nbJoueursParLigue(idLigue);

-- 8 

create or replace Procedure affichageInfosTournoi(
	p_idTournoi IN Tournois.idTournoi%TYPE) is
	rty_ligne Tournois%ROWTYPE;
begin
	select * into rty_ligne
	from Tournois
	where idTournoi=p_idTournoi;
	DBMS_OUTPUT.put_Line('Identifiant du tournoi : ' || rty_ligne.idTournoi);
	DBMS_OUTPUT.put_Line('Nom du tournoi : ' || rty_ligne.nomTournoi);
	DBMS_OUTPUT.put_Line('Lieu du tournoi : ' || rty_ligne.lieuTournoi);
	DBMS_OUTPUT.put_Line('Nombre de rondes du tournoi : ' || rty_ligne.nbRondesTournoi);
Exception
	when No_data_found then
		DBMS_OUTPUT.put_Line('Le tournoi ' || p_idTournoi || ' n existe pas');
end;

-- 9

create or replace procedure miseAJourNbParticipantsTournoi is
begin
	UPDATE Tournois T
	set nbParticipantsTournoi=(select count(*)
								from Participer
								where idtournoi=T.idtournoi);
end;

-- 10

create or replace Procedure affichageParticipantsTournoi(
	p_idTournoi IN Tournois.idTournoi%TYPE) is
	rty_ligne Joueurs%ROWTYPE;	
	cursor c_participantsTournoi  is
		select *
		from Joueurs
		where idJoueur in 	(select idJoueur
					from Participer P
					where idTournoi=p_idTournoi)
		order by eloJoueur desc,nomJoueur;
begin
	open c_participantsTournoi;
	loop
		fetch c_participantsTournoi into rty_ligne;
		exit when c_participantsTournoi%NOTFOUND;
		DBMS_OUTPUT.put_Line(rty_ligne.nomJoueur || ' ' || rty_ligne.prenomJoueur || ' ' || rty_ligne.eloJoueur);		
	end loop;
	close c_participantsTournoi;
end;

-- 11

create or replace procedure affichageToutTournoi(
	p_idTournoi IN Tournois.idTournoi%TYPE) is
begin
	affichageInfosTournoi(p_idTournoi);
	affichageParticipantsTournoi(p_idTournoi);
end;

-- 12

create or replace procedure affichageJoueursParLigueEtClub(
	p_idLigue IN Ligues.idLigue%TYPE) is
	cursor c_clubsDeLaLigue is
		select *
		from Clubs 
		where idLigue=p_idLigue
		order by nomClub ;
	rty_club Clubs%ROWTYPE;
	cursor c_joueurs (p_idClub IN Joueurs.idClub%TYPE) is 
		select nomJoueur, prenomJoueur, eloJoueur , count(idTournoi) as nbTournoi
		from Joueurs J, Participer P 
		where J.idclub=p_idClub and
		J.idJoueur=P.idJoueur(+)
		group by nomJoueur, prenomJoueur, eloJoueur
		order by nbTournoi desc, eloJoueur desc;
	rty_joueur c_joueurs%ROWTYPE;
begin
	open c_clubsDeLaLigue;
	loop
		fetch c_clubsDeLaLigue into rty_club;
		exit when c_clubsDeLaLigue%NOTFOUND;
		open c_joueurs(rty_club.idClub);
		loop
			fetch c_joueurs into rty_joueur;
			exit when c_joueurs%NOTFOUND;
		end loop;
		DBMS_OUTPUT.put_Line('Club : ' || rty_club.idClub || ' ' || rty_club.nomClub || ' (' || c_joueurs%ROWCOUNT || ' joueurs)');
		close c_joueurs;
		open c_joueurs(rty_club.idClub);
		loop
			fetch c_joueurs into rty_joueur;
			exit when c_joueurs%NOTFOUND;
			DBMS_OUTPUT.put_Line('-----> ' || rty_joueur.nomJoueur || ' ' || rty_joueur.prenomJoueur || ' ' || rty_joueur.eloJoueur || ' a participé à ' || rty_joueur.nbTournoi || ' tournoi(s)');
		end loop;
		close c_joueurs;
	end loop;
	close c_clubsDeLaLigue;
end;

call affichageJoueursParLigueEtClub('LAN');

-- 13

create or replace function categorieJoueur(
	p_dateNaissance IN Joueurs.dateNaissanceJoueur%TYPE, 
	p_sexe IN Joueurs.sexeJoueur%TYPE) Return Varchar is
	v_date varchar(3);
begin
	if p_dateNaissance<='31/12/1959' then
		v_date := 'Vet';
	end if;
	if p_dateNaissance>='1/1/1960' AND p_dateNaissance<='31/12/1994' then
		v_date := 'Sen';
	end if;
	if p_dateNaissance>='1/1/1995' then
		v_date := 'Jun' ;
	end if;
	return v_date||p_sexe;
end;

select categorieJoueur('1/1/1960','M')
from dual

-- 14

create or replace procedure affichageResultatRonde(
	p_idTournoi IN Parties.idTournoi%TYPE,
	p_numRonde IN Parties.numRonde%TYPE) is
	cursor c_table is
		select J1.nomJoueur as jn1, J1.prenomJoueur as jp1, categorieJoueur(J1.dateNaissanceJoueur,J1.sexeJoueur) as jcp1, J1.eloJoueur as je1, P.resultatPartie, J2.nomJoueur, J2.prenomJoueur, categorieJoueur(J2.dateNaissanceJoueur,J2.sexeJoueur) as jc2, J2.eloJoueur
		from Joueurs J2, Parties P, Joueurs J1
		where	P.idtournoi=p_idTournoi and
				J1.idJoueur=P.idJoueurBlancs and
				J2.idJoueur=P.idJoueurNoirs and
				P.numRonde=p_numRonde
				order by P.numtable;
	rty c_table%ROWTYPE;
begin
	open c_table;
	loop
		fetch c_table into rty;
		exit when c_table%NOTFOUND;
		DBMS_OUTPUT.put_Line(rty.jn1 || ' ' || rty.jp1 || ' ' || rty.jcp1 || ' ' || rty.je1 || ' ' || rty.resultatPartie || ' ' || rty.nomJoueur || ' ' || rty.prenomJoueur || ' ' || rty.jc2 || ' ' || rty.eloJoueur);
	end loop;
	close c_table;
end;

-- 15

create or replace procedure affichageInfosJoueur(
	p_idJoueur IN Joueurs.idJoueur%TYPE) is
	rty_ligne Joueurs%ROWTYPE;
begin
	select * into rty_ligne
	from Joueurs
	where idJoueur=p_idJoueur;
	DBMS_OUTPUT.put_Line('Identifiant Joueur : ' || rty_ligne.idJoueur);
	DBMS_OUTPUT.put_Line('Nom Joueur : ' || rty_ligne.nomJoueur);
	DBMS_OUTPUT.put_Line('Prénom Joueur : ' || rty_ligne.prenomJoueur);
	DBMS_OUTPUT.put_Line('Elo Joueur : ' || rty_ligne.eloJoueur);
	DBMS_OUTPUT.put_Line('Catégorie Joueur : ' || categorieJoueur(rty_ligne.dateNaissanceJoueur,rty_ligne.sexeJoueur));
	DBMS_OUTPUT.put_Line('Club Joueur : ' || rty_ligne.idClub);
Exception
	when No_data_found then
		DBMS_OUTPUT.put_Line('Le joueur ' || p_idJoueur || ' n existe pas');
end;

call affichageInfosJoueur('J10');
call affichageInfosJoueur('J100');

-- 16

create or replace function resultatEnPoint( 
	p_couleur IN Varchar,
	p_resultat IN Parties.resultatPartie%TYPE)
	return Number is
	v_pJoueurB number :=0;
	v_pJoueurN number :=0;
begin
	if p_resultat='1-0' then
		v_pJoueurB :=1;
		v_pJoueurN :=0;
	else if p_resultat='0-1' then
		v_pJoueurB :=0;
		v_pJoueurN :=1;
	else  
		return .5;
	end if;
	end if;
	if p_couleur='B' then
		return v_pJoueurB;
	else 
		return v_pJoueurN;
	end if;
end;

select resultatEnPoint('B','1-0')
from dual;

select resultatEnPoint('B','0-1')
from dual;

select resultatEnPoint('N','1/0')
from dual;

-- 17

create or replace function couleurJoueurRonde(
	p_idJoueur IN Joueurs.idJoueur%TYPE,
	p_idTournoi IN Tournois.idTournoi%TYPE,
	p_numRonde IN Parties.numRonde%TYPE)
	return varchar is
	rty_ligne Parties%ROWTYPE;
begin
	select * into rty_ligne
	from Parties
	where 	idTournoi=p_idTournoi and
			numRonde=p_numRonde and
			(idJoueurNoirs=p_idJoueur or
			idJoueurBlancs=p_idJoueur);
	if rty_ligne.idJoueurBlancs=p_idJoueur then
		return 'B';
	else if rty_ligne.idJoueurNoirs=p_idJoueur then
		return 'N';
	end if;
	end if;
	return null;
end;

select couleurJoueurRonde('J1','T1',1)
from dual;
select couleurJoueurRonde('J1','T1',2)
from dual;

-- 18

create or replace function adversaireJoueurRonde(
	p_idJoueur IN Joueurs.idJoueur%TYPE,
	p_idTournoi IN Tournois.idTournoi%TYPE,
	p_numRonde IN Parties.numRonde%TYPE)
	return Joueurs.idJoueur%TYPE is
	rty_ligne Parties%ROWTYPE;
begin
	select * into rty_ligne
	from Parties
	where 	idTournoi=p_idTournoi and
			numRonde=p_numRonde and
			(idJoueurNoirs=p_idJoueur or
			idJoueurBlancs=p_idJoueur);
	if couleurJoueurRonde(p_idJoueur,p_idTournoi,p_numRonde)='B' then
		return rty_ligne.idJoueurNoirs;
	else if couleurJoueurRonde(p_idJoueur,p_idTournoi,p_numRonde)='N' then
		return rty_ligne.idJoueurBlancs;
	end if;
	end if;
	return null;
end;

select adversaireJoueurRonde('J10','T1',1)
from dual;
select adversaireJoueurRonde('J10','T1',2)
from dual;

-- 19

create or replace function resultatJoueurRonde(
	p_idJoueur IN Joueurs.idJoueur%TYPE,
	p_idTournoi IN Tournois.idTournoi%TYPE,
	p_numRonde IN Parties.numRonde%TYPE)
	return number is
	v_param Parties.resultatPartie%TYPE;
begin
	select resultatPartie into v_param
	from Parties
	where 	idTournoi=p_idTournoi and
			numRonde=p_numRonde and
			(idJoueurNoirs=p_idJoueur or
			idJoueurBlancs=p_idJoueur);
	return resultatEnPoint(couleurJoueurRonde(p_idJoueur,p_idTournoi,p_numRonde),v_param);
end;

select resultatJoueurRonde('J1','T2',6)
from dual;
select resultatJoueurRonde('J1','T2',7)
from dual;

-- 20
	
create or replace procedure affichagePartiesJoueurTournoi(
	p_idJoueur IN Joueurs.idJoueur%TYPE,
	p_idTournoi IN Tournois.idTournoi%TYPE) is
	cursor c_table is
		select * 
		from parties
		where (idJoueurBlancs=p_idJoueur or
		idJoueurNoirs=p_idJoueur) and
		idTournoi=p_idTournoi;
	rty c_table%ROWTYPE;
	rty_joueur Joueurs%ROWTYPE;
begin
	open c_table;
	loop
		fetch c_table into rty;
		exit when c_table%NOTFOUND;
		select * into rty_joueur
		from Joueurs
		where idJoueur=adversaireJoueurRonde(p_idJoueur,p_idTournoi,rty.numRonde);
		DBMS_OUTPUT.put_Line('R' || rty.numRonde || ' ' || couleurJoueurRonde(p_idJoueur,p_idTournoi,rty.numRonde) || ' ' || rty_joueur.nomJoueur || ' ' || rty_joueur.prenomJoueur || ' ' || categorieJoueur(rty_joueur.dateNaissanceJoueur,rty_joueur.sexeJoueur) || ' ' || rty_joueur.eloJoueur || ' ' || resultatJoueurRonde(p_idJoueur,p_idTournoi,rty.numRonde));
	end loop;
end;

call affichagePartiesJoueurTournoi('J4','T3');
call affichagePartiesJoueurTournoi('J6','T2');

-- 21

create or replace function nbPointsJoueurTournoi(
	p_idJoueur IN Joueurs.idJoueur%TYPE,
	p_idTournoi IN Tournois.idTournoi%TYPE)
	return number is
	cursor c_table is
		select numRonde 
		from parties
		where (idJoueurNoirs=p_idJoueur or idJoueurBlancs=p_idJoueur) and
		idTournoi=p_idTournoi;
	resultat number := 0;
	rty c_table%ROWTYPE;
begin
	open c_table;
	loop
		fetch c_table into rty;
		exit when c_table%NOTFOUND;
		resultat := resultat + resultatJoueurRonde(p_idJoueur,p_idTournoi,rty.numRonde);
	end loop;
	close c_table;
	return resultat;
end;

select nbPointsJoueurTournoi('J10','T1')
from dual;
select nbPointsJoueurTournoi('J8','T1')
from dual;
select nbPointsJoueurTournoi('J8','T2')
from dual;

-- 22

create or replace function cumulatifJoueurTournoi(
	p_idJoueur IN Joueurs.idJoueur%TYPE,
	p_idTournoi IN Tournois.idTournoi%TYPE)
	return number is
	cursor c_table is
		select numRonde 
		from parties
		where (idJoueurNoirs=p_idJoueur or idJoueurBlancs=p_idJoueur) and
		idTournoi=p_idTournoi;
	cursor c_table1 is
		select numRonde 
		from parties
		where (idJoueurNoirs=p_idJoueur or idJoueurBlancs=p_idJoueur) and
		idTournoi=p_idTournoi;
	resultat number := 0;
	rty c_table%ROWTYPE;
	compteur number := 1;
	rty1 c_table1%ROWTYPE;
begin
	open c_table;
	loop
		fetch c_table into rty;
		exit when c_table%NOTFOUND;
		open c_table1;
		for c in 1..compteur loop
			fetch c_table1 into rty1;
			resultat := resultat +  resultatJoueurRonde(p_idJoueur,p_idTournoi,rty1.numRonde);
		end loop;
		close c_table1;
		compteur := compteur + 1;
	end loop;
	close c_table;
	return resultat;
end;

select cumulatifJoueurTournoi('J1','T2')
from dual;
select cumulatifJoueurTournoi('J4','T1')
from dual;

-- 23

create or replace function performanceEloJoueurTournoi(
	p_idJoueur IN Joueurs.idJoueur%TYPE,
	p_idTournoi IN Tournois.idTournoi%TYPE)
	return number is
	nbPoints number := nbPointsJoueurTournoi(p_idJoueur,p_idTournoi);
	cursor c_table is
		select numRonde 
		from parties
		where (idJoueurNoirs=p_idJoueur or idJoueurBlancs=p_idJoueur) and
		idTournoi=p_idTournoi;
	rty c_table%ROWTYPE;
	compteur number := 0;
	compteurElo number := 0;
	buffElo number;
begin
	open c_table;
	loop
		fetch c_table into rty;
		exit when c_table%NOTFOUND;
		select eloJoueur into buffElo
		from Joueurs
		where idJoueur=adversaireJoueurRonde(p_idJoueur, p_idTournoi, rty.numRonde);
		compteurElo := compteurElo + buffElo;
		compteur := compteur + 1;
	end loop;
	return compteurElo/compteur + (nbPoints/compteur - 0.5)*750;
end;

select performanceEloJoueurTournoi('J26','T2')
from dual;
select performanceEloJoueurTournoi('J11','T2')
from dual;
select performanceEloJoueurTournoi('J8','T3')
from dual;
select performanceEloJoueurTournoi('J24','T2')
from dual;

-- 24 

create or replace procedure affichageResultatJoueurTournoi(
	p_idJoueur IN Joueurs.idJoueur%TYPE,
	p_idTournoi IN Tournois.idTournoi%TYPE) is
begin
	DBMS_OUTPUT.put_Line('Nombre de points : ' || nbPointsJoueurTournoi(p_idJoueur,p_idTournoi));
	DBMS_OUTPUT.put_Line('Cumulatif : ' || cumulatifJoueurTournoi(p_idJoueur,p_idTournoi));
	DBMS_OUTPUT.put_Line('Perf : ' || performanceEloJoueurTournoi(p_idJoueur,p_idTournoi));
end;

call affichageResultatJoueurTournoi('J1','T2');
call affichageResultatJoueurTournoi('J10','T3');

-- 25

create or replace function estInvaincu(
	p_idJoueur IN Joueurs.idJoueur%TYPE,
	p_idTournoi IN Tournois.idTournoi%TYPE)
	return number is
	nbPoints number := nbPointsJoueurTournoi(p_idJoueur,p_idTournoi);
	compteur number := 0;
	cursor c_table is
		select numRonde 
		from parties
		where (idJoueurNoirs=p_idJoueur or idJoueurBlancs=p_idJoueur) and
		idTournoi=p_idTournoi;
	rty c_table%ROWTYPE;
begin
	open c_table;
	loop
		fetch c_table into rty;
		exit when c_table%NOTFOUND;
		compteur := compteur + 1;
	end loop;
	if compteur=nbPoints then
		return 1;
	else 
		return 0;
	end if;
end;

select estInvaincu('J10','T2')
from dual;
select estInvaincu('J27','T2')
from dual;

--

set serveroutput on;

-- 
