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
Where OrderDate>DATEADD(year,-1,MAX(OrderDate))
Group By ShipCountry
Order By AVG(Freight) Desc

select * from orders




