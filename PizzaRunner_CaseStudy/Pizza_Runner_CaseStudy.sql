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
SELECT customer_id,
AVG(CAST((duration/distance) as DECIMAL(10,2))) as avg_distance
FROM runner_orders
JOIN
customer_orders
on runner_orders.order_id=customer_orders.order_id
GROUP BY customer_id











