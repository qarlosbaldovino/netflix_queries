-- NETFLIX PROJECT

-- 1. Count the number of Movies vs TV Shows
SELECT
	type,
	COUNT(*) AS Total,
	FORMAT((COUNT(*) * 100.0) / SUM(COUNT(*)) OVER(), 'N2') + '%' AS Percentage
FROM
	Netflix
GROUP BY
	type


-- 2. Find the most common rating for movies and TV shows
SELECT
	type,
	rating,
	total_rating
FROM
(
SELECT
	type,
	rating,
	COUNT(*) as total_rating,
	RANK() OVER(PARTITION BY type ORDER BY COUNT(*) DESC) as ranking
FROM
	NetflixProject..Netflix 
GROUP BY 
	type, rating
) as t1
WHERE 
	ranking = 1

-- VER 2 con CTE
WITH CountedRatings AS (
    SELECT
        type,
        rating,
        COUNT(*) AS Total
    FROM
        NetflixProject..Netflix
    GROUP BY
        type, rating
),
MaxRatings AS (
    SELECT
        type,
        MAX(Total) AS MaxTotal
    FROM
        CountedRatings
    GROUP BY
        type
)
SELECT
    c.type,
    c.rating,
    c.Total
FROM
    CountedRatings c
JOIN
    MaxRatings m
ON
    c.type = m.type AND c.Total = m.MaxTotal
ORDER BY
    c.type, c.Total DESC;

--3. List all movies released in a specific year (e.g., 1997)
SELECT
	type,
	title,
	release_year
FROM
	NetflixProject..Netflix
WHERE
	type = 'Movie'
	AND	
	release_year = 1997