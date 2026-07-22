SELECT
    customer_type,
    COUNT(*) AS customer_type_count
FROM bronze.customers
GROUP BY customer_type
ORDER BY customer_type_count DESC;


SELECT 
    MAX(credit_terms_days) AS max_credit_terms_days,
    MIN(credit_terms_days) AS min_credit_terms_days
FROM bronze.customers


SELECT
    credit_terms_days,
    COUNT(*) AS customer_count
FROM bronze.customers
GROUP BY credit_terms_days
ORDER BY credit_terms_days;