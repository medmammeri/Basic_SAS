/*
Mohamed Mammeri
*/

/*Exercice 1*/

/* 1.1 */

LIBNAME Projet "C:\Users\Desktop\Projet\PROJET FINAL";

DATA IMPORT; /* Creation de la table IMPORT dans la bibliotheque temporaire */
INFILE CARDS4 DLM=";"; /* Interpretation du caractere ';' comme separateur de champs */
INPUT TEST $ @; /* L'insertion est stoppee pour effectuer un test sur la variable TEST  */
IF TEST=59 THEN DO; /* Si la variable TEST vaut 59 alors la ligne de donnees est importee */
	INPUT CODE $ LIBELLE :$17.;
	OUTPUT;
END; /* Fin du test */
DROP TEST; /* La variable TEST n'est pas importe dans la table IMPORT */
CARDS4; /* La plage de donnees à saisir commence. */
62;62041;ARRAS
59;59009;VILLENEUVE-D'ASCQ
59;59350;LILLE
62;62498;LENS
59;59360;LOOS
62;62193;CALAIS
;;;; /* La plage de donnees ae saisir est terminee. */
RUN;

/* 1.2 */
/*  
Le fichier commence par des informations relatives aux donnees qu'il contient,
qui commencent a la ligne 14. Il contient 10 variables qualitatives et quantitatives.

Les lignes pouvant poser probleme lors d'une importation sont les premieres lignes decrivant le document,
ainsi que les lignes comptabilisant les totaux par annee, ces lignes sont caracterisees
par le caractere '*' au debut.
*/

/* 1.3 */

DATA PROJET.TGV; 
INFILE 'C:\Users\Desktop\Projet\PROJET FINAL/Regularite mensuelle TGV.txt' DLM = "|" ;
INPUT  TEST $ @;
IF TEST='*' THEN DO;
INPUT annee $ mois $ id_trajet $ id_gare_depart $ gare_depart :$40. id_gare_arrivee $ gare_arrivee :$40. nb_tgv_programmee nb_tgv_annulee nb_tgv_retard;
OUTPUT;
END;
DROP TEST;
RUN;


/* 1.4 */

PROC PRINT DATA=PROJET.TGV (OBS=20);
RUN;

/* 1.5 */

PROC CONTENTS DATA=PROJET.TGV;
RUN;
/*
Il y a 4800 observations. 
Attributs des variables :
Libelle				Type	Longueur
annee				Texte	8
gare_arrivee		Texte	40
gare_depart			Texte	40
id_gare_arrivee		Texte	8
id_gare_depart		Texte	8
id_trajet			Texte	8
mois				Texte	8
nb_tgv_annulee		Num.	8
nb_tgv_programmee	Num.	8
nb_tgv_retard		Num.	8

La table n'est pas triee.

Les variables qualitatives : annee, gare_arrivee, gare_depart, id_gare_arrivee, id_gare_depart, id_trajet, mois.
Les variables quatitatives : nb_tgv_annulee, nb_tgv_programmee, nb_tgv_retard.
*/

/* 1.6 */

PROC MEANS DATA=PROJET.TGV SUM MEAN MIN MAX MEDIAN;
VAR nb_tgv_programmee nb_tgv_retard nb_tgv_annulee;
RUN;

PROC MEANS DATA=PROJET.TGV NMISS;
VAR nb_tgv_programmee nb_tgv_retard nb_tgv_annulee;
RUN;

/* Oui il y a des valeurs manquantes */

PROC PRINT DATA=PROJET.TGV;
	WHERE MISSING(nb_tgv_programmee)
	OR MISSING(nb_tgv_annulee)
	OR MISSING(nb_tgv_retard);
RUN;

/* 1.7 */

PROC MEANS DATA=PROJET.TGV SUM MEAN MIN MAX MEDIAN NMISS;
CLASS annee;
RUN;

/* Les resultats des sommes correspondent aux sommes du fichier source. */

/* 1.8 */

PROC FREQ DATA=PROJET.TGV NLEVELS;
TABLES annee--gare_arrivee / NOPRINT;
RUN;

/* La variable id_trajet peut prendre 100 modalites differentes */

/* 1.9 */

PROC FREQ DATA = PROJET.TGV;
TABLES annee--gare_arrivee;
WEIGHT nb_tgv_programmee;
RUN;

/* 1.10 */

PROC PRINT DATA=projet.structure_sncf (OBS=20);
RUN;

/* 1.11 */

PROC CONTENTS DATA=projet.structure_sncf;
RUN;
 /*
Il y a 100 observations, 3 varaibles :
Libelle		Type	Longueur
ID_AXE		Texte	2
AXE			Texte	10
ID_TRAJET	Texte	3,
la table est triee selon la variable id_trajet.
*/
/* 1.12 */

PROC FREQ DATA=projet.structure_sncf NLEVELS;
TABLES ID_AXE--ID_TRAJET / NOPRINT;
RUN;

/* 1.13 */

PROC FREQ DATA=projet.structure_sncf;
TABLE AXE / NOCUM NOPERCENT;
RUN;

