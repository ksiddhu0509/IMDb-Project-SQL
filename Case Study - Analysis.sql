USE imdb;

/* Now that we have imported the data sets, let’s explore some of the tables. 
 To begin with, it is beneficial to know the shape of the tables and whether any column has null values.
 Further in this segment, we will take a look at 'movies' and 'genre' tables.*/



-- Segment 1:




-- Q1. Find the total number of rows in each table of the schema?

SELECT table_name,
       table_rows
FROM   INFORMATION_SCHEMA.TABLES
WHERE  TABLE_SCHEMA = 'imdb'; 

-- Q2. Which columns in the movie table have null values?

describe MOVIE;
describe GENRE;
SELECT 'ID',
       COUNT(*) AS Null_Count
FROM   MOVIE
WHERE  ID IS NULL
UNION
SELECT 'Title',
       COUNT(*) AS Null_Count
FROM   MOVIE
WHERE  TITLE IS NULL
UNION
SELECT 'Year',
       COUNT(*) AS Null_Count
FROM   MOVIE
WHERE  YEAR IS NULL
UNION
SELECT 'Date Published',
       COUNT(*) AS Null_Count
FROM   MOVIE
WHERE  DATE_PUBLISHED IS NULL
UNION
SELECT 'Movie',
       COUNT(*) AS Null_Count
FROM   MOVIE
WHERE  DURATION IS NULL
UNION
SELECT 'Country',
       COUNT(*) AS Null_Count
FROM   MOVIE
WHERE  COUNTRY IS NULL
UNION
SELECT 'WorldWide_Gross',
       COUNT(*) AS Null_Count
FROM   MOVIE
WHERE  WORLWIDE_GROSS_INCOME IS NULL
UNION
SELECT 'Languages',
       COUNT(*) AS Null_Count
FROM   MOVIE
WHERE  LANGUAGES IS NULL
UNION
SELECT 'Prod Company',
       COUNT(*) AS Null_Count
FROM   MOVIE
WHERE  PRODUCTION_COMPANY IS NULL; 

-- country, worlwide_gross_income, languages and production_company columns have NULL values.

-- Now as we can see four columns of the movie table has null values. Let's look at the at the movies released each year. 
-- Q3. Find the total number of movies released each year? How does the trend look month wise? (Output expected)

/* Output format for the first part:

+---------------+-------------------+
| Year			|	number_of_movies|
+-------------------+----------------
|	2017		|	2134			|
|	2018		|		.			|
|	2019		|		.			|
+---------------+-------------------+


Output format for the second part of the question:
+---------------+-------------------+
|	month_num	|	number_of_movies|
+---------------+----------------
|	1			|	 134			|
|	2			|	 231			|
|	.			|		.			|
+---------------+-------------------+ */

-- Number of movies released anually.
SELECT Year,
       COUNT(TITLE) AS 'number_of_movies'
FROM   MOVIE
GROUP  BY YEAR;

-- Number of movies released every month.
SELECT MONTH(DATE_PUBLISHED) AS'month_num',
       COUNT(TITLE)          AS 'number_of_movies'
FROM   MOVIE
GROUP  BY MONTH(DATE_PUBLISHED)
ORDER  BY COUNT(TITLE) DESC; 

/*The highest number of movies is produced in the month of March.
So, now that we have understood the month-wise trend of movies, let’s take a look at the other details in the movies table. 
We know USA and India produces huge number of movies each year. Lets find the number of movies produced by USA or India for the last year.*/
  
-- Q4. How many movies were produced in the USA or India in the year 2019??

SELECT year,
       COUNT(TITLE) AS number_of_movies
FROM   MOVIE
WHERE  YEAR = 2019
       AND ( COUNTRY LIKE '%USA%'
              OR COUNTRY LIKE '%India%' )
GROUP  BY YEAR; 

/* USA and India produced more than a thousand movies(we know the exact number!) in the year 2019.
Exploring table Genre would be fun!! 
Let’s find out the different genres in the dataset.*/

