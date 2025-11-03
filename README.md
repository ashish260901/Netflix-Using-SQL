# 🎬 Netflix SQL Analysis Project (PostgreSQL)

## 📖 Overview
This project explores Netflix content data using **PostgreSQL**.  
It includes various SQL queries to analyze, categorize, and extract insights from Netflix titles such as movies and TV shows.  

The analysis covers content trends, genres, countries, directors, and more.

---

## 🧱 Database Setup

### Create Table

```sql
CREATE TABLE Netflix (
    show_id VARCHAR(6),
    type VARCHAR(10),
    title VARCHAR(150),
    director VARCHAR(100),
    casts TEXT,
    country VARCHAR(100),
    date_added VARCHAR(50),
    release_year INT,
    rating VARCHAR(10),
    duration VARCHAR(50),
    listed_in TEXT,
    description TEXT
);
🔍 Basic Exploration
sql
Copy code
-- View all data
SELECT * FROM Netflix;

-- Count total content
SELECT COUNT(*) AS total_content FROM Netflix;

-- View unique content types
SELECT DISTINCT type FROM Netflix;
📊 Analysis Queries
1️⃣ Count the number of Movies vs TV Shows
sql
Copy code
SELECT type, COUNT(*) AS total_content 
FROM Netflix 
GROUP BY type;
2️⃣ Find the most common rating for movies and TV shows
sql
Copy code
SELECT type, rating 
FROM (
    SELECT 
        type, 
        rating, 
        COUNT(*), 
        RANK() OVER (PARTITION BY type ORDER BY COUNT(*) DESC) AS ranking 
    FROM Netflix 
    GROUP BY 1,2
) AS t1
WHERE ranking = 1;
3️⃣ List all movies released in a specific year (e.g., 2020)
sql
Copy code
SELECT * 
FROM Netflix 
WHERE type = 'Movie' AND release_year = 2020;
4️⃣ Find the top 5 countries with the most content on Netflix
sql
Copy code
SELECT 
    UNNEST(STRING_TO_ARRAY(country, ',')) AS country, 
    COUNT(show_id) AS total_content 
FROM Netflix 
GROUP BY 1 
ORDER BY 2 DESC 
LIMIT 5;
5️⃣ Identify the longest movie
sql
Copy code
SELECT * 
FROM Netflix 
WHERE type = 'Movie' 
AND duration = (SELECT MAX(duration) FROM Netflix);
6️⃣ Find content added in the last 5 years
sql
Copy code
SELECT * 
FROM Netflix 
WHERE (
    (date_added ~ '^[0-9]{4}-[0-9]{2}-[0-9]{2}$' 
        AND TO_DATE(date_added, 'YYYY-MM-DD') >= CURRENT_DATE - INTERVAL '5 years')
    OR
    (date_added ~ '^[A-Za-z]+' 
        AND TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years')
);
7️⃣ Find all the movies/TV shows by director 'Rajiv Chilaka'
sql
Copy code
SELECT * 
FROM Netflix 
WHERE director ILIKE '%Rajiv Chilaka%';
8️⃣ List all TV shows with more than 5 seasons
sql
Copy code
SELECT * 
FROM Netflix 
WHERE type = 'TV Show' 
AND SPLIT_PART(duration, ' ', 1)::NUMERIC > 5;
9️⃣ Count the number of content items in each genre
sql
Copy code
SELECT 
    UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS genre, 
    COUNT(show_id) AS total_content 
FROM Netflix 
GROUP BY 1 
ORDER BY 2 DESC;
🔟 Find each year and the average numbers of content release in India on Netflix (Top 5 Years)
sql
Copy code
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
    COUNT(*) AS total,
    ROUND(COUNT(*)::NUMERIC / 
        (SELECT COUNT(*) FROM Netflix WHERE country = 'India')::NUMERIC * 100, 2
    ) AS avg_content_per_year
FROM Netflix
WHERE country = 'India'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;
11️⃣ List all movies that are documentaries
sql
Copy code
SELECT * 
FROM Netflix 
WHERE listed_in ILIKE '%Documentaries%';
12️⃣ Find all content without a director
sql
Copy code
SELECT * 
FROM Netflix 
WHERE director IS NULL;
13️⃣ Find how many movies actor 'Salman Khan' appeared in last 10 years
sql
Copy code
SELECT * 
FROM Netflix 
WHERE casts ILIKE '%Salman Khan%' 
AND release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10;
14️⃣ Find the top 10 actors who have appeared in the highest number of movies produced in India
sql
Copy code
SELECT 
    UNNEST(STRING_TO_ARRAY(casts, ',')) AS actor,
    COUNT(*) 
FROM Netflix
WHERE country = 'India'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;
15️⃣ Categorize content based on keywords 'kill' or 'violence' in the description
sql
Copy code
SELECT 
    category,
    type,
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
🧠 Insights from the Project
Distribution between Movies and TV Shows.

Top-rated categories and most frequent ratings.

Regional trends in Netflix content.

Insights about directors, actors, and genres.

Categorization of content based on violence indicators.

🧰 Tools & Technologies
Database: PostgreSQL

Language: SQL

Platform: pgAdmin4

Dataset: Netflix titles (CSV or imported data)

👩‍💻 Author

Ashish
📧 ashishssep2001@gmail.com