/* 1.14 */

	/*
	La variable qui doit etre utilisee comme cle de jointure pour fusionner les tables TGV et STRUCTURE_SNCF est ID_TRAJET.
	Les points à verifier sont les suivants :
		1. Les variables identifiant_trajet doivent avoir le meme nom ID_TRAJET
		2. La variable ID_TRAJET doit avoir le meme type et la meme longueur dans les deux tables
		3. Verifier que les deux tables n'ont pas d'autres variables en commun qui risqueraient d'etre ecrasees, les renommer le cas echeant
		4. Trier les deux tables selon la cle de jointure
	*/

PROC SORT DATA=PROJET.structure_sncf; BY ID_TRAJET;
RUN;

PROC SORT DATA=PROJET.TGV; BY ID_TRAJET;
RUN;

DATA TGV_STRUCTURE_SNCF;
MERGE PROJET.TGV PROJET.STRUCTURE_SNCF; BY ID_TRAJET;
RUN;

/* 1.15 */

	/* 1.15.1 */
PROC FREQ DATA=tgv_structure_sncf;
TABLES AXE;
WEIGHT nb_tgv_programmee;
WHERE annee='2015';
RUN;

/* Il s'agit de l'axe SUD-EST avec un pourcentage de 44,06% */

	/* 1.15.2 */
/* Question pas tres bien comprise */

PROC MEANS DATA=tgv_structure_sncf MEAN;
VAR nb_tgv_programmee;
CLASS AXE;
WHERE annee='2015';
RUN;
/*
L'axe avec le nombre moyen de tgv programmes en 2015 le plus eleve est est l'axe atlantique.
L'axe avec le nombre moyen de tgv programmes en 2015 le plus faible est est l'axe est.
*/

	/* 1.15.3 */
PROC FREQ DATA=tgv_structure_sncf ORDER=FREQ;
TABLES gare_arrivee / NOCUM NOPERCENT;
WEIGHT nb_tgv_programmee;
RUN;
/* La ville la mieux desservie est Paris */	

	/* 1.15.4 */
PROC FREQ DATA=tgv_structure_sncf ORDER=FREQ;
TABLES annee*mois / NOCUM;
WEIGHT nb_tgv_annulee;
RUN;

/* L'annee où le nombre de tgv annules a ete le plus eleve est 2014 avec un pourcentage de 60,77%,
au mois de juin en particulier avec un pourcentage de 56,91% des annulations en 2014. */

/* 1.16 */

PROC MEANS DATA=tgv_structure_sncf SUM;
VAR nb_tgv_programmee--nb_tgv_retard;
CLASS AXE annee;
TYPES annee AXE*annee;
OUTPUT OUT=RESULTAT SUM=nb_tgv_programmee nb_tgv_annule nb_tgv_retarde;
RUN;

/* 1.17 */

DATA RESULTAT;
SET RESULTAT;
pct_annulation = nb_tgv_annule/nb_tgv_programmee;
pct_regulartie=(nb_tgv_programmee-nb_tgv_annule-nb_tgv_retarde)/(nb_tgv_programmee-nb_tgv_annule);
rapport=(nb_tgv_programmee-nb_tgv_annule-nb_tgv_retarde)/nb_tgv_retarde;
RUN;

/* 1.18 */

PROC SORT DATA=resultat;
BY AXE DESCENDING annee;
RUN;

ODS PDF FILE="C:\Users\Desktop\Projet\PROJET FINAL/Rapport.pdf"
STYLE=PLATEAU STARTPAGE=NO;
TITLE "Regularite des TGV par axe en 2015, 2014, 2013 et 2012";
PROC PRINT DATA=RESULTAT NOOBS;
VAR annee nb_tgv_programmee nb_tgv_annule pct_annulation nb_tgv_retarde pct_regulartie rapport;
WHERE _TYPE_=1;
FORMAT pct_annulation pct_regulartie PERCENT8.1 nb_tgv_programmee nb_tgv_annule nb_tgv_retarde NLNUM10. rapport NLNUM10.1;
RUN;
PROC PRINT DATA=RESULTAT NOOBS;
VAR annee nb_tgv_programmee nb_tgv_annule pct_annulation nb_tgv_retarde pct_regulartie rapport;
BY AXE;
WHERE _TYPE_=3;
FORMAT pct_annulation pct_regulartie PERCENT8.1 nb_tgv_programmee nb_tgv_annule nb_tgv_retarde NLNUM10. rapport NLNUM10.1;
RUN;
ODS PDF CLOSE;

/*Exercice 2*/

/* 2.1 */

PROC CONTENTS DATA = Projet.CAC40_2016 ORDER = VARNUM ;
RUN;

/* Nombre d'observations = 237, 
Nombre de variables = 6, 
1-COD_ISIN 2-DATE_COTATION 3-COURS_OUV 4-COURS_MAX 5-COURS_MIN 6-COURS_CLT
Les observations sont trier par la variable 2-DATE_COTATION */

/* 2.2 */

