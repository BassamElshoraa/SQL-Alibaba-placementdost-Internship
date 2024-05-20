--  Retrieve all columns from the table for the first 10 rows.
SELECT
	TOP 10 *
FROM
	[Alibabadb].[dbo].[Alibaba Data]


-- Display the products where the shipping city is 'New York'.
SELECT
	*
FROM
	[Alibabadb].[dbo].[Alibaba Data]
WHERE
	shipping_city = 'New York'


-- Retrieve the top 5 products with the highest item price.
SELECT TOP 5 
		Name, 
		Item_Price
FROM
	[Alibabadb].[dbo].[Alibaba Data]
ORDER BY 
	Item_Price DESC


-- Group the data by category and display the total quantity sold for each category.
SELECT
	Category,
	SUM(Quantity) AS Quantity
FROM
	[Alibabadb].[dbo].[Alibaba Data]
GROUP BY 
	Category
ORDER BY
	Quantity


-- Create a new table for payment methods and join it with the main table to display product names and their payment methods.
-- Step 1: Create the Payment_Methods table.
CREATE TABLE Payment_Methods 
	(PaymentID INT PRIMARY KEY,
	Payment_Name VARCHAR(50))

-- Step 2: Insert data from Alibaba_Data into Payment_Methods.
INSERT INTO Payment_Methods(
	PaymentID,
	Payment_Name)
SELECT 
	S_no, 
	Payment_Method
FROM
	[Alibabadb].[dbo].[Alibaba Data]
	

-- Find products where the cost price is greater than the average cost price.
SELECT
	NAME,
	Cost_Price
FROM
	[Alibabadb].[dbo].[Alibaba Data]
WHERE
	Cost_Price > (SELECT AVG(Cost_Price) FROM [Alibabadb].[dbo].[Alibaba Data])


-- Calculate the total special price for products in the 'Electronics' category
SELECT
	SUM(Special_price)
FROM
	[Alibabadb].[dbo].[Alibaba Data]
WHERE
	Category = 'Electronics'


-- Increase the cost price by 10% for products in the 'Clothing' category.
UPDATE
	[Alibabadb].[dbo].[Alibaba Data]
SET
	Cost_Price = Cost_Price * 1.10
WHERE
	Category_Grouped = 'Apparels'


-- Add a new record for a product with necessary details
INSERT INTO [Alibabadb].[dbo].[Alibaba Data] (
    S_no,
    Name,
    Category,
    Cost_Price, 
    Item_Price,
	Paid_pr
)
VALUES (
    50847, 
    'New Product', 
    'Electronics', 
    150.00, 
    200.00,
	200.00
)

-- Remove all products where the sale flag is 0.
DELETE FROM
	[Alibabadb].[dbo].[Alibaba Data]
WHERE 
	Sale_Flag = 'Not on Sale'


-- Create a new column 'Discount_Type' that categorizes products based on their item price: 'High' if above $200, 'Medium' if between $100 and $200, 'Low' if below $100.
-- Step 1: Add the new column
ALTER TABLE [Alibabadb].[dbo].[Alibaba Data]
ADD Discount_Type VARCHAR(50)

-- Step 2: Update the new column based on item price
UPDATE [Alibabadb].[dbo].[Alibaba Data]
SET Discount_Type = 
    CASE 
        WHEN Item_Price > 200 THEN 'High'
        WHEN Item_Price BETWEEN 100 AND 200 THEN 'Medium'
        WHEN Item_Price < 100 THEN 'Low'
    END


-- Rank the products based on their special prices within each category.
SELECT 
    Category,
    Name,
    Special_Price,
	RANK() OVER (PARTITION BY Category ORDER BY Special_Price DESC) AS Rank
FROM 
    [Alibabadb].[dbo].[Alibaba Data]
ORDER BY
	Rank

--  Calculate the running total of the quantity sold for each product
SELECT DISTINCT
	COUNT(S_no)
FROM
	[Alibabadb].[dbo].[Alibaba Data]
ORDER BY
	Name

SELECT
	S_no,
	Name,
	Quantity,
	sum(Quantity) OVER (PARTITION BY Name ORDER BY NAME) AS Quantity_Running_Total
FROM
	[Alibabadb].[dbo].[Alibaba Data]


-- Create a CTE that lists products in the 'Fashion' sub-category with their corresponding brand and color.
WITH Fashion AS (
    SELECT
        Name,
        Product_Gender,
        Family,
		Brand,
		Color,
		Cost_Price,
		Item_Price
    FROM
        [Alibabadb].[dbo].[Alibaba Data]
    WHERE
        Category_Grouped = 'Apparels'
)
SELECT
    *
FROM
    Fashion;


-- Pivot the data to show the total quantity sold for each category and sub-category.
-- Create a CTE to aggregate the quantity sold for each category and sub-category.
WITH Category_Totals AS (
    SELECT
        Category_Grouped,
        Category,
		Sub_Category,
        SUM(Quantity) AS Total_Quantity_Sold
    FROM
        [Alibabadb].[dbo].[Alibaba Data]
    GROUP BY
        Category_Grouped,
        Category,
		Sub_Category
)
-- Pivot the aggregated data
SELECT
    *
FROM
    Category_Totals

PIVOT (
	SUM(Total_Quantity_Sold)
    FOR Sub_Category IN ([Fashion], [Electronics], [Home], [Beauty], [Sports])) AS PivotTable
ORDER BY
    Category


-- Create a stored procedure that accepts a category name as input and returns the total quantity sold for that category.
CREATE PROCEDURE GetTotalQuantitySoldByCategory
    @CategoryName VARCHAR(100)
AS
BEGIN
    SELECT
        Category,
        SUM(Quantity) AS Sold_Quantity
    FROM
        [Alibabadb].[dbo].[Alibaba Data]
    WHERE
        Category = @CategoryName
    GROUP BY
        Category;
END;

EXEC GetTotalQuantitySoldByCategory @CategoryName = 'Electronics';