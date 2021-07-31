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