DATA Projet.CAC40_2016_N1;
SET Projet.CAC40_2016;
JOUR = DAY (DATE_COTATION);
ANNEE = YEAR (DATE_COTATION);
MOIS = MONTH (DATE_COTATION);
RUN;
PROC SORT DATA = Projet.CAC40_2016_N1;
BY ANNEE MOIS;
RUN;
DATA Projet.CAC40_2016_N1;
SET Projet.CAC40_2016_N1;
BY ANNEE MOIS;
RETAIN NB_JOURS_M COURS_CLT_PREC 0;
ATTRIB VAR_M_PCT FORMAT = NLPCTN9.1;
ATTRIB VAR_A_PCT FORMAT = NLPCTN9.1;
IF FIRST.MOIS THEN NB_JOURS_M = 0;
NB_JOURS_M = NB_JOURS_M+1;
IF LAST.MOIS  THEN DO;
    VAR_M_PCT = COURS_CLT/COURS_CLT_PREC-1;
    VAR_M = COURS_CLT - COURS_CLT_PREC;
	COURS_CLT_PREC = COURS_CLT;
END;
IF LAST.MOIS  THEN DO;
    VAR_A_PCT = COURS_CLT/4637.06-1;
    VAR_A = COURS_CLT - 4637.06;
END;
RUN;
DATA Projet.CAC40_2016_N1;
SET Projet.CAC40_2016_N1;
FORMAT DATE_COTATION DDMMYY10.;
FORMAT COURS_CLT NUMX9.1;
FORMAT VAR_M NUMX9.1;
FORMAT VAR_A NUMX9.1;
BY ANNEE MOIS;
IF LAST.MOIS AND ANNEE = 2016;
RUN;
PROC PRINT DATA = Projet.CAC40_2016_N1;
VAR DATE_COTATION NB_JOURS_M COURS_CLT VAR_M VAR_M_PCT VAR_A VAR_A_PCT;
RUN;

/*Exercice 3*/

/* 3.1. */

	/* Cette probabilite est donnee par le quart de l'aire du cercle de rayon 
	1 i.e. pi/4. */

/* 3.2. */

	/* Les coordonnees x et y du point doivent verifier la condition suivante 
	: x^2+y^2<=1. */

/* 3.3. */

	/* Le ratio k/n tend vers la probabilite qu'un point P tire au hasard
 	du carre unite soit dans le quart de cercle. Une approximation de pi est 
 	alors donnee par 4k/n. */
 
/* 3.4. */

%MACRO Pi(n);
%LET k=0;  /* Cette variable compte le nombre de points dans le quart cercle
 des n tirages effectues  */
%DO i=1 %TO &n.;
	%LET x=%SYSFUNC(RANUNI(0));  
	%LET y=%SYSFUNC(RANUNI(0));
	%IF %SYSEVALF(&x.**2+&y.**2)<=1 %THEN %DO; 
	%LET k=%EVAL(&k.+1); 
	%END;
%END;
%PUT Une approximation de pi basee sur &n. tirages aleatoires de points du
carre unite est donnee par %SYSEVALF(4*&k./&n.).;
%MEND Pi;

%Pi(10);
%Pi(100);
%Pi(1000);
%Pi(10000);

/* 3.5. */

%MACRO Pi(n);
%LET k=0;
%DO i=1 %TO &n.;
	%LET x=%SYSFUNC(RANUNI(0));
	%LET y=%SYSFUNC(RANUNI(0));
	%IF %SYSEVALF(&x.**2+&y.**2)<=1 %THEN %DO; 
	%LET k=%EVAL(&k.+1); 
	%END;
%END;
%GLOBAL pi_glob; /* La variable globale qui contiendra l'estimation de pi */
%LET pi_glob=%SYSEVALF(4*&k./&n.);
%MEND Pi;

%Pi(10);
%Put &pi_glob.;
%Pi(100);
%Put &pi_glob.;
%Pi(1000);
%Put &pi_glob.;
%Pi(10000);
%Put &pi_glob.;

/* 3.6. */

%MACRO Pi2(deb, fin, pas);
DATA PI;
%DO i=%EVAL(&deb.-1) /* Le -1 a pour but rectifier un decallage */ %TO &fin. %BY &pas.;
	%Pi(&i.);
	n=&i.;
	approximation_pi=&pi_glob.;
	OUTPUT; /* A chaque iteration on enregistre n et la valeur et l'approximation de pi associee */
%END;
RUN;
%MEND Pi2;

%Pi2(100,5000,99);

PROC PRINT DATA=PI;
RUN;

/* 3.7. */

DATA _NULL_;
SET PI;
FILE "C:\Users\Desktop\Projet\PROJET FINAL/PI.csv" DLM=";";
PUT n approximation_pi NUMX9.5;
RUN;

/*Exercice 4*/

/* 4.1. */

PROC PRINT DATA = Projet.BASE_DECES_2015 (OBS = 20);
RUN;

/* 4.2. */

PROC CONTENTS DATA =Projet.BASE_DECES_2015 ORDER=VARNUM;
RUN;

/* Nombre d'observations = 590791, 
Nombre de variables = 11, 
1-ANNEE_DECES 2-MOIS_DECES 3-SEXE 4-AGE 5-COD_LIEU_DECES 6-LIB_LIEU_DECES 7-COD_ACTIVITE 8-LIB_ACTIVITE 9-COD_ETAT_MAT 10-LIB_ETAT_MAT 11-COD_COMMUNE
Les observations sont trier par la variable 3-SEXE
variable quantitative 4-AGE Type Num
variable qualitative 1-ANNEE_DECES 2-MOIS_DECES 3-SEXE 5-COD_LIEU_DECES 6-LIB_LIEU_DECES 7-COD_ACTIVITE 8-LIB_ACTIVITE 9-COD_ETAT_MAT 10-LIB_ETAT_MAT 11-COD_COMMUNE Type Texte */