-- Q5. Find the unique list of the genres present in the data set?

SELECT DISTINCT genre
FROM   GENRE; 

/* So, RSVP Movies plans to make a movie of one of these genres.
Now, wouldn’t we want to know which genre had the highest number of movies produced in the last year?
Combining both the movie and genres table can give more interesting insights. */

-- Q6.Which genre had the highest number of movies produced overall?

SELECT g.genre,
       COUNT(m.TITLE) AS no_of_movies
FROM   MOVIE m
       INNER JOIN GENRE g
               ON g.MOVIE_ID = m.ID
GROUP  BY g.GENRE
ORDER  BY COUNT(m.TITLE) DESC
LIMIT  1; 

/* So, based on the insight that we just drew, RSVP Movies should focus on the ‘Drama’ genre. 
But wait, it is too early to decide. A movie can belong to two or more genres. 
So, let’s find out the count of movies that belong to only one genre.*/

-- Q7. How many movies belong to only one genre?

WITH AGG
     AS (SELECT m.ID,
                Count(g.GENRE) AS Genre
         FROM   MOVIE m
                INNER JOIN GENRE g
                        ON g.MOVIE_ID = m.ID
         GROUP  BY ID
         HAVING Count(g.GENRE) = 1)
SELECT Count(ID) AS movie_count
FROM   AGG; 

/* There are more than three thousand movies which has only one genre associated with them.
So, this figure appears significant. 
Now, let's find out the possible duration of RSVP Movies’ next project.*/

-- Q8.What is the average duration of movies in each genre? 
-- (Note: The same movie can belong to multiple genres.)


/* Output format:

+---------------+-------------------+
| genre			|	avg_duration	|
+-------------------+----------------
|	thriller	|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */

SELECT g.genre,
       ROUND(AVG(m.DURATION), 2) AS avg_duration
FROM   MOVIE m
       INNER JOIN GENRE g
               ON g.MOVIE_ID = m.ID
GROUP  BY g.GENRE
ORDER  BY ROUND(AVG(m.DURATION), 2) DESC;  

/* Now we know, movies of genre 'Drama' (produced highest in number in 2019) has the average duration of 106.77 mins.
Lets find where the movies of genre 'thriller' on the basis of number of movies.*/

-- Q9.What is the rank of the ‘thriller’ genre of movies among all the genres in terms of number of movies produced? 
-- (Hint: Use the Rank function)


/* Output format:
+---------------+-------------------+---------------------+
| genre			|		movie_count	|		genre_rank    |	
+---------------+-------------------+---------------------+
|drama			|	2312			|			2		  |
+---------------+-------------------+---------------------+*/

WITH GENRE_RANKS
     AS (SELECT genre,
                Count(MOVIE_ID)                    AS 'movie_count',
                RANK()
                  OVER(
                    ORDER BY Count(MOVIE_ID) DESC) AS genre_rank
         FROM   GENRE
         GROUP  BY GENRE)
SELECT *
FROM   GENRE_RANKS
WHERE  GENRE = 'thriller'; 

/*Thriller movies is in top 3 among all genres in terms of number of movies
 In the previous segment, we analysed the movies and genres tables. 
 In this segment, we will analyse the ratings table as well.
To start with lets get the min and max values of different columns in the table*/




-- Segment 2:




-- Q10.  Find the minimum and maximum values in  each column of the ratings table except the movie_id column?
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
| min_avg_rating|	max_avg_rating	|	min_total_votes   |	max_total_votes 	 |min_median_rating|min_median_rating|
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
|		0		|			5		|	       177		  |	   2000	    		 |		0	       |	8			 |
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+*/

SELECT ROUND(MIN(AVG_RATING), 1) AS min_avg_rating,
       ROUND(MAX(AVG_RATING), 1) AS max_avg_rating,
       MIN(TOTAL_VOTES)          AS min_total_votes,
       MAX(TOTAL_VOTES)          AS max_total_votes,
       MIN(MEDIAN_RATING)        AS min_median_rating,
       MAX(MEDIAN_RATING)        AS max_median_rating
