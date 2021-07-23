--Clean customer_orders table
UPDATE customer_orders
SET exclusions= 'None'
WHERE exclusions='null' or exclusions=''

UPDATE customer_orders 
SET extras ='None'
WHERE extras is null or extras='null' or extras=''

-- Clean runner_orders table
UPDATE runner_orders
SET cancellation='None'
WHERE cancellation is null or cancellation IN (NULL,'null','')

UPDATE runner_orders
SET distance=TRIM('km' from distance),
duration=TRIM('minutes' from duration)