/* 4.3. */

PROC FREQ DATA = Projet.BASE_DECES_2015 NLEVELS;
TABLES ANNEE_DECES MOIS_DECES SEXE COD_LIEU_DECES LIB_LIEU_DECES COD_ACTIVITE LIB_ACTIVITE COD_ETAT_MAT LIB_ETAT_MAT COD_COMMUNE / NOPRINT;
RUN;

/*La variable COD_COMMUNE peut prendre 31268 modalites.*/

/* 4.4. */

PROC FREQ DATA = Projet.BASE_DECES_2015;
TABLES ANNEE_DECES MOIS_DECES SEXE COD_LIEU_DECES LIB_LIEU_DECES COD_ACTIVITE LIB_ACTIVITE COD_ETAT_MAT LIB_ETAT_MAT COD_COMMUNE;
RUN;

/* La variable : ANNEE_DECES : elle contient une seule modalite 2015 de frequence 590791 (100 %)
La variable : MOIS_DECES :  elle contient 12 modalites de 1 e 12 chacune de frequence et pourcentage donnees dans la table ( )
La variable : SEXE :  elle contient 2 modalites de F (Femme) et M (masculin) chacune de frequence 295664, 295127 et pourcentage 50.05, 49.95 donnees dans la table ( )
La variable : COD_LIEU_DECES :  elle contient 4 modalites de 1 e 4 chacune de frequence et pourcentage donnees dans la table ( )
La variable : LIB_LIEU_DECES :  elle contient 4 modalites AUTRE, HOSPICE, MAISON DE RETRAITE, LOGEMENT OU DOMICILE, eTABLISSEMENT HOSPITALIER OU CLINIQUE PRIVeE chacune de frequence et pourcentage donnees dans la table ( )
La variable : COD_ACTIVITE :  elle contient 3 modalites de 1 e 3 chacune de frequence et pourcentage donnees dans la table ( )
La variable : LIB_ACTIVITE :  elle contient 3 modalites ACTIF, INACTIF, RETRAITe chacune de frequence et pourcentage donnees dans la table ( )
La variable : COD_ETAT_MAT :  elle contient 4 modalites de 1 e 4 chacune de frequence et pourcentage donnees dans la table ( )
La variable : LIB_ETAT_MAT :  elle contient 4 modalites CeLIBATAIRE, DIVORCe, MARIe, VEUF chacune de frequence et pourcentage donnees dans la table ( )
La variable : COD_COMMUNE :  elle contient 96423 modalites de 01001 e 97424 chacune de frequence et pourcentage donnees dans la table ( ) */

/* 4.5. */

/* 4.5.1 */
PROC FREQ DATA = Projet.BASE_DECES_2015;
TABLES SEXE*AGE;
RUN;
/* On remarque de 0 ans jusqu'e 85 ans le plus grand nombre de deces sont les personnes de sexe Masculin apres on trouve l'inverse apres 85 ans.
Si on analyse par rapport e la totalite (M+F) on voit qu'il y a un grand nombre qui nee morts (age = 0) apres ea demenu jusqu'e l'age de 4 ans et ea augmente d'une maniere continue apres l'age de 14 ans, et de 60 ans jusqu'e 93 ans on voit une augmentation remarquable ce qu'est tout e fait naturel */

/* 4.5.2 */
PROC FREQ DATA = Projet.BASE_DECES_2015;
TABLES SEXE*LIB_LIEU_DECES;
RUN; 

/* 4.5.3 */
PROC FREQ DATA = Projet.BASE_DECES_2015;
TABLES SEXE*LIB_ACTIVITE;
RUN;

/* 4.5.4 */
PROC FREQ DATA = Projet.BASE_DECES_2015;
TABLES SEXE*LIB_ETAT_MAT;
RUN;

/* 4.5.5 */
PROC FREQ DATA = Projet.BASE_DECES_2015;
TABLES AGE*LIB_LIEU_DECES;
RUN;

/* 4.5.6 */
PROC FREQ DATA = Projet.BASE_DECES_2015;
TABLES AGE*LIB_ACTIVITE;
RUN;

/* 4.5.7 */
PROC FREQ DATA = Projet.BASE_DECES_2015;
TABLES AGE*LIB_ETAT_MAT;
RUN;

/* 4.6. */

PROC MEANS DATA = Projet.BASE_DECES_2015 N NMISS MEAN MIN MAX MEDIAN;
VAR AGE;
RUN;

/* Il n'y a pas des observations avec des valeurs manquante */

/* 4.7. */

PROC MEANS DATA = Projet.BASE_DECES_2015 N NMISS MEAN MIN MAX MEDIAN;
VAR AGE;
CLASS SEXE;
RUN;

/* La moyenne de deces pour un Homme = 74.9743060 
La moyenne de deces pour une Femme = 82.5215616 */

/* 4.8. */

