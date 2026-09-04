/*
	AUTHOR: Rodini Vince B. Rosario
	VERSION@September 4, 2026
	PROBLEM: Exploratory SQL analysis of global CO2 emissions data (mtco2_flat, 
	percapita_flat) covering data cleaning/validation, total vs. per-capita 
	emissions rankings, source breakdown (coal/oil/gas/cement/flaring), year-over-
	year trends, top-emitter concentration since 2002, and a US vs. India 
	developed/developing comparison.
*/


-- Data Cleaning & Validation
-- Sanity checks on both tables before running any analysis queries
-- Check for duplicate rows (same country + year appearing twice)
SELECT 
	country, 
	year, 
	COUNT(*)
FROM mtco2_flat
GROUP BY country, year
HAVING COUNT(*) > 1;

-- Check row counts match across tables
SELECT COUNT(*) FROM mtco2_flat;
SELECT COUNT(*) FROM percapita_flat;

-- Look for non-country "aggregate" rows mixed into country data
SELECT DISTINCT country
FROM mtco2_flat
ORDER BY country;

-- Check for negative or clearly wrong values
SELECT 
	country, 
	year, 
	total
FROM mtco2_flat
WHERE total < 0;

-- Check the ISO code column for blanks — these usually flag non-standard entities
SELECT 
	DISTINCT country, 
	iso_code
FROM mtco2_flat
WHERE iso_code IS NULL 
	OR iso_code = '';

-- Check how much data is missing (NULL) for recent years
SELECT 
	year, 
	COUNT(*) AS total_rows, 
	COUNT(total) AS non_null_total
FROM mtco2_flat
WHERE year >= 2015
GROUP BY year
ORDER BY year;


-- Analysis Questions
-- 13 questions grouped by complexity: warm-up aggregates, time trends, 
-- joins across both tables, and impact-focused comparisons

-- Warm-up: single-table aggregates
-- Basic filtering, ranking, and grouping on mtco2_flat/percapita_flat alone
-- 1. Which 10 countries had the highest total emissions in the most recent year available?
SELECT 
	country, 
	year, 
	total
FROM mtco2_flat
WHERE total IS NOT NULL
  AND country <> 'Global'
  AND iso_code IS NOT NULL
  AND year = (
	  	SELECT MAX(year) 
		FROM mtco2_flat
	)
ORDER BY total DESC
LIMIT 10;

-- 2. Which 10 countries had the highest per-capita emissions in the most recent year?
SELECT 
	p.country, 
	p.year, 
	p.total
FROM percapita_flat p
WHERE p.total IS NOT NULL
	AND p.country <> 'Global'
	AND p.iso_code IS NOT NULL
	AND p.year = (
			SELECT MAX(year)
			FROM percapita_flat
		)
ORDER BY p.total DESC
LIMIT 10;

-- 3. What's the global breakdown by source (coal, oil, gas, cement, flaring) for the latest year — which source dominates?
SELECT 
	country,
	year,
	total,
	ROUND(coal / total * 100, 1) AS coal_pct,
    ROUND(oil / total * 100, 1) AS oil_pct,
    ROUND(gas / total * 100, 1) AS gas_pct,
    ROUND(cement / total * 100, 1) AS cement_pct,
    ROUND(flaring / total * 100, 1) AS flaring_pct
FROM mtco2_flat
WHERE country = 'Global'
	AND year = (
			SELECT MAX(year)
			FROM mtco2_flat
		);

-- 4. How many countries have zero or missing (NULL) emissions data in a given recent year — any surprises?
-- Part A: The list, with zero/missing clearly labeled
SELECT 
    country,
    total,
    CASE 
        WHEN total IS NULL THEN 'Missing'
        WHEN total = 0 THEN 'Zero'
    END AS status
FROM mtco2_flat
WHERE country <> 'Global'
    AND iso_code IS NOT NULL
    AND (total = 0 OR total IS NULL)
    AND year = (
			SELECT MAX(year) 
			FROM mtco2_flat
		)
ORDER BY status, country;

