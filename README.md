# Netflix Movies and TV Shows Data Analysis using SQL

## Overview
This project involves a comprehensive analysis of Netflix's movies and TV shows data using SQL. The goal is to extract valuable insights and answer various business questions based on the dataset. The following README provides a detailed account of the project's objectives, business problems, solutions, findings, and conclusions.

## Objectives
- Analyze the distribution of content types (movies vs TV shows).
- Identify the most common ratings for movies and TV shows.
- List and analyze content based on release years, countries, and durations.
- Explore and categorize content based on specific criteria and keywords.

## Dataset
The data for this project is sourced from the Kaggle dataset:
- Dataset Link: [Movies Dataset](https://www.kaggle.com/datasets/shivamb/netflix-shows?resource=download).

## Schema
```sql 
DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix (
show_id VARCHAR(5),
type VARCHAR(10),
title VARCHAR(250),
director VARCHAR(550),
casts VARCHAR(1050),
country VARCHAR(550),
date_added VARCHAR(55),
release_year INT,
rating VARCHAR(15),
duration VARCHAR(15),
listed_in VARCHAR(250),
description  VARCHAR(550));
```

## Business Problems and Solutions
### 1. Count the number of Movies vs TV Shows
```sql 
SELECT type, COUNT(*)
FROM netflix
GROUP BY 1;
```

**Objective:** Determine the distribution of content types on Netflix.

### 2. Find the most common rating for movies and TV shows
```sql 
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
```

**Objective:** Identify the most frequently occurring rating for each type of content.

### 3. List all movies released in a specific year (e.g., 2020)
```sql 
Select * From netflix where release_year = '2020';
```

**Objective:** Retrieve all movies released in a specific year.

### 4. Find the top 5 countries with the most content on Netflix
```sql 
SELECT country, COUNT(*) AS total_content 
	FROM netflix
	WHERE country IS NOT NULL
	GROUP BY country
	ORDER BY total_content DESC
	LIMIT 5;
```

**Objective:** Identify the top 5 countries with the highest number of content items.

### 5. Identify the longest movie
```sql 
SELECT * 
FROM netflix 
WHERE type = 'Movie' 
ORDER BY CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) DESC 
LIMIT 10;
```

**Objective:** Find the movie with the longest duration.

### 6. Find content added in the last 5 years
```sql 
SELECT *
FROM netflix
WHERE STR_TO_DATE(date_added, '%M %d, %Y') >= date_sub(current_date(), INTERVAL 5 YEAR);
```

**Objective:** Retrieve content added to Netflix in the last 5 years.

### 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!  (using RECURSIVE)
```sql 
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
```

**Objective:** List all content directed by 'Rajiv Chilaka'.

### 8. List all TV shows with more than 5 seasons
```sql 
Select * from netflix where type = 'Tv Show' and substring_index(duration, ' ',1) >5;
```

**Objective:** Identify TV shows with more than 5 seasons.

### 9. Count the number of content items in each genre
```sql 
Select SUBSTRING_Index(Listed_in, ",",1 ) as genre, count(listed_in) as content_items from netflix group by 1;
```

**Objective:** Count the number of content items in each genre.

### 10. Find each year and the average numbers of content release in India on netflix.  return top 5 year with highest avg content release!
```sql 
select country, release_year, count(show_id) as total_content, 
	round(count(show_id)/(select count(show_id) from netflix where country = 'india') * 100,1 )  as avg_release
from netflix
Where country = 'India'
group by country, release_year
order by avg_release desc
Limit 5;
```

**Objective:** Calculate and rank years by the average number of content releases by India.

### 11. List all movies that are documentaries
```sql 
Select * From netflix where listed_in like 'documentaries%';
```

**Objective:** Retrieve all movies classified as documentaries.

### 12. Find all content without a director
```sql 
Select * From netflix where director = 'Not Available';
```

**Objective:** List content that does not have a director.

### 13. Find how many movies actor 'Salman Khan' appeared in last 20 years!
```sql 
SELECT title, release_year
FROM netflix
WHERE casts like '%Salman Khan%' and release_year > extract(year from current_date) -20;
```

**Objective:** Count the number of movies featuring 'Salman Khan' in the last 10 years.

### 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.
```sql 
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
```

**Objective:** Identify the top 10 actors with the most appearances in Indian-produced movies.

### 15. Categorize the content based on the presence of the keywords 'kill' and 'violence' in the description field. Label content containing these keywords as 'Bad' and all other content as 'Good'. Count how many items fall into each category.
```sql 
Select category, Count(*) as Content_category 
	From ( Select Case 
					When description like '%kill%' or '%violence%' then 'Bad Movies'
                    Else 'Good Movies'
					End as category
                    From netflix) as categorized_content
	Group by category;
```

**Objective:** Categorize content as 'Bad' if it contains 'kill' or 'violence' and 'Good' otherwise. Count the number of items in each category.
