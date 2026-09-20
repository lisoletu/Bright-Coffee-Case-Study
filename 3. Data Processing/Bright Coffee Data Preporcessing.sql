-- Databricks notebook source
---checking what my raw data looks like
SELECT *
FROM bright_coffee.analytics.coffee_sales
LIMIT 10;

---Check the table structure and data types
DESCRIBE bright_coffee.analytics.coffee_sales;

---Check the number of records
SELECT COUNT(*) AS total_rows
FROM bright_coffee.analytics.coffee_sales; ---(there is 149116 rows)

---count of unique values  in each column
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT transaction_id) AS unique_transactions,
    COUNT(DISTINCT store_id) AS stores,
    COUNT(DISTINCT store_location) AS number_of_locations,
    COUNT(DISTINCT product_id) AS products,
    COUNT(DISTINCT product_category) AS categories,
    COUNT(DISTINCT product_type) AS product_types,
    COUNT(DISTINCT product_detail) AS product_details
FROM bright_coffee.analytics.coffee_sales;

---checking nulls for all rows
SELECT
    SUM(CASE WHEN transaction_id IS NULL THEN 1 ELSE 0 END) AS null_transaction_id,
    SUM(CASE WHEN transaction_date IS NULL THEN 1 ELSE 0 END) AS null_transaction_date,
    SUM(CASE WHEN transaction_time IS NULL THEN 1 ELSE 0 END) AS null_transaction_time,
    SUM(CASE WHEN transaction_qty IS NULL THEN 1 ELSE 0 END) AS null_transaction_qty,
    SUM(CASE WHEN store_id IS NULL THEN 1 ELSE 0 END) AS null_store_id,
    SUM(CASE WHEN store_location IS NULL THEN 1 ELSE 0 END) AS null_store_location,
    SUM(CASE WHEN product_id IS NULL THEN 1 ELSE 0 END) AS null_product_id,
    SUM(CASE WHEN unit_price IS NULL THEN 1 ELSE 0 END) AS null_unit_price,
    SUM(CASE WHEN product_category IS NULL THEN 1 ELSE 0 END) AS null_product_category,
    SUM(CASE WHEN product_type IS NULL THEN 1 ELSE 0 END) AS null_product_type,
    SUM(CASE WHEN product_detail IS NULL THEN 1 ELSE 0 END) AS null_product_detail
FROM bright_coffee.analytics.coffee_sales;

---duplicates check
SELECT
    transaction_id,
    COUNT(*) AS transaction_count
FROM bright_coffee.analytics.coffee_sales
GROUP BY transaction_id
HAVING COUNT(*) > 1;

------------------------------------------------------------------------------
---CHECKING transaction_qty COLUMN
------------------------------------------------------------------------------

--checking min and max quantity
SELECT
    MIN(transaction_qty) AS minimum_quantity,
    MAX(transaction_qty) AS maximum_quantity
FROM bright_coffee.analytics.coffee_sales;

--Quantity category
SELECT 
    CASE 
        WHEN transaction_qty =1 THEN 'Low'
        WHEN transaction_qty BETWEEN 2 AND 3 THEN 'Medium'
        ELSE 'High'
    END AS Quantity_category
FROM bright_coffee.analytics.coffee_sales;

---checking total quantity sold by bright coffee
SELECT SUM (transaction_qty) AS total_units_sold
FROM bright_coffee.analytics.coffee_sales; --214470

------------------------------------------------------------------------------
---CHECKING unit_price COLUMN
------------------------------------------------------------------------------
--checking data type
DESCRIBE bright_coffee.analytics.coffee_sales;--data type = DOUBLE (no comma-formatted string values present so no need to convert)

--inspecting the unit price column
SELECT
    unit_price 
FROM bright_coffee.analytics.coffee_sales
LIMIT 20;

--- checking min and max price
SELECT
    MIN(unit_price) AS minimum_price,---0.8
    MAX(unit_price) AS maximum_price---45
FROM bright_coffee.analytics.coffee_sales;

---converting price into 2 decimal places 
SELECT DISTINCT
    CAST(unit_price AS DECIMAL(10,2)) AS unit_price
FROM bright_coffee.analytics.coffee_sales
ORDER BY unit_price;

---checking if theres invalid prices
SELECT COUNT(*) AS invalid_prices
FROM bright_coffee.analytics.coffee_sales
WHERE unit_price <= 0;

----Creating total amount column (revenue per transaction)
SELECT
    transaction_id,
    transaction_qty,
    CAST(unit_price AS DECIMAL(10,2)) AS unit_price,
    CAST((unit_price* transaction_qty) AS DECIMAL(10,2)) AS total_amount
FROM bright_coffee.analytics.coffee_sales;

---checking total revenue of bright coffee
SELECT
    CAST (SUM(unit_price * transaction_qty) AS DECIMAL (10,2)) AS total_revenue ---698812.33
FROM bright_coffee.analytics.coffee_sales;

