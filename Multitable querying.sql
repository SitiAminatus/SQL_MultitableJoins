use mavenmovies;

-- INNER JOIN
SELECT *
FROM rental
ORDER BY inventory_id; 

SELECT *
FROM inventory;

SELECT COUNT(DISTINCT inventory_id) AS 'countinventory' -- retrieve how many inventory we have in inventory table, returned 4,581
FROM inventory;
SELECT COUNT(DISTINCT inventory_id) AS 'countinventory' -- retrieve how many inventory we have in rental table, returned 4,580
FROM rental; -- there is one in inventory_id is never rented

-- Below we will only show the exact inventory_id from rental table and inventory table. it supposed not exceed above 4,580
SELECT COUNT(DISTINCT rental.inventory_id) AS 'matching_inventory'
FROM rental INNER JOIN inventory
ON rental.inventory_id = inventory.inventory_id;

-- Let's list the unique inventory_id we have 
SELECT DISTINCT inventory.inventory_id
FROM rental INNER JOIN inventory
ON rental.inventory_id = inventory.inventory_id; -- inventory in both rental and inventory table, we get 1000 record in inventory_id range 1-1001. There will be one missing id!! it supposed to be in range 1-1000

-- Assignment INNER JOIN
/*“Can you pull for me a list of each film we have in inventory?
I would like to see the film’s title, description, and the store_id value
associated with each item, and its inventory_id. Thanks!”*/

SELECT inventory.inventory_id, inventory.store_id, film.title, film.description -- this order matter
FROM film INNER JOIN inventory
ON film.film_id = inventory.film_id; -- this order not matter

-- LEFT JOIN
/*return all column in left table and add the matching column from the right table.
This commonly used when we want to add new column into our existing table without removing the existing table*/

-- looking for how many times each actor get involved in a film--> it returned 199 unique actor and the total film they involved in
SELECT actor.first_name, actor.last_name, 
		COUNT(film_actor.film_id) AS 'number_of_films'
FROM actor LEFT JOIN film_actor
ON actor.actor_id = film_actor.actor_id
GROUP BY actor.first_name, actor.last_name;

-- show inventory_id in rental table and in inventory table
SELECT inventory.inventory_id, rental.inventory_id
FROM inventory LEFT JOIN rental -- we will pull all inventory_id in inventory table and add new column inventory_id from rental table
ON inventory.inventory_id = rental.inventory_id; -- return= there is null value in rental.inventory_id = 5 which means that inventory_id = 5 is never rented before.

/*what happen if I change the LEFT JOIN table into rental  (from previously inventory as the left table)
if I did this, the record of inventory_id = 5 is not apperar because this id is not exist in rental table*/
SELECT inventory.inventory_id, rental.inventory_id
FROM  rental LEFT JOIN  inventory
ON inventory.inventory_id = rental.inventory_id; 

-- ASSIGNMENT LEFT JOIN
/*“One of our investors is interested in the films we carry and how many actors are listed for each film title.
Can you pull a list of all titles, and figure out how many actors are associated with each title?”*/
SELECT COUNT(DISTINCT title) -- there are 1000 unique film
FROM film;

SELECT COUNT(DISTINCT film_id) -- to validate the total number of title correct, we can count total of unique film in film_id and it returned 1000 record too. so the title,  film_id, is recorded 1000 list
FROM film;

/*
1. we need to know which column will be shown as our result. here we need to show title and the number of actor.
2. find in which table we have title column, we find it in film column. 
3. define ALIAS (AS) 'number_of_actor' first, when we already write the AS we will automatically thing, which column we will use to count the actor. it will be actor_id, first_name&last_name?
4. we will take actor_id because it must be a Primary Key of this case. then try to find in which table we can get actor_id
5. We find actor_id in actor table and film_actor, but in actor table there is no film_id related which we will need it when we JOIN 2 tables.
6. Then we will use film_actor table to get the actor_id which has film_id too.
7. Then go to LEFT JOIN part. to define which table will be the left table or right, we need to count the more complete data we have. Below I found film get 1000 unique list than film_actor which only returned 997 list
8. GROUP BY, this part define which column will be the focus, because we will try to find out how many actor in title, then the focus is title --> Group by title
*/

SELECT COUNT(DISTINCT film_id)
FROM film_actor; -- Returned 997 film
SELECT COUNT(DISTINCT film_id)
FROM film;-- returned 1000 film

SELECT 
	film.title,
	COUNT(DISTINCT film_actor.actor_id) AS 'number_of_actors'
FROM film 
	LEFT JOIN film_actor
		ON film.film_id = film_actor.film_id
GROUP BY film.title;


-- BRIDGING UNRELATED TABLES
/*To connect 2 tables which not have overlapping column*/
-- joining FILM and CATEGORY using FILM_CATEGORY as a BRIDGE 
SELECT film.film_id, film.title, film_category.category_id, name AS 'category'
FROM film 
	INNER JOIN film_category
		ON film.film_id = film_category.film_id
	INNER JOIN category
		ON category.category_id = film_category.category_id;

-- ASSIGNMENT BRIDGING
/*“Customers often ask which films their favorite actors appear in.
It would be great to have a list of all actors, with each title that they
appear in. Could you please pull that for me?”*/


SELECT actor.first_name, actor.last_name, film.title
FROM actor 
	INNER JOIN film_actor
		ON actor.actor_id = film_actor.actor_id
	INNER JOIN film
		ON film_actor.film_id = film.film_id;

-- Multi-condition Joins
/*having a condition / filter in multi-table
example below*/

SELECT film.film_id, film.title, film.rating, category.name
FROM film
	INNER JOIN film_category
		ON film.film_id = film_category.film_id
	INNER JOIN category
		ON film_category.category_id = category.category_id
WHERE category.name = 'horror'
ORDER BY film_id;

-- OR THIS CODE
SELECT film.film_id, film.title, film.rating, category.name
FROM film
	INNER JOIN film_category
		ON film.film_id = film_category.film_id
	INNER JOIN category
		ON film_category.category_id = category.category_id
        AND category.name = 'horror'
ORDER BY film_id;

/*2 queries above give the same result but different time processing. the second code will give faster processing time because it will run in one process include the condition
whereas the first code takes 2 process (first = pull all category name, second =  pull only horror category) */


-- MULTI-CONDITION JOINS ASSIGNMENT
/*“The Manager from Store 2 is working on expanding our film collection there. 
Could you pull a list of distinct titles and their descriptions, currently
available in inventory at store 2?”*/

-- The query below is my solution as an example of BRIDGING implementation AND MULTI-CONDITION JOINS
SELECT DISTINCT film.title, film_text.description -- although description is appear in film table, but I insist to use film_text table to implement muti-condition join
FROM film_text 
	INNER JOIN film
INNER JOIN inventory
	ON inventory.film_id = film.film_id
	AND store_id = '2'; 