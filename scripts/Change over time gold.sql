SELECT
YEAR(order_date) as order_year,
MONTH(order_date) AS order_month,
SUM(sales_amount) as total_sales,
COUNT(DISTINCT customer_key) as total_customers,
SUM(quantity) as total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date),MONTH(order_date)
ORDER BY YEAR(order_date), MONTH(order_date)

-- How many times does each customer appear in the dimension?
