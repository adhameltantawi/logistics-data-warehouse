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
FROM bronze.drivers;

SELECT
    driver_id,
    COUNT(*)
FROM bronze.drivers
GROUP BY driver_id
HAVING COUNT(*) > 1 OR driver_id IS NULL; 


SELECT first_name
FROM bronze.drivers
WHERE first_name != TRIM(first_name) OR first_name IS NULL OR first_name = '';

SELECT last_name
FROM bronze.drivers
WHERE last_name != TRIM(last_name) OR last_name IS NULL OR last_name = '';

SELECT hire_date, termination_date
FROM bronze.drivers
WHERE hire_date IS NULL OR termination_date <= hire_date

SELECT license_number
FROM bronze.drivers
WHERE LEN(license_number) != 11 OR license_number IS NULL