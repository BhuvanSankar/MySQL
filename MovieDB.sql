@C:\Users\Subashchandran\INFS7903Project\project2015.sql;


DESC FILM;
DESC ACTOR;
DESC CATEGORY;
DESC FILM_ACTOR;
DESC FILM_CATEGORY;
DESC "language";





--TASK 1 : CONSTRAINTS
--##########################

--TASK 1.a:
--##########

/*1.3:*/ --select * from user_constraints where table_name = "FILM";
					--[OR]
/*1.3:*/ select * from user_constraints where constraint_name = 'PK_FILMID';
/*1.4:*/ select * from user_constraints where constraint_name = 'PK_LANGUAGEID';
/*1.5:*/ select * from user_constraints where constraint_name = 'UN_DESCRIPTION';
					--[OR]
/*1.5:*/ --select * from user_constraints where table_name = "FILM";


--TASK 1.b:
--##############

/*1.1*/ alter table actor add constraint PK_ACTORID primary key(actor_id);
/*1.2*/ alter table category add constraint PK_CATEGORYID primary key ( category_id ); 
--1.3 alter table film add constraint PK_FILMID primary key ( film_id ); [Already exists]
--1.4 alter table "language" add constraint PK_LANGUAGEID primary key ( language_id ); [Already exists]
--1.5 alter table film add constraint UN_DESCRIPTION unique (DESCRIPTION); [Already exists]
/*1.6*/ alter table actor modify first_name VARCHAR2(45) NOT NULL; 
/*1.7*/ alter table actor modify last_name VARCHAR2(45) NOT NULL; 
/*1.8*/ alter table film modify title VARCHAR2(255) NOT NULL; 
/*1.9*/ alter table category modify name VARCHAR2(25) NOT NULL; 
/*1.10*/ alter table film modify rental_rate NUMBER(4,2) NOT NULL; 
/*1.11*/ alter table film add constraint CK_RATING Check (rating in ('G', 'PG', 'PG-13', 'R', 'NC-17') ); 
/*1.12*/ alter table film add constraint CK_SPLFEATURES check (special_features in
 		(NULL, 'Trailers', 'Commentaries', 'Deleted Scenes', 'Behind the Scenes')); 
/*1.13*/ alter table film add constraint FK_LANGUAGEID foreign key (language_id) 
		references "language" (language_id); 
/*1.14*/ alter table film add constraint FK_ORLANGUAGEID foreign key 
		(original_language_id) references "language" (language_id); 
/*1.15*/ alter table film_actor add constraint FK_ACTORID foreign key (actor_id) references actor(actor_id); 
/*1.16*/ alter table film add constraint CK_RELEASEYR check (release_year <= 2014); 



--TASK 2  :  TRIGGERS
--########################

--TASK 2.a:  
--###########

CREATE SEQUENCE "FILM_ID_SEQ" MINVALUE 21000 MAXVALUE 999999999 INCREMENT BY 1 START WITH 21000;


CREATE OR REPLACE TRIGGER "BI_FILM" 
	BEFORE INSERT ON "FILM"
	FOR EACH ROW
BEGIN
	SELECT "FILM_ID_SEQ" .NEXTVAL INTO :NEW.FILM_ID FROM DUAL; 
END;
/


SELECT*FROM USER_SEQUENCES;


SELECT*FROM USER_TRIGGERS;




--TASK 2.b:
--###########

CREATE OR REPLACE TRIGGER "RATING_FILM"
	BEFORE INSERT ON "FILM"
	FOR EACH ROW
BEGIN
	IF :NEW.RATING LIKE '% G %' THEN
		:NEW.REPLACEMENT_COST := :new.REPLACEMENT_COST - 0.10;
		:NEW.DESCRIPTION := IFNULL(CONCAT(:NEW.DESCRIPTION, ', RECOMMENDED FOR ALL AUDIENCES'), 'RECOMMENDED FOR ALL AUDIENCES');
	END IF;

	IF :NEW.RATING LIKE '% PG %' THEN
		:NEW.REPLACEMENT_COST := :NEW.REPLACEMENT_COST + 0.20;
		:NEW.DESCRIPTION := IFNULL(CONCAT(:NEW.DESCRIPTION, ', PARENTAL GUIDANCE FOR YOUNG VIEWERS'), 'PARENTAL GUIDANCE FOR YOUNG VIEWERS');
	END IF;

	IF :NEW.RATING LIKE '% PG-13 %' THEN
		:NEW.REPLACEMENT_COST := :NEW.REPLACEMENT_COST + 0.20;
		:NEW.DESCRIPTION := IFNULL(CONCAT(:NEW.DESCRIPTION, ', PARENTAL GUIDANCE FOR YOUNG VIEWERS'), 'PARENTAL GUIDANCE FOR YOUNG VIEWERS');
	END IF;

	IF :NEW.RATING LIKE '% R %' THEN
		:NEW.REPLACEMENT_COST := :NEW.REPLACEMENT_COST + 0.60;
		:NEW.DESCRIPTION := IFNULL(CONCAT(:NEW.DESCRIPTION, ', RECOMMENDED FOR MATURE AUDIENCES'), 'RECOMMENDED FOR MATURE AUDIENCES');
	END IF;

	IF :NEW.RATING LIKE '% NC-17 %' THEN
		:NEW.REPLACEMENT_COST := :NEW.REPLACEMENT_COST + 1.00;
		:NEW.DESCRIPTION := IFNULL(CONCAT(:NEW.DESCRIPTION, ', MATURE AUDIENCES ONLY'), 'MATURE AUDIENCES ONLY');
	END IF;
