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
HAVING COUNT(*) > 1; 

SELECT
    driver_id
FROM bronze.drivers
WHERE driver_id IS NULL; 


SELECT first_name
FROM bronze.drivers
WHERE first_name != TRIM(first_name) OR first_name IS NULL OR first_name = '';

SELECT last_name
FROM bronze.drivers
WHERE last_name != TRIM(last_name) OR last_name IS NULL OR last_name = '';


SELECT hire_date, termination_date
FROM bronze.drivers
WHERE hire_date IS NULL OR termination_date <= hire_date;

SELECT DISTINCT LEN(license_number)
FROM bronze.drivers;

SELECT license_number
FROM bronze.drivers
WHERE license_number IS NULL OR license_number = '' OR license_number != TRIM(license_number);


SELECT license_state
FROM bronze.drivers
WHERE license_state != TRIM(license_state) OR license_state IS NULL OR license_state = '';



SELECT date_of_birth
FROM bronze.drivers
WHERE date_of_birth IS NULL;

SELECT DISTINCT home_terminal 
FROM bronze.drivers;

SELECT DISTINCT employment_status
FROM bronze.drivers;

SELECT DISTINCT cdl_class
FROM bronze.drivers;

SELECT years_experience
FROM bronze.drivers
WHERE years_experience = 0;


SELECT
    COUNT(*) AS total_rows
FROM bronze.drivers;


SELECT
    MIN(date_of_birth) AS min_birthdate,
    MAX(date_of_birth) AS max_birthdate
FROM bronze.drivers;

SELECT
    MIN(years_experience) AS min_year_of_experience,
    MAX(years_experience) AS max_year_of_experience
FROM bronze.drivers;

