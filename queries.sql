SELECT *
FROM netflix
WHERE FALSE;  -- This will return an empty result but show the column names.

--data cleaning
DELETE FROM netflix
WHERE 
    show_id IS NULL
    OR
    "type" IS NULL
    OR 
    title IS NULL
    OR
    director IS NULL
    OR
    casts IS NULL
    OR
    description IS NULL
    OR
    country IS NULL
    OR
    date_added IS NULL  -- Corrected here
    OR
    release_year IS NULL
    OR
    rating IS NULL
    OR
    duration IS NULL
    OR
    listed_in IS NULL;
	select count(*) from netflix;

-- 1. Count the number of Movies vs TV Shows
SELECT 
	type,
	COUNT(*)
FROM netflix
GROUP BY 1

-- 2. Find the most common rating for movies and TV shows
WITH RatingCounts AS (
    SELECT 
        type,
        rating,
        COUNT(*) AS rating_count
    FROM netflix
    GROUP BY type, rating
),
RankedRatings AS (
    SELECT 
        type,
        rating,
        rating_count,
        RANK() OVER (PARTITION BY type ORDER BY rating_count DESC) AS rank
    FROM RatingCounts
)
SELECT 
    type,
    rating AS most_frequent_rating
FROM RankedRatings
WHERE rank = 1;

-- 3. List all movies released in a specific year (e.g., 2020)
select release_year, title from netflix
group by release_year, title
order by release_year;

-- 4. Find the top 5 countries with the most content on Netflix

SELECT * 
FROM  
(
	SELECT 
		
		UNNEST(STRING_TO_ARRAY(country, ',')) as country,
		COUNT(*) as total_content
	FROM netflix
	GROUP BY 1
)as t1
WHERE country IS NOT NULL
ORDER BY total_content DESC
LIMIT 5

--5. Identify the longest movie

select title, duration
from netflix
where type='Movie'
ORDER BY SPLIT_PART(duration, ' ', 1)::INT DESC

-- 6. Find content added in the last 5 years
SELECT
*
FROM netflix
WHERE TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years'

--7. Find all the movies/TV shows by director 'Rajiv Chilaka'!
select * from  
(select *,
UNNEST(STRING_TO_ARRAY(director, ',')) as director_name
from netflix)
where
director_name='Rajiv Chilaka'

--alternative code:
select * from netflix where director like '%Rajiv Chilaka%';

-- 8. List all TV shows with more than 5 seasons
select * from netflix
where type='TV Show' and split_part(duration,' ',1)::int>5;

-- 9. Count the number of content items in each genre
select 
unnest(string_to_array(listed_in,',')) as genre_name , count(*) as total_content from netflix
group by genre_name;


---- 10. Find each year and the average numbers of content release by India on netflix. 
-- return top 5 year with highest avg content release !

SELECT 
	country,
	release_year,
	COUNT(show_id) as total_release,
	ROUND(
		COUNT(show_id)::numeric/
								(SELECT COUNT(show_id) FROM netflix WHERE country = 'India')::numeric * 100 
		,2
		)
		as avg_release
FROM netflix
WHERE country = 'India' 
GROUP BY country, 2
ORDER BY avg_release DESC 
LIMIT 5





-- 12. Find all content without a director
SELECT * FROM netflix
WHERE director IS NULL

-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years!
SELECT * FROM netflix
WHERE 
	casts LIKE '%Salman Khan%'
	AND 
	release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10

-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.
SELECT count(*),
    unnest(string_to_array(casts, ',')) AS cast_name
	
    FROM netflix
	where country='India'
group by cast_name
order by count(*) desc
limit 10;


/*
Question 15:
Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
the description field. Label content containing these keywords as 'Bad' and all other 
content as 'Good'. Count how many items fall into each category.
*/


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
    FROM netflix
) AS categorized_content
GROUP BY 1,2
ORDER BY 2
