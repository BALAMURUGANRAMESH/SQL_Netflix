Use netflix;

-- Project TASK 
-- 1. Count the number of Movies vs TV Shows

SELECT type, COUNT(*)
FROM netflix
GROUP BY 1;

-- 2. Find the most common rating for movies and TV shows
SELECT 
		type, 
		rating, 
		COUNT(*) AS total_count,
		RANK() OVER(PARTITION BY type ORDER BY COUNT(*) DESC) as ranks
	FROM netflix
	GROUP BY type, rating;

SELECT type, rating, total_count
	FROM (
		SELECT 
			type, 
			rating, 
			COUNT(*) AS total_count,
			RANK() OVER(PARTITION BY type ORDER BY COUNT(*) DESC) as ranks
		FROM netflix
		GROUP BY type, rating
	) AS Ranking
	WHERE ranks = 1;

Delimiter $$
Create procedure most_common_ratings()
Begin
	SELECT type, rating, total_count
	FROM (
		SELECT 
			type, 
			rating, 
			COUNT(*) AS total_count,
			RANK() OVER(PARTITION BY type ORDER BY COUNT(*) DESC) as ranks
		FROM netflix
		GROUP BY type, rating
	) AS Ranking
	WHERE ranks = 1;
End $$ 
Delimiter ;

Call most_common_ratings();

-- 3. List all movies released in a specific year (e.g., 2020)
Select * From netflix where release_year = '2020';

-- 4. Find the top 5 countries with the most content on Netflix
SELECT country, COUNT(*) AS total_content 
	FROM netflix
	WHERE country IS NOT NULL
	GROUP BY country
	ORDER BY total_content DESC
	LIMIT 5;
-- 5. Identify the longest movie
SELECT * 
FROM netflix 
WHERE type = 'Movie' 
ORDER BY CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) DESC 
LIMIT 10;

-- 6. Find content added in the last 5 years
SELECT *
FROM netflix
WHERE STR_TO_DATE(date_added, '%M %d, %Y') >= date_sub(current_date(), INTERVAL 5 YEAR);


-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!  (using RECURSIVE)

WITH RECURSIVE director_split AS (
    SELECT 
        show_id, title,
        TRIM(SUBSTRING_INDEX(director, ',', 1)) AS director_name, -- 
        SUBSTRING(director, LOCATE(',', director) + 1) AS remaining_directors
    FROM netflix
    WHERE director IS NOT NULL
    
    UNION ALL
    
    SELECT 
        show_id, title,
        TRIM(SUBSTRING_INDEX(remaining_directors, ',', 1)),
        IF(LOCATE(',', remaining_directors) > 0, 
           SUBSTRING(remaining_directors, LOCATE(',', remaining_directors) + 1), 
           '')
    FROM director_split
    WHERE remaining_directors <> ''
)
SELECT * 
FROM director_split 
WHERE director_name = 'Rajiv Chilaka';

-- 8. List all TV shows with more than 5 seasons

Select * from netflix where type = 'Tv Show' and substring_index(duration, ' ',1) >5;

-- 9. Count the number of content items in each genre

Select SUBSTRING_Index(Listed_in, ",",1 ) as genre, count(listed_in) as content_items from netflix group by 1; 

-- 10.Find each year and the average numbers of content release in India on netflix.  return top 5 year with highest avg content release!

select country, release_year, count(show_id) as total_content, 
	round(count(show_id)/(select count(show_id) from netflix where country = 'india') * 100,1 )  as avg_release
from netflix
Where country = 'India'
group by country, release_year
order by avg_release desc
Limit 5;

-- 11. List all movies that are documentaries

Select * From netflix where listed_in like 'documentaries%';

-- 12. Find all content without a director

Select * From netflix where director = 'Not Available';


-- 13. Find how many movies actor 'Salman Khan' appeared in last 20 years!

SELECT title, release_year
FROM netflix
WHERE casts like '%Salman Khan%' and release_year > extract(year from current_date) -20;

-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.

WITH RECURSIVE actors_split AS (
    -- Initial part: Get the first actor and the remaining string
    SELECT 
        TRIM(SUBSTRING_INDEX(casts, ',', 1)) AS actor,
        SUBSTRING(casts, LOCATE(',', casts) + 1) AS remaining_cast,
        IF(LOCATE(',', casts) > 0, 1, 0) AS has_more
    FROM netflix
    WHERE country = 'India' AND casts IS NOT NULL AND casts <> ''

    UNION ALL

    -- Recursive part: Keep splitting the 'remaining_cast' until done
    SELECT 
        TRIM(SUBSTRING_INDEX(remaining_cast, ',', 1)) AS actor,
        IF(LOCATE(',', remaining_cast) > 0, SUBSTRING(remaining_cast, LOCATE(',', remaining_cast) + 1), '') AS remaining_cast,
        IF(LOCATE(',', remaining_cast) > 0, 1, 0) AS has_more
    FROM actors_split
    WHERE has_more = 1
)
SELECT 
    actor, 
    COUNT(*) AS total_content
FROM actors_split
WHERE actor <> ''
GROUP BY actor
ORDER BY total_content DESC
LIMIT 10;
	
-- 15. Categorize the content based on the presence of the keywords 'kill' and 'violence' in the description field. Label content containing these keywords as 'Bad' and all other content as 'Good'. Count how many items fall into each category.

Select category, Count(*) as Content_category 
	From ( Select Case 
					When description like '%kill%' or '%violence%' then 'Bad Movies'
                    Else 'Good Movies'
					End as category
                    From netflix) as categorized_content
	Group by category;
