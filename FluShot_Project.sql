DROP TABLE IF EXISTS conditions;
DROP TABLE IF EXISTS encounters;
DROP TABLE IF EXISTS immunizations;
DROP TABLE IF EXISTS patients;

-- Table: Conditions
CREATE TABLE conditions (
START DATE
,STOP DATE
,PATIENT VARCHAR(1000)
,ENCOUNTER VARCHAR(1000)
,CODE VARCHAR(1000)
,DESCRIPTION VARCHAR(200)
);

-- Table: Encounters
CREATE TABLE encounters (
 Id VARCHAR(100)
,START TIMESTAMP
,STOP TIMESTAMP
,PATIENT VARCHAR(100)
,ORGANIZATION VARCHAR(100)
,PROVIDER VARCHAR(100)
,PAYER VARCHAR(100)
,ENCOUNTERCLASS VARCHAR(100)
,CODE VARCHAR(100)
,DESCRIPTION VARCHAR(100)
,BASE_ENCOUNTER_COST FLOAT
,TOTAL_CLAIM_COST FLOAT
,PAYER_COVERAGE FLOAT
,REASONCODE VARCHAR(100)
--,REASONDESCRIPTION VARCHAR(100)
);

-- Table: Immunizations
CREATE TABLE immunizations
(
 DATE TIMESTAMP
,PATIENT varchar(100)
,ENCOUNTER varchar(100)
,CODE int
,DESCRIPTION varchar(500)
--,BASE_COST float
);

-- Table: Patients
CREATE TABLE patients
(
 Id VARCHAR(100)
,BIRTHDATE date
,DEATHDATE date
,SSN VARCHAR(100)
,DRIVERS VARCHAR(100)
,PASSPORT VARCHAR(100)
,PREFIX VARCHAR(100)
,FIRST VARCHAR(100)
,LAST VARCHAR(100)
,SUFFIX VARCHAR(100)
,MAIDEN VARCHAR(100)
,MARITAL VARCHAR(100)
,RACE VARCHAR(100)
,ETHNICITY VARCHAR(100)
,GENDER VARCHAR(100)
,BIRTHPLACE VARCHAR(100)
,ADDRESS VARCHAR(100)
,CITY VARCHAR(100)
,STATE VARCHAR(100)
,COUNTY VARCHAR(100)
,FIPS INT 
,ZIP INT
,LAT float
,LON float
,HEALTHCARE_EXPENSES float
,HEALTHCARE_COVERAGE float
,INCOME int
,Mrn int
);

-- Import conditions.txt
COPY Conditions
FROM '/Users/sujitkandala/Downloads/FluShots Project/conditions.txt'
WITH (
    FORMAT text,
    HEADER true,
    DELIMITER ','
);

-- Import encounters.txt
COPY Encounters
FROM '/Users/sujitkandala/Downloads/FluShots Project/encounters.txt'
WITH (
    FORMAT text,
    HEADER true,
    DELIMITER ','
);

-- Import immunizations.txt
COPY Immunizations
FROM '/Users/sujitkandala/Downloads/FluShots Project/immunizations.txt'
WITH (
    FORMAT text,
    HEADER true,
    DELIMITER ','
);

-- Import patients.txt
COPY Patients
FROM '/Users/sujitkandala/Downloads/FluShots Project/patients.txt'
WITH (
    FORMAT text,
    HEADER true,
    DELIMITER ','
);

-- Verify the import
SELECT * FROM conditions;
SELECT * FROM encounters;
SELECT * FROM immunizations;
SELECT * FROM patients;


/*
Project Objectives:
Flu Shots Dashboard (2022) should include the following:

1.) Total % of patients getting flu shots stratified by
   a.) Age
   b.) Race
   c.) County (on a Map)
   d.) Overall
2.) Running Total of Flu Shots over the course of 2022
3.) Total number of Flu Shots given in 2022
4.) List of patients that show whether or not they received the Flu Shots
   
Requirements:
Patients must have "Active" status at the hospital
*/

WITH active_patients AS (
    SELECT DISTINCT patient
    FROM encounters AS e
    JOIN patients AS pat
      ON e.patient = pat.id
    WHERE "start" BETWEEN '2020-01-01 00:00' AND '2022-12-31 23:59'
      AND pat.deathdate IS NULL
      AND EXTRACT(EPOCH FROM age('2022-12-31'::DATE, pat.birthdate)) / 2592000 >= 6

),

flu_shot_2022 AS (
    SELECT patient, MIN(date) AS earliest_flu_shot_2022 
    FROM immunizations
    WHERE code = '5302'
      AND date BETWEEN '2022-01-01 00:00' AND '2022-12-31 23:59'
    GROUP BY patient
)

SELECT pat.birthdate,
       pat.race,
       pat.county,
       pat.id,
       pat.first,
       pat.last,
       pat.gender,
       EXTRACT(YEAR FROM age('2022-12-31'::DATE, pat.birthdate)) AS age,
       flu.earliest_flu_shot_2022,
       flu.patient,
       CASE WHEN flu.patient IS NOT NULL THEN 1 ELSE 0 END AS flu_shot_2022
FROM patients AS pat
LEFT JOIN flu_shot_2022 AS flu
  ON pat.id = flu.patient
WHERE pat.id IN (SELECT patient FROM active_patients);

SELECT * FROM patients;




