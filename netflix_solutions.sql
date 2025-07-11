--PROBLEMS AND SOLUTIONS

--1. Count the Number of Movies vs TV Shows
SELECT type, COUNT(*) 
FROM netflix_titles
GROUP BY type;

--2. Find the Most Common Rating for Movies and TV Shows

SELECT type, rating AS most_frequent_rating
FROM (
    SELECT 
        type,
        rating,
        COUNT(*) AS rating_count,
        RANK() OVER (PARTITION BY type ORDER BY COUNT(*) DESC) AS rnk
    FROM netflix_titles
    GROUP BY type, rating
) AS ranked
WHERE rnk = 1;

--3. List All Movies Released in a Specific Year (e.g., 2020)

SELECT * 
FROM netflix_titles
WHERE release_year = '2020';

--4. Find the Top 5 Countries with the Most Content on Netflix

SELECT TOP 5
    country_trimmed AS country,
    COUNT(*) AS total_content
FROM (
    SELECT 
        LTRIM(RTRIM(value)) AS country_trimmed
    FROM netflix_titles
    CROSS APPLY STRING_SPLIT(country, ',')
) AS split_countries
WHERE country_trimmed IS NOT NULL AND country_trimmed <> ''
GROUP BY country_trimmed
ORDER BY total_content DESC;

--5. Identify the Longest Movie

SELECT *
FROM netflix_titles
WHERE type = 'Movie'
ORDER BY 
    TRY_CAST(LEFT(duration, CHARINDEX(' ', duration + ' ') - 1) AS INT) DESC;

--6. Find Content Added in the Last 5 Years

SELECT *
FROM netflix_titles
WHERE 
    TRY_CAST(date_added AS DATE) >= DATEADD(YEAR, -5, GETDATE());

--7. Find All Movies/TV Shows by Director 'Rajiv Chilaka'

SELECT * 
FROM netflix_titles
WHERE  director = 'Rajiv Chilaka';

--8. List All TV Shows with More Than 5 Seasons

SELECT *
FROM netflix_titles
WHERE type = 'TV Show' 
  AND TRY_CAST(LEFT(duration, CHARINDEX(' ', duration + ' ') - 1) AS INT) > 5;

--9. Count the Number of Content Items in Each Genre

SELECT 
    LTRIM(RTRIM(split_genre.value)) AS genre,
    COUNT(*) AS total_content
FROM netflix_titles
CROSS APPLY STRING_SPLIT(listed_in, ',') AS split_genre
GROUP BY LTRIM(RTRIM(split_genre.value));

--10.Find each year and the average numbers of content release in India on netflix.

SELECT TOP 5
    country,
    release_year,
    COUNT(show_id) AS total_release,
    ROUND(
        CAST(COUNT(show_id) AS FLOAT) / 
        (SELECT COUNT(show_id) FROM netflix_titles WHERE country = 'India') * 100, 
        2
    ) AS avg_release
FROM netflix_titles
WHERE country = 'India'
GROUP BY country, release_year
ORDER BY avg_release DESC;

--11. List All Movies that are Documentaries

SELECT * 
FROM netflix_titles
WHERE listed_in LIKE '%Documentaries';

--12. Find All Content Without a Director

SELECT * 
FROM netflix_titles
WHERE director IS NULL;

--13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years

SELECT * 
FROM netflix_titles
WHERE cast LIKE '%Salman Khan%'
 AND TRY_CAST(release_year AS INT) > YEAR(GETDATE()) - 10;


 --14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India

 SELECT TOP 10 
    TRIM(value) AS actor,
    COUNT(*) AS appearances
FROM netflix_titles
CROSS APPLY STRING_SPLIT(cast, ',')
WHERE country = 'India'
GROUP BY TRIM(value)
ORDER BY COUNT(*) DESC;

--15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords

SELECT 
    category,
    COUNT(*) AS content_count
FROM (
    SELECT 
        CASE 
            WHEN description LIKE '%kill%' OR description LIKE '%violence%' THEN 'Bad'
            ELSE 'Good'
        END AS category
    FROM netflix_titles
) AS categorized_content
GROUP BY category;



