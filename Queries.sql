--INTRO:

CREATE VIEW forestation AS 
SELECT
   f.country_code,
   f.country_name,
   f.year,
   f.forest_area_sqkm,
   l.total_area_sq_mi,
   (
      l.total_area_sq_mi*2.59
   )
   AS total_area_sqkm,
   (
(f.forest_area_sqkm / (l.total_area_sq_mi*2.59)) * 100
   )
   AS perc_forest_area,
   r.region,
   r.income_group 
FROM
   forest_area f 
   JOIN
      land_area l 
      ON f.country_code = l.country_code 
      AND f.year = l.year 
   JOIN
      regions r 
      ON l.country_code = r.country_code;


--GLOBAL SITUATION:

--a)/*What was the total forest area (in sq km) of the world in 1990? Please keep in mind that you can use the country record denoted as “World" in the region table.*/

SELECT
   forest_area_sqkm 
FROM
   forestation 
WHERE
   year = 1990 
   AND country_code = 'WLD';

--b)What was the total forest area (in sq km) of the world in 2016? Please keep in mind that you can use the country record in the table is denoted as “World.”

SELECT
   forest_area_sqkm 
FROM
   forestation 
WHERE
   year = 2016 
   AND country_code = 'WLD';

--c)What was the change (in sq km) in the forest area of the world from 1990 to 2016?

WITH t1 AS
(
   SELECT
      country_name,
      forest_area_sqkm AS forest_area_sqkm_90 
   FROM
      forestation 
   WHERE
      year = 1990 
      AND country_code = 'WLD'
)
,
t2 AS 
(
   SELECT
      country_name,
      forest_area_sqkm AS forest_area_sqkm_16 
   FROM
      forestation 
   WHERE
      year = 2016 
      AND country_code = 'WLD'
)
SELECT
   t1.country_name,
   t1.forest_area_sqkm_90,
   t2.forest_area_sqkm_16,
   (
      t1.forest_area_sqkm_90 - t2.forest_area_sqkm_16
   )
   AS forest_area_diff 
FROM
   t1 
   JOIN
      t2 
      ON t1.country_name = t2.country_name;

--d)What was the percent change in forest area of the world between 1990 and 2016?

WITH t1 AS
(
   SELECT
      country_name,
      forest_area_sqkm AS forest_area_sqkm_90 
   FROM
      forestation 
   WHERE
      year = 1990 
      AND country_code = 'WLD'
)
,
t2 AS 
(
   SELECT
      country_name,
      forest_area_sqkm AS forest_area_sqkm_16 
   FROM
      forestation 
   WHERE
      year = 2016 
      AND country_code = 'WLD'
)
SELECT
   t1.country_name,
   t1.forest_area_sqkm_90,
   t2.forest_area_sqkm_16,
   (
((t2.forest_area_sqkm_16 - t1.forest_area_sqkm_90) / t1.forest_area_sqkm_90)*100
   )
   AS perc_change_forest 
FROM
   t1 
     JOIN
      t2 
      ON t1.country_name = t2.country_name;

/*e)If you compare the amount of forest area lost between 
1990 and 2016, to which country's total area in 2016 is it
closest to?*/

SELECT
   country_name,
   total_area_sqkm AS country_land_area,
   (
      WITH t1 AS
      (
         SELECT
            country_name,
            forest_area_sqkm AS forest_area_sqkm_90 
         FROM
            forestation 
         WHERE
            year = 1990 
            AND country_code = 'WLD'
      )
,
      t2 AS 
      (
         SELECT
            country_name,
            forest_area_sqkm AS forest_area_sqkm_16 
         FROM
            forestation 
         WHERE
            year = 2016 
            AND country_code = 'WLD'
      )
      SELECT
(t1.forest_area_sqkm_90 - t2.forest_area_sqkm_16) AS forest_area_diff 
      FROM
         t1 
         JOIN
            t2 
            ON t1.country_name = t2.country_name
   )
   AS world_forest_loss,
   ABS(total_area_sqkm - (WITH t1 AS
   (
      SELECT
         country_name,
         forest_area_sqkm AS forest_area_sqkm_90 
      FROM
         forestation 
      WHERE
         year = 1990 
         AND country_code = 'WLD'
   )
, t2 AS 
   (
      SELECT
         country_name,
         forest_area_sqkm AS forest_area_sqkm_16 
      FROM
         forestation 
      WHERE
         year = 2016 
         AND country_code = 'WLD'
   )
   SELECT
(t1.forest_area_sqkm_90 - t2.forest_area_sqkm_16) AS forest_area_diff 
   FROM
      t1 
      JOIN
         t2 
         ON t1.country_name = t2.country_name)) AS abs_diff 
   FROM
      forestation 
   WHERE
      year = 2016 
   ORDER BY
      abs_diff LIMIT 1;
                                                                                    
                                                                                                                                                                                                                                                
