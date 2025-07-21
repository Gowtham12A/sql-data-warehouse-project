/*
=================================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
=================================================================
Script Purpose:
This stored procedure loads data into the 'bronze' schema from external CSV files.
It performs the following actions:

Truncates the bronze tables before loading data.

Uses the BULK INSERT command to load data from CSV files to bronze tables.

Parameters:
None.
This stored procedure does not accept any parameters or return any values.

Usage example:
EXEC bronze.load_brone;
=================================================================
*/

CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME ;
	BEGIN TRY
		Print '============================================';
		Print 'Loading bronze layer';
		Print '============================================';

		PRINT '--------------------------------------------';
		PRINT 'Loading CRM tables';
		PRINT '--------------------------------------------';

		SET @start_time = GETDATE();
		PRINT '>> Truncating the table: bronze.crm_cust_info ';
			TRUNCATE TABLE bronze.crm_cust_info;
		PRINT '>> Inserting the data into: bronze.crm_cust_info';
			BULK INSERT bronze.crm_cust_info
			FROM 'G:\Projects\SQL Data with Baraa projects\sql-data-analytics-project\datasets\csv-files\bronze.crm_cust_info.csv'
			WITH (
				FIRSTROW = 2,
				FIELDTERMINATOR = ',',
				TABLOCK
			);
		SET @end_time = GETDATE();
		PRINT '>> Loading Duration:' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR)+ 'seconds' ;  
		PRINT '-------------------';

		SET @start_time = GETDATE();
		PRINT '>> Truncating the table:bronze.crm_prd_info ';
			TRUNCATE TABLE bronze.crm_prd_info;
		PRINT '>> Inserting the data into: bronze.crm_prd_info';
			BULK INSERT bronze.crm_prd_info
			FROM 'G:\Projects\SQL Data with Baraa projects\sql-data-analytics-project\datasets\csv-files\bronze.crm_prd_info.csv'
			WITH (
				FIRSTROW = 2,
				FIELDTERMINATOR = ',',
				TABLOCK
			);
		SET @end_time = GETDATE();
		PRINT '>> Loading Duration:' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR)+ 'seconds' ;  
		PRINT '-------------------';

		SET @start_time = GETDATE();
		PRINT '>> Truncating the table: bronze.crm_sales_details ';
			TRUNCATE TABLE bronze.crm_sales_details;
		PRINT '>> Inserting the data into: bronze.crm_sales_details';
			BULK INSERT bronze.crm_sales_details
			FROM 'G:\Projects\SQL Data with Baraa projects\sql-data-analytics-project\datasets\csv-files\bronze.crm_sales_details.csv'
			WITH (
				FIRSTROW = 2,
				FIELDTERMINATOR = ',',
				TABLOCK
			);
		SET @end_time = GETDATE();
		PRINT '>> Loading Duration:' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR)+ 'seconds' ;  
		PRINT '-------------------';

		SET @start_time = GETDATE();
		PRINT '>> Truncating the table: bronze.erp_loc_a101';
			TRUNCATE TABLE bronze.erp_loc_a101;
		PRINT '>> Inserting the data into: bronze.erp_loc_a101';
			BULK INSERT bronze.erp_loc_a101
			FROM 'G:\Projects\SQL Data with Baraa projects\sql-data-analytics-project\datasets\csv-files\bronze.erp_loc_a101.csv'
			WITH (
				FIRSTROW = 2,
				FIELDTERMINATOR = ',',
				TABLOCK
			);
		SET @end_time = GETDATE();
		PRINT '>> Loading Duration:' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR)+ 'seconds' ;  
		PRINT '-------------------';

		SET @start_time = GETDATE();
		PRINT '>> Truncating the table:bronze.erp_cust_az12';
			TRUNCATE TABLE bronze.erp_cust_az12;
		PRINT '>> Inserting the data into: bronze.erp_cust_az12';
			BULK INSERT bronze.erp_cust_az12
			FROM 'G:\Projects\SQL Data with Baraa projects\sql-data-analytics-project\datasets\csv-files\bronze.erp_cust_az12.csv'
			WITH (
				FIRSTROW = 2,
				FIELDTERMINATOR = ',',
				TABLOCK
			);
		SET @end_time = GETDATE();
		PRINT '>> Loading Duration:' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR)+ 'seconds' ;  
		PRINT '-------------------';

		SET @start_time = GETDATE();
		PRINT '>> Truncating the table: bronze.erp_px_cat_g1v2';
			TRUNCATE TABLE bronze.erp_px_cat_g1v2;
		PRINT '>> Inserting the data into: bronze.erp_px_cat_g1v2';
			BULK INSERT bronze.erp_px_cat_g1v2
			FROM 'G:\Projects\SQL Data with Baraa projects\sql-data-analytics-project\datasets\csv-files\bronze.erp_px_cat_g1v2.csv'
			WITH (
				FIRSTROW = 2,
				FIELDTERMINATOR = ',',
				TABLOCK
			);
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


EXEC bronze.load_bronze


