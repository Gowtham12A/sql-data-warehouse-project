-- Data cleaning

SELECT 
id FROM bronze.erp_px_cat_g1v2

-- Check for unwnated spaces
SELECT * FROM bronze.erp_px_cat_g1v2
WHERE cat! = TRIM(cat) OR subcat! = TRIM(subcat)

-- Data Standardization & Consistency
SELECT DISTINCT
maintenance
FROM bronze.erp_px_cat_g1v2