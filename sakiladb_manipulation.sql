USE sakila;

-- question 1a - Display the first and last names of all actors FROM the table actor
SELECT first_name, last_name FROM actor;

-- question 1b - Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name
SELECT concat(upper(first_name), ' ', upper(last_name)) AS 'Name'
FROM actor

-- question 2a - You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe."
-- What is one query would you use to obtain this information?
SELECT actor_id, first_name, last_name
FROM actor
WHERE first_name = 'Joe';

-- question 2b - Find all actors whose last name contain the letters GEN:
SELECT * 
FROM actor
WHERE last_name LIKE "%Gen%";

-- question 2c - Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
SELECT *
FROM actor
WHERE last_name LIKE "%Li%" 
ORDER BY last_name, first_name;

-- question 2d -  Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT country_id, country
FROM country
WHERE country IN ("Afghanistan", "Bangladesh", "China");

-- question 3a -  You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a 
-- column in the table actor named description and use the data type BLOB (Make sure to research the type BLOB, as the difference between it 
-- and VARCHAR are significant).
ALTER TABLE actor
ADD (Description BLOB);

-- question 3b - Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.
ALTER table actor
DROP column description;

-- question 4a - List the last names of actors, as well as how many actors have that last name.
SELECT COUNT(last_name) AS lastNameCount, last_name
FROM actor
GROUP BY last_name;

-- question 4b - List last names of actors and the number of actors who have that last name, but only for names that are shared by 
-- at least two actors
SELECT COUNT(last_name) lastNameCount, last_name
FROM actor
GROUP BY last_name
HAVING lastNameCount >= 2;

-- question 4c - The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.
SET SQL_SAFE_UPDATES = 0;
UPDATE actor
SET first_name = 'Harpo'
WHERE first_name = 'Groucho';
SET SQL_SAFE_UPDATES = 1;

-- question 4d - Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! 
-- In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.
SET SQL_SAFE_UPDATES = 0;
UPDATE actor
SET first_name = 'Groucho'
WHERE first_name = 'Harpo';
SET SQL_SAFE_UPDATES = 1;

-- question 5a - You cannot locate the schema of the address table. Which query would you use to re-create it?
SHOW CREATE TABLE address;

-- question 6a - Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
SELECT first_name, last_name, address 
FROM staff s
left JOIN address a 
ON s.address_id = a.address_id;

-- question 6b - Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
SELECT s.last_name, s.first_name, SUM(p.amount)
FROM staff s
LEFT JOIN payment p
ON s.staff_id = p.staff_id
WHERE (p.payment_date BETWEEN '2005-08-01' AND '2005-09-01')
GROUP BY s.first_name;

-- question 6c - List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
SELECT title, COUNT(actor_id)
FROM film f
INNER JOIN film_actor a
ON f.film_id = a.film_id
GROUP BY title;

-- question 6d - How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT f.title, COUNT(i.inventory_id) AS FilmCopies
FROM inventory i
JOIN film f
ON i.film_id = f.film_id
WHERE f.title = 'Hunchback Impossible';

-- question 6e - Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:
SELECT first_name, last_name, SUM(amount)
FROM customer c
JOIN payment p ON c.customer_id = p.customer_id
GROUP BY first_name, last_name
ORDER BY last_name;

-- question 7a - The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the
-- letters K and Q have also soared in popularity. Use subqueries to display the titles of movies starting with the letters K and Q whose 
-- language is English.
SELECT title
FROM film f
WHERE title LIKE 'K%'OR title LIKE 'Q%'
AND f.language_id = (
	SELECT language_id FROM `language` WHERE name = 'English'
);

-- question 7b - Use subqueries to display all actors who appear in the film Alone Trip.
SELECT first_name, last_name 
FROM actor
WHERE actor_id IN (
	SELECT actor_id FROM film_actor 
	WHERE film_id = (
		SELECT film_id FROM film WHERE title = 'Alone Trip'
	)
);

-- question 7c - You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers.
-- Use joins to retrieve this information.
SELECT first_name, last_name, email, country
FROM customer a
JOIN address b ON a.address_id = b.address_id
JOIN city c ON b.city_id = c.city_id
JOIN country d ON c.country_id = d.country_id
WHERE d.country = 'Canada';

-- question 7d - Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
-- comment: no wonder the sales are lagging. The data set is bad. NC-17 and R rated movies were marked as family movies.
SELECT title, description, rating, release_year, name as 'type'
FROM film f
JOIN film_category b ON f.film_id = b.film_id
JOIN category c ON b.category_id = c.category_id
WHERE c.name = 'Family';

-- question 7e - Display the most frequently rented movies in descending order.
SELECT f.title, COUNT(r.inventory_id) AS rentalCount
FROM rental r
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film f ON i.film_id = f.film_id
GROUP BY f.title
ORDER BY rentalcount DESC;

-- question 7f - Write a query to display how much business, in dollars, each store brought in.
SELECT c.store_id AS StoreID, SUM(p.amount)
FROM payment p
JOIN staff s ON p.staff_id = s.staff_id
JOIN store c ON s.store_id = c.store_id
GROUP BY c.store_id;

-- question 7g - Write a query to display for each store its store ID, city, and country.
SELECT s.store_id, c.city, d.country
FROM store s 
JOIN address a ON s.address_id = a.address_id
JOIN city c ON a.city_id = c.city_id
JOIN country d ON c.country_id = d.country_id;

-- question 7h - List the top five genres in gross revenue in descending order.
-- (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
SELECT c.name AS filmCategory, SUM(p.amount) AS Revenue
FROM payment p
JOIN rental r ON p.rental_id = r.rental_id
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film_category f ON i.film_id = f.film_id
JOIN category c ON f.category_id = c.category_id
GROUP BY filmcategory
ORDER BY Revenue DESC
LIMIT 5;

-- question 8a - In your new role as an executive, you would like to have an easy way of VIEWing the Top five genres by gross revenue. 
-- Use the solution FROM the problem above to CREATE a VIEW. If you haven't solved 7h, you can substitute another query to CREATE a VIEW.
-- reference: https://dev.mysql.com/doc/refman/8.0/en/CREATE-VIEW.html
CREATE VIEW top_five_genres
AS (
	SELECT c.name AS filmCategory, SUM(p.amount) AS Revenue
	FROM payment p
	JOIN rental r ON p.rental_id = r.rental_id
	JOIN inventory i ON r.inventory_id = i.inventory_id
	JOIN film_category f ON i.film_id = f.film_id
	JOIN category c ON f.category_id = c.category_id
	GROUP BY filmcategory
	ORDER BY Revenue DESC
	LIMIT 5
);

-- 8b - How would you display the VIEW that you CREATEd in 8a?
SELECT * FROM top_five_genres;

-- 8c - You find that you no longer need the VIEW top_five_genres. Write a query to delete it.
-- https://dev.mysql.com/doc/refman/8.0/en/DROP-VIEW.html
DROP VIEW IF EXISTS top_five_genres;