-- Part B: The count, which directly answers "how many"
SELECT 
    COUNT(*) FILTER (WHERE total IS NULL) AS missing_count,
    COUNT(*) FILTER (WHERE total = 0) AS zero_count
FROM mtco2_flat
WHERE country <> 'Global'
    AND iso_code IS NOT NULL
    AND year = (
			SELECT MAX(year) 
			FROM mtco2_flat
		);

-- Time Trends: year-over-year change and long-run trajectories
-- Uses LAG() and self-joins to compare emissions across years
-- 5. Global total emissions trend by year
SELECT 
	year,
	total,
	total - LAG(total) OVER(ORDER BY year) AS yoy_change,
	ROUND((total - LAG(total) OVER (ORDER BY year)) / LAG(total) OVER (ORDER BY year) * 100, 2) AS yoy_pct_change
FROM mtco2_flat
WHERE country = 'Global'
	AND year >= 1950
ORDER BY year;

-- 6. Which countries increased total emissions the most since 2002? Which decreased the most?
SELECT 
    a.country,
    a.total AS total_2002,
    b.total AS total_latest,
    b.total - a.total AS change,
    ROUND((b.total - a.total) / a.total * 100, 2) AS pct_change
FROM mtco2_flat a
JOIN mtco2_flat b 
    ON a.country = b.country
WHERE a.year = 2002
	AND b.year = (SELECT MAX(year) FROM mtco2_flat)
	AND a.iso_code IS NOT NULL
	AND a.country <> 'Global'
	AND a.total IS NOT NULL
	AND a.total <> 0
	AND b.total IS NOT NULL
ORDER BY change DESC
LIMIT 10;

-- 7. Year-over-year % change for one major emitter using LAG()
SELECT 
	country,
	year,
	ROUND(total, 2) AS current_year_total,
	ROUND(LAG(total) OVER(ORDER BY year), 2) AS previous_year_total,
	ROUND(((total - LAG(total) OVER(ORDER BY year)) / LAG(total) OVER(ORDER BY year)) * 100, 2) AS pct_change 
FROM mtco2_flat
WHERE country = 'China' 
	AND year >= 2002
ORDER BY year ASC;


-- Joins Across Tables: total vs. per-capita, ranking divergence
-- Combines mtco2_flat and percapita_flat to compare emissions by scale vs. by person
-- 8. Join mtco2_flat and percapita_flat on country+year: 
-- which countries have high total emissions but low per-capita (big population, industrializing) 
-- vs low total but high per-capita (small population, high consumption)?
-- Part A: Sorted by total emissions — surfaces the "big population, industrializing" side
SELECT 
	m.country,
	m.year,
	m.total AS emission,
	p.total AS per_capita
FROM mtco2_flat AS m
INNER JOIN percapita_flat AS p
ON m.country = p.country 
	AND m.year = p.year
WHERE m.country <> 'Global'
	AND m.iso_code IS NOT NULL
	AND m.year BETWEEN 2016 AND 2021
ORDER BY emission DESC;

-- Part B: Sorted by per-capita — surfaces the "small population, high consumption" side
SELECT m.country,
	m.year,
	m.total AS emission,
	p.total AS per_capita
FROM mtco2_flat AS m
INNER JOIN percapita_flat AS p
ON m.country = p.country AND m.year = p.year
WHERE m.country <> 'Global'
	AND m.iso_code IS NOT NULL
	AND m.year BETWEEN 2016 AND 2021
	AND p.total IS NOT NULL
ORDER BY per_capita DESC;
	
-- 9. Rank countries by total emissions within each year, alongside their per-capita rank 
-- in the same year — where do rankings diverge most?
SELECT 
	m.country,
	m.year,
	m.total AS emission,
	p.total AS per_capita,
	DENSE_RANK() OVER(PARTITION BY m.year ORDER BY m.total DESC) AS emission_rank,
	DENSE_RANK() OVER(PARTITION BY m.year ORDER BY p.total DESC) AS per_capita_rank,
	ABS(DENSE_RANK() OVER(PARTITION BY m.year ORDER BY m.total DESC)  - 
		DENSE_RANK() OVER(PARTITION BY m.year ORDER BY p.total DESC)) AS rank_gap
