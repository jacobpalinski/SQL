--- How many customers has Foodie-Fi ever had?
SELECT COUNT(DISTINCT customer_id) as total_customers
FROM subscriptions

--- What is the monthly distribution of trial plan start_date values for our dataset?
--use the start of the month as group by value?
SELECT DATENAME(MONTH,start_date)as month, 
COUNT(subscriptions.plan_id) as trial_count
FROM subscriptions
JOIN
plans
on subscriptions.plan_id=plans.plan_id
WHERE plan_name='trial'
GROUP BY DATENAME(MONTH,start_date)

--- What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events
--- for each plan_name
SELECT plan_name,
COUNT(plan_name) as plan_count
FROM plans
JOIN
subscriptions 
on plans.plan_id=subscriptions.plan_id
WHERE YEAR(start_date)>2020
GROUP BY plan_name 

--- What is the customer count and percentage of customers who have churned rounded to 1 decimal place?
select * from subscriptions
select * from plans

SELECT COUNT(subscriptions.customer_id),
1.0*(SELECT COUNT(distinct customer_id) FROM subscriptions)/COUNT(subscriptions.customer_id)
FROM plans
JOIN
subscriptions