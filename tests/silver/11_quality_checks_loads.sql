-- =============================================================
-- Quality Checks: bronze.loads
-- Purpose : Validate data integrity and readiness for Silver
--           layer transformation before loading.
-- Table   : bronze.loads
-- =============================================================


-- =============================================================
-- 1. Raw Data Preview
-- =============================================================
SELECT
    load_id,
    customer_id,
    route_id,
    load_date,
    load_type,
    weight_lbs,
    pieces,
    revenue,
    fuel_surcharge,
    accessorial_charges,
    load_status,
    booking_type
FROM bronze.loads;


-- =============================================================
-- 2. Uniqueness & Nulls Checks
-- =============================================================

-- Check for NULL load_id
SELECT load_id
FROM bronze.loads
WHERE load_id IS NULL;

-- Check for duplicate load_id
SELECT
    load_id,
    COUNT(*)
FROM bronze.loads
GROUP BY load_id
HAVING COUNT(*) > 1;


-- =============================================================
-- 3. Foreign Key Checks
-- =============================================================

-- Check for NULL customer_id
SELECT customer_id
FROM bronze.loads
WHERE customer_id IS NULL;

-- Check for NULL route_id
SELECT route_id
FROM bronze.loads
WHERE route_id IS NULL;


-- =============================================================
-- 4. Categorical Field Checks
-- =============================================================

-- Review distinct load types
SELECT DISTINCT load_type
FROM bronze.loads;

-- Check for NULL, empty, or untrimmed load_type
SELECT load_type
FROM bronze.loads
WHERE load_type IS NULL OR load_type = '' OR load_type != TRIM(load_type);

-- Review distinct load statuses
SELECT DISTINCT load_status
FROM bronze.loads;

-- Check for NULL, empty, or untrimmed load_status
SELECT load_status
FROM bronze.loads
WHERE load_status IS NULL OR load_status = '' OR load_status != TRIM(load_status);

-- Review distinct booking types
SELECT DISTINCT booking_type
FROM bronze.loads;

-- Check for NULL, empty, or untrimmed booking_type
SELECT booking_type
FROM bronze.loads
WHERE booking_type IS NULL OR booking_type = '' OR booking_type != TRIM(booking_type);


-- =============================================================
-- 5. Weight & Pieces Checks
-- =============================================================

-- Weight range sanity check
SELECT
    MIN(weight_lbs) AS min_weight,
    MAX(weight_lbs) AS max_weight,
    AVG(weight_lbs) AS avg_weight
FROM bronze.loads;

-- Check for NULL, zero, or negative weight
SELECT weight_lbs
FROM bronze.loads
WHERE weight_lbs IS NULL OR weight_lbs <= 0;

-- Pieces range sanity check
SELECT
    MIN(pieces) AS min_pieces,
    MAX(pieces) AS max_pieces
FROM bronze.loads;

-- Check for NULL, zero, or negative pieces
SELECT pieces
FROM bronze.loads
WHERE pieces IS NULL OR pieces <= 0;


-- =============================================================
-- 6. Revenue & Charges Checks
-- =============================================================

-- Revenue range sanity check
SELECT
    MIN(revenue)             AS min_revenue,
    MAX(revenue)             AS max_revenue,
    AVG(revenue)             AS avg_revenue,
    MIN(fuel_surcharge)      AS min_surcharge,
    MAX(fuel_surcharge)      AS max_surcharge,
    MIN(accessorial_charges) AS min_accessorial,
    MAX(accessorial_charges) AS max_accessorial
FROM bronze.loads;

-- Check for negative revenue
SELECT revenue
FROM bronze.loads
WHERE revenue < 0;

-- Check for negative fuel_surcharge
SELECT fuel_surcharge
FROM bronze.loads
WHERE fuel_surcharge < 0;

-- Check for negative accessorial_charges
SELECT accessorial_charges
FROM bronze.loads
WHERE accessorial_charges < 0;


-- =============================================================
-- 7. Date Checks
-- =============================================================

-- Load date range sanity check
SELECT
    MIN(load_date) AS min_load_date,
    MAX(load_date) AS max_load_date
FROM bronze.loads;

-- Check for NULL load_date
SELECT load_date
FROM bronze.loads
WHERE load_date IS NULL;


-- =============================================================
-- 8. Row Count
-- =============================================================
SELECT
    COUNT(*) AS total_rows
FROM bronze.loads;