FROM   RATINGS; 

/* So, the minimum and maximum values in each column of the ratings table are in the expected range. 
This implies there are no outliers in the table. 
Now, let’s find out the top 10 movies based on average rating.*/

-- Q11. Which are the top 10 movies based on average rating?
/* Output format:
+---------------+-------------------+---------------------+
| title			|		avg_rating	|		movie_rank    |
+---------------+-------------------+---------------------+
| Fan			|		9.6			|			5	  	  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
+---------------+-------------------+---------------------+*/

SELECT     M.title,
           R.avg_rating,
           RANK() OVER(ORDER BY R.AVG_RATING DESC) AS movie_rank
FROM       RATINGS R
INNER JOIN MOVIE M
ON         R.MOVIE_ID=M.ID
ORDER BY   R.AVG_RATING DESC
LIMIT      10;

/* Do we find our favourite movie FAN in the top 10 movies with an average rating of 9.6? If not, please check your code again!!
So, now that we know the top 10 movies, do we think character actors and filler actors can be from these movies?
Summarising the ratings table based on the movie counts by median rating can give an excellent insight.*/

-- Q12. Summarise the ratings table based on the movie counts by median ratings.
/* Output format:

+---------------+-------------------+
| median_rating	|	movie_count		|
+-------------------+----------------
|	1			|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Order by is good to have

SELECT median_rating,
       COUNT(MOVIE_ID) AS movie_count
FROM   RATINGS
GROUP  BY MEDIAN_RATING
ORDER  BY COUNT(MOVIE_ID) DESC; 

/* Movies with a median rating of 7 is highest in number. 
Now, let's find out the production house with which RSVP Movies can partner for its next project.*/

-- Q13. Which production house has produced the most number of hit movies (average rating > 8)??
/* Output format:
+------------------+-------------------+---------------------+
|production_company|movie_count	       |	prod_company_rank|
+------------------+-------------------+---------------------+
| The Archers	   |		1		   |			1	  	 |
+------------------+-------------------+---------------------+*/
-- Type your code below:

WITH AGG
AS
  (
             SELECT     M.production_company,
                        M.ID,
                        R.AVG_RATING
             FROM       MOVIE M
             INNER JOIN RATINGS R
             ON         M.ID=R.MOVIE_ID
             WHERE      AVG_RATING>8
             ORDER BY   R.AVG_RATING DESC )
  SELECT   production_company,
           COUNT(ID)                             AS movie_count,
           RANK() OVER (ORDER BY COUNT(ID) DESC) AS prod_company_rank
  FROM     AGG
  WHERE    PRODUCTION_COMPANY IS NOT NULL
  GROUP BY PRODUCTION_COMPANY
  ORDER BY MOVIE_COUNT DESC
  LIMIT    2;

-- It's ok if RANK() or DENSE_RANK() is used too
-- Answer can be Dream Warrior Pictures or National Theatre Live or both

-- Q14. How many movies released in each genre during March 2017 in the USA had more than 1,000 votes?
/* Output format:

+---------------+-------------------+
| genre			|	movie_count		|
+-------------------+----------------
|	thriller	|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */

WITH AGG
     AS (SELECT g.genre,
                r.MOVIE_ID,
                m.DATE_PUBLISHED,
                m.COUNTRY
         FROM   RATINGS r
                INNER JOIN GENRE g
                        ON r.MOVIE_ID = g.MOVIE_ID
                INNER JOIN MOVIE m
                        ON g.MOVIE_ID = m.ID
         WHERE  r.TOTAL_VOTES > 1000
                AND Month(DATE_PUBLISHED) = 3
                AND Year(DATE_PUBLISHED) = 2017
                AND m.COUNTRY IN ( 'USA' ))
SELECT GENRE,
       Count(MOVIE_ID) AS movie_count
