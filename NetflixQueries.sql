-- NETFLIX Project
SELECT
	*
FROM
	NetflixProject..Netflix


-- Verificamos cuantas peliculas/series cargadas hay
Select
	COUNT(*) as Total_MoviesSeries
FROM
	NetflixProject..Netflix

-- ver 2 SUBCONSULTAS
SELECT
	(SELECT COUNT(*) FROM NetflixProject..Netflix) AS Total_MoviesSeries,
	(SELECT COUNT(*) FROM NetflixProject..Netflix WHERE type = 'Movie') AS Total_Movies,
	(SELECT COUNT(*) FROM NetflixProject..Netflix WHERE type = 'TV Show') AS Total_Series


-- Mostramos tipos de shows del dataset
SELECT
	DISTINCT type
FROM NetflixProject..Netflix


--2. Find the most common rating for movies and TV shows
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


--4. Find the top 5 countries with the most content on Netflix
SELECT TOP 5
    country,
    COUNT(*) AS total_content
FROM
    NetflixProject..Netflix
WHERE
    country IS NOT NULL
GROUP BY
    country
ORDER BY
    total_content DESC;


--5. Identify the longest movie
SELECT 
	type,
	title,
	CAST(LEFT(duration, CHARINDEX(' ', duration) - 1) AS INT) AS duration_in_minutes
FROM
	NetflixProject..Netflix
WHERE
    type = 'Movie' AND duration LIKE '%min'
ORDER BY
    duration_in_minutes DESC;


--6. Find content added in the last 5 years
SELECT
	title,
	release_year
FROM
	NetflixProject..Netflix
WHERE
	 release_year >= YEAR(GETDATE()) - 5 AND release_year <= YEAR(GETDATE())


--7. Find all the movies/TV shows by director 'Rajiv Chilaka'!
SELECT
	type,
	title,
	director
FROM
	NetflixProject..Netflix
WHERE
	LOWER(director) like 'rajiv chilaka' -- Buena practica pasarlo a minusculas



--8. List all TV shows with more than 5 seasons
SELECT
	type,
	title,
	duration
FROM
	NetflixProject..Netflix
WHERE
	type = 'TV Show' AND
	CAST(LEFT(duration, CHARINDEX(' ', duration) - 1) AS INT) > 5
ORDER BY
	CAST(LEFT(duration, CHARINDEX(' ', duration) - 1) AS INT) DESC;


--9. Count the number of content items in each genre
SELECT
	TRIM(value) AS genre, -- Quita espacios alrededor del valor y value es cada valor que STRING_SPLIT separa
	COUNT(*) AS quantity
FROM
	NetflixProject..Netflix
CROSS APPLY -- Aplica una función a cada fila de una columna especificada
    STRING_SPLIT(listed_in, ',') -- Divide los géneros separados por coma
WHERE
	listed_in IS NOT NULL
GROUP BY
    TRIM(value)        
ORDER BY 
	COUNT(*) DESC


--10.Find each year and the average numbers of content release in India on netflix. 
--return top 5 year with highest avg content release!

WITH YearlyContent AS (
    SELECT
        release_year,
        COUNT(*) AS total_content  -- Total de contenido lanzado por año en India
    FROM
        NetflixProject..Netflix
    WHERE
        country = 'India'          -- Filtramos solo los datos de India
    GROUP BY
        release_year               -- Agrupamos por año de lanzamiento
),
TotalContent AS (
    SELECT
        COUNT(*) AS global_content -- Total global de contenidos en India
    FROM
        NetflixProject..Netflix
    WHERE
        country = 'India'         -- Filtramos solo los contenidos de India
)
SELECT TOP 5
    yc.release_year,
    yc.total_content,
    (yc.total_content * 1.0 / tc.global_content) AS avg_content_percentage  -- Calculamos el porcentaje de contenido por año
FROM
    YearlyContent yc
CROSS JOIN
    TotalContent tc
ORDER BY
    avg_content_percentage DESC; -- Ordenamos por el porcentaje de contenido de mayor a menor


--11. List all movies that are documentaries
SELECT
    TRIM(value) AS genre, -- Quita espacios alrededor del valor
	title
FROM
    NetflixProject..Netflix
CROSS APPLY  -- Aplica una función a cada fila de una columna especificada
    STRING_SPLIT(listed_in, ',')  -- Divide los géneros separados por coma
WHERE
	type = 'Movie'  -- Filtra por películas
    AND TRIM(value) = 'Documentaries'  -- Filtra por documentales

--12. Find all content without a director
SELECT
	type, title, director
FROM
	NetflixProject..Netflix
WHERE
	director is NULL


--13. Find how many movies actor 'Salman Khan' appeared in last 10 years!
SELECT
    TRIM(value) AS actor, -- Quita espacios alrededor del valor
	title,
	release_year
FROM
    NetflixProject..Netflix
CROSS APPLY  -- Aplica una función a cada fila de una columna especificada
    STRING_SPLIT(cast, ',')  -- Divide actores separados por coma
WHERE
	type = 'Movie'  -- Filtra por películas
    AND LOWER(TRIM(value)) = 'salman khan'  -- Filtra por documentales
	AND release_year >= YEAR(GETDATE()) - 10


--14. Find the top 10 actors who have appeared in the highest number of movies produced in India.
SELECT TOP 10
    TRIM(value) AS actor,         -- Nombre del actor (sin espacios adicionales)
    COUNT(*) AS total_movies      -- Total de películas en las que apareció
FROM
    NetflixProject..Netflix
CROSS APPLY
    STRING_SPLIT(cast, ',')       -- Divide los nombres de los actores separados por comas
WHERE
    type = 'Movie'                -- Filtra por películas
    AND country = 'India'         -- Filtra por contenido producido en India
    AND cast IS NOT NULL          -- Asegúrate de que la columna cast no sea NULL
GROUP BY
    TRIM(value)                   -- Agrupa por el nombre del actor
ORDER BY
    total_movies DESC; 


--15.
--Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
--the description field. Label content containing these keywords as 'Bad' and all other 
--content as 'Good'. Count how many items fall into each category.
SELECT
    CASE
        WHEN description LIKE '%kill%' OR description LIKE '%violence%' THEN 'Bad'
        ELSE 'Good'
    END AS category,         -- Etiqueta como 'Bad' o 'Good'
    COUNT(*) AS total_items  -- Cuenta el número de elementos en cada categoría
FROM
    NetflixProject..Netflix
GROUP BY
    CASE
        WHEN description LIKE '%kill%' OR description LIKE '%violence%' THEN 'Bad'
        ELSE 'Good'
    END;                   