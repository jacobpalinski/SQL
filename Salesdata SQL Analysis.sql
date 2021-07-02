sp_tables

--Total Number of Products in each Category
Select CategoryName,
Count(ProductID) as TotalProducts
From Products
inner join
Categories
on Categories.Categoryid=Products.Categoryid
Group By CategoryName
Order By Count(ProductID) Desc

--Total Customers per country/city
Select Country,
City,
Count(CustomerID) as TotalCustomer
From Customers
Group by Country,City
Order by Count(CustomerID) Desc

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

--Salespeople with most late orders
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


sp_tables