FROM   AGG
GROUP  BY GENRE
ORDER  BY Count(MOVIE_ID) DESC; 

-- Lets try to analyse with a unique problem statement.
-- Q15. Find movies of each genre that start with the word ‘The’ and which have an average rating > 8?
/* Output format:
+---------------+-------------------+---------------------+
| title			|		avg_rating	|		genre	      |
+---------------+-------------------+---------------------+
| Theeran		|		8.3			|		Thriller	  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
+---------------+-------------------+---------------------+*/

SELECT m.title,
       r.avg_rating,
       g.genre
FROM   GENRE g
       INNER JOIN RATINGS r
               ON g.MOVIE_ID = r.MOVIE_ID
       INNER JOIN MOVIE m
               ON g.MOVIE_ID = m.ID
WHERE  r.AVG_RATING > 8
       AND LOWER(m.TITLE) LIKE 'the%'
ORDER  BY r.AVG_RATING DESC; 

-- We should also try our hand at median rating and check whether the ‘median rating’ column gives any significant insights.
-- Q16. Of the movies released between 1 April 2018 and 1 April 2019, how many were given a median rating of 8?

SELECT r.median_rating,
       COUNT(m.TITLE) AS movie_count
FROM   RATINGS r
       INNER JOIN MOVIE m
               ON m.ID = r.MOVIE_ID
WHERE  r.MEDIAN_RATING = 8
       AND m.DATE_PUBLISHED BETWEEN '2018-04-01' AND '2019-04-01'
GROUP  BY r.MEDIAN_RATING; 

-- Once again, try to solve the problem given below.
-- Q17. Do German movies get more votes than Italian movies? 
-- Hint: Here we have to find the total number of votes for both German and Italian movies.

WITH LANGUAGES_GROUPED
AS
  (
             SELECT     languages,
                        total_votes,
                        CASE
                                   WHEN LANGUAGES REGEXP 'German' THEN 'German'
                                   WHEN LANGUAGES REGEXP 'Italian' THEN 'Italian'
                                   ELSE 'Others'
                        END AS languages_grouped
             FROM       MOVIE M
             INNER JOIN RATINGS R
             ON         M.ID=R.MOVIE_ID )
  SELECT   LANGUAGES_GROUPED AS 'languages',
           SUM(TOTAL_VOTES)  AS total_votes
  FROM     LANGUAGES_GROUPED
  WHERE    LANGUAGES_GROUPED IN ('German',
                                 'Italian')
  GROUP BY LANGUAGES_GROUPED
  ORDER BY TOTAL_VOTES DESC ;

-- Answer is Yes

/* Now that we have analysed the movies, genres and ratings tables, let us now analyse another table, the names table. 
Let’s begin by searching for null values in the tables.*/




-- Segment 3:



-- Q18. Which columns in the names table have null values??
/*Hint: we can find null values for individual columns or follow below output format
+---------------+-------------------+---------------------+----------------------+
| name_nulls	|	height_nulls	|date_of_birth_nulls  |known_for_movies_nulls|
+---------------+-------------------+---------------------+----------------------+
|		0		|			123		|	       1234		  |	   12345	    	 |
+---------------+-------------------+---------------------+----------------------+*/

SELECT COUNT(*) - COUNT(ID)               AS id_nulls,
       COUNT(*) - COUNT(NAME)             AS name_nulls,
       COUNT(*) - COUNT(HEIGHT)           AS height_nulls,
       COUNT(*) - COUNT(DATE_OF_BIRTH)    AS date_of_birth_nulls,
       COUNT(*) - COUNT(KNOWN_FOR_MOVIES) AS known_for_movies_nulls
FROM   NAMES; 

/* There are no Null value in the column 'name'.
The director is the most important person in a movie crew. 
Let’s find out the top three directors in the top three genres who can be hired by RSVP Movies.*/

