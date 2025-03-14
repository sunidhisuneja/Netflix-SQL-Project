6--Netflix Project--
DROP TABlE IF EXISTS netflix;
CREATE TABLE netflix
(
	show_id	varchar(10),
	type varchar(10),	
	title varchar(150),	
	director varchar(220),	
	casts varchar(1000),	
	country varchar(150),	
	date_added	varchar(50),
	release_year int,	
	rating	varchar(10),
	duration varchar(15),	
	listed_in varchar(100),	
	description varchar(250)
);

Select * from Netflix;

Select count(*) as tot_content
from Netflix;

--Handling Null Values--
Select * from Netflix 
where show_id is null
or
type is null
or
title is null
or
director is null
or
casts is null
or
country is null
or
date_added is null
or
release_year is null
or
rating is null
or
duration is null
or
listed_in is null
or
description is null;

Delete from Netflix 
where show_id is null
or
type is null
or
title is null
or
director is null
or
casts is null
or
country is null
or
date_added is null
or
release_year is null
or
rating is null
or
duration is null
or
listed_in is null
or
description is null;

Select Distinct type 
from Netflix;

--Data Analysis--
--Q-1 Count the number of Movies vs TV Shows
Select type,count(*) from Netflix
group by type;

--Q-2 Find the most common rating for movies and tv shows.
With t1 as
(
Select type,rating,count(*),
rank() over(partition by type order by count(*) DESC) as ranking
--max(rating) as no max is possible in text 
from Netflix
group by type,rating
)
--order by 1,3 desc
Select type,rating,ranking from t1
 where ranking =1;
 
--Q-3 List all the movies released in year 2020.
Select type,title,release_year from Netflix
where type = 'Movie' and release_year = '2020';

--Q-4 Find the top 5 countries with the most content on netflix.

Select unnest(String_to_array(country,','))as new_country,
count(show_id) as tot_con
--rank() over(order by count(show_id) DESC) as rank2
from Netflix
group by new_country
order by 2 DESC
Limit 5;

--Q-5 Identify the longest movie or TV show duration.
Select * from Netflix 
where type = 'Movie'
and duration = (Select Max(duration) from Netflix);

--Q-6 Find the content added in the last 5 years.
Select *
from Netflix 
where To_Date(date_added,'Month DD,YYYY') >= current_date - interval '5 years'

--Select current_date - interval '5 years'

--Q-7 Find all the movies/TV Shows by director 'Rajiv Chilaka'.
Select * from Netflix
where director ilike '%Rajiv Chilaka%'
--ilike is used if the director name does not start have proper case 

--Q-8 List all TV shows with more than 5 seasons.

Select *
--Split_part(duration,' ',1) as seasons
--1 delimiter se pehle 
from Netflix 
where Type = 'TV Show'
and
Split_part(duration,' ',1)::numeric > 5

--Q-9 Count the number of content items in each genre.

Select unnest(string_to_array(listed_in,','))as genre,count(show_id)
from Netflix
group by genre

--Q-10 Find each year and the average numbers of content released by India on netflix.
--return top 5 year with highest avg content release.
Select Extract(year from To_date(date_added,'Month DD,YYYY')),
count(*),
count(*)::numeric/(Select count(*) from netflix where country ilike '%India%')::numeric*100 as avg_cont_peryear
from netflix
where country ilike '%India%'
group by 1
order by avg_cont_peryear DESC
limit 5
--avg= yearlycount/total count

--Q-11 List all movies that are documentaries.

Select * from Netflix
where listed_in ilike '%Documentaries%'
and type ='Movie'

--Q-12 Find all content without a director.
Select * from Netflix
where director is null;

--Q-13
Select *
from Netflix 
where To_Date(date_added,'Month DD,YYYY') >= current_date - interval '10 years'
and type = 'Movie'
and casts ilike '%Salman Khan%'

--Q-14 Find the top 10 actors who have appeared in the highest number of movies produced in India.
Select unnest(String_to_array(casts,',')) as actors,count(show_id)
from Netflix
where country ilike '%India%' and type = 'Movie'
group by 1
order by 2 DESC
limit 10;

--Q-15 Categorize the content based on the presence of the keywords 'kill' and 'violence' in the
--description field.Label content containing these keywords as 'Bad' and 
-- all other content as 'Good'. Count how many items fall into each category.
With t5 as
(
Select *,
CASE
	when description ilike '%kill%'
	or
	description ilike '%violence%' then 'Bad_film'
	Else 'Good_film'
END AS category
From Netflix
)
Select category,count(*) as cat_count
from t5
group by 1