END;
/

--FOR TESTING
--##############

INSERT INTO FILM VALUES (20001, 'SUPER', 'SHARK MOVIE', 2013, 1, NULL, 5, '4.99', 40, '10.50', 'PG-13', 'BEHIND THE SCENES');

SELECT TITLE RATING REPLACEMENT_COST DESCRIPTION FROM FILM WHERE FILM_ID='20001';



--TASK 3 : VIEWS
--###############


--TASK 3.a:
--##########

SELECT F1.TITLE, F1.REPLACEMENT_COST FROM FILM F1
WHERE REPLACEMENT_COST IN 
(SELECT MAX(REPLACEMENT_COST) FROM FILM F, FILM_CATEGORY FC, CATEGORY C
WHERE C.NAME = 'DRAMA' AND FC.CATEGORY_ID = C.CATEGORY_ID
AND F.FILM_ID = FC.FILM_ID);



--TASK 3.b:
--############

CREATE VIEW V_ACTOR AS
SELECT A.ACTOR_ID, A.FIRST_NAME, A.LAST_NAME 
FROM ACTOR A, FILM_ACTOR FA, FILM F
WHERE F.FILM_ID=FA.FILM_ID AND FA.ACTOR_ID = A.ACTOR_ID AND F.TITLE = 'DANCING HAUNTING';



--TASK 3.c:
--###########

CREATE OR REPLACE VIEW V_DRAMA_ACTORS_2000 AS
SELECT A.ACTOR_ID, A.FIRST_NAME, A.LAST_NAME 
FROM ACTOR A, FILM F, CATEGORY C, FILM_CATEGORY FC, FILM_ACTOR FA
WHERE F.RELEASE_YEAR = 2000 AND  C.NAME = 'Drama' 
AND C.CATEGORY_ID = FC.CATEGORY_ID 
AND F.FILM_ID = FC.FILM_ID
AND F.FILM_ID =  FA.FILM_ID 
AND FA.ACTOR_ID = A.ACTOR_ID;



--TASK 3.d:
--############

CREATE OR REPLACE MATERIALIZED VIEW MV_DRAMA_ACTORS_2000 
BUILD IMMEDIATE 
AS
SELECT A.ACTOR_ID, A.FIRST_NAME, A.LAST_NAME 
FROM ACTOR A, FILM F, CATEGORY C, FILM_CATEGORY FC, FILM_ACTOR FA
WHERE F.RELEASE_YEAR = 2000 AND  C.NAME = 'Drama' 
AND C.CATEGORY_ID = FC.CATEGORY_ID 
AND F.FILM_ID = FC.FILM_ID
AND F.FILM_ID =  FA.FILM_ID 
AND FA.ACTOR_ID = A.ACTOR_ID;




--TASK 3.e:
--###########

SELECT * FROM V_DRAMA_ACTORS_2000;

SELECT * FROM MV_DRAMA_ACTORS_2000;


--TASK 4 : INDEXES
--#################

--TASK 4.a:
--###########


SELECT COUNT(*) AS COUNT
FROM ACTOR 
GROUP BY FIRST_NAME, LAST_NAME
HAVING COUNT(*)>1/;


--TASK 4.b:
--##########

CREATE INDEX AR_IDX ON ACTOR(FIRST_NAME, LAST_NAME);

TASK 4.a:   (2ND TIME QUERY)
############################

SELECT COUNT(*) AS COUNT
FROM ACTOR 
GROUP BY FIRST_NAME, LAST_NAME
HAVING COUNT(*)>1;




--TASK 4.c:
--##########

--REPORTING THE EXECUTION TIME AND REASON FOR TIME DIFFERENCE

--TASK 5.a:
--##########

--QUERY:
--########

EXPLAIN PLAN FOR SELECT /*+RULE*/ * FROM FILM WHERE FILM_ID = 18001;


--QUERY:
--###########

SELECT PLAN_TABLE_OUTPUT FROM TABLE (DBMS_XPLAN.DISPLAY);



--TASK 5.b:
--###########

--QUERY:
--###########

ALTER TABLE FILM DROP CONSTRAINT PK_FILMID;



--QUERY:
--###########

EXPLAIN PLAN FOR SELECT /*+RULE*/ * FROM FILM WHERE FILM_ID = 18001;



--QUERY:
--###########

SELECT PLAN_TABLE_OUTPUT FROM TABLE (DBMS_XPLAN.DISPLAY);




--TASK 5.c:
--###########

--OPINION ABOUT THE PLAN
 














     

