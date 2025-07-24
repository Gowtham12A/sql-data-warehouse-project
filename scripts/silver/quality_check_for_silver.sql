/*
===============================================================
Quality Checks
===============================================================

Script Purpose:
    This script performs various quality checks for data consistency, accuracy, 
    and standardization across the 'silver' schema. It includes checks for:
    - Null or duplicate primary keys.
    - Unwanted spaces in string fields.
    - Data standardization and consistency.
    - Invalid date ranges and orders.
    - Data consistency between related fields.

Usage Notes:
    - Run these checks after data loading Silver Layer.
    - Investigate and resolve any discrepancies found during the checks.
===============================================================
*/
===============================================================
-- Checking for silver.crm_cust_info
===============================================================
-- Check for NULLS on Duplicates in Primary key
===============================================================