PROC UNIVARIATE DATA = Projet.BASE_DECES_2015;
VAR AGE;
CLASS SEXE;
RUN;

/* Sexe F : Ecart interquartile = 14.00000 = Q3(troisieme quantile (3N/4)) - Q1(premier quantile (N/4)) = 92 - 78
Sexe M : Ecart interquartile = 21.00000 = Q3(troisieme quantile (3N/4)) - Q1(premier quantile (N/4)) = 87 - 66 */

/* 4.9. */

PROC BOXPLOT DATA = Projet.BASE_DECES_2015;
PLOT AGE*SEXE;
RUN;

/* La boite de moustache de la variable AGE selon SEXE=F (Femme), la mediane des femme = 85, le quart des femme d'intervalle d'age important deces entre 0 et 77 ans, la moite des Femmes d'un intervalle d'age peut important deces entre 77 et 90 ans, le dernier quart des femmes se deces entre 90 et 120 ans
La boite de moustache de la variable AGE selon SEXE=M (mMasculin), la mediane des homme = 78, le quart des hommes d'intervalle d'age important deces entre 0 et 68 ans, la moite des hommes d'un intervalle d'age peut important deces entre 68 et 85 ans, le dernier quart des hommes se deces entre 85 et 109 ans */

/* 4.10. */

DATA Projet.BASE_DECES_2015_TRANCHE_AGE;
SET Projet.BASE_DECES_2015;
ATTRIB TRANCHE_AGE LENGTH = $ 20.;
IF AGE < 18 THEN TRANCHE_AGE = "0 - 17 ANS.";
ELSE IF AGE >= 18 AND AGE < 45 THEN TRANCHE_AGE = "18 - 44 ANS.";
ELSE IF AGE >= 45 AND AGE < 60 THEN TRANCHE_AGE = "45 - 59 ANS.";
ELSE IF AGE >= 60 AND AGE < 75 THEN TRANCHE_AGE = "60 - 74 ANS.";
ELSE IF AGE >= 75 AND AGE < 85 THEN TRANCHE_AGE = "75 - 84 ANS.";
ELSE IF AGE >= 85 AND AGE < 95 THEN TRANCHE_AGE = "85 - 94 ANS.";
ELSE IF AGE >= 95 THEN TRANCHE_AGE = "95 ANS ET PLUS.";
RUN;

/* 4.11. */

PROC FREQ DATA = Projet.BASE_DECES_2015_TRANCHE_AGE;
TABLES TRANCHE_AGE;
RUN;

/* 4.12. */

PROC FREQ DATA = Projet.BASE_DECES_2015_TRANCHE_AGE;
TABLES TRANCHE_AGE*SEXE;
RUN;

/* Pour les tranches 0-17 ans, 18-44 ans, 45-59 ans, 60-74 ans, 75-84 ans il y a plus de deces Masculin que Femme telle que jusqu'e 74 ans presque le double sachant que le nombre de Masculin est aussi presque le double apres on voit l'inverse.
Si on analyse sur la totalite on voit que le nombre de deces total est moins important pour les tranches 0-17 ans, 18-44 ans, 45-59 ans que pour 60-74 ans, 75-84, 85-94 ans apres ea baisse car le nombre de personne reste vivant jusqu'a cette age est faible. */

/* 4.13. */

PROC SORT DATA = Projet.BASE_DECES_2015_TRANCHE_AGE;
BY COD_COMMUNE;
RUN;
DATA CONSO_COMMUNE;
SET Projet.BASE_DECES_2015_TRANCHE_AGE (KEEP = COD_COMMUNE SEXE TRANCHE_AGE);
BY COD_COMMUNE;
RETAIN NB_DECES NB_DECES_H NB_DECES_F NB_DECES_0_17 NB_DECES_18_44 NB_DECES_45_59 NB_DECES_60_74  NB_DECES_75_84 NB_DECES_85_94 NB_DECES_SUP_95;
IF FIRST.COD_COMMUNE THEN DO;
NB_DECES_H = 0;
NB_DECES_F = 0;
NB_DECES_0_17 = 0;
NB_DECES_18_44 = 0;
NB_DECES_45_59 = 0;
NB_DECES_60_74 = 0;
NB_DECES_75_84 = 0;
NB_DECES_85_94 = 0;
NB_DECES_SUP_95 =0;
END;
IF (SEXE = "M") THEN NB_DECES_H = NB_DECES_H + 1;
IF (SEXE = "F") THEN NB_DECES_F = NB_DECES_F + 1;
NB_DECES = NB_DECES_H + NB_DECES_F;
IF (TRANCHE_AGE = "0 - 17 ANS." ) THEN NB_DECES_0_17 = NB_DECES_0_17 + 1;
IF (TRANCHE_AGE = "18 - 44 ANS." ) THEN NB_DECES_18_44 = NB_DECES_18_44 + 1;
IF (TRANCHE_AGE = "45 - 59 ANS." ) THEN NB_DECES_45_59 = NB_DECES_45_59 + 1;
IF (TRANCHE_AGE = "60 - 74 ANS." ) THEN NB_DECES_60_74 = NB_DECES_60_74 + 1;
IF (TRANCHE_AGE = "75 - 84 ANS." ) THEN NB_DECES_75_84 = NB_DECES_75_84 + 1;
IF (TRANCHE_AGE = "85 - 94 ANS." ) THEN NB_DECES_85_94 = NB_DECES_85_94 + 1;
IF (TRANCHE_AGE = "95 ANS ET PLUS." ) THEN NB_DECES_SUP_95 = NB_DECES_SUP_95 + 1;
DROP SEXE TRANCHE_AGE;
IF LAST.COD_COMMUNE;
RUN;

