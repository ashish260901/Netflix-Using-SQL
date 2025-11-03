-- Netfilx Project

CREATE TABLE Netflix (
     show_id VARCHAR(6),
	 type VARCHAR(10),
	 title VARCHAR(150),
	 director VARC
	 cast	
	 country	
	 date_added	
	 release_year	
	 rating	duration	
	 listed_in	
	 description
)

SELECT * FROM Netflix;

SELECT COUNT (*) AS total_content FROM Netflix;

SELECT DISTINCT TYPE FROM Netflix;

-- 1. Count the number of Movies vs TV Shows
SELECT type, COUNT(*) AS total_content FROM Netflix GROUP BY type;

-- 2. Find the most common rating for movies and TV shows
SELECT type, rating FROM 
(SELECT type, rating, COUNT(*), RANK() OVER (PARTITION BY type ORDER BY COUNT(*) DESC) AS ranking FROM Netflix GROUP BY 1,2) AS t1
WHERE ranking = 1;

-- 3. List all movies released in a specific year (e.g., 2020)
SELECT * FROM Netflix WHERE type = 'Movie' AND release_year = 2020;

-- 4. Find the top 5 countries with the most content on Netflix
SELECT UNNEST(STRING_TO_ARRAY(country,',')) AS Country, COUNT(show_id) AS total_content FROM Netflix GROUP BY 1 ORDER BY 2 DESC LIMIT 5;
 
-- 5. Identify the longest movie
SELECT * FROM Netflix WHERE type = 'Movie' AND duration = (SELECT MAX(duration) FROM Netflix);

-- 6. Find content added in the last 5 years
SELECT * FROM Netflix WHERE (
    (date_added ~ '^[0-9]{4}-[0-9]{2}-[0-9]{2}$' AND TO_DATE(date_added, 'YYYY-MM-DD') >= CURRENT_DATE - INTERVAL '5 years')
    OR
    (date_added ~ '^[A-Za-z]+' AND TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years'));

-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!
SELECT * FROM Netflix WHERE director ILIKE '%Rajiv Chilaka%';

-- 8. List all TV shows with more than 5 seasons
SELECT * FROM Netflix WHERE type = 'TV Show' AND  SPLIT_PART(duration, ' ', 1):: NUMERIC > 5;

-- 9. Count the number of content items in each genre
SELECT UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS genre, COUNT(show_id) AS total_content FROM Netflix GROUP BY 1 ORDER BY 2 DESC;

-- 10.Find each year and the average numbers of content release in India on netflix. Return top 5 year with highest avg content release!
 SELECT 
    EXTRACT(YEAR FROM 
        CASE
            WHEN date_added ~ '^[0-9]{4}-[0-9]{2}-[0-9]{2}$' 
                THEN TO_DATE(date_added, 'YYYY-MM-DD')
            WHEN date_added ~ '^[A-Za-z]+' 
                THEN TO_DATE(date_added, 'Month DD, YYYY')
            ELSE NULL
        END
    ) AS year,
    COUNT(*),
	ROUND(COUNT(*)::NUMERIC/(SELECT COUNT(*) FROM Netflix WHERE country = 'India')::NUMERIC * 100,2) AS avg_content_per_year
FROM Netflix
WHERE country = 'India'
GROUP BY 1
ORDER BY 2 DESC;

-- 11. List all movies that are documentaries
SELECT * FROM Netflix WHERE listed_in ILIKE '%Documentaries%';

-- 12. Find all content without a director
SELECT * FROM Netflix WHERE director IS NULL;

-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years!
SELECT * FROM Netflix WHERE casts ILIKE '%Salman Khan%' AND release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10;

-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.
SELECT 
	UNNEST(STRING_TO_ARRAY(casts, ',')) as actor,
	COUNT(*)
FROM Netflix
WHERE country = 'India'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;

-- 15. Categorize the content based on the presence of the keywords 'kill' and 'violence' in the description field. Label content 
-- containing these keywords as 'Bad' and all other content as 'Good'. Count how many items fall into each category.
SELECT 
    category,
	TYPE,
    COUNT(*) AS content_count
FROM (
    SELECT 
		*,
        CASE 
            WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'Bad'
            ELSE 'Good'
        END AS category
    FROM Netflix
) AS categorized_content
GROUP BY 1,2
ORDER BY 2;
