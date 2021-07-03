sp_tables

--Total Number of Products in each Category
Select CategoryName,
COUNT(ProductID) as TotalProducts
From Products
inner join
Categories
on Categories.Categoryid=Products.Categoryid
Group By CategoryName
Order By COUNT(ProductID) Desc

--Total Customers per country/city
Select Country,
City,
COUNT(CustomerID) as TotalCustomer
From Customers
Group by Country,City
Order by COUNT(CustomerID) Desc

--Products that need to be reordered (UnitsInStock < ReorderLevel)
Select ProductID,
ProductName,
UnitsInStock,
ReorderLevel
From Products
Where UnitsInStock<ReorderLevel

--Above Query Taking Into Account UnitsInStock + UnitsOnOrder < ReorderLevel and Discontinued Flag is False
Select ProductID,
ProductName,
UnitsInStock,
ReorderLevel
From Products
Where UnitsInStock + UnitsOnOrder<ReorderLevel 
AND
Discontinued=0

--Customer list by Region (Nulls at the End)
Select CustomerID,
CompanyName,
Region
From Customers
Order By 
Case When
Region is NULL 
THEN 1
ELSE 0
END

--Top 3 Highest Freight Charges by Country
Select Top 3 ShipCountry,
AVG(Freight) as AverageFreight
From Orders
Group By ShipCountry
Order By AVG(Freight) Desc

--Top 3 Highest Freight Charges 2015
Select Top 3 ShipCountry,
AVG(Freight) as AverageFreight
From Orders
Where YEAR(OrderDate)=2015
Group By ShipCountry
Order By AVG(Freight) Desc

--Highest Freight Charges in the Last Year
Select Top 3 ShipCountry,
AVG(Freight) as AverageFreight
From Orders
Where OrderDate>DATEADD(year,-1,(Select MAX(OrderDate) From Orders))
Group By ShipCountry
Order By AVG(Freight) Desc

--List of Inventory
Select Orders.EmployeeID, 
LastName, 
Orders.OrderID, 
ProductName, 
Quantity
from Orders
Inner Join
Employees 
on Orders.EmployeeID=Employees.EmployeeID
Inner Join
OrderDetails
on Orders.OrderID=OrderDetails.OrderID
Inner Join 
Products
on Products.ProductID=OrderDetails.ProductID

--Customers with No Orders
Select Customers.CustomerID as Customers_CustomerID,
Orders.CustomerID as Orders_CustomerID
From Customers
Left Join
Orders
on Customers.CustomerID=Orders.CustomerID
where Orders.CustomerID is null

--Highest Value Customers Discounted and Non Discounted Order Values
--(Highest Value defined as Customers with Total Orders >15000 Non Discounted in the Last Year)
Select Customers.CustomerID,
CompanyName, 
SUM(Quantity*UnitPrice) as TotalWithoutDiscount, 
SUM((1-Discount)*(Quantity*UnitPrice)) as TotalWithDiscount
from Customers
Inner Join 
Orders
on Customers.CustomerID=Orders.CustomerID
Inner Join
OrderDetails
on Orders.OrderID=OrderDetails.OrderID
Where OrderDate>DATEADD(year,-1,(Select MAX(OrderDate) From Orders))
Group By Customers.CustomerID, CompanyName
Having SUM(UnitPrice*Quantity)>15000
Order By TotalWithDiscount desc

--Month End Orders
Select EmployeeID,
OrderID 
From Orders
Where DATEDIFF(d,OrderDate,EOMONTH(Orderdate))=0
Order By EmployeeID, OrderID asc

--Top 10 Orders with Most Line Items
Select top 10 OrderID, 
COUNT(OrderID) as TotalOrderDetails
From OrderDetails
Group By OrderID
Order By TotalOrderDetails desc

--Late Orders
Select OrderID,
OrderDate,
RequiredDate,
ShippedDate
From Orders
Where ShippedDate>RequiredDate

--Salespeople with Most Late Orders
Select Orders.EmployeeID, 
LastName,
COUNT(Orders.EmployeeID) as TotalLateOrders
From Orders
INNER JOIN
Employees
on Orders.EmployeeID=Employees.EmployeeID
Where ShippedDate>RequiredDate
Group By Orders.EmployeeID, LastName
Order By TotalLateOrders Desc

--Late Orders vs Total Orders
with LateOrders as (
Select Employees.EmployeeID, 
LastName,
ISNULL(COUNT(Orders.EmployeeID),0) as TotalLateOrders
From Orders
RIGHT JOIN
Employees
on Orders.EmployeeID=Employees.EmployeeID
Where ShippedDate>RequiredDate
Group By Employees.EmployeeID, LastName),

TotalOrders as (
Select EmployeeID, 
COUNT(OrderID) as AllOrders
From ORDERS
Group By EmployeeID)

Select TotalOrders.EmployeeID, 
LastName,
AllOrders,
TotalLateOrders,
CAST(1.0*TotalLateOrders/AllOrders AS Decimal(10,2)) as PercentLateOrders
From LateOrders
LEFT JOIN
TotalOrders
on TotalOrders.EmployeeID=LateOrders.EmployeeID

--Customer Grouping Low, Medium and High Value Customers
--- Low: 0-7500, Medium: 7501-15000, High: >=15,001
;with CustOrderAmounts as (
Select Customers.CustomerID,
Customers.CompanyName,
SUM(Quantity*UnitPrice) as TotalOrderAmount
From Customers
INNER JOIN
Orders
on Orders.CustomerID=Customers.CustomerID
INNER JOIN
OrderDetails
on Orders.OrderID=OrderDetails.OrderID
Group By Customers.CustomerID,
Customers.CompanyName),

CustGroups as (
Select CustomerID,
CompanyName,
TotalOrderAmount,
Case 
When TotalOrderAmount between 0 and 7500 Then 'Low'
When TotalOrderAmount between 7501 and 15000 Then 'Medium'
When TotalOrderAmount>15000 Then 'High'
End as CustomerGroup
From CustOrderAmounts)

--Percentage of Customers in Each Group
;with CustOrderAmounts as (
Select Customers.CustomerID,
Customers.CompanyName,
SUM(Quantity*UnitPrice) as TotalOrderAmount
From Customers
INNER JOIN
Orders
on Orders.CustomerID=Customers.CustomerID
INNER JOIN
OrderDetails
on Orders.OrderID=OrderDetails.OrderID
Group By Customers.CustomerID,
Customers.CompanyName),

CustGroups as (
Select CustomerID,
CompanyName,
TotalOrderAmount,
Case 
When TotalOrderAmount between 0 and 7500 Then 'Low'
When TotalOrderAmount between 7501 and 15000 Then 'Medium'
When TotalOrderAmount>15000 Then 'High'
End as CustomerGroup
From CustOrderAmounts)

Select CustomerGroup,
COUNT(CustomerGroup) as TotalInGroup,
1.0*COUNT(CustomerGroup)/(Select COUNT(*) From CustGroups) as PercentageInGroup
From CustGroups
Group By CustomerGroup
Order by TotalInGroup desc

--Suppliers and Customers by Country
;with CountSupplier as (
Select Country,
COUNT(Country) as TotalSuppliers
From Suppliers
Group By Country),

CountCustomer as (
Select Country,
COUNT(Country) as TotalCustomers
from Customers
Group By Country)

Select ISNULL(CountCustomer.Country,CountSupplier.Country) as Country,
ISNULL(TotalSuppliers,0) as TotalSuppliers,
ISNULL(TotalCustomers,0) as TotalCustomers
From
CountSupplier
FULL JOIN
CountCustomer
on CountSupplier.Country=CountCustomer.Country

--Customers Who Can Minimise Freight Costs
;with NextOrderDate as (
Select CustomerID,
CONVERT(date,OrderDate) as OrderDate,
CONVERT(date, LEAD(OrderDate,1) 
OVER (Partition By CustomerID Order By CustomerID, OrderDate)) as NextOrderDate
From Orders)

Select CustomerID,
OrderDate,
NextOrderDate,
DATEDIFF(dd,OrderDate, NextOrderDate) as DaysBetweenOrders
From NextOrderDate
Where
DATEDIFF(dd,Orderdate, NextOrderDate) <=5