-- Q19. Who are the top three directors in the top three genres whose movies have an average rating > 8?
-- (Hint: The top three genres would have the most number of movies with an average rating > 8.)
/* Output format:

+---------------+-------------------+
| director_name	|	movie_count		|
+---------------+-------------------|
|James Mangold	|		4			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */

WITH TOP_3_GENRE
AS
  (
             SELECT     GENRE
             FROM       RATINGS R
             INNER JOIN MOVIE M
             ON         R.MOVIE_ID=M.ID
             INNER JOIN GENRE
             USING      (MOVIE_ID)
             WHERE      AVG_RATING > 8
             GROUP BY   GENRE
             ORDER BY   COUNT(GENRE) DESC
             LIMIT      3 )
  SELECT     NAME        AS director_name,
             COUNT(NAME) AS movie_count
  FROM       RATINGS R
  INNER JOIN MOVIE M
  ON         R.MOVIE_ID=M.ID
  INNER JOIN GENRE
  USING      (MOVIE_ID)
  INNER JOIN DIRECTOR_MAPPING D
  USING      (MOVIE_ID)
  INNER JOIN NAMES N
  ON         D.NAME_ID=N.ID
  WHERE      GENRE IN
             (
                    SELECT *
                    FROM   TOP_3_GENRE)
  AND        AVG_RATING>8
  GROUP BY   NAME
  ORDER BY   COUNT(NAME) DESC
  LIMIT      3 ;

/* James Mangold can be hired as the director for RSVP's next project. Do we remeber his movies, 'Logan' and 'The Wolverine'. 
Now, let’s find out the top two actors.*/

-- Q20. Who are the top two actors whose movies have a median rating >= 8?
/* Output format:

+---------------+-------------------+
| actor_name	|	movie_count		|
+-------------------+----------------
|Christain Bale	|		10			|
|	.			|		.			|
+---------------+-------------------+ */

SELECT NAME        AS actor_name,
       COUNT(NAME) AS movie_count
FROM   NAMES N
       INNER JOIN ROLE_MAPPING RO
               ON N.ID = RO.NAME_ID
       INNER JOIN RATINGS RA
               ON RO.MOVIE_ID = RA.MOVIE_ID
WHERE  MEDIAN_RATING >= 8
       AND CATEGORY = 'actor'
GROUP  BY NAME
ORDER  BY COUNT(NAME) DESC
LIMIT  2; 

/* Have we find our favourite actor 'Mohanlal' in the list. If no, please check our code again. 
RSVP Movies plans to partner with other global production houses. 
Let’s find out the top three production houses in the world.*/

-- Q21. Which are the top three production houses based on the number of votes received by their movies?
/* Output format:
+------------------+--------------------+---------------------+
|production_company|vote_count			|		prod_comp_rank|
+------------------+--------------------+---------------------+
| The Archers		|		830			|		1	  		  |
|	.				|		.			|			.		  |
|	.				|		.			|			.		  |
+-------------------+-------------------+---------------------+*/

SELECT     production_company,
           SUM(TOTAL_VOTES)                                  AS vote_count,
           DENSE_RANK() OVER(ORDER BY SUM(TOTAL_VOTES) DESC) AS prod_comp_rank
FROM       MOVIE M
INNER JOIN RATINGS RA
ON         M.ID=RA.MOVIE_ID
GROUP BY   PRODUCTION_COMPANY
LIMIT      3;

/*Yes Marvel Studios rules the movie world.
So, these are the top three production houses based on the number of votes received by the movies they have produced.

Since RSVP Movies is based out of Mumbai, India also wants to woo its local audience. 
RSVP Movies also wants to hire a few Indian actors for its upcoming project to give a regional feel. 
Let’s find who these actors could be.*/

-- Q22. Rank actors with movies released in India based on their average ratings. Which actor is at the top of the list?
-- Note: The actor should have acted in at least five Indian movies. 
-- (Hint: We should use the weighted average based on votes. If the ratings clash, then the total number of votes should act as the tie breaker.)

