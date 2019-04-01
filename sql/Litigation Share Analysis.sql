WITH casedata AS (
	SELECT
		casenumber,
		YEAR(datefiled) AS year,
		location
	FROM casehistory
	WHERE natureofsuit = 'ANTITRUST'
	GROUP BY casenumber, datefiled, location),

casedata_agg AS (
SELECT
	location,
	year,
	COUNT(*) casevolume
FROM casedata
GROUP BY location, year),

reshape_casedata AS (
SELECT
	location,
	[2014], [2015], [2016], [2017], [2018], [2019]
FROM casedata_agg
PIVOT
(MAX(casevolume) FOR year IN (
	[2014], [2015], [2016], [2017], [2018], [2019]
)) AS pivottable),

calculate_share AS (
SELECT 
	location,
	ROUND(CAST([2014] AS FLOAT) / (SELECT SUM([2014]) FROM reshape_casedata), 5) AS [2014],
	ROUND(CAST([2015] AS FLOAT) / (SELECT SUM([2015]) FROM reshape_casedata), 5) AS [2015],
	ROUND(CAST([2016] AS FLOAT) / (SELECT SUM([2016]) FROM reshape_casedata), 5) AS [2016],
	ROUND(CAST([2017] AS FLOAT) / (SELECT SUM([2017]) FROM reshape_casedata), 5) AS [2017],
	ROUND(CAST([2018] AS FLOAT) / (SELECT SUM([2018]) FROM reshape_casedata), 5) AS [2018],
	ROUND(CAST([2019] AS FLOAT) / (SELECT SUM([2019]) FROM reshape_casedata), 5) AS [2019]
FROM reshape_casedata)

SELECT
	location AS State,
	CASE WHEN [2014] IS NULL THEN 0 ELSE [2014] END AS [2014],
	CASE WHEN [2015] IS NULL THEN 0 ELSE [2015] END AS [2015],
	CASE WHEN [2016] IS NULL THEN 0 ELSE [2016] END AS [2016],
	CASE WHEN [2017] IS NULL THEN 0 ELSE [2017] END AS [2017],
	CASE WHEN [2018] IS NULL THEN 0 ELSE [2018] END AS [2018],
	CASE WHEN [2019] IS NULL THEN 0 ELSE [2019] END AS [2019]
FROM calculate_share;