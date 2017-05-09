
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

Create or replace Function nbJoueursParClub(p_idClub in Clubs.idClub%TYPE) RETURN number is
	v_idclub Clubs.idclub%TYPE;
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

create or replace Function nbJoueursParLigue(p_idLigue In Ligues.idLigue%TYPE) Return Number is
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

create or replace Procedure affichageInfosTournoi(p_idTournoi IN Tournois.idTournoi%TYPE) is
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

create or replace Procedure affichageParticipantsTournoi(p_idTournoi IN Tournois.idTournoi%TYPE) is
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

create or replace procedure affichageToutTournoi(p_idTournoi IN Tournois.idTournoi%TYPE) is
begin
	affichageInfosTournoi(p_idTournoi);
	-- Trouver pour sauter une ligne
	affichageParticipantsTournoi(p_idTournoi);
end;

--

set serveroutput on;

-- 














