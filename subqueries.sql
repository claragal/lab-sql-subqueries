USE sakila;

--  Number of copies of the film "Hunchback Impossible" in the inventory system
SELECT 
    COUNT(*) AS number_of_copies
FROM 
    inventory
WHERE 
    film_id = (SELECT film_id FROM film WHERE title = 'Hunchback Impossible');
    
-- Films longer than the average of all the films in Sakila database
/* SELECT 
    AVG(length) AS average_length
FROM 
    film;

OUTPUT = '115.2720'*/

SELECT 
    title, 
    length
FROM 
    film
WHERE 
    length > (SELECT AVG(length) FROM film);
    
    
-- subquery to display actors who appear in the film "Alone Trip"
SELECT 
    a.first_name, 
    a.last_name
FROM 
    actor a
WHERE 
    a.actor_id IN (
        SELECT actor_id 
        FROM film_actor 
        WHERE film_id = (SELECT film_id FROM film WHERE title = 'Alone Trip')
    );
    
-- BONUS
-- Identify all movies categorized as family films
/* with joins
SELECT 
    f.title AS film_title,
    c.name AS category_name
FROM 
    film f
JOIN 
    film_category fc ON f.film_id = fc.film_id
JOIN 
    category c ON fc.category_id = c.category_id
WHERE 
    c.name = 'Family';
 */
 
 /*With subqueries*/
 SELECT 
    title AS film_title
FROM 
    film
WHERE 
    film_id IN (
        SELECT film_id 
        FROM film_category
        WHERE category_id = (
            SELECT category_id 
            FROM category
            WHERE name = 'Family'
        )
    );
    
-- Retrieve the name and email of customers from Canada
-- With joins
SELECT 
    c.first_name, 
    c.last_name, 
    c.email
FROM 
    customer c
JOIN 
    address a ON c.address_id = a.address_id
JOIN 
    city ci ON a.city_id = ci.city_id
JOIN 
    country co ON ci.country_id = co.country_id
WHERE 
    co.country = 'Canada';
    
-- With subqueries
 SELECT 
    first_name, 
    last_name, 
    email
FROM 
    customer
WHERE 
    address_id IN (
        SELECT a.address_id
        FROM address a
        JOIN city ci ON a.city_id = ci.city_id
        JOIN country co ON ci.country_id = co.country_id
        WHERE co.country = 'Canada'
    );
    
-- Identify the Most Prolific Actor
SELECT 
    a.first_name, 
    a.last_name,
    fa.actor_id, 
    COUNT(fa.film_id) AS num_films
FROM 
    film_actor fa
JOIN 
    actor a ON fa.actor_id = a.actor_id
GROUP BY 
    fa.actor_id
ORDER BY 
    num_films DESC
LIMIT 1;

-- Find the Films Starred by the Most Prolific Actor
SELECT 
    f.title AS film_title
FROM 
    film f
WHERE 
    f.film_id IN (
        SELECT fa.film_id 
        FROM film_actor fa
        WHERE fa.actor_id = (
            SELECT fa.actor_id
            FROM film_actor fa
            GROUP BY fa.actor_id
            ORDER BY COUNT(fa.film_id) DESC
            LIMIT 1
        )
    );

-- Identify the Most Profitable Customer
	-- With JOINS"
SELECT 
    f.title AS film_title
FROM 
    film f
JOIN 
    inventory i ON f.film_id = i.film_id
JOIN 
    rental r ON i.inventory_id = r.inventory_id
JOIN 
    payment p ON r.rental_id = p.rental_id
WHERE 
    p.customer_id = (
        SELECT p.customer_id
        FROM payment p
        GROUP BY p.customer_id
        ORDER BY SUM(p.amount) DESC
        LIMIT 1
    );

	-- With subqueries
SELECT 
    f.title AS film_title
FROM 
    film f
WHERE 
    f.film_id IN (
        SELECT i.film_id
        FROM inventory i
        WHERE i.inventory_id IN (
            SELECT r.inventory_id
            FROM rental r
            WHERE r.rental_id IN (
                SELECT p.rental_id
                FROM payment p
                WHERE p.customer_id = (
                    SELECT p.customer_id
                    FROM payment p
                    GROUP BY p.customer_id
                    ORDER BY SUM(p.amount) DESC
                    LIMIT 1
                )
            )
        )
    );
    
-- Clients who spent more than the average
	-- With subqueries
SELECT 
    p.customer_id, 
    SUM(p.amount) AS total_amount_spent
FROM 
    payment p
GROUP BY 
    p.customer_id
HAVING 
    SUM(p.amount) > (
        SELECT AVG(total_spent) 
        FROM (
            SELECT SUM(p.amount) AS total_spent
            FROM payment p
            GROUP BY p.customer_id
        ) AS avg_spent
    );
    
	-- With JOINS
SELECT 
    p.customer_id, 
    SUM(p.amount) AS total_amount_spent
FROM 
    payment p
JOIN 
    (
        SELECT customer_id, SUM(amount) AS total_spent
        FROM payment
        GROUP BY customer_id
    ) AS total_per_customer
    ON p.customer_id = total_per_customer.customer_id
GROUP BY 
    p.customer_id
HAVING 
    SUM(p.amount) > (
        SELECT AVG(total_spent)
        FROM (
            SELECT SUM(amount) AS total_spent
            FROM payment
            GROUP BY customer_id
        ) AS avg_spent
    );