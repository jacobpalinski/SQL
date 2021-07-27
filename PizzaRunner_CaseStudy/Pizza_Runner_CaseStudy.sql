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
COUNT(CAST(customer_orders.pizza_id as VARCHAR(100))
FROM pizza_names
JOIN
customer_orders
on pizza_names.pizza_id=customer_orders.pizza_id
GROUP BY pizza_name