--checking the lowest and highest sales value 
SELECT
    MIN (unit_price* transaction_qty) AS min_sales_value,---0.8
    MAX (unit_price* transaction_qty) AS high_sales_value--360
FROM bright_coffee.analytics.coffee_sales;


------------------------------------------------------------------------------
---CHECKING transaction_date COLUMN
----------------------------------------------------------------------------

---looking at the values of my transaction_date column
SELECT transaction_date
FROM bright_coffee.analytics.coffee_sales;

---checking the earliest and latest transaction date
SELECT
    MIN(transaction_date) AS first_transaction_date,
    MAX(transaction_date) AS last_transaction_date
FROM bright_coffee.analytics.coffee_sales;

---Transforming date column creating what I NEED: (day of week, day number, month name, month number & year)
SELECT
  transaction_date,
   DAYNAME(transaction_date) AS day_name,-- extracting day of week
    DAYOFWEEK(transaction_date) AS day_number,--- extracting day number
        CASE 
            WHEN  DAYOFWEEK (transaction_date) IN (1,7) THEN 'Weekend'
            ELSE 'Weekday'
        END AS Day_classification,
    DATE_FORMAT(transaction_date,'MMMM') AS month_name,--- extracting month name
    MONTH(transaction_date) AS month_number,--- extracting month number
    YEAR(transaction_date) AS year--- extracting year
FROM bright_coffee.analytics.coffee_sales;


--revenue by day of week (highest and lowest performing day)  
SELECT
   DAYNAME(transaction_date) AS day_name,
    CAST(SUM(transaction_qty * unit_price) AS DECIMAL (10,2)) AS total_revenue
FROM bright_coffee.analytics.coffee_sales
GROUP BY day_name
ORDER BY total_revenue DESC;---HIGH= Mon, LOW= Sat

--- weekdays and weekend revenue
SELECT 
    CASE 
            WHEN  DAYOFWEEK (transaction_date) IN (1,7) THEN 'Weekend'
            ELSE 'Weekday'
        END AS Day_classification,
    CAST(SUM(transaction_qty * unit_price) AS DECIMAL (10,2)) AS total_revenue
FROM bright_coffee.analytics.coffee_sales
GROUP BY Day_classification
ORDER BY total_revenue DESC; -- high = weekday, Low = weekend

---revenue by month (highest and lowest performing month)
SELECT
    DATE_FORMAT(transaction_date,'MMMM') AS month_name,
    CAST(SUM(transaction_qty * unit_price) AS DECIMAL (10,2)) AS total_revenue
FROM bright_coffee.analytics.coffee_sales
GROUP BY month_name
ORDER BY total_revenue DESC; ------High = June, Low = Feb
    
    
------------------------------------------------------------------------------
---CHECKING transaction_time COLUMN
------------------------------------------------------------------------------

----converting timestamp into time & extracting the earliest and latest transaction time
SELECT 
    MIN(DATE_FORMAT(transaction_time, 'HH:mm:ss')) AS earliest_time,
    MAX(DATE_FORMAT(transaction_time, 'HH:mm:ss')) AS latest_time
FROM bright_coffee.analytics.coffee_sales;

---Transforming time column creating what I NEED: (transaction hour, transaction time bucket)
SELECT DISTINCT DATE_FORMAT(transaction_time, 'HH:mm:ss') AS transaction_time_only,--converting timestamp into time
       HOUR(transaction_time) AS transaction_hour,--- extracts transaction hour
        CASE ---creating transaction time buckets (30 min intervals)
            WHEN MINUTE(transaction_time) < 30 THEN DATE_FORMAT(transaction_time, 'HH:00')
        ELSE
            DATE_FORMAT(transaction_time, 'HH:30')
END AS transaction_time_bucket
FROM bright_coffee.analytics.coffee_sales
ORDER BY transaction_hour;

---checking DISTINCT hours
SELECT DISTINCT HOUR(transaction_time) AS transaction_hour---15
FROM bright_coffee.analytics.coffee_sales
ORDER BY transaction_hour;

--checking revenue by transactiong time bucket (to know what time of the day the shop perfoms the best)
SELECT   
       CASE 
            WHEN MINUTE(transaction_time) < 30 THEN DATE_FORMAT(transaction_time, 'HH:00')
        ELSE
            DATE_FORMAT(transaction_time, 'HH:30')
       END AS transaction_time_bucket,    
    CAST(SUM(transaction_qty * unit_price) AS DECIMAL (10,2)) AS total_revenue
FROM bright_coffee.analytics.coffee_sales
GROUP BY transaction_time_bucket
ORDER BY total_revenue DESC;  --- high revenue = 10:30, low revenue= 20:00


------------------------------------------------------------------------------
---CHECKING product_category COLUMN
------------------------------------------------------------------------------
--checking unique product category values
SELECT DISTINCT product_category
FROM bright_coffee.analytics.coffee_sales;

----Check total units sold by product category & revenue (low and high performing product category)
SELECT    
    product_category,
    SUM(transaction_qty) AS units_sold,
    CAST(SUM(transaction_qty * unit_price) AS DECIMAL (10,2)) AS total_revenue