/* 4.14. */

PROC CONTENTS DATA =Projet.STRUCTURE_TERRITOIRE ORDER=VARNUM;
RUN;

/* Nombre d'observations = 36815, 
Nombre de variables = 5, 
1- NIVEAU 2- CODE 3- LIBELLE 4- NIVEAU_SUP 5- CODE_SUP
Les observations sont trier par la variable 1- NIVEAU ET 2- CODE */

/* 4.15. */
/* La table STRUCTURE_TERRITOIRE est organiser par NIVEAU, telle que : 
NIVEAU = 1 : les donnees est organiser par region 
NIVEAU = 2 : les donnees est organiser par departement, ainsi chaque departement est signaler la region ou il appartient par le NIVEAU_SUP et CODE_SUP
NIVEAU = 3 : les donnees est organiser par commune, ainsi chaque commune est signaler le departement ou elle appartenu par le NIVEAU_SUP et CODE_SUP
On peut exploiter cette table on faisant le traitement de chaque NIVEAU a part (ou on separant la table STRUCTURE_TERRITOIRE on 3 tables : region - departement - commune) */

/* 4.16. */

PROC SQL;
CREATE TABLE REGION AS
SELECT 
	NIVEAU,
	CODE AS COD_REGION,
	LIBELLE AS LIB_REGION
FROM 
	Projet.STRUCTURE_TERRITOIRE
WHERE 
	NIVEAU = 1
GROUP BY 
	CODE,
	LIBELLE;
QUIT;

PROC SQL;
CREATE TABLE DEPARTEMENT AS
SELECT 
	NIVEAU_SUP AS NIVEAU,
	CODE_SUP AS COD_REGION,
	CODE AS COD_DEPARTEMENT,
	LIBELLE AS LIB_DEPARTEMENT
FROM 
	Projet.STRUCTURE_TERRITOIRE
WHERE 
	NIVEAU = 2
GROUP BY 
	CODE_SUP,
	CODE,
	LIBELLE;
QUIT;

PROC SQL;
CREATE TABLE COMMUNE AS
SELECT 
	NIVEAU_SUP AS NIVEAU,
	CODE_SUP AS COD_DEPARTEMENT,
	CODE AS COD_COMMUNE,
	LIBELLE AS LIB_COMMUNE
FROM 
	Projet.STRUCTURE_TERRITOIRE
WHERE 
	NIVEAU = 3
GROUP BY 
	CODE_SUP,
	CODE,
	LIBELLE;
QUIT;

PROC SQL;
CREATE TABLE STRUCTURE AS 
SELECT 
	REGION.COD_REGION,
	REGION.LIB_REGION,
	DEPARTEMENT.COD_DEPARTEMENT,
	DEPARTEMENT.LIB_DEPARTEMENT,
	COMMUNE.COD_COMMUNE,
	COMMUNE.LIB_COMMUNE
FROM 
	WORK.REGION FULL JOIN WORK.DEPARTEMENT
	ON REGION.COD_REGION = DEPARTEMENT.COD_REGION
	FULL JOIN WORK.COMMUNE
	ON DEPARTEMENT.COD_DEPARTEMENT =COMMUNE.COD_DEPARTEMENT
ORDER BY 
	COD_REGION,
	LIB_REGION,
	COD_DEPARTEMENT,
	LIB_DEPARTEMENT,
	COD_COMMUNE,
	LIB_COMMUNE;
QUIT;

/* 4.17. */

PROC SQL;
SELECT 
	COUNT(DISTINCT COD_REGION)
FROM 
	WORK.STRUCTURE;
QUIT;

/* Il y a 17 regions */

PROC SQL;
SELECT 
	COUNT(DISTINCT COD_DEPARTEMENT)
FROM 
	WORK.STRUCTURE;
QUIT;

/* Il y a 100 departements */

PROC SQL;
SELECT 
	COUNT(DISTINCT COD_COMMUNE)
FROM 
	WORK.STRUCTURE;
QUIT;

/* Il y a 36698 communes  */

/* 4.18. */

PROC SQL;
SELECT DISTINCT
	LIB_REGION,
	COUNT (DISTINCT COD_DEPARTEMENT),
	COUNT(DISTINCT COD_COMMUNE)
FROM
	WORK.STRUCTURE
GROUP BY 
	LIB_REGION;
QUIT;

/* 4.19. */

PROC SQL;
SELECT
	LIB_COMMUNE,
    	COUNT(*) AS NB_APPARITION
FROM
	WORK.STRUCTURE 
WHERE 
	LIB_REGION ="NORD-PAS-DE-CALAIS-PICARDIE" AND  LIB_DEPARTEMENT IN ("NORD", "PAS DE CALAIS")
