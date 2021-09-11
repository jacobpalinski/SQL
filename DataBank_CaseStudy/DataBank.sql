--- How many unique nodes are there on the Data Bank system?
SELECT COUNT(*)
FROM data_bank.customer_nodes

--- What is the number of nodes per region?
SELECT region_id, 
COUNT(*)
FROM data_bank.customer_nodes
GROUP BY region_id
ORDER BY region_id asc

--- How many customers are allocated to each region?
SELECT region_id, 
COUNT(DISTINCT customer_id)
FROM data_bank.customer_nodes
GROUP BY region_id
ORDER BY region_id asc

--- How many days on average are customers reallocated to a different node?
SELECT AVG(DATE_PART('day',end_date)-DATE_PART('day',start_date))
FROM data_bank.customer_nodes

--- What is the median, 80th and 95th percentile for this same reallocation days metric for
--- each region?
SELECT region_id,
PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY DATE_PART('day',end_date)-DATE_PART('day',start_date) ) as median,
PERCENTILE_DISC(0.8) WITHIN GROUP (ORDER BY DATE_PART('day',end_date)-DATE_PART('day',start_date) ),
PERCENTILE_DISC(0.95) WITHIN GROUP (ORDER BY DATE_PART('day',end_date)-DATE_PART('day',start_date) )
FROM data_bank.customer_nodes
GROUP BY region_id

--- What is the unique count and total amount for each transaction type?
SELECT txn_type,
COUNT(txn_type) as num_transactions,
SUM(txn_amount) as total_amount
FROM data_bank.customer_transactions
GROUP BY txn_type

--- What is the average total historical deposit counts and amounts for all customers?
;with cust_summary as (SELECT COUNT(txn_type) as num_transactions,
SUM(txn_amount) as total_amount
FROM data_bank.customer_transactions
WHERE txn_type='deposit'
GROUP BY customer_id)

SELECT ROUND(AVG(num_transactions),2) as avg_deposits,
ROUND(AVG(total_amount),2) as avg_amount
FROM cust_summary

--- For each month- how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 
--- withdrawal in a single month?
SELECT TO_CHAR(txn_date, 'Month') as "Month",
COUNT(distinct customer_id) as total_customers
FROM data_bank.customer_transactions
GROUP BY TO_CHAR(txn_date, 'Month')
HAVING (COUNT(txn_type='deposit')>1 AND COUNT(txn_type='purchase')>=1)
OR (COUNT(txn_type='deposit')>1 AND COUNT(txn_type='withdrawal')>=1)




