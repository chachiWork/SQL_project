--EDA
SELECT * FROM customers;
SELECT * FROM restaurants;
SELECT * FROM orders;
SELECT * FROM riders;
SELECT * FROM deliveries;
-- Missing data check up
SELECT COUNT(*) FROM customers
WHERE 
	customer_name IS NULL
	OR 
	reg_date IS NULL;

SELECT COUNT (*) FROM restaurants
WHERE 
	restaurant_name IS NULL 
	OR
	city IS NULL 
	OR 
	opening_hours IS NULL
	;

SELECT COUNT (*) FROM orders
WHERE 
	order_item IS NULL 
	OR 
	order_date IS NULL
	OR 
	order_time IS NULL
	OR
	order_status IS NULL
	OR
	total_amount IS NULL;

SELECT COUNT (*) FROM riders
WHERE  
	rider_name IS NULL
	OR 
	sign_up_date IS NULL;


INSERT INTO orders(order_id , customer_id , restaurant_id)
VALUES 
(10002,9,5),
(10003,4,8);

DELETE FROM orders
WHERE 
	order_item IS NULL 
	OR 
	order_date IS NULL
	OR 
	order_time IS NULL
	OR
	order_status IS NULL
	OR
	total_amount IS NULL;

-- Q.1 Write a query to find the top 5 most frequently ordered dishes by customer called "Arjun Mehta" in the last 3 year.Diya Iyer
SELECT customer_name,
       dishes
FROM 
(
SELECT c.customer_id ,
       c.customer_name,
       o.order_item as dishes,
	   COUNT(*) as total_order,
	   DENSE_RANK() OVER(ORDER BY COUNT (*) DESC ) as rank
	
FROM orders as o
JOIN 
customers as c
ON o.customer_id= c.customer_id
WHERE  
	customer_name = 'Diya Iyer'
	AND
	o.order_date >= CURRENT_DATE - INTERVAL '3 year'
GROUP BY 1,2,3
ORDER BY total_order DESC 
)
AS t1 
WHERE rank <=2

-- Q.2 Popular time slots
-- question: Identify the time slots during which the most orders are placed. based on 2-hour intervals.
SELECT 
	CASE 
		WHEN EXTRACT(HOUR FROM order_time) BETWEEN 0 AND 1 THEN '00:00 - 02:00'
		WHEN EXTRACT(HOUR FROM order_time) BETWEEN 2 AND 3 THEN '02:00 - 04:00'
		WHEN EXTRACT(HOUR FROM order_time) BETWEEN 4 AND 5 THEN '04:00 - 06:00'
		WHEN EXTRACT(HOUR FROM order_time) BETWEEN 6 AND 7 THEN '06:00 - 08:00'
		WHEN EXTRACT(HOUR FROM order_time) BETWEEN 8 AND 9 THEN '08:00 - 10:00'
		WHEN EXTRACT(HOUR FROM order_time) BETWEEN 10 AND 11 THEN '10:00 - 12:00'
		WHEN EXTRACT(HOUR FROM order_time) BETWEEN 12 AND 13 THEN '12:00 - 14:00'
		WHEN EXTRACT(HOUR FROM order_time) BETWEEN 14 AND 15 THEN '14:00 - 16:00'
		WHEN EXTRACT(HOUR FROM order_time) BETWEEN 16 AND 17 THEN '16:00 - 18:00'
		WHEN EXTRACT(HOUR FROM order_time) BETWEEN 18 AND 19 THEN '18:00 - 20:00'
		WHEN EXTRACT(HOUR FROM order_time) BETWEEN 20 AND 21 THEN '20:00 - 22:00'
		ELSE '22:00 - 00:00'
	END AS time_slot,
    COUNT(*) AS total_order
FROM orders
GROUP BY 1
ORDER BY total_order DESC;

--Option 2:
SELECT
    CONCAT(
        EXTRACT(HOUR FROM order_time)::INT / 2 * 2,
        ':00 - ',
        EXTRACT(HOUR FROM order_time)::INT / 2 * 2 + 2,
        ':00'
    ) AS time_slot,
    COUNT(*) AS total_orders
FROM orders
GROUP BY time_slot
ORDER BY total_orders DESC;

-- Q.3 Order Value Analysis
-- Question: Find the average order value per customer who has placed more than 20 orders.
-- return customer_name, and customer_id!
SELECT 
c.customer_id,
c.customer_name,
COUNT(order_id) as order_placed,
ROUND(AVG(o.total_amount)::numeric ,2) as avg_amount
    
FROM customers as c
JOIN 
orders as o
ON 
c.customer_id = o.customer_id
GROUP BY 1,2
HAVING COUNT(order_id) > 20
ORDER BY customer_id

;

SELECT * FROM orders;

-- Q.4 High Valued cusotmers
-- Question: List the customers who have spent more than 100K in total on food orders.
-- return customer_name and customer_id 
SELECT 
  c.customer_id,
  c.customer_name,
  SUM(total_amount) as total_val
FROM customers as c
JOIN 
orders as o 
ON
c.customer_id = o.customer_id
GROUP BY 1,2 
HAVING SUM(total_amount) >= 600
ORDER BY 1

-- Q.5 Orders without Delivery
-- Question: Write a query to find orders that were placed but not delivered.
-- Return each restuarant name, city and number of not delivered orders

SELECT r.restaurant_name,
       r.city,
	   COUNT(order_status) as num_not_delivered
FROM orders as o
JOIN 
restaurants as r
ON o.restaurant_id = r.restaurant_id
WHERE order_status = 'Cancelled'
GROUP BY 1,2
ORDER BY num_not_delivered DESC;


SELECT * FROM restaurants;
SELECT * FROM deliveries;

-- Q.6: Restaurant Revenue Ranking:
-- Rank restaurants by their total revenue from the last year, including their name,
-- total revenue, and rank within their city.
WITH r_t1 
AS
(SELECT r.restaurant_name,
       r.city,
       SUM(o.total_amount) as total_revenue,
	   RANK() OVER (PARTITION BY r.city ORDER BY SUM(o.total_amount) DESC) as rank
FROM restaurants as r
JOIN 
orders as o
ON
r.restaurant_id = o.restaurant_id
WHERE 
 order_date >= CURRENT_DATE - INTERVAL '3 year'
GROUP BY 1,2
)
SELECT restaurant_name,
       city,
	   total_revenue,
	   rank
FROM r_t1
WHERE rank = 1
;

SELECT * FROM orders;

-- Q.7 
-- Most popular Dish by city:
-- Identify the most popular dish in each city based on the number of orders
WITH t2 
AS
(SELECT  r.city,
	        o.order_item,
			COUNT (o.order_id),
			RANK () OVER(PARTITION BY r.city ORDER BY COUNT (o.order_id) DESC) 
			
	FROM restaurants as r
	JOIN 
	orders as o
	ON r.restaurant_id = o.restaurant_id
	GROUP BY 1,2)
SELECT * FROM t2 
WHERE rank=1
SELECT * FROM orders;

-- Q.8 Customer churn:
-- Find customers who haven't placed an order in 2024 (2)febuary not in march(3).


SELECT  c.customer_name,
		o.order_date ,
		EXTRACT(MONTH from order_date) as month
FROM customers as c
JOIN 
orders as o
ON c.customer_id = o.customer_id
 WHERE 
 	EXTRACT(MONTH from order_date) = 2  
	AND 
	c.customer_id  NOT IN (select DISTINCT customer_id  FROM orders WHERE EXTRACT(MONTH from order_date) = 3 )
;

SELECT * FROM orders;

-- Q.9 Cancellation Rate Comparison:
-- Calculate and compare the order cancellation rate for each restaurant between the 
-- current year and the previous year.
-- WITH t1 AS 
-- (
-- SELECT r.restaurant_name,
--        o.order_date,
--        COUNT(o.order_id) as cnt_orders,
-- 	   SUM(CASE WHEN order_status ='Cancelled' THEN 1 ELSE 0 END) as sum_can_cnt
	    
	  
-- FROM restaurants AS r
-- JOIN 
-- orders AS o
-- ON r.restaurant_id = o.restaurant_id
--  WHERE EXTRACT(MONTH FROM order_date) = 3
-- GROUP BY 1,2 )

-- SELECT restaurant_name ,
-- ROUND(sum_can_cnt::DECIMAL / cnt_orders * 100, 4) AS c_rate
-- FROM t1 
-- GROUP BY 1,2


-- Q.10 Rider Average Delivery Time:
-- Determine each rider's average delivery time.
SELECT * FROM riders;
SELECT * FROM deliveries;
SELECT * FROM orders;