--REGIONAL OUTLOOK:

/* Create a table that shows the Regions and their 
percent forest area (sum of forest area divided by 
the sum of land area) in 1990 and 2016. 
(Note that 1 sq mi = 2.59 sq km).*/

CREATE VIEW region_area AS 
SELECT
   r.region,
   f.year,
   (
      sum(f.forest_area_sqkm) / sum(l.total_area_sq_mi*2.59)
   )
   *100 AS percent_forest_area 
FROM
   regions r 
   JOIN
      forest_area f 
      ON r.country_name = f.country_name 
   JOIN
      land_area l 
      ON r.country_name = l.country_name 
WHERE
   f.year = 1990 
   or f.year = 2016 
GROUP BY
   r.region,
   f.year 
ORDER BY
   r.region;

--a1)What was the percent forest of the entire world in 2016 to 2 decimal places?

SELECT
   region,
   ROUND(CAST(percent_forest_area AS numeric), 2) AS percent_forest_area 
FROM
   region_area 
WHERE
   year = 2016 
   AND region = 'World';


--a2)Which region had the HIGHEST percent forest in 2016 to 2 decimal places?

SELECT
   region,
   ROUND(CAST(percent_forest_area AS numeric), 2) AS percent_forest_area 
FROM
   region_area 
WHERE
   year = 2016 
ORDER BY
   percent_forest_area DESC LIMIT 1;

--a3)Which had the LOWEST percent forest in 2016 to 2 decimal places?

SELECT
   region,
   ROUND(CAST(percent_forest_area AS numeric), 2) AS percent_forest_area 
FROM
   region_area 
WHERE
   year = 2016 
ORDER BY
   Percent_forest_area LIMIT 1;

--b1)What was the percent forest of the entire world in 1990 to 2 decimal places?

SELECT
   region,
   ROUND(CAST(percent_forest_area AS numeric), 2) AS percent_forest_area 
FROM
   region_area 
WHERE
   year = 1990 
   AND region = 'World';

--b2 ) Which region had the HIGHEST percent forest in 1990 to 2 decimal places?

SELECT
   region,
   ROUND(CAST(percent_forest_area AS numeric), 2) AS percent_forest_area 
FROM
   region_area 
WHERE
   year = 1990 
ORDER BY
   Percent_forest_area DESC LIMIT 1;

--b3)Which had the LOWEST percent forest in 1990 to 2 decimal places?

SELECT
   region,
   ROUND(CAST(percent_forest_area AS numeric), 2) AS percent_forest_area 
FROM
   region_area 
WHERE
   year = 1990 
ORDER BY
   Percent_forest_area LIMIT 1;


/* c) Based on the table you created, which regions of 
the world DECREASED in forest area from 1990 to 2016?*/

CREATE VIEW difference AS
(
   SELECT
      * 
   FROM
      (
         WITH t1 AS 
         (
            SELECT
               region,
               percent_forest_area AS pfa_90 
            FROM
               region_area 
            WHERE
               year = 1990 
         )
,
         t2 AS 
         (
            SELECT
               region,
               percent_forest_area AS pfa_16 
            FROM
               region_area 
            WHERE
               year = 2016 
         )
         SELECT
            t1.region,
            t1.pfa_90,
            t2.pfa_16 
         FROM
            t1 
            JOIN
               t2 
               ON t1.region = t2.region
      )
      subq
)

--Below is a self table join from the above view difference.
SELECT
   a.region 
FROM
   difference a 
   JOIN
      difference b 
      ON a.region = b.region 
      AND b.pfa_90 > a.pfa_16 
WHERE
   a.region != 'World';

--COUNTRY LEVEL DETAIL:

/*a) Which 5 countries saw the largest amount decrease 
	in forest area from 1990 to 2016? What was the 
    difference in forest area for each?*/ 