GROUP BY 
	LIB_COMMUNE
HAVING
	NB_APPARITION > 1;
QUIT;

/* Il y a la cummune : SAINT-AUBIN qui est dans le departement NORD et departement pas de calais  */

/* 4.20. */

PROC SQL;
SELECT
	LIB_COMMUNE,
    COUNT(*) AS NB_APPARITION
FROM
	WORK.STRUCTURE 
GROUP BY 
	LIB_COMMUNE
HAVING
	NB_APPARITION > 1
ORDER BY
	NB_APPARITION DESC;
QUIT;

/* La commune la plus rependu est : SAINTE-COLOMBE, Telle que il y a 13 communes qui porte nom */

/* 4.19.  IL Y AVAIT UNE REDENDANCE DANS LES NUMERO DE QUESTIONS DANS LE SUJET DE PROJET */

/* La cle de jointure entre la table STRUCTURE et la table CONSO_COMMUNE sera COD_COMMUNE
On va faire une jointure complete (FULL JOIN) on utilisant aussi COALESCE */

PROC SQL;
CREATE TABLE DECES_2015 AS 
SELECT 
	COALESCE (CONSO_COMMUNE.COD_COMMUNE, STRUCTURE.COD_COMMUNE) AS COD_COMMUNE,
	CONSO_COMMUNE.NB_DECES,
	CONSO_COMMUNE.NB_DECES_H,
	CONSO_COMMUNE.NB_DECES_F,
	CONSO_COMMUNE.NB_DECES_0_17,
	CONSO_COMMUNE.NB_DECES_18_44,
	CONSO_COMMUNE.NB_DECES_45_59,
	CONSO_COMMUNE.NB_DECES_60_74,
	CONSO_COMMUNE.NB_DECES_75_84,
	CONSO_COMMUNE.NB_DECES_85_94,
	CONSO_COMMUNE.NB_DECES_85_94,
	CONSO_COMMUNE.NB_DECES_SUP_95,
	STRUCTURE.COD_REGION,
	STRUCTURE.LIB_REGION,
	STRUCTURE.COD_DEPARTEMENT,
	STRUCTURE.LIB_DEPARTEMENT,
	STRUCTURE.LIB_COMMUNE
FROM 
	WORK.CONSO_COMMUNE FULL JOIN WORK.STRUCTURE
	ON CONSO_COMMUNE.COD_COMMUNE = STRUCTURE.COD_COMMUNE;
QUIT;

/* 4.20. IL Y AVAIT UNE REDENDANCE DANS LES NUMERO DE QUESTIONS DANS LE SUJET DE PROJET */

PROC SQL;
SELECT 
	COUNT(COD_COMMUNE)
FROM
	WORK.DECES_2015
WHERE
	NB_DECES < 1;
QUIT;

/* Il y a 5430 communes qui n'ont pas eu de deces en 2015 */ 

/* 4.21. */

PROC SQL;
SELECT 
	COD_REGION,
	LIB_REGION,
	SUM(NB_DECES) AS NB_DECES_PAR_REGION,
	SUM(NB_DECES_H) AS NB_DECES_PAR_REGION_H,
	CALCULATED NB_DECES_PAR_REGION_H * 100 / CALCULATED NB_DECES_PAR_REGION AS PR_H,
	SUM(NB_DECES_F) AS NB_DECES_PAR_REGION_F,
	CALCULATED NB_DECES_PAR_REGION_F * 100 /CALCULATED  NB_DECES_PAR_REGION AS PR_F
FROM
	WORK.DECES_2015
GROUP BY
	COD_REGION,
	LIB_REGION;
QUIT;

/* 4.22. */

DATA DECES_2015;
SET WORK.DECES_2015;
BY COD_DEPARTEMENT;
RETAIN NB_DECES_DEP ; 
FIRST_DEPARTEMENT = FIRST.COD_DEPARTEMENT;
LAST_DEPARTEMENT = LAST.COD_DEPARTEMENT;
IF MISSING(NB_DECES) = 1 THEN NB_DECES=0;
IF FIRST.COD_DEPARTEMENT THEN NB_DECES_DEP = 0;
	NB_DECES_DEP = NB_DECES_DEP + NB_DECES;
RUN;
PROC SQL;
CREATE TABLE VARIABLE AS
SELECT 
	COD_DEPARTEMENT,
	NB_DECES_DEP AS CUM_DECES_DEP
FROM
	WORK.DECES_2015
WHERE
	LAST_DEPARTEMENT =1
ORDER BY 
	COD_DEPARTEMENT;
QUIT;
DATA DECES_2015_CUM;
MERGE  DECES_2015 VARIABLE;
BY COD_DEPARTEMENT ;
RUN; 
DATA DECES_2015_CUM;
SET WORK.DECES_2015_CUM;
ATTRIB POIDS_DEP FORMAT = NLPCTN9.2;
POIDS_DEP = (NB_DECES) / CUM_DECES_DEP;
RUN;

/* 4.23. */

