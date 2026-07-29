-- =============================================================
-- Quality Checks: bronze.trailers
-- Purpose : Validate data integrity and readiness for Silver
--           layer transformation before loading.
-- Table   : bronze.trailers
-- =============================================================


-- =============================================================
-- 1. Raw Data Preview
-- =============================================================
SELECT
    trailer_id,
    trailer_number,
    trailer_type,
    length_feet,
    model_year,
    vin,
    acquisition_date,
    status,
    current_location
FROM bronze.trailers;


-- =============================================================
-- 2. Uniqueness & Nulls Checks
-- =============================================================

-- Check for NULL trailer_id (primary key must never be NULL)
SELECT trailer_id
FROM bronze.trailers
WHERE trailer_id IS NULL;

-- Check for duplicate trailer_id
SELECT
    trailer_id,
    COUNT(*)
FROM bronze.trailers
GROUP BY trailer_id
HAVING COUNT(*) > 1;


-- =============================================================
-- 3. Trailer Type & Status Checks
-- =============================================================

-- Review distinct trailer types
SELECT DISTINCT trailer_type
FROM bronze.trailers;

-- Check for NULL, empty, or untrimmed trailer_type
SELECT trailer_type
FROM bronze.trailers
WHERE trailer_type IS NULL OR trailer_type = '' OR trailer_type != TRIM(trailer_type);

-- Review distinct statuses
SELECT DISTINCT status
FROM bronze.trailers;

-- Check for NULL, empty, or untrimmed status
SELECT status
FROM bronze.trailers
WHERE status IS NULL OR status = '' OR status != TRIM(status);


-- =============================================================
-- 4. VIN Checks
-- =============================================================

-- Check for NULL or empty VIN
SELECT vin
FROM bronze.trailers
WHERE vin IS NULL OR vin = '';

-- Check for duplicate VINs (should be unique per trailer)
SELECT
    vin,
    COUNT(*) AS cnt
FROM bronze.trailers
GROUP BY vin
HAVING COUNT(*) > 1;

-- VIN length distribution
SELECT DISTINCT LEN(vin) AS vin_length
FROM bronze.trailers;


-- =============================================================
-- 5. Numeric & Range Checks
-- =============================================================

-- Length feet range sanity check
SELECT
    MIN(length_feet) AS min_length,
    MAX(length_feet) AS max_length
FROM bronze.trailers;

-- Check for NULL or invalid length_feet
SELECT length_feet
FROM bronze.trailers
WHERE length_feet IS NULL OR length_feet <= 0;

-- Model year range sanity check
SELECT
    MIN(model_year) AS min_model_year,
    MAX(model_year) AS max_model_year
FROM bronze.trailers;

-- Check for unreasonable model years
SELECT model_year
FROM bronze.trailers
WHERE model_year IS NULL OR model_year < 1990 OR model_year > 2030;

-- Trailer number range check
SELECT
    MIN(trailer_number) AS min_trailer_num,
    MAX(trailer_number) AS max_trailer_num
FROM bronze.trailers;


-- =============================================================
-- 6. Date Checks
-- =============================================================

-- Acquisition date range sanity check
SELECT
    MIN(acquisition_date) AS min_acq_date,
    MAX(acquisition_date) AS max_acq_date
FROM bronze.trailers;

-- Check for NULL acquisition_date
SELECT acquisition_date
FROM bronze.trailers
WHERE acquisition_date IS NULL;

-- Check for future acquisition dates
SELECT acquisition_date
FROM bronze.trailers
WHERE acquisition_date > GETDATE();


-- =============================================================
-- 7. Current Location Checks
-- =============================================================

-- Review distinct locations
SELECT DISTINCT current_location
FROM bronze.trailers;

-- Check for NULL or untrimmed current_location
SELECT current_location
FROM bronze.trailers
WHERE current_location IS NULL OR current_location = '' OR current_location != TRIM(current_location);


-- =============================================================
-- 8. Row Count
-- =============================================================
SELECT
    COUNT(*) AS total_rows
FROM bronze.trailers;
