-- =============================================================
-- Quality Checks: bronze.trucks
-- Purpose : Validate data integrity and readiness for Silver
--           layer transformation before loading.
-- Table   : bronze.trucks
-- =============================================================


-- =============================================================
-- 1. Raw Data Preview
-- =============================================================
SELECT
    truck_id,
    unit_number,
    make,
    model_year,
    vin,
    acquisition_date,
    acquisition_mileage,
    fuel_type,
    tank_capacity_gallons,
    status,
    home_terminal
FROM bronze.trucks;


-- =============================================================
-- 2. Uniqueness & Nulls Checks
-- =============================================================

-- Check for NULL truck_id (primary key must never be NULL)
SELECT truck_id
FROM bronze.trucks
WHERE truck_id IS NULL;

-- Check for duplicate truck_id
SELECT
    truck_id,
    COUNT(*)
FROM bronze.trucks
GROUP BY truck_id
HAVING COUNT(*) > 1;


-- =============================================================
-- 3. String Field Checks
-- =============================================================

-- Check for NULL, empty, or untrimmed make
SELECT make
FROM bronze.trucks
WHERE make IS NULL OR make = '' OR make != TRIM(make);

-- Review distinct makes
SELECT DISTINCT make
FROM bronze.trucks;

-- Review distinct fuel types
SELECT DISTINCT fuel_type
FROM bronze.trucks;

-- Check for NULL, empty, or untrimmed fuel_type
SELECT fuel_type
FROM bronze.trucks
WHERE fuel_type IS NULL OR fuel_type = '' OR fuel_type != TRIM(fuel_type);

-- Review distinct statuses
SELECT DISTINCT status
FROM bronze.trucks;

-- Review distinct home terminals
SELECT DISTINCT home_terminal
FROM bronze.trucks;


-- =============================================================
-- 4. VIN Checks
-- =============================================================

-- Check for NULL or empty VIN
SELECT vin
FROM bronze.trucks
WHERE vin IS NULL OR vin = '';

-- Check for duplicate VINs (should be unique per truck)
SELECT
    vin,
    COUNT(*) AS cnt
FROM bronze.trucks
GROUP BY vin
HAVING COUNT(*) > 1;

-- VIN length distribution
SELECT DISTINCT LEN(vin) AS vin_length
FROM bronze.trucks;


-- =============================================================
-- 5. Numeric & Range Checks
-- =============================================================

-- Model year range sanity check
SELECT
    MIN(model_year) AS min_model_year,
    MAX(model_year) AS max_model_year
FROM bronze.trucks;

-- Check for unreasonable model years
SELECT model_year
FROM bronze.trucks
WHERE model_year IS NULL OR model_year < 1990 OR model_year > 2030;

-- Acquisition mileage range check
SELECT
    MIN(acquisition_mileage) AS min_mileage,
    MAX(acquisition_mileage) AS max_mileage
FROM bronze.trucks;

-- Check for negative acquisition mileage
SELECT acquisition_mileage
FROM bronze.trucks
WHERE acquisition_mileage < 0;

-- Tank capacity range check
SELECT
    MIN(tank_capacity_gallons) AS min_tank,
    MAX(tank_capacity_gallons) AS max_tank
FROM bronze.trucks;

-- Check for invalid tank capacity
SELECT tank_capacity_gallons
FROM bronze.trucks
WHERE tank_capacity_gallons IS NULL OR tank_capacity_gallons <= 0;


-- =============================================================
-- 6. Date Checks
-- =============================================================

-- Acquisition date range sanity check
SELECT
    MIN(acquisition_date) AS min_acq_date,
    MAX(acquisition_date) AS max_acq_date
FROM bronze.trucks;

-- Check for NULL acquisition_date
SELECT acquisition_date
FROM bronze.trucks
WHERE acquisition_date IS NULL;

-- Check for future acquisition dates
SELECT acquisition_date
FROM bronze.trucks
WHERE acquisition_date > GETDATE();


-- =============================================================
-- 7. Row Count
-- =============================================================
SELECT
    COUNT(*) AS total_rows
FROM bronze.trucks;
