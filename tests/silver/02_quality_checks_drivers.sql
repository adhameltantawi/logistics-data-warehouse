-- =============================================================
-- Quality Checks: bronze.drivers
-- Purpose : Validate data integrity and readiness for Silver
--           layer transformation before loading.
-- Table   : bronze.drivers
-- =============================================================


-- =============================================================
-- 1. Raw Data Preview
-- =============================================================

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


-- =============================================================
-- 2. Uniqueness & Nulls Checks
-- =============================================================

-- Check for duplicate driver_id
SELECT
    driver_id,
    COUNT(*)
FROM bronze.drivers
GROUP BY driver_id
HAVING COUNT(*) > 1;

-- Check for NULL driver_id (primary key must never be NULL)
SELECT
    driver_id
FROM bronze.drivers
WHERE driver_id IS NULL;


-- =============================================================
-- 3. Name Field Checks
-- =============================================================

-- Check for NULL, empty, or untrimmed first_name
SELECT first_name
FROM bronze.drivers
WHERE first_name != TRIM(first_name) OR first_name IS NULL OR first_name = '';

-- Check for NULL, empty, or untrimmed last_name
SELECT last_name
FROM bronze.drivers
WHERE last_name != TRIM(last_name) OR last_name IS NULL OR last_name = '';


-- =============================================================
-- 4. Date Checks
-- =============================================================

-- Check for NULL hire_date or illogical termination_date (before or same as hire)
SELECT hire_date, termination_date
FROM bronze.drivers
WHERE hire_date IS NULL OR termination_date <= hire_date;

-- Check for NULL date_of_birth
SELECT date_of_birth
FROM bronze.drivers
WHERE date_of_birth IS NULL;

-- Hire date range sanity check
SELECT
    MIN(hire_date),
    MAX(hire_date)
FROM bronze.drivers;


-- =============================================================
-- 5. License Checks
-- =============================================================

-- Inspect distinct license number lengths (to detect format inconsistencies)
SELECT DISTINCT LEN(license_number)
FROM bronze.drivers;

-- Check for NULL, empty, or untrimmed license_number
SELECT license_number
FROM bronze.drivers
WHERE license_number IS NULL OR license_number = '' OR license_number != TRIM(license_number);

-- Check for NULL, empty, or untrimmed license_state
SELECT license_state
FROM bronze.drivers
WHERE license_state != TRIM(license_state) OR license_state IS NULL OR license_state = '';


-- =============================================================
-- 6. Categorical Field Checks
-- =============================================================

-- Review distinct values for home_terminal
SELECT DISTINCT home_terminal
FROM bronze.drivers;

-- Review distinct values for employment_status
SELECT DISTINCT employment_status
FROM bronze.drivers;

-- Review distinct values for cdl_class
SELECT DISTINCT cdl_class
FROM bronze.drivers;


-- =============================================================
-- 7. Numeric & Range Checks
-- =============================================================

-- Flag drivers with zero years of experience (may indicate bad data)
SELECT years_experience
FROM bronze.drivers
WHERE years_experience = 0;

-- Experience range sanity check
SELECT
    MIN(years_experience) AS min_year_of_experience,
    MAX(years_experience) AS max_year_of_experience
FROM bronze.drivers;

-- Birthdate range sanity check
SELECT
    MIN(date_of_birth) AS min_birthdate,
    MAX(date_of_birth) AS max_birthdate
FROM bronze.drivers;


-- =============================================================
-- 8. Row Count
-- =============================================================

SELECT
    COUNT(*) AS total_rows
FROM bronze.drivers;