PROC SORT DATA=WORK.DECES_2015_CUM; 
BY DESCENDING NB_DECES; 
RUN;     
PROC SORT DATA=WORK.DECES_2015_CUM; 
BY COD_DEPARTEMENT; 
RUN;  
ODS TAGSETS.EXCELXP
FILE="C:\Users\Desktop\Projet\PROJET FINAL\Resultats.xls" 
STYLE=STATISTICAL OPTIONS(SHEET_INTERVAL="BYGROUP"); 
PROC PRINT DATA=WORK.DECES_2015_CUM NOOBS; 
VAR  COD_COMMUNE LIB_COMMUNE NB_DECES POIDS_DEP NB_DECES_H NB_DECES_F NB_DECES_0_17 NB_DECES_18_44 NB_DECES_45_59 NB_DECES_60_74 NB_DECES_75_84 NB_DECES_85_94 NB_DECES_SUP_95; 
WHERE LIB_REGION = "NORD-PAS-DE-CALAIS-PICARDIE";
BY COD_DEPARTEMENT; 
RUN; 
ODS TAGSETS.EXCELXP CLOSE;

/* 4.24. */

%MACRO Export(codregion);

PROC SORT DATA=WORK.DECES_2015_CUM;
BY DESCENDING NB_DECES;
RUN;

PROC SORT DATA=WORK.DECES_2015_CUM;
BY COD_DEPARTEMENT;
RUN;

ODS TAGSETS.EXCELXP
FILE="C:\Users\Desktop\Projet\PROJET FINAL\Resultats code region &codregion. .xls"
STYLE=STATISTICAL OPTIONS(SHEET_INTERVAL="BYGROUP");

PROC PRINT DATA=WORK.DECES_2015_CUM NOOBS;
VAR  COD_COMMUNE LIB_COMMUNE NB_DECES POIDS_DEP NB_DECES_H NB_DECES_F NB_DECES_0_17 NB_DECES_18_44 NB_DECES_45_59 NB_DECES_60_74 NB_DECES_75_84 NB_DECES_85_94 NB_DECES_SUP_95;
WHERE COD_REGION = "&codregion.";
BY COD_DEPARTEMENT;
RUN;

ODS TAGSETS.EXCELXP CLOSE;
%MEND Export;

%Export(32);
%Export(84);
%Export(93);
%Export(75);

/* 4.25. */

%MACRO Export(liste);
%LET i=1;
%DO %WHILE(%LENGTH(%SCAN(&liste.,&i.,-)) >0);
        %LET codregion=%SCAN(&liste.,&i.,-);
        %LET i=%EVAL(&i.+1);

        PROC SORT DATA=WORK.DECES_2015_CUM;
        BY DESCENDING NB_DECES;
        RUN;

        PROC SORT DATA=WORK.DECES_2015_CUM;
        BY COD_DEPARTEMENT;
        RUN;

        ODS TAGSETS.EXCELXP
        FILE="C:\Users\Desktop\Projet\PROJET FINAL\Resultats code region &codregion. .xls"
        STYLE=STATISTICAL OPTIONS(SHEET_INTERVAL="BYGROUP");

        PROC PRINT DATA=WORK.DECES_2015_CUM NOOBS;
        VAR  COD_COMMUNE LIB_COMMUNE NB_DECES POIDS_DEP NB_DECES_H NB_DECES_F NB_DECES_0_17 NB_DECES_18_44 NB_DECES_45_59 NB_DECES_60_74 NB_DECES_75_84 NB_DECES_85_94 NB_DECES_SUP_95;
        WHERE COD_REGION = "&codregion.";
        BY COD_DEPARTEMENT;
        RUN;

        ODS TAGSETS.EXCELXP CLOSE;
%END;

%MEND Export;

%Export(32-75);

/* 4.26. */

%MACRO Export(ls);
%LET liste = &ls.;
%IF %LENGTH(&liste.)=0 %THEN %DO;
%LET liste=01-02-03-04-11-24-27-28-32-44-52-53-75-76-84-93-94;
%END;

%LET i=1;
%DO %WHILE(%LENGTH(%SCAN(&liste.,&i.,-)) >0);
        %LET codregion=%SCAN(&liste.,&i.,-);
        %LET i=%EVAL(&i.+1);

        PROC SORT DATA=WORK.DECES_2015_CUM;
        BY DESCENDING NB_DECES;
        RUN;

        PROC SORT DATA=WORK.DECES_2015_CUM;
        BY COD_DEPARTEMENT;
        RUN;

        ODS TAGSETS.EXCELXP
        FILE="C:\Users\Desktop\Projet\PROJET FINAL\Resultats code region &codregion. .xls"
        STYLE=STATISTICAL OPTIONS(SHEET_INTERVAL="BYGROUP");

        PROC PRINT DATA=WORK.DECES_2015_CUM NOOBS;
        VAR  COD_COMMUNE LIB_COMMUNE NB_DECES POIDS_DEP NB_DECES_H NB_DECES_F NB_DECES_0_17 NB_DECES_18_44 NB_DECES_45_59 NB_DECES_60_74 NB_DECES_75_84 NB_DECES_85_94 NB_DECES_SUP_95;
        WHERE COD_REGION = "&codregion.";
        BY COD_DEPARTEMENT;
        RUN;

        ODS TAGSETS.EXCELXP CLOSE;
%END;

%MEND Export;

%Export();
%Export(01-02);