/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actor_name	|	total_votes		|	movie_count		  |	actor_avg_rating 	 |actor_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Yogi Babu	|			3455	|	       11		  |	   8.42	    		 |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/

WITH ACTORS
AS
  (
             SELECT     NAME                                                       AS actor_name ,
                        SUM(TOTAL_VOTES)                                           AS total_votes,
                        COUNT(NAME)                                                AS movie_count,
                        ROUND(SUM(AVG_RATING * TOTAL_VOTES) / SUM(TOTAL_VOTES), 2) AS actor_avg_rating
             FROM       NAMES N
             INNER JOIN ROLE_MAPPING RO
             ON         N.ID = RO.NAME_ID
             INNER JOIN MOVIE M
             ON         RO.MOVIE_ID = M.ID
             INNER JOIN RATINGS RA
             ON         M.ID = RA.MOVIE_ID
             WHERE      COUNTRY REGEXP 'india'
             AND        CATEGORY = 'actor'
             GROUP BY   NAME
             HAVING     MOVIE_COUNT >= 5)
  SELECT   *,
           DENSE_RANK() OVER ( ORDER BY ACTOR_AVG_RATING DESC, TOTAL_VOTES DESC) AS actor_rank
  FROM     ACTORS;

-- Top actor is Vijay Sethupathi

-- Q23.Find out the top five actresses in Hindi movies released in India based on their average ratings? 
-- Note: The actresses should have acted in at least three Indian movies. 
-- (Hint: We should use the weighted average based on votes. If the ratings clash, then the total number of votes should act as the tie breaker.)
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	|	total_votes		|	movie_count		  |	actress_avg_rating 	 |actress_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Tabu		|			3455	|	       11		  |	   8.42	    		 |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/

WITH ACTRESS
AS
  (
             SELECT     NAME AS actress_name,
                        total_votes,
                        COUNT(NAME)                                           AS movie_count,
                        ROUND(SUM(AVG_RATING*TOTAL_VOTES)/SUM(TOTAL_VOTES),2) AS actress_avg_rating
             FROM       NAMES N
             INNER JOIN ROLE_MAPPING RO
             ON         N.ID=RO.NAME_ID
             INNER JOIN MOVIE M
             ON         RO.MOVIE_ID=M.ID
             INNER JOIN RATINGS RA
             USING     (MOVIE_ID)
             WHERE      LANGUAGES REGEXP 'hindi'
             AND        COUNTRY REGEXP 'india'
             AND        CATEGORY = 'actress'
             GROUP BY   ACTRESS_NAME
             HAVING     COUNT(ACTRESS_NAME)>=3 )
  SELECT   *,
           DENSE_RANK() OVER(ORDER BY ACTRESS_AVG_RATING DESC, TOTAL_VOTES DESC) AS actress_rank
  FROM     ACTRESS
  LIMIT    5;

/* Taapsee Pannu tops with average rating 7.74. 
Now let us divide all the thriller movies in the following categories and find out their numbers.*/


/* Q24. Select thriller movies as per avg rating and classify them in the following category: 

			Rating > 8: Superhit movies
			Rating between 7 and 8: Hit movies
			Rating between 5 and 7: One-time-watch movies
			Rating < 5: Flop movies
--------------------------------------------------------------------------------------------*/

SELECT TITLE AS movie,
       AVG_RATING,
       CASE
         WHEN AVG_RATING > 8 THEN 'Superhit movies'
         WHEN AVG_RATING BETWEEN 7 AND 8 THEN 'Hit movies'
         WHEN AVG_RATING BETWEEN 5 AND 7 THEN 'One-time-watch movies'
         WHEN AVG_RATING < 5 THEN 'Flop movies'
       END   AS 'avg_rating_category'
FROM   GENRE g
       INNER JOIN RATINGS ra USING(MOVIE_ID)
       INNER JOIN MOVIE m
               ON ra.MOVIE_ID = m.ID
