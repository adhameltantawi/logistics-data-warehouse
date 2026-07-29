-- =============================================================
-- Quality Checks: bronze.trips
-- Purpose : Validate data integrity and readiness for Silver
--           layer transformation before loading.
-- Table   : bronze.trips
-- =============================================================


-- =============================================================
-- 1. Raw Data Preview
-- =============================================================
SELECT
    trip_id,
    load_id,
    driver_id,
    truck_id,
    trailer_id,
    dispatch_date,
    actual_distance_miles,
    actual_duration_hours,
    fuel_gallons_used,
    average_mpg,
    idle_time_hours,
    trip_status
FROM bronze.trips;


-- =============================================================
-- 2. Uniqueness & Nulls Checks
-- =============================================================

-- Check for NULL trip_id
SELECT trip_id
FROM bronze.trips
WHERE trip_id IS NULL;

-- Check for duplicate trip_id
SELECT
    trip_id,
    COUNT(*)
FROM bronze.trips
GROUP BY trip_id
HAVING COUNT(*) > 1;


-- =============================================================
-- 3. Foreign Key Checks
-- =============================================================

-- Check for NULL load_id
SELECT load_id
FROM bronze.trips
WHERE load_id IS NULL;

-- Check for NULL driver_id
SELECT driver_id
FROM bronze.trips
WHERE driver_id IS NULL;

-- Check for NULL truck_id
SELECT truck_id
FROM bronze.trips
WHERE truck_id IS NULL;

-- Check for NULL trailer_id
SELECT trailer_id
FROM bronze.trips
WHERE trailer_id IS NULL;


-- =============================================================
-- 4. Categorical Field Checks
-- =============================================================

-- Review distinct trip statuses
SELECT DISTINCT trip_status
FROM bronze.trips;

-- Check for NULL, empty, or untrimmed trip_status
SELECT trip_status
FROM bronze.trips
WHERE trip_status IS NULL OR trip_status = '' OR trip_status != TRIM(trip_status);


-- =============================================================
-- 5. Distance & Duration Checks
-- =============================================================

-- Distance range sanity check
SELECT
    MIN(actual_distance_miles) AS min_distance,
    MAX(actual_distance_miles) AS max_distance,
    AVG(actual_distance_miles) AS avg_distance
FROM bronze.trips;

-- Check for NULL, zero, or negative distance
SELECT actual_distance_miles
FROM bronze.trips
WHERE actual_distance_miles IS NULL OR actual_distance_miles <= 0;

-- Duration range sanity check
SELECT
    MIN(actual_duration_hours) AS min_duration,
    MAX(actual_duration_hours) AS max_duration,
    AVG(actual_duration_hours) AS avg_duration
FROM bronze.trips;

-- Check for negative duration
SELECT actual_duration_hours
FROM bronze.trips
WHERE actual_duration_hours < 0;


-- =============================================================
-- 6. Fuel & MPG Checks
-- =============================================================

-- Fuel range sanity check
SELECT
    MIN(fuel_gallons_used) AS min_fuel,
    MAX(fuel_gallons_used) AS max_fuel,
    AVG(fuel_gallons_used) AS avg_fuel
FROM bronze.trips;

-- Check for negative fuel usage
SELECT fuel_gallons_used
FROM bronze.trips
WHERE fuel_gallons_used < 0;

-- MPG range sanity check
SELECT
    MIN(average_mpg) AS min_mpg,
    MAX(average_mpg) AS max_mpg,
    AVG(average_mpg) AS avg_mpg
FROM bronze.trips;

-- Check for negative or unreasonably high MPG
SELECT average_mpg
FROM bronze.trips
WHERE average_mpg < 0 OR average_mpg > 20;

-- Idle time range check
SELECT
    MIN(idle_time_hours) AS min_idle,
    MAX(idle_time_hours) AS max_idle
FROM bronze.trips;

-- Check for negative idle time
SELECT idle_time_hours
FROM bronze.trips
WHERE idle_time_hours < 0;


-- =============================================================
-- 7. Date Checks
-- =============================================================

-- Dispatch date range sanity check
SELECT
    MIN(dispatch_date) AS min_dispatch_date,
    MAX(dispatch_date) AS max_dispatch_date
FROM bronze.trips;

-- Check for NULL dispatch_date
SELECT dispatch_date
FROM bronze.trips
WHERE dispatch_date IS NULL;


-- =============================================================
-- 8. Row Count
-- =============================================================
SELECT
    COUNT(*) AS total_rows
FROM bronze.trips;
