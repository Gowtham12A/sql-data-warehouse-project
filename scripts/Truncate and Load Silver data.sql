CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
DECLARE @start_time DATETIME, @end_time DATETIME;
	BEGIN TRY
	
		Print '============================================';
		Print 'Loading silver layer';
		Print '============================================';

		PRINT '--------------------------------------------';
		PRINT 'Loading CRM tables';
		PRINT '--------------------------------------------';
		-- Loading CRM tables
		SET @start_time = GETDATE();
		PRINT '>>  Truncating Table: silver.crm_cust_info';
		TRUNCATE TABLE silver.crm_cust_info
		PRINT '>> Inserting Data into: silver.crm_cust_info';
		INSERT INTO silver.crm_cust_info (
			cst_id,
			cst_key,
			cst_firstname,
			cst_lastname,
			cst_material_status,
			cst_gndr,
			cst_create_date)


		SELECT
			cst_id,
			cst_key,
			TRIM(cst_firstname) AS cst_firstname,
			TRIM(cst_lastname) AS cst_lastname,
		CASE WHEN UPPER(TRIM(cst_material_status)) = 'S' THEN 'Single'
		WHEN  UPPER(TRIM(cst_material_status)) = 'M' THEN 'Married'
			ELSE 'n/a'
		END cst_material_status,
			CASE WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN ' Female'
			WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
			ELSE 'n/a'
		END cst_gndr,
			cst_create_date
		FROM (
			SELECT
			*,
			ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC ) AS flag_last
			FROM bronze.crm_cust_info
			WHERE cst_id IS NOT NULL
		)t WHERE flag_last = 1
		
		SET @end_time = GETDATE();
		PRINT '>> Loading Duration:' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR)+ 'seconds' ;  
		PRINT '-------------------';
		SET @start_time = GETDATE();
		PRINT '>>  Truncating Table: silver.crm_prd_info';
		TRUNCATE TABLE silver.crm_prd_info
		PRINT '>> Inserting Data into: silver.crm_prd_info';
		INSERT INTO silver.crm_prd_info (
			prd_id,
			cat_id,
			prd_key,
			prd_nm,
			prd_cost,
			prd_line,
			prd_start_dt,
			prd_end_dt
		)
		SELECT 
		prd_id,
		REPLACE(SUBSTRING(prd_key, 1, 5), '-','_') as cat_id, -- Extract category ID
		SUBSTRING(prd_key, 7,LEN(prd_key)) as prd_key, -- Extract product key
		prd_nm,
		ISNULL(prd_cost, 0) as prd_cost,
		CASE WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain'
			 WHEN UPPER(TRIM(prd_line)) = 'S'THEN 'other Sales'
			 WHEN UPPER(TRIM(prd_line)) = 'R'THEN 'Road'
			 WHEN UPPER(TRIM(prd_line)) = 'T'THEN 'Touring'
			 ELSE 'n/a' 
		END as prd_line, -- Map product line codes to descriptive values
		CAST(prd_start_dt as DATE) as prd_start_dt,
		CAST(LEAD(prd_start_dt)  OVER (PARTITION BY prd_key ORDER BY prd_start_dt)-1 AS DATE) AS  prd_end_dt -- Calculate end date as one day before the next start date
		FROM bronze.crm_prd_info
		SET @end_time = GETDATE();
		PRINT '>> Loading Duration:' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR)+ 'seconds' ;  
		PRINT '-------------------';
		SET @start_time = GETDATE();
		PRINT '>>  Truncating Table: silver.crm_sales_details';
		TRUNCATE TABLE silver.crm_sales_details
		PRINT '>> Inserting Data into: silver.crm_sales_details';

		INSERT INTO silver.crm_sales_details (
			sls_ord_num,
			sls_prd_key,
			sls_cust_id,
			sls_order_dt,
			sls_ship_dt,
			sls_due_dt,
			sls_sales,
			sls_quantity,
			sls_price
		)
		SELECT 
		sls_ord_num,
		sls_prd_key,
		sls_cust_id,
		CASE WHEN sls_order_dt = 0 OR LEN(sls_order_dt) !=  8 THEN NULL
			ELSE CAST(CAST(sls_order_dt as varchar) as DATE)
		END AS sls_order_dt,
		CASE WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) !=  8 THEN NULL
			ELSE CAST(CAST(sls_ship_dt as varchar) as DATE)
		END AS sls_ship_dt,
		CASE WHEN sls_due_dt = 0 OR LEN(sls_due_dt) !=  8 THEN NULL
			ELSE CAST(CAST(sls_due_dt as varchar) as DATE)
		END AS sls_due_dt,
		CASE WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales = sls_quantity * ABS(sls_price)
				THEN sls_quantity * ABS(sls_price)
				ELSE sls_sales
		END AS sls_sales, -- Recalculate sales if the ORIGINAL value is missing or incorrect
		sls_quantity,
		CASE WHEN sls_price < = 0 OR sls_price IS NULL 
			THEN sls_sales / NULLIF(sls_quantity, 0)
			ELSE sls_price
		END AS sls_price -- Derive the price if value is invalid
		FROM bronze.crm_sales_details
		SET @end_time = GETDATE();
		PRINT '>> Loading Duration:' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR)+ 'seconds' ;  
		PRINT '-------------------';
		SET @start_time = GETDATE();
		PRINT '>>  Truncating Table: silver.erp_cust_az12';
		TRUNCATE TABLE silver.erp_cust_az12
		PRINT '>> Inserting Data into: silver.erp_cust_az12';
		INSERT INTO silver.erp_cust_az12 (cid, bdate, gen)

		SELECT
		CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid)) -- Remove 'NAS' prefix if present
			 ELSE cid
		END cid,
		CASE WHEN bdate > GETDATE() THEN NULL
			ELSE bdate
		END AS bdate, -- Set future birthdates to NULL
		CASE WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
			 WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
			 ELSE 'n/a'
		END AS gen -- Normalize gender values and handle unknown cases
		FROM bronze.erp_cust_az12
		SET @end_time = GETDATE();
		PRINT '>> Loading Duration:' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR)+ 'seconds' ;  
		PRINT '-------------------';
		SET @start_time = GETDATE();
		PRINT '>>  Truncating Table: silver.erp_loc_a101';
		TRUNCATE TABLE silver.erp_loc_a101
		PRINT '>> Inserting Data into: silver.erp_loc_a101';
		INSERT INTO silver.erp_loc_a101 ( cid, cntry)

		SELECT
		REPLACE (cid, '-', '') cid,
		CASE WHEN TRIM(cntry) IN  ('US' , 'USA') THEN 'United States'
			 WHEN TRIM(cntry) = 'DE' THEN 'Germany'
			 WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'
			 ELSE TRIM(cntry)
		END AS cntry
		FROM bronze.erp_loc_a101 
		SET @end_time = GETDATE();
		PRINT '>> Loading Duration:' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR)+ 'seconds' ;  
		PRINT '-------------------';
		SET @start_time = GETDATE();
		PRINT '>>  Truncating Table: silver.erp_px_cat_g1v2';
		TRUNCATE TABLE silver.erp_px_cat_g1v2
		PRINT '>> Inserting Data into: silver.erp_px_cat_g1v2';
		INSERT INTO silver.erp_px_cat_g1v2 (id, cat, subcat, maintenance)
		SELECT 
		id,
		cat,
		subcat,
		maintenance
		FROM bronze.erp_px_cat_g1v2
		SET @end_time = GETDATE();
		PRINT '>> Loading Duration:' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR)+ 'seconds' ;  
		PRINT '-------------------';

			END TRY
			BEGIN CATCH
				PRINT '=============================================';
				PRINT 'Error message' + ERROR_MESSAGE();
				PRINT 'Error message' + CAST(ERROR_NUMBER() AS NVARCHAR);
				PRINT 'Error message' + CAST(ERROR_STATE() AS NVARCHAR);
			END CATCH
END
		
EXEC silver.load_silver