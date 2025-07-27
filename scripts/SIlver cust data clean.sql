--Quality checks
-- Check for unwanted spaces
SELECT
prd_nm
FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm)


-- Data standarization & Consistency
SELECT
DISTINCT prd_line
FROM silver.crm_prd_info

-- Check for Negative numbers or Nulls:
SELECT DISTINCT
sls_sales AS old_sls_sales,
sls_quantity,
sls_price as old_sls_price,
CASE WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales = sls_quantity * ABS(sls_price)
		THEN sls_quantity * ABS(sls_price)
		ELSE sls_sales
END AS sls_sales,
CASE WHEN sls_price < = 0 OR sls_price IS NULL 
	THEN sls_sales / NULLIF(sls_quantity, 0)
	ELSE sls_price
END AS sls_price
FROM bronze.crm_sales_details
ORDER BY sls_sales, sls_quantity, sls_price



-- Check for Nulls or Duplicates in Primary key
-- Expectation: No result
SELECT
prd_id,
COUNT(*)
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL 

-- Check for Invalid date orders
SELECT
NULLIF(sls_due_dt, 0) as sls_due_dt
FROM 
bronze.crm_sales_details
WHERE sls_due_dt <=0
OR LEN(sls_due_dt) != 8
OR sls_due_dt > 20500101
OR sls_due_dt < 19000101

-- Check Invalid dates for Order, Shipping, Due dates
SELECT 
*
FROM bronze.crm_sales_details
WHERE sls_order_dt > sls_ship_dt or sls_order_dt > sls_due_dt;

SELECT *
FROM bronze.crm_sales_details