WHERE  GENRE = 'thriller'; 

/* Until now, we have analysed various tables of the data set. 
Now, we will perform some tasks that will give we a broader understanding of the data in this segment.*/

-- Segment 4:

-- Q25. What is the genre-wise running total and moving average of the average movie duration? 
-- (Note: We need to show the output table in the question.) 
/* Output format:
+---------------+-------------------+---------------------+----------------------+
| genre			|	avg_duration	|running_total_duration|moving_avg_duration  |
+---------------+-------------------+---------------------+----------------------+
|	comdy		|			145		|	       106.2	  |	   128.42	    	 |
|		.		|			.		|	       .		  |	   .	    		 |
|		.		|			.		|	       .		  |	   .	    		 |
|		.		|			.		|	       .		  |	   .	    		 |
+---------------+-------------------+---------------------+----------------------+*/

WITH GENRE
     AS (SELECT GENRE,
                ROUND(AVG(DURATION), 2)                      AS avg_duration,
                SUM(AVG(DURATION))
                  OVER (
                    ORDER BY GENRE ROWS UNBOUNDED PRECEDING) AS
                running_total_duration,
                AVG(AVG(DURATION))
                  OVER (
                    ORDER BY GENRE ROWS UNBOUNDED PRECEDING) AS
                moving_avg_duration
         FROM   MOVIE m
                INNER JOIN GENRE g
                        ON m.ID = g.MOVIE_ID
         GROUP  BY GENRE)
SELECT genre,
       avg_duration,
       ROUND(RUNNING_TOTAL_DURATION, 2) AS running_total_duration,
       ROUND(MOVING_AVG_DURATION, 2)    AS moving_avg_duration
FROM   GENRE;

-- Round is good to have and not a must have; Same thing applies to sorting


-- Let us find top 5 movies of each year with top 3 genres.

-- Q26. Which are the five highest-grossing movies of each year that belong to the top three genres? 
-- (Note: The top 3 genres would have the most number of movies.)

/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| genre			|	year			|	movie_name		  |worldwide_gross_income|movie_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	comedy		|			2017	|	       indian	  |	   $103244842	     |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/

-- Top 3 Genres based on most number of movies

WITH TOP_3_GENRE
AS
  (
           SELECT   GENRE
           FROM     GENRE
           GROUP BY GENRE
           ORDER BY COUNT(GENRE) DESC
           LIMIT    3 ),
  TOP_MOVIES
AS
  (
             SELECT     genre,
                        year,
                        TITLE                                                                                                                     AS movie_name,
                        CAST(REPLACE(IFNULL(WORLWIDE_GROSS_INCOME,0),'$ ','') AS DECIMAL(10))                                                     AS worldwide_gross_income_$,
                        ROW_NUMBER() OVER (PARTITION BY YEAR ORDER BY CAST(REPLACE(IFNULL(WORLWIDE_GROSS_INCOME,0),'$ ','') AS DECIMAL(10)) DESC) AS movie_rank
             FROM       MOVIE M
             INNER JOIN GENRE G
             ON         M.ID = G.MOVIE_ID
             WHERE      GENRE IN
                        (
                               SELECT *
                               FROM   TOP_3_GENRE) )
  SELECT *
  FROM   TOP_MOVIES
  WHERE  MOVIE_RANK<=5;

-- Finally, let’s find out the names of the top two production houses that have produced the highest number of hits among multilingual movies.
-- Q27.  Which are the top two production houses that have produced the highest number of hits (median rating >= 8) among multilingual movies?
/* Output format:
+-------------------+-------------------+---------------------+
|production_company |movie_count		|		prod_comp_rank|
+-------------------+-------------------+---------------------+
| The Archers		|		830			|		1	  		  |
|	.				|		.			|			.		  |
|	.				|		.			|			.		  |
+-------------------+-------------------+---------------------+*/

