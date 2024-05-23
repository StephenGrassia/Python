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

/* Create table with cleaned up data */
DROP table if exists incidents_clean
;
CREATE table incidents_clean
AS
	SELECT *
		,date_part('year', date_occurred) AS year
		,CASE
			WHEN CAST(date_occurred AS TIME) BETWEEN '00:00:00' AND '03:59:00' THEN '00:00 - 03:59'
			WHEN CAST(date_occurred AS TIME) BETWEEN '04:00:00' AND '07:59:00' THEN '04:00 - 07:59'
			WHEN CAST(date_occurred AS TIME) BETWEEN '08:00:00' AND '11:59:00' THEN '08:00 - 11:59'
			WHEN CAST(date_occurred AS TIME) BETWEEN '12:00:00' AND '15:59:00' THEN '12:00 - 15:59'
			WHEN CAST(date_occurred AS TIME) BETWEEN '16:00:00' AND '19:59:00' THEN '16:00 - 19:59'
			WHEN CAST(date_occurred AS TIME) BETWEEN '20:00:00' AND '23:59:00' THEN '20:00 - 23:59'
			ELSE 'Other'
			END AS TimeGroups
		,CASE 
			WHEN EXTRACT(dow FROM date_occurred) = 0 THEN 'Sunday'
			WHEN EXTRACT(dow FROM date_occurred) = 1 THEN 'Monday'
			WHEN EXTRACT(dow FROM date_occurred) = 2 THEN 'Tuesday'
			WHEN EXTRACT(dow FROM date_occurred) = 3 THEN 'Wednesday'
			WHEN EXTRACT(dow FROM date_occurred) = 4 THEN 'Thursday'
			WHEN EXTRACT(dow FROM date_occurred) = 5 THEN 'Friday'
			WHEN EXTRACT(dow FROM date_occurred) = 6 THEN 'Saturday'
			END AS DayOfWeek
FROM (
		SELECT *
			,TRIM(TRAILING ' ' FROM offense_code) AS trim_code
		FROM police_incidents
) AS i
JOIN code_list c
ON i.trim_code = c.code
;
