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
SELECT COUNT(subscriptions.customer_id) as churn_customer,
100.0* COUNT(subscriptions.customer_id)/(SELECT COUNT(distinct customer_id) FROM subscriptions) as churn_percentage
FROM plans
JOIN
subscriptions
on plans.plan_id=subscriptions.plan_id
WHERE plan_name='churn'

--- How many customers have churned straight after the initial free trial - what percentage is rounded to the nearest whole
--- number?
with trialplans as (SELECT customer_id,
plan_name,
plan_name1=lead(plan_name,1) over (order by start_date asc)
FROM plans
JOIN
subscriptions
on plans.plan_id=subscriptions.plan_id)

SELECT COUNT(customer_id) as trialchurn_customer,
100.0* COUNT(customer_id)/(SELECT COUNT(distinct customer_id) FROM subscriptions) as churn_percentage
from trialplans
WHERE plan_name='trial' AND plan_name1='churn'

--- What is the number and percentage of customer plans after their initial free trial?
SELECT (SELECT COUNT(distinct customer_id) FROM subscriptions WHERE
plan_id!=0) as aftertrial_customer,
100.0* COUNT(subscriptions.customer_id)/(SELECT COUNT(distinct customer_id) FROM subscriptions WHERE
plan_id!=0) as churn_percentage
FROM plans
JOIN
subscriptions
on plans.plan_id=subscriptions.plan_id
where plans.plan_id=0

select * from plans
select * from subscriptions