SELECT     production_company,
           COUNT(PRODUCTION_COMPANY)                                  AS movie_count ,
           DENSE_RANK() OVER(ORDER BY COUNT(PRODUCTION_COMPANY) DESC) AS prod_comp_rank
FROM       MOVIE M
INNER JOIN RATINGS RA
ON         M.ID=RA.MOVIE_ID
WHERE      MEDIAN_RATING>=8
AND        LANGUAGES REGEXP ','
GROUP BY   PRODUCTION_COMPANY
LIMIT      2;

-- Multilingual is the important piece in the above question. It was created using POSITION(',' IN languages)>0 logic
-- If there is a comma, that means the movie is of more than one language


-- Q28. Who are the top 3 actresses based on number of Super Hit movies (average rating >8) in drama genre?
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	|	total_votes		|	movie_count		  |actress_avg_rating	 |actress_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Laura Dern	|			1016	|	       1		  |	   9.60			     |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/

SELECT     NAME                                                  AS actress_name,
           SUM(TOTAL_VOTES)                                      AS total_votes,
           COUNT(NAME)                                           AS movie_count,
           ROUND(SUM(AVG_RATING*TOTAL_VOTES)/SUM(TOTAL_VOTES),2) AS actress_avg_rating,
           ROW_NUMBER() OVER (ORDER BY COUNT(NAME) DESC)         AS actress_rank
FROM       GENRE G
INNER JOIN MOVIE M
ON         G.MOVIE_ID=M.ID
INNER JOIN RATINGS RA
USING     (MOVIE_ID)
INNER JOIN ROLE_MAPPING RO
USING      (MOVIE_ID)
INNER JOIN NAMES N
ON         RO.NAME_ID=N.ID
WHERE      AVG_RATING >8
AND        GENRE = 'drama'
AND        CATEGORY = 'actress'
GROUP BY   NAME
LIMIT      3;

/* Q29. Get the following details for top 9 directors (based on number of movies)
Director id
Name
Number of movies
Average inter movie duration in days
Average movie ratings
Total votes
Min rating
Max rating
total movie durations

Format:
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+
| director_id	|	director_name	|	number_of_movies  |	avg_inter_movie_days |	avg_rating	| total_votes  | min_rating	| max_rating | total_duration |
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+
|nm1777967		|	A.L. Vijay		|			5		  |	       177			 |	   5.65	    |	1754	   |	3.7		|	6.9		 |		613		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+

--------------------------------------------------------------------------------------------*/

WITH NEXT_DATE_PUBLISH
AS
  (
             SELECT     NAME_ID AS DIRECTOR_ID,
                        NAME    AS DIRECTOR_NAME,
                        DATE_PUBLISHED,
                        AVG_RATING,
                        TOTAL_VOTES,
                        DURATION,
                        LEAD(DATE_PUBLISHED,1) OVER(PARTITION BY NAME_ID ORDER BY DATE_PUBLISHED) AS NEXT_DATE_PUBLISHED
             FROM       DIRECTOR_MAPPING D
             INNER JOIN NAMES N
             ON         D.NAME_ID=N.ID
             INNER JOIN MOVIE M
             ON         D.MOVIE_ID=M.ID
             INNER JOIN RATINGS RA
             USING     (MOVIE_ID) )
  SELECT   director_id,
           director_name,
           COUNT(DIRECTOR_NAME)                                       AS number_of_movies,
           ROUND(AVG(DATEDIFF(NEXT_DATE_PUBLISHED,DATE_PUBLISHED)),0) AS avg_inter_movie_days,
           ROUND(AVG(AVG_RATING),2)                                   AS avg_rating,
           SUM(TOTAL_VOTES)                                           AS total_votes,
           MIN(AVG_RATING)                                            AS min_rating,
           MAX(AVG_RATING)                                            AS max_rating,
           SUM(DURATION)                                              AS total_duration
  FROM     NEXT_DATE_PUBLISH
  GROUP BY DIRECTOR_ID
  ORDER BY NUMBER_OF_MOVIES DESC
  LIMIT    9;