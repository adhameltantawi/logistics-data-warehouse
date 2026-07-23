-- =============================================================
-- Quality Checks: bronze.customers
-- Purpose : Validate data integrity and readiness for Silver
--           layer transformation before loading.
-- Table   : bronze.customers
-- =============================================================

-- =============================================================
-- 1. Raw Data Preview
-- =============================================================
SELECT
    customer_id,
    customer_name,
    customer_type,
    credit_terms_days,
    primary_freight_type,
    account_status,
    contract_start_date,
    annual_revenue_potential
FROM bronze.customers;

-- =============================================================
-- 2. Uniqueness & Nulls Checks
-- =============================================================
-- Check for NULL customer_id (primary key must never be NULL)
SELECT customer_id
FROM bronze.customers
WHERE customer_id IS NULL;

-- Check for duplicate customer_id
SELECT 
    customer_id,
    COUNT(*)
FROM bronze.customers
GROUP BY customer_id
HAVING COUNT(*) > 1;

-- =============================================================
-- 3. Customer Name Checks
-- =============================================================
-- Check for untrimmed customer_name (leading/trailing spaces)
SELECT 
    customer_name
FROM bronze.customers
WHERE customer_name != TRIM(customer_name);

-- Check for the same customer_name mapped to multiple customer_ids
-- (possible duplicate customer records under different IDs)
SELECT
    customer_name,
    COUNT(DISTINCT customer_id) AS customer_count
FROM bronze.customers
GROUP BY customer_name
HAVING COUNT(DISTINCT customer_id) > 1;

-- Spot-check a specific customer record
SELECT *
FROM bronze.customers
WHERE customer_name = 'ABC Corp';

-- =============================================================
-- 4. Customer Type Checks
-- =============================================================
-- Review distinct values for customer_type
SELECT DISTINCT customer_type
FROM bronze.customers;

-- Check for NULL, empty, or untrimmed customer_type
SELECT 
    customer_type
FROM bronze.customers
WHERE customer_type != TRIM(customer_type)
   OR customer_type IS NULL
   OR customer_type = '';

-- =============================================================
-- 5. Credit Terms Checks
-- =============================================================
-- Check for NULL credit_terms_days
SELECT credit_terms_days
FROM bronze.customers
WHERE credit_terms_days IS NULL;

-- Check for credit_terms_days outside expected standard values
SELECT credit_terms_days
FROM bronze.customers
WHERE credit_terms_days NOT IN (0,15,30,45,60,90);

-- =============================================================
-- 6. Freight Type Checks
-- =============================================================
-- Check for NULL, empty, or untrimmed primary_freight_type
SELECT primary_freight_type
FROM bronze.customers
WHERE primary_freight_type != TRIM(primary_freight_type)
   OR primary_freight_type IS NULL
   OR primary_freight_type = ''; 

-- Review distinct values for primary_freight_type
SELECT DISTINCT primary_freight_type
FROM bronze.customers;

-- =============================================================
-- 7. Account Status Checks
-- =============================================================
-- Check for NULL, empty, or untrimmed account_status
SELECT account_status
FROM bronze.customers
WHERE account_status != TRIM(account_status)
   OR account_status IS NULL
   OR account_status = '';

-- Review distinct values for account_status
SELECT DISTINCT account_status
FROM bronze.customers;

-- =============================================================
-- 8. Contract Start Date Checks
-- =============================================================
-- Check for NULL or blank contract_start_date
SELECT contract_start_date
FROM bronze.customers
WHERE contract_start_date IS NULL
   OR contract_start_date = '';

-- Check for future-dated contract_start_date (should not be after today)
SELECT contract_start_date
FROM bronze.customers
WHERE contract_start_date > GETDATE();

-- Check for suspiciously old contract_start_date (possible bad data)
SELECT *
FROM bronze.customers
WHERE contract_start_date < '2000-01-01';

-- Contract start date range sanity check
SELECT 
    MIN(contract_start_date) AS min_contract_start_date,
    MAX(contract_start_date) AS max_contract_start_date
FROM bronze.customers;

-- =============================================================
-- 9. Annual Revenue Potential Checks
-- =============================================================
-- Revenue range sanity check
SELECT 
    MAX(annual_revenue_potential) AS max_annual_revenue_potential,
    MIN(annual_revenue_potential) AS min_annual_revenue_potential
FROM bronze.customers;

-- Check for NULL annual_revenue_potential
SELECT annual_revenue_potential
FROM bronze.customers
WHERE annual_revenue_potential IS NULL;

-- =============================================================
-- 10. Row Count
-- =============================================================
SELECT
    COUNT(*) AS total_rows
FROM bronze.customers;