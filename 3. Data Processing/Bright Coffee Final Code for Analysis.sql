-- Databricks notebook source
CREATE OR REPLACE TABLE cleaned_BrightCoffee_sales_data AS

    SELECT
        transaction_id,
        transaction_date,
         --transaction date transformations
        DAYNAME(transaction_date) AS day_name,-- extracting day of week
        DAYOFWEEK(transaction_date) AS day_number,--- extracting day number
            CASE 
                WHEN  DAYOFWEEK (transaction_date) IN (1,7) THEN 'Weeekend'
            ELSE 'Weekday'
        END AS Day_classification,
        DATE_FORMAT(transaction_date,'MMMM') AS month_name,--- extracting month name
        MONTH(transaction_date) AS month_number,--- extracting month number
        YEAR(transaction_date) AS year,--- extracting year

        transaction_time,
         -- transaction Time transformations
        DATE_FORMAT(transaction_time, 'HH:mm:ss') AS transaction_time_only,
        HOUR(transaction_time) AS transaction_hour,--- extracts transaction hour
            CASE ---creating transaction time buckets (30 min intervals)
                WHEN MINUTE(transaction_time) < 30 THEN DATE_FORMAT(transaction_time, 'HH:00')
            ELSE
            DATE_FORMAT(transaction_time, 'HH:30')
        END AS transaction_time_bucket,
        store_id,
        store_location,
        product_id,
        product_category,
        product_type,
        product_detail,
        transaction_qty,
        unit_price,
        -- Revenue calculation per qty
        CAST((unit_price* transaction_qty) AS DECIMAL(10,2)) AS total_amount
    FROM bright_coffee.analytics.coffee_sales;

------------------------------------------------------------------------------------
--checking my final clean table
SELECT *
FROM cleaned_BrightCoffee_sales_data;
----------------------------------------------------------------------------------

--checking data types on my final clean table
DESCRIBE cleaned_BrightCoffee_sales_data; 


---checking the number of records
SELECT COUNT(*) AS total_rows
FROM cleaned_BrightCoffee_sales_data; ---149116


---check total revenue
SELECT
    SUM(total_amount) AS total_revenue
FROM cleaned_BrightCoffee_sales_data; ---698812.33