FROM bright_coffee.analytics.coffee_sales
GROUP BY product_category
ORDER BY total_revenue DESC; ---high = Coffee, Low = packaged chocolate

------------------------------------------------------------------------------
---CHECKING product_type COLUMN
------------------------------------------------------------------------------
--checking unique product type values
SELECT DISTINCT product_type
FROM bright_coffee.analytics.coffee_sales;

--total units sold by product type & revenue (low and high performing products)
SELECT
    product_type,
    SUM(transaction_qty) AS units_sold,
    CAST(SUM(transaction_qty * unit_price) AS DECIMAL (10,2)) AS total_revenue
FROM bright_coffee.analytics.coffee_sales
GROUP BY product_type
ORDER BY total_revenue DESC;  --high = Barista Espresso, Low = Green beans
-------------------------------------------------------------------------------------------------
--finding sales peak period
SELECT 
    CASE 
         WHEN MINUTE(transaction_time) < 30 THEN DATE_FORMAT(transaction_time, 'HH:00')
    ELSE
        DATE_FORMAT(transaction_time, 'HH:30')
    END AS transaction_time_bucket,    
    SUM(transaction_qty) AS units_sold,
    CAST(SUM(transaction_qty * unit_price) AS DECIMAL  (10,2)) AS total_revenue
FROM bright_coffee.analytics.coffee_sales
GROUP BY transaction_time_bucket
ORDER BY total_revenue DESC;


---what product type & category sells the best? at what time? 
SELECT product_category,product_type,
    CASE ---creating transaction time buckets (30 min intervals)
         WHEN MINUTE(transaction_time) < 30 THEN DATE_FORMAT(transaction_time, 'HH:00')
    ELSE
        DATE_FORMAT(transaction_time, 'HH:30')
    END AS transaction_time_bucket,    
    SUM(transaction_qty) AS units_sold,
    CAST(SUM(transaction_qty * unit_price) AS DECIMAL  (10,2)) AS total_revenue
FROM bright_coffee.analytics.coffee_sales
GROUP BY transaction_time_bucket,product_type,product_category
ORDER BY total_revenue DESC;


------------------------------------------------------------------------------
---CHECKING product_detail COLUMN
------------------------------------------------------------------------------
--checking unique product detail values
SELECT DISTINCT product_detail
FROM bright_coffee.analytics.coffee_sales;

--revenue by individual products (low and high performing products)
SELECT
    product_detail,
    CAST(SUM(transaction_qty * unit_price) AS DECIMAL (10,2)) AS total_revenue
FROM bright_coffee.analytics.coffee_sales
GROUP BY product_detail
ORDER BY total_revenue DESC;  --- High = Sustainably Grown Organic Lg, Low = Dark chocolate

---units sold by individual product
SELECT
    product_detail,
    SUM(transaction_qty) AS units_sold
FROM bright_coffee.analytics.coffee_sales_clean
GROUP BY product_detail
ORDER BY units_sold DESC;

---underperforming products
SELECT
    product_detail,
    SUM(transaction_qty) AS units_sold,
    SUM(total_amount) AS total_revenue
FROM bright_coffee.analytics.coffee_sales_clean
GROUP BY product_detail
ORDER BY total_revenue ASC;

------------------------------------------------------------------------------
--- CHECKING store_id AND store_location COLUMN
------------------------------------------------------------------------------
--checking unique store id and location values
SELECT DISTINCT store_id, store_location
FROM bright_coffee.analytics.coffee_sales;

---revenue by store (to know which store is making most revenue)
SELECT store_id,
    store_location,
    CAST(SUM(transaction_qty * unit_price) AS DECIMAL(10,2)) AS total_revenue
FROM bright_coffee.analytics.coffee_sales
GROUP BY store_location, store_id
ORDER BY total_revenue DESC;   ---high = Hell's Kitchen, Low = Lower Manhattan

---units sold by store
SELECT store_id,
    store_location,
    SUM(transaction_qty) AS units_sold
FROM bright_coffee.analytics.coffee_sales
GROUP BY store_location, store_id
ORDER BY store_location DESC;  --- high = Lower Manhattan, Low = Astoria

---transactions by store
SELECT store_id,
    store_location,
   COUNT(*) AS transaction_count
FROM bright_coffee.analytics.coffee_sales
GROUP BY store_location, store_id
ORDER BY transaction_count DESC;  --- high = Hell's Kitchen, Low = Lower Manhattan
--------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------
SELECT
product_category,
product_type,
product_detail,
transaction_qty,
unit_price,
(transaction_qty * unit_price) AS total_amount,
SUM(transaction_qty) AS total_items_sold,
CAST (SUM(transaction_qty * unit_price) AS DECIMAL (10,2)) AS total_revenue
FROM bright_coffee.analytics.coffee_sales
GROUP BY
product_category,
product_type,
product_detail,
unit_price,
transaction_qty,
total_amount
ORDER BY total_revenue DESC;