WITH t1 AS 
(
   SELECT
      country_name,
      region,
      forest_area_sqkm as forest_area_90 
   FROM
      forestation 
   WHERE
      year = 1990 
      AND forest_area_sqkm IS NOT NULL
)
,
t2 AS 
(
   SELECT
      country_name,
      forest_area_sqkm as forest_area_16 
   FROM
      forestation 
   WHERE
      year = 2016 
      AND forest_area_sqkm IS NOT NULL
)
SELECT
   t1.country_name,
   t1.region,
   (
      T2.forest_area_16 - t1.forest_area_90 
   )
   AS forest_diff 
FROM
   t1 
   JOIN
      t2 
      ON t1.country_name = t2.country_name 
WHERE
   t1.country_name != 'World' 
ORDER BY
   3 LIMIT 5;

/* b)Which 5 countries saw the largest percent decrease 
in forest area from 1990 to 2016? What was the percent 
change to 2 decimal places for each?*/

WITH t1 AS
(
   SELECT
      country_name,
      region,
      perc_forest_area
      AS perc_forest_area_90 
   FROM
      forestation 
   WHERE
      YEAR = 1990
)
,
t2 AS
(
   SELECT
      country_name,
      forest_area_sqkm,
      total_area_sqkm,
      perc_forest_area
      AS perc_forest_area_16 
   FROM
      forestation 
   WHERE
      YEAR = 2016
)
SELECT
   t1.country_name,
   t1.region,
   round(CAST((((t2.perc_forest_area_16 - t1.perc_forest_area_90)/
  (t1.perc_forest_area_90))*100)AS NUMERIC), 2) AS perc_forest_diff
FROM
   t1 
   JOIN
      t2 
      ON t1.country_name = t2.country_name 
WHERE
   t1.country_name != 'World' 
   AND T1.perc_forest_area_90 IS NOT NULL
AND T2.perc_forest_area_16 IS NOT NULL

ORDER BY
   3 LIMIT 5;

--c) If countries were grouped by percent forestation in 
-- quartiles, which group had the most countries in it in 2016?

SELECT
   T1.perc_forest_area_quartiles,
   COUNT(t1.perc_forest_area_quartiles),
   RANK() OVER (
ORDER BY
   COUNT(t1.perc_forest_area_quartiles)DESC) AS count_rank 
FROM
   (
      SELECT
         perc_forest_area,
         CASE
            WHEN
               perc_forest_area <= 25 
            THEN
               '0-25' 
            WHEN
               perc_forest_area <= 50 
               AND perc_forest_area > 25 
            THEN
               '26-50' 
            WHEN
               perc_forest_area <= 75 
               AND perc_forest_area > 51 
            THEN
               '51-75' 
            ELSE
               '76-100' 
         END
         AS perc_forest_area_quartiles 
      FROM
         forestation 
      WHERE
         YEAR = 2016 
         AND perc_forest_area IS NOT NULL 
      ORDER BY
         perc_forest_area 
   )
   t1 
GROUP BY
   perc_forest_area_quartiles 
ORDER BY
   2 DESC;

-- d) List all of the countries that were in the 4th quartile (percent forest > 75%) in 2016.

SELECT
   t1.country_name 
FROM
   (
      SELECT
         country_name,
         perc_forest_area,
         CASE
            WHEN
               perc_forest_area <= 25 
            THEN
               '0-25' 
            WHEN
               perc_forest_area <= 50 
               AND perc_forest_area > 25 
            THEN
               '26-50' 
            WHEN
               perc_forest_area <= 75 
               AND perc_forest_area > 51 
            THEN
               '51-75' 
            ELSE
               '76-100' 
         END
         AS perc_forest_area_quartiles 
      FROM
         forestation 
      WHERE
         YEAR = 2016 
         AND perc_forest_area IS NOT NULL 
   )
   t1 
WHERE
   perc_forest_area_quartiles = '76-100'
                                                                                                                                                                                                                                                                                                              
--e) How many countries had a percent forestation higher than the United States in 2016?

SELECT
   COUNT(country_name) AS country_count_higher_usa 
FROM
   forestation 
WHERE
   perc_forest_area > 
   (
   SELECT
      perc_forest_area 
   FROM
      forestation 
   WHERE
      year = 2016 
      AND country_name = 'United States'
   ) 
AND year = 2016;       