Create database netflix;
Use netflix;

DROP TABLE IF EXISTS netflix;
-- creating a table called netflix
CREATE TABLE netflix (show_id VARCHAR(5), type VARCHAR(10), title VARCHAR(250), director VARCHAR(550), casts VARCHAR(1050), country VARCHAR(550), date_added VARCHAR(55), release_year INT, rating VARCHAR(15), duration VARCHAR(15), listed_in VARCHAR(250), description  VARCHAR(550));

-- import data from CSV file
SET GLOBAL local_infile = 1;
LOAD DATA LOCAL INFILE 'H:/Data Analytics/SQL/netflix/netflix_titles.csv'
	INTO TABLE netflix
	FIELDS TERMINATED BY ','
	ENCLOSED BY '"'
	LINES TERMINATED BY '\n'
	IGNORE 1 LINES;

SELECT * FROM netflix;

-- Finding no_of_missing_values
SELECT 
    SUM(CASE WHEN show_id IS NULL OR show_id = '' THEN 1 ELSE 0 END) AS show_id_missing,
    SUM(CASE WHEN type IS NULL OR type = '' THEN 1 ELSE 0 END) AS type_missing,
    SUM(CASE WHEN title IS NULL OR title = '' THEN 1 ELSE 0 END) AS title_missing,
    SUM(CASE WHEN director IS NULL OR director = '' THEN 1 ELSE 0 END) AS director_missing,
    SUM(CASE WHEN casts IS NULL OR casts = '' THEN 1 ELSE 0 END) AS casts_missing,
    SUM(CASE WHEN country IS NULL OR country = '' THEN 1 ELSE 0 END) AS country_missing,
    SUM(CASE WHEN date_added IS NULL OR date_added = '' THEN 1 ELSE 0 END) AS date_added_missing,
    SUM(CASE WHEN rating IS NULL OR rating = '' THEN 1 ELSE 0 END) AS rating_missing,
    SUM(CASE WHEN duration IS NULL OR duration = '' THEN 1 ELSE 0 END) AS duration_missing
FROM netflix;
                            
-- updating missing/blank values as 'not available'
UPDATE netflix SET director = 'Not Available' WHERE director = '' or director is null ;
UPDATE netflix SET casts = 'Not Available' WHERE casts = '' or casts is null ;
UPDATE netflix SET country = 'Not Available' WHERE country = '' or country is null ;
UPDATE netflix SET date_added = 'Not Available' WHERE date_added = '' or date_added is null ;
UPDATE netflix SET rating = 'Not Available' WHERE rating = '' or rating is null ;
UPDATE netflix SET duration = 'Not Available' WHERE duration = '' or duration is null ;

-- Describe Table
Desc netflix;

-- Correct the data
UPDATE netflix 
SET director = 'Steven Bognar, Julia Reichert' 
WHERE title =  '9to5: The Story of a Movement' ;