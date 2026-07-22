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


SELECT customer_id
FROM bronze.customers
WHERE customer_id IS NULL;


SELECT 
    customer_id,
    COUNT(*)
FROM bronze.customers
GROUP BY customer_id
HAVING COUNT(*) > 1;


SELECT 
    customer_name
FROM bronze.customers
WHERE customer_name != TRIM(customer_name);


SELECT
    customer_name,
    COUNT(DISTINCT customer_id) AS customer_count
FROM bronze.customers
GROUP BY customer_name
HAVING COUNT(DISTINCT customer_id) > 1;


SELECT *
FROM bronze.customers
WHERE customer_name = 'ABC Corp';


SELECT DISTINCT customer_type
FROM bronze.customers


SELECT 
    customer_type
FROM bronze.customers
WHERE customer_type != TRIM(customer_type)
   OR customer_type IS NULL
   OR customer_type = '';


SELECT credit_terms_days
FROM bronze.customers
WHERE credit_terms_days IS NULL
   OR credit_terms_days = '';


SELECT primary_freight_type
FROM bronze.customers
WHERE primary_freight_type != TRIM(primary_freight_type)
   OR primary_freight_type IS NULL
   OR primary_freight_type = ''; 


SELECT DISTINCT primary_freight_type
FROM bronze.customers;


SELECT account_status
FROM bronze.customers
WHERE account_status != TRIM(account_status)
   OR account_status IS NULL
   OR account_status = '';


SELECT DISTINCT account_status
FROM bronze.customers;


SELECT contract_start_date
FROM bronze.customers
WHERE contract_start_date IS NULL
   OR contract_start_date = '';


SELECT contract_start_date
FROM bronze.customers
WHERE contract_start_date > GETDATE();


SELECT *
FROM bronze.customers
WHERE contract_start_date < '2000-01-01';


SELECT 
    MIN(contract_start_date) AS min_contract_start_date,
    MAX(contract_start_date) AS max_contract_start_date
FROM bronze.customers;


SELECT 
    MAX(annual_revenue_potential) AS max_annual_revenue_potential,
    MIN(annual_revenue_potential) AS min_annual_revenue_potential
FROM bronze.customers