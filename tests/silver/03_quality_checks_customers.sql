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
    customer_type,
    COUNT(*) AS customer_type_count
FROM bronze.customers
GROUP BY customer_type
HAVING COUNT(DISTINCT customer_type) > 1; 


SELECT 
    customer_type
FROM bronze.customers
WHERE customer_type != TRIM(customer_type)

