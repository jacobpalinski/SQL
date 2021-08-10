--- Clean customer_orders table
UPDATE customer_orders
SET exclusions= 'None'
WHERE exclusions='null' or exclusions=''

UPDATE customer_orders 
SET extras ='None'
WHERE extras is null or extras='null' or extras=''

--- Clean runner_orders table
UPDATE runner_orders
SET cancellation='None'
WHERE cancellation is null or cancellation IN (NULL,'null','')

UPDATE runner_orders
SET distance=TRIM('km' from distance),
duration=TRIM('minutes' from duration)

UPDATE runner_orders
SET distance=0,
duration=0
WHERE distance is null OR duration='ll'

ALTER TABLE runner_orders
ALTER COLUMN distance float

ALTER TABLE runner_orders
ALTER COLUMN duration float

--- Change datatype of pizza_name in pizzarunner table
ALTER TABLE pizza_names
ALTER COLUMN pizza_name varchar(100)

--- How many Pizzas were ordered?
SELECT COUNT(pizza_id) as pizzas_ordered
FROM customer_orders

--- How many unique customer orders were made?
SELECT COUNT(DISTINCT order_id) as customer_orders
FROM customer_orders

--- How many successful orders were delivered by each runner?
SELECT runner_id,
SUM(CASE WHEN cancellation='None' THEN 1 ELSE 0 END) as successful_orders
FROM runner_orders
GROUP BY runner_id

--- How many of each type of pizza was delivered?
SELECT pizza_name,
COUNT(customer_orders.pizza_id) as pizzas_delivered
FROM pizza_names
JOIN
customer_orders
on pizza_names.pizza_id=customer_orders.pizza_id
JOIN
runner_orders
on customer_orders.order_id=runner_orders.order_id
WHERE cancellation='None'
GROUP BY pizza_name

--- How many vegetarian and meatlovers were ordered by each customer?
SELECT customer_id, pizza_name,
COUNT(customer_orders.pizza_id) as pizzas_ordered
FROM pizza_names
JOIN
customer_orders
on pizza_names.pizza_id=customer_orders.pizza_id
GROUP BY customer_id,pizza_name
ORDER BY customer_id ASC

---What was the maximum number of pizzas delivered in a single order?
SELECT TOP 1 
COUNT(pizza_id) as pizzas_delivered
from customer_orders
JOIN
runner_orders
on customer_orders.order_id=runner_orders.order_id
WHERE cancellation='None'
GROUP BY customer_orders.order_id
ORDER BY pizzas_delivered desc

--- For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
SELECT customer_id,
changes = SUM(CASE WHEN (exclusions!='None' or extras!='None') THEN 1 ELSE 0 END),
no_changes = SUM(CASE WHEN (exclusions='None' and extras='None') THEN 1 ELSE 0 END)
FROM customer_orders
JOIN
runner_orders
on customer_orders.order_id=runner_orders.order_id
WHERE cancellation='None'
GROUP BY customer_id

--- How many pizzas were delivered that had exclusions and extras?
SELECT SUM(CASE WHEN (exclusions!='None' and extras!='None') THEN 1 ELSE 0 END)
FROM customer_orders
JOIN
runner_orders
on customer_orders.order_id=runner_orders.order_id
WHERE cancellation='None'

--- What was the total volume of pizzas ordered for each hour of the day?
SELECT DATEPART(HOUR,order_time) AS time_hour,
COUNT(pizza_id) as pizzas_ordered
FROM customer_orders 
GROUP BY DATEPART(HOUR,order_time)

--- What was the volume of orders for each day of the week?
SELECT DATENAME(WEEKDAY,order_time) as day,
COUNT(pizza_id) as pizzas_ordered
FROM customer_orders
GROUP BY DATENAME(WEEKDAY,order_time)

--- How many runners signed up for each 1 week period?
SELECT DATEPART(WEEK,registration_date) as week,
COUNT(registration_date) as runners
FROM runners
GROUP BY DATEPART(WEEK,registration_date)

--- What was the average time in minutes it took for each runner to arrive at the Pizza HQ to pickup the order?
SELECT runner_id, 
AVG(DATEDIFF(mi,order_time,pickup_time)) as average_pickup_time
FROM runner_orders
JOIN
customer_orders
on runner_orders.order_id=customer_orders.order_id
WHERE pickup_time!='null'
GROUP BY runner_id

--- Is there any relationship between the number of pizzas and how long the order takes to prepare?
;with cte as 
(SELECT order_id,
order_time,
COUNT(pizza_id) as pizza_count
FROM customer_orders
GROUP BY order_id,order_time)

SELECT cte.order_id, 
cte.pizza_count,
DATEDIFF(mi,order_time,pickup_time) as average_pickup_time
FROM runner_orders
JOIN
cte
on runner_orders.order_id=cte.order_id
WHERE pickup_time!='null'

--- What was the average distance travelled for each customer?
SELECT customer_id,
AVG(CAST(duration as DECIMAL(10,2))) as avg_distance
FROM runner_orders
JOIN
customer_orders
on runner_orders.order_id=customer_orders.order_id
GROUP BY customer_id

---What was the difference between the longest and shortest delivery times for all orders?
;with cte as (SELECT customer_orders.order_id,
DATEDIFF(mi,order_time,pickup_time) as pickup_time
FROM runner_orders
JOIN
customer_orders
on runner_orders.order_id=customer_orders.order_id
WHERE pickup_time!='null')

SELECT MAX(pickup_time)-MIN(pickup_time) as pickup_time
FROM cte

--- What was the average speed for each runner for each delivery and do you notice any trend for these values?
SELECT runner_id,
AVG(duration/distance) as avg_speed
FROM runner_orders
JOIN
customer_orders
on runner_orders.order_id=customer_orders.order_id
WHERE pickup_time!='null'
GROUP BY runner_id

--- What was the successful delivery percentage for each runner?
SELECT runner_id,
100.0*SUM(CASE WHEN cancellation='None' THEN 1 ELSE 0 END)/COUNT(runner_id) as delivery_percentage
FROM runner_orders
GROUP BY runner_id

--- If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza
--- Runner made so far if there are no delivery fees?
SELECT SUM(CASE WHEN pizza_id=1 THEN 12 ELSE 10 END) as revenue
FROM customer_orders

--- What if there was an additional $1 charge for any pizza extras?
SELECT SUM(CASE WHEN (pizza_id=1 and extras!='None') THEN 13
WHEN (pizza_id=1 and extras='None') THEN 12
WHEN (pizza_id=2 and extras!='None') THEN 11
WHEN (pizza_id=2 and extras='None') THEN 10 END) as revenue_extras
FROM customer_orders

--- The pizza runner team now wants an additional rating system that allows customers to rate their runner,
--- how would you design an additional table for this new dataset- generate a schema for this new table and insert your own
---data for ratings for each successful customer order between 1 to 5
CREATE TABLE runner_ratings
(customer_id int,
order_id int,
runner_id int,
rating int)

INSERT INTO runner_ratings
SELECT DISTINCT customer_id, 
runner_orders.order_id,
runner_id, 
1
FROM runner_orders
JOIN
customer_orders
on customer_orders.order_id=runner_orders.order_id
WHERE cancellation='None'

UPDATE runner_ratings
SET rating=3
WHERE customer_id=101 and order_id=1 and runner_id=1

UPDATE runner_ratings
SET rating=2
WHERE customer_id=101 and order_id=2 and runner_id=1

UPDATE runner_ratings
SET rating=2
WHERE customer_id=102 and order_id=3 and runner_id=1

UPDATE runner_ratings
SET rating=4
WHERE customer_id=102 and order_id=8 and runner_id=2

UPDATE runner_ratings
SET rating=5
WHERE customer_id=103 and order_id=4 and runner_id=2

UPDATE runner_ratings
SET rating=4
WHERE customer_id=104 and order_id=5 and runner_id=3

UPDATE runner_ratings
SET rating=1
WHERE customer_id=104 and order_id=10 and runner_id=1

UPDATE runner_ratings
SET rating=3
WHERE customer_id=105 and order_id=7 and runner_id=2

--- Using your newly generated table can you join all of the information together to form a table that has the following information
-- successful deliveries? customer_id, order_id,runner_id, rating,order_time, pickup_time, Time between order and pickup
--- delivery duration, average speed, total number of pizzas.
SELECT runner_ratings.customer_id,
runner_ratings.order_id,
rating,
order_time,
pickup_time,
DATEDIFF(mi,order_time,pickup_time) as time_diff,
duration,
1.0*(distance/duration) as average_speed,
COUNT(pizza_id) as pizzas_ordered
FROM runner_ratings
JOIN
customer_orders
on runner_ratings.customer_id=customer_orders.customer_id AND runner_ratings.order_id=customer_orders.order_id
JOIN
runner_orders
on runner_orders.order_id=customer_orders.order_id
GROUP BY runner_ratings.customer_id, runner_ratings.order_id, rating, order_time, pickup_time,DATEDIFF(mi,order_time,pickup_time),
duration, 1.0*(distance/duration)

--- If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30
--- kilometre traveled- how much money does Pizza Runner have left over after these deliveries 
SELECT SUM(CASE WHEN pizza_name= 'Meatlovers' THEN 12 ELSE 10 END) - 0.30*SUM(distance) as money_leftover
FROM runner_orders
JOIN
customer_orders
on runner_orders.order_id=customer_orders.order_id
JOIN
pizza_names
on customer_orders.pizza_id=pizza_names.pizza_id


