FROM mtco2_flat AS m
INNER JOIN percapita_flat AS p
ON m.country = p.country 
	AND m.year = p.year
WHERE m.country <> 'Global'
	AND m.iso_code IS NOT NULL
	AND p.total IS NOT NULL
	AND m.year BETWEEN 2016 AND 2021
ORDER BY rank_gap DESC;

-- 10. For the top 10 total emitters, what's their per-capita rank? (shows the "who's actually responsible" story)
WITH ranked AS(
	SELECT
		m.country,
		m.year,
		m.total AS emission,
		p.total AS per_capita,
		DENSE_RANK() OVER(ORDER BY m.total DESC) AS emission_rank,
		DENSE_RANK() OVER(ORDER BY p.total DESC) AS per_capita_rank
	FROM mtco2_flat AS m
	INNER JOIN percapita_flat AS p
	ON m.country = p.country AND m.year = p.year
	WHERE m.country <> 'Global'
		AND m.iso_code IS NOT NULL
		AND p.total IS NOT NULL
		AND m.year = (
			SELECT MAX(year)
			FROM mtco2_flat
		)
)

SELECT *
FROM ranked
WHERE emission_rank <= 10
ORDER BY emission_rank ASC;

-- Impact-Focused: peak emissions, global concentration, country comparisons
-- Looks at per-capita improvement over time and developed vs. developing trajectories
-- 11. Which countries cut per-capita emissions the most since their peak year?
SELECT 
	*,
	ROUND((peak_capita - latest_capita) / peak_capita * 100, 2) AS pct_drop,
	ROUND(peak_capita - latest_capita, 2) AS absolute_drop
FROM (
	SELECT
		m.country,
		MAX(p.total) AS peak_capita,
		(
			SELECT total
			FROM percapita_flat
			WHERE country = m.country
				AND year = (SELECT MAX(year) FROM mtco2_flat)
		) AS latest_capita
	FROM mtco2_flat AS m
	INNER JOIN percapita_flat AS p
		ON m.country = p.country AND m.year = p.year
	WHERE m.country <> 'Global'
		AND m.iso_code IS NOT NULL
		AND p.total IS NOT NULL
	GROUP BY m.country
) AS capita_summary
WHERE peak_capita > latest_capita
	AND peak_capita > 1
ORDER BY pct_drop DESC
LIMIT 10;

-- 12. What share of total global emissions do the top 10 countries account for, 
-- and how has that share changed since 2002?
WITH yearly_totals AS (
	SELECT
		year,
		SUM(CASE WHEN country = 'Global' THEN 0 ELSE total END) AS global_total,
		SUM(CASE WHEN emission_rank <= 10 THEN total ELSE 0 END) AS top10_total
	FROM (
		SELECT
			country,
			year,
			total,
			DENSE_RANK() OVER (PARTITION BY year ORDER BY total DESC) AS emission_rank
		FROM mtco2_flat
		WHERE country <> 'Global'
			AND iso_code IS NOT NULL
	) AS ranked
	GROUP BY year
)
SELECT
	year,
	global_total,
	top10_total,
	ROUND(top10_total / global_total * 100, 2) AS top10_share_pct
FROM yearly_totals
WHERE year IN (2002, (SELECT MAX(year) FROM mtco2_flat))
ORDER BY year;

-- 13. Compare a developed vs developing country pair (US vs India) 
-- across both total and per-capita over the full period
SELECT
	m.year,
	MAX(CASE WHEN m.country = 'USA' THEN m.total END) AS us_total,
	MAX(CASE WHEN m.country = 'India' THEN m.total END) AS india_total,
	COALESCE(MAX(CASE WHEN m.country = 'USA' THEN p.total END), 0) AS us_per_capita,
	COALESCE(MAX(CASE WHEN m.country = 'India' THEN p.total END), 0) AS india_per_capita
FROM mtco2_flat AS m
INNER JOIN percapita_flat AS p
	ON m.country = p.country AND m.year = p.year
WHERE m.country IN ('USA', 'India') 
	AND m.year >= 2002
GROUP BY m.year
ORDER BY m.year;
