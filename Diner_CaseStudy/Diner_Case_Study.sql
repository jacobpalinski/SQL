sp_tables

select * from members
select * from menu
select * from sales

--Total amount spent by each customer at the restaurant
SELECT customer_id,
SUM(price) as totalspent
from sales
JOIN
menu
on sales.product_id=menu.product_id
GROUP BY customer_id
ORDER BY totalspent DESC

--How many days each customer has visited the restaurant
SELECT customer_id,
COUNT(order_date) as days_visited
FROM sales
GROUP BY customer_id
ORDER BY days_visited DESC

-- First item from the menu purchased by each customer
select * from sales
select * from menu
;with date_ranking as (SELECT customer_id,
product_name, 
rn=ROW_NUMBER() over (PARTITION BY customer_id ORDER by order_date asc)
FROM sales
JOIN
menu
on sales.product_id=menu.product_id)

SELECT customer_id,
product_name 
FROM date_ranking
WHERE rn=1

-- What was the most purchased item on the menu and how many times was it purchased by each customer
SELECT customer_id,
product_name,
COUNT(product_name) as Itemcount
FROM menu
JOIN
sales 
on menu.product_id=sales.product_id
WHERE sales.product_id=(SELECT TOP 1 product_id FROM sales GROUP BY product_id ORDER BY COUNT(product_id) DESC)
GROUP BY customer_id, product_name

-- Which item is the most popular for each customer?
;with product_counts as (SELECT customer_id,
product_name,
product_count=COUNT(sales.product_id),
rnk= RANK() OVER (PARTITION BY customer_id ORDER BY COUNT(sales.product_id) DESC)
FROM menu
JOIN
sales
on menu.product_id=sales.product_id
GROUP BY customer_id, product_name)

SELECT customer_id,
product_name
FROM product_counts
WHERE rnk=1

-- Which item was purchased first by the customer after they became a member?
;with purchase_member as (SELECT members.customer_id,
product_name,
rn= ROW_NUMBER() over (PARTITION BY members.customer_id ORDER BY order_date asc)
FROM members
JOIN
sales
on members.customer_id=sales.customer_id
JOIN
menu
on sales.product_id=menu.product_id
WHERE join_date < order_date)

SELECT customer_id,
product_name
FROM purchase_member
WHERE rn=1

-- Which item was purchased just before the customer became a member?
;with purchase_member as (SELECT members.customer_id,
product_name,
rn= ROW_NUMBER() over (PARTITION BY members.customer_id ORDER BY order_date DESC)
FROM members
JOIN
sales
on members.customer_id=sales.customer_id
JOIN
menu
on sales.product_id=menu.product_id
WHERE join_date > order_date)

SELECT customer_id,
product_name
FROM purchase_member
WHERE rn=1

-- What is the total items and amount spent for each member before they became a member?
SELECT members.customer_id,
COUNT(product_name) as total_items,
SUM(price) as total_price
FROM members
JOIN
sales
on members.customer_id=sales.customer_id
JOIN
menu
on sales.product_id=menu.product_id
WHERE join_date > order_date
GROUP BY members.customer_id

-- If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
SELECT members.customer_id,
SUM(CASE WHEN product_name='sushi' THEN price*20.0 ELSE price*10.0 END) as points
FROM members
JOIN
sales
on members.customer_id=sales.customer_id
JOIN
menu
on sales.product_id=menu.product_id
GROUP BY members.customer_id

-- In the first week after a customer joins the program (including their join date) they are earn 2x
-- points on all items, not just sushi- how many points do customer A and B have at the end of January?
SELECT members.customer_id,
SUM(CASE WHEN DATEDIFF(d,join_date,order_date)<=7 then price*20
ELSE price*10 END) as points
FROM members
JOIN
sales
on members.customer_id=sales.customer_id
JOIN
menu
on sales.product_id=menu.product_id
WHERE MONTH(order_date)=1
GROUP BY members.customer_id

-- Join All The Things
CREATE VIEW [join_all] as SELECT 
sales.customer_id,
order_date,
product_name,
price,
CASE WHEN order_date>=join_date THEN 'Y' ELSE 'N' END as member
FROM members
JOIN
sales
on members.customer_id=sales.customer_id
JOIN
menu
on sales.product_id=menu.product_id

-- Rank All The Things
SELECT 
sales.customer_id,
order_date,
product_name,
price,
CASE WHEN order_date>=join_date THEN 'Y' ELSE 'N' END as member,
CASE WHEN order_date>=join_date THEN RANK() OVER (PARTITION BY sales.customer_id ORDER BY order_date asc) END as ranking
FROM members
JOIN
sales
on members.customer_id=sales.customer_id
JOIN
menu
on sales.product_id=menu.product_id

select * from rank_all