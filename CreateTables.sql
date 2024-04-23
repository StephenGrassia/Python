/*** Police Incidents ***/
/* Drop table */
DROP table if exists police_incidents
;

/* Create table */
CREATE table police_incidents
(
  IncidentNumber TEXT,
  OBJECTID INTEGER,
  Date_Occurred TIMESTAMP,
  Date_Found TIMESTAMP,
  Offense_Code TEXT,
  Offense_Description TEXT,
  Block TEXT,
  Street TEXT,
  Precincts TEXT,
  Subdivision TEXT,
  Zone_ID TEXT,
  Case_Status TEXT
)
;

/* Copy police incident data */
COPY police_incidents
FROM 'C:/path/to/police_incidents.csv'
DELIMITER ','
CSV HEADER
;

/*** Code List ***/
/* Drop table */
DROP table if exists code_list
;

/* Create table */
CREATE table code_list
(
  Description TEXT,
  Code TEXT
)
;

/* Copy code list */
COPY code_list
FROM 'C:/path/to/code_list.csv'
DELIMITER ','
CSV HEADER
;
