SELECT
    driver_id,
    first_name,
    last_name,
    hire_date,
    termination_date,
    license_number,
    license_state,
    date_of_birth,
    home_terminal,
    employment_status,
    cdl_class,
    years_experience
FROM bronze.drivers

SELECT
    driver_id,
    COUNT(*)
FROM bronze.drivers
GROUP BY driver_id
HAVING COUNT(*) > 1


SELECT first_name
FROM bronze.drivers
WHERE first_name != TRIM(first_name)