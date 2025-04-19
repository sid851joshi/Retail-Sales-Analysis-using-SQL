create database Project1

use Project1

-- Create TABLE
DROP TABLE IF EXISTS retail_sales;
CREATE TABLE retail_sales
            (
                transaction_id INT PRIMARY KEY,	
                sale_date DATE,	 
                sale_time TIME,	
                customer_id	INT,
                gender	VARCHAR(15),
                age	INT,
                category VARCHAR(15),	
                quantity	INT,
                price_per_unit FLOAT,	
                cogs	FLOAT,
                total_sale FLOAT
            );

-- truncate the table first
TRUNCATE TABLE dbo.retail_sales;
GO
 
-- import the file
BULK INSERT dbo.retail_sales
FROM 'F:\Downloads\RetailSalesAnalysis.csv'
WITH
(
        FORMAT='CSV',
        FIRSTROW=2
)
GO


select top 10 * from retail_sales

select count(*) from retail_sales

select gender, count(customer_id) [Total Customers] from retail_sales group by gender

-- Data Cleaning
SELECT * FROM retail_sales
WHERE transaction_id IS NULL

SELECT * FROM retail_sales
WHERE sale_date IS NULL

SELECT * FROM retail_sales
WHERE sale_time IS NULL

SELECT * FROM retail_sales
WHERE 
    transaction_id IS NULL
    OR
    sale_date IS NULL
    OR 
    sale_time IS NULL
    OR
    gender IS NULL
    OR
    category IS NULL
    OR
    quantity IS NULL
    OR
    cogs IS NULL
    OR
    total_sale IS NULL;

-- 
DELETE FROM retail_sales
WHERE 
    transaction_id IS NULL
    OR
    sale_date IS NULL
    OR 
    sale_time IS NULL
    OR
    gender IS NULL
    OR
    category IS NULL
    OR
    quantity IS NULL
    OR
    cogs IS NULL
    OR
    total_sale IS NULL;


-- Data Exploration
--Total Sales
select count(*) [Total Sales] from retail_sales

-- Total customers based on gender
select gender, count(customer_id) [Total Customers] from retail_sales group by gender

--Total Distict Customers based on gendre
select gender, count(distinct customer_id) [Distinct Total Customers] from retail_sales group by gender

select distinct category from retail_sales

-- Data Analysis and Business Key Problems and Solutions

-- My Analysis & Findings
-- Q.1 Write a SQL query to retrieve all columns for sales made on '2022-11-05
-- Q.2 Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 10 in the month of Nov-2022
-- Q.3 Write a SQL query to calculate the total sales (total_sale) for each category.
-- Q.4 Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.
-- Q.5 Write a SQL query to find all transactions where the total_sale is greater than 1000.
-- Q.6 Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.
-- Q.7 Write a SQL query to calculate the average sale for each month. Find out best selling month in each year
-- Q.8 Write a SQL query to find the top 5 customers based on the highest total sales 
-- Q.9 Write a SQL query to find the number of unique customers who purchased items from each category.
-- Q.10 Write a SQL query to create each shift and number of orders (Example Morning <=12, Afternoon Between 12 & 17, Evening >17)

 --Q.1 Write a SQL query to retrieve all columns for sales made on '2022-11-05
 select * from retail_sales where sale_date = '2022-11-05'

 -- Q.2 Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 4 in the month of Nov-2022
 SELECT * 
FROM retail_sales 
WHERE category = 'Clothing' 
  AND quantity >= 4 
  AND FORMAT(sale_date, 'yyyy-MM') = '2022-11';

-- Q.3 Write a SQL query to calculate the total sales (total_sale) for each category.
select category,sum(total_sale) [Sum of Total Sales],count(*) [Total Orders] from retail_sales group by category

-- Q.4 Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.
select category,avg(age) [Avg Age of cutomers],count(*) [Total Customers] from retail_sales where category = 'Beauty'  group by category

-- Q.5 Write a SQL query to find all transactions where the total_sale is greater than 1000.
select * from retail_sales where total_sale > 1000

-- Q.6 Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.
select gender,count(transaction_id) [Total Customers] from retail_sales group by gender

-- Q.7 Write a SQL query to calculate the average sale for each month. Find out best selling month in each year
WITH monthly_sales as (
    SELECT 
        YEAR(sale_date) AS sale_year,
        MONTH(sale_date) AS sale_month,
        SUM(total_sale) AS total_monthly_sale
    FROM 
        retail_sales
    GROUP BY 
        YEAR(sale_date), MONTH(sale_date)
),
ranked_sales AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY sale_year ORDER BY total_monthly_sale DESC) AS rn
    FROM monthly_sales
)
SELECT sale_year, sale_month, total_monthly_sale
FROM ranked_sales
WHERE rn = 1;

-- Q.8 Write a SQL query to find the top 5 customers based on the highest total sales 
select top 5 customer_id,sum(total_sale) from retail_sales group by customer_id order by sum(total_sale) desc

-- Q.9 Write a SQL query to find the number of unique customers who purchased items from each category.
select category, count(distinct customer_id)[Total Customers] from retail_sales group by category 

-- Q.10 Write a SQL query to create each shift and number of orders (Example Morning <=12, Afternoon Between 12 & 17, Evening >17)
SELECT 
    CASE 
        WHEN DATEPART(HOUR, sale_time) < 12 THEN 'Morning'
        WHEN DATEPART(HOUR, sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
    END AS shift,
    COUNT(*) AS number_of_orders
FROM retail_sales
GROUP BY 
    CASE 
        WHEN DATEPART(HOUR, sale_time) < 12 THEN 'Morning'
        WHEN DATEPART(HOUR, sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
    END;
