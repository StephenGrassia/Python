/* Master Code List */
SELECT *
FROM code_list
;

/* There are 139 DISTINCT offense_codes w/ related offense_description in the master_code_list table */
/* DISTINCT Offense_Codes */
SELECT COUNT(DISTINCT offense_code) AS CodeCount
	,COUNT(DISTINCT offense_description) AS DescriptionCount
FROM police_incidents
;

/* Looks like there are way more distinct counts of Offense_Descriptions than Offense_Codes. 
   We will join the master code list to the police_incident table on offense_code. */ 
SELECT COUNT(DISTINCT offense_code) AS CodeCount
	,COUNT(DISTINCT offense_description) AS DescriptionCount
FROM (
		SELECT i.offense_code, c.description AS offense_description
		FROM police_incidents AS i
		JOIN code_list c
		ON i.offense_code = c.offense_code
	 ) a
;

/* Create a view */
CREATE view v_incident_clean
AS
SELECT *
	,date_part('year', date_occurred) AS year
FROM police_incidents AS i
JOIN code_list c
ON i.offense_code = c.code
;

/* Top 10 Police Incidents by Count */
SELECT offense_code
	,offense_description
	,COUNT(*) AS TotalCount
FROM v_incident_clean
GROUP BY 1,2
ORDER BY 3 DESC
LIMIT 10
;

/* Top 10 by Year */
SELECT year::TEXT
	,code
	,initcap(description) AS description
	,COUNT(*) AS totalcount
FROM v_incident_clean
WHERE description IN (SELECT description
					  FROM v_incident_clean
					  GROUP BY 1
					  ORDER BY COUNT(*) DESC
					  LIMIT 10)
GROUP BY 1,2,3
ORDER BY 1,4 DESC
;

/* Most frequent incident for each date */
SELECT *
FROM (
		SELECT DATE(date_occurred) as date_occurred
			,code
			,initcap(description) AS description
			,ROW_NUMBER() OVER (PARTITION BY DATE(date_occurred) ORDER BY COUNT(*) DESC) AS row_number
		FROM v_incident_clean
		WHERE description IN (SELECT description
					  		FROM v_incident_clean
					  		GROUP BY 1
					  		ORDER BY COUNT(*) DESC
					  		LIMIT 10)
		GROUP BY 1,2,3
		ORDER BY 1
)
WHERE row_number = 1
;

/* Frequency of each incident at #1 */
SELECT DISTINCT(description)
	,COUNT(description) OVER (PARTITION BY description) AS DaysAtHighest
FROM (
		SELECT DATE(date_occurred) AS date_occurred
			,code
			,initcap(description) AS description
			,ROW_NUMBER() OVER (PARTITION BY DATE(date_occurred) ORDER BY COUNT(*) DESC) AS row_number
		FROM v_incident_clean
		WHERE description IN (SELECT description
							  FROM v_incident_clean
							  GROUP BY 1
							  ORDER BY COUNT(*) DESC
							  LIMIT 10)
		GROUP BY 1,2,3
		ORDER BY 1
	)
WHERE row_number = 1
ORDER BY 2 DESC
;