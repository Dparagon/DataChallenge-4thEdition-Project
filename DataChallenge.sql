-- #DATA OVERVIEW
SELECT * FROM Sales_January_2019     ---(42 nulls)
SELECT * FROM Sales_February_2019    ---(50 nulls)
SELECT * FROM Sales_March_2019       ---(72 nulls)
SELECT * FROM Sales_April_2019       ---(94 nulls)
SELECT * FROM Sales_May_2019         ---(81 nulls)
SELECT * FROM Sales_June_2019        ---(66 nulls)
SELECT * FROM Sales_July_2019        ---(80 nulls)
SELECT * FROM Sales_August_2019      ---(54 nulls)
SELECT * FROM Sales_September_2019   ---(57 nulls)
SELECT * FROM Sales_October_2019     ---(95 nulls)
SELECT * FROM Sales_November_2019    ---(81 nulls)
SELECT * FROM Sales_December_2019    ---(128 nulls)

-- #DATA INFORMATION
SELECT TABLE_NAME,
       DATA_TYPE,  
	   COLUMN_NAME,
	   TABLE_CATALOG
FROM INFORMATION_SCHEMA.COLUMNS

-- #DATA CLEANING AND TRANSFORMATION

--- Deleting Order_ID columns in each month sales data
ALTER TABLE Sales_January_2019 DROP COLUMN Order_ID
ALTER TABLE Sales_February_2019 DROP COLUMN Order_ID
ALTER TABLE Sales_March_2019 DROP COLUMN Order_ID
ALTER TABLE Sales_April_2019 DROP COLUMN Order_ID
ALTER TABLE Sales_May_2019 DROP COLUMN Order_ID
ALTER TABLE Sales_June_2019 DROP COLUMN Order_ID
ALTER TABLE Sales_July_2019 DROP COLUMN Order_ID
ALTER TABLE Sales_August_2019 DROP COLUMN Order_ID
ALTER TABLE Sales_September_2019 DROP COLUMN Order_ID
ALTER TABLE Sales_October_2019 DROP COLUMN Order_ID
ALTER TABLE Sales_November_2019 DROP COLUMN Order_ID
ALTER TABLE Sales_December_2019 DROP COLUMN Order_ID

--- Merging data tables
SELECT * INTO Sales_2019 FROM (SELECT * FROM Sales_January_2019
                               UNION
                               SELECT * FROM Sales_February_2019
	                           UNION
                               SELECT * FROM Sales_March_2019
                           	   UNION
                               SELECT * FROM Sales_April_2019
	                           UNION
                               SELECT * FROM Sales_May_2019
	                           UNION
                               SELECT * FROM Sales_June_2019
	                           UNION
                               SELECT * FROM Sales_July_2019
	                           UNION
                               SELECT * FROM Sales_August_2019
	                           UNION
                               SELECT * FROM Sales_September_2019
	                           UNION      
                               SELECT * FROM Sales_October_2019
	                           UNION
                               SELECT * FROM Sales_November_2019
	                           UNION
                               SELECT * FROM Sales_December_2019) sales

SELECT * FROM Sales_2019 --(185,688 rows.)

--- Rearranging Order_Date format
UPDATE Sales_2019 SET Order_Date =  FORMAT(Order_Date,'20dd-MM-yy hh:mm:ss') 

--- Removing nulls
SELECT * FROM Sales_2019
WHERE Product IS NULL --(2 null rows.)

DELETE FROM Sales_2019
WHERE Product IS NULL --(185,686 rows available affter deletion.)

--- Creating and Updating new columns: Revenue, State, City and Month
ALTER TABLE Sales_2019 ADD Revenue INT
ALTER TABLE Sales_2019 ADD State NVARCHAR(10)
ALTER TABLE Sales_2019 ADD City NVARCHAR(50)
ALTER TABLE Sales_2019 ADD Month_name NVARCHAR(50)

UPDATE Sales_2019 SET Revenue = Quantity_Ordered * Price_Each
UPDATE Sales_2019 SET State = LEFT(PARSENAME(REPLACE(Purchase_Address,',','.'),1),3)
UPDATE Sales_2019 SET City = PARSENAME(REPLACE(Purchase_Address,',','.'),2)
UPDATE Sales_2019 SET Month_name = DATENAME(MONTH, Order_Date)

--#DATA INFORMATION (After Merging & Cleaning)
SELECT TABLE_NAME,  
	   COLUMN_NAME,
	   DATA_TYPE,
	   TABLE_CATALOG
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Sales_2019'

--#DATA ANALYSIS
SELECT * FROM Sales_2019

---1. What is the total revenue generated?
SELECT SUM(Revenue) FROM Sales_2019

---2. What is the total quantity sold?
SELECT SUM(Quantity_Ordered) FROM Sales_2019

---3. Total number of orders
SELECT COUNT(Quantity_Ordered) FROM Sales_2019

---4. Total revenue by month
SELECT Month_name, SUM(Revenue) Monthly_Revenue
FROM Sales_2019
GROUP BY Month_name
ORDER BY Monthly_Revenue DESC

---5. Total revenue by product
SELECT Product, SUM(Revenue) Product_Revenue
FROM Sales_2019
GROUP BY Product
ORDER BY Product_Revenue DESC

---6. Total revenue by city
SELECT City, SUM(Revenue) City_Revenue
FROM Sales_2019
GROUP BY City
ORDER BY City_Revenue DESC

---7. Total revenue by state
SELECT State, SUM(Revenue) State_Revenue
FROM Sales_2019
GROUP BY State
ORDER BY State_Revenue DESC

---8. Quarterly revenue trend
SELECT Qrt, SUM(Revenue)
FROM (SELECT *, CASE WHEN Month_name IN ('January', 'February', 'March') THEN 'Qtr 1'
                WHEN Month_name IN ('April', 'May', 'June') THEN 'Qtr 2'
			    WHEN Month_name IN ('July', 'August', 'September') THEN 'Qtr 3'
			    WHEN Month_name IN ('October', 'November', 'December') THEN 'Qtr 4'
			    END AS Qrt
      FROM Sales_2019) sales
GROUP BY Qrt
ORDER BY Qrt

--- 9. No of quantity ordered by month
SELECT Month_name, SUM(Quantity_Ordered) Monthly_Orders
FROM Sales_2019
GROUP BY Month_name
ORDER BY Monthly_Orders DESC

--- 10. No of each product ordered
SELECT Product, SUM(Quantity_Ordered) Product_Orders
FROM Sales_2019
GROUP BY Product
ORDER BY Product_Orders DESC

--- 11. Total revenue and quantity sold of products
SELECT Product, 
ROUND(Price_Each,1) Price_Per_Unit,
SUM(Revenue) Product_Revenue, 
SUM(quantity_ordered) Product_Sold
FROM Sales_2019
GROUP BY Product, Price_Each
ORDER BY Product_Revenue DESC

