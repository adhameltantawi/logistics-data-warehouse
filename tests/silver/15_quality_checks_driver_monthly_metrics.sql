-- =============================================================
-- Quality Checks: bronze.driver_monthly_metrics
-- Purpose : Validate data integrity and readiness for Silver
--           layer transformation before loading.
-- Table   : bronze.driver_monthly_metrics
-- =============================================================


-- =============================================================
-- 1. Raw Data Preview
-- =============================================================
SELECT
    driver_id,
    month,
    trips_completed,
    total_miles,
    total_revenue,
    average_mpg,
    total_fuel_gallons,
    on_time_delivery_rate,
    average_idle_hours
FROM bronze.driver_monthly_metrics;


-- =============================================================
-- 2. Uniqueness & Nulls Checks (Composite Key: driver_id + month)
-- =============================================================

-- Check for NULL driver_id
SELECT driver_id
FROM bronze.driver_monthly_metrics
WHERE driver_id IS NULL;

-- Check for NULL month
SELECT month
FROM bronze.driver_monthly_metrics
WHERE month IS NULL;

-- Check for duplicate (driver_id, month) combinations
SELECT
    driver_id,
    month,
    COUNT(*)
FROM bronze.driver_monthly_metrics
GROUP BY driver_id, month
HAVING COUNT(*) > 1;


-- =============================================================
-- 3. Month/Date Checks
-- =============================================================

-- Month range sanity check
SELECT
    MIN(month) AS min_month,
    MAX(month) AS max_month
FROM bronze.driver_monthly_metrics;

-- Verify all months are the 1st of a month (expected for monthly snapshots)
SELECT DISTINCT DAY(month) AS day_of_month
FROM bronze.driver_monthly_metrics;


-- =============================================================
-- 4. Numeric Range Checks
-- =============================================================

-- Trips completed range check
SELECT
    MIN(trips_completed) AS min_trips,
    MAX(trips_completed) AS max_trips
FROM bronze.driver_monthly_metrics;

-- Check for negative trips
SELECT trips_completed
FROM bronze.driver_monthly_metrics
WHERE trips_completed < 0;

-- Total miles range check
SELECT
    MIN(total_miles) AS min_miles,
    MAX(total_miles) AS max_miles
FROM bronze.driver_monthly_metrics;

-- Check for negative miles
SELECT total_miles
FROM bronze.driver_monthly_metrics
WHERE total_miles < 0;

-- Revenue range check
SELECT
    MIN(total_revenue) AS min_revenue,
    MAX(total_revenue) AS max_revenue
FROM bronze.driver_monthly_metrics;

-- Check for negative revenue
SELECT total_revenue
FROM bronze.driver_monthly_metrics
WHERE total_revenue < 0;

-- MPG range check
SELECT
    MIN(average_mpg) AS min_mpg,
    MAX(average_mpg) AS max_mpg
FROM bronze.driver_monthly_metrics;

-- Fuel gallons range check
SELECT
    MIN(total_fuel_gallons) AS min_fuel,
    MAX(total_fuel_gallons) AS max_fuel
FROM bronze.driver_monthly_metrics;

-- Check for negative fuel
SELECT total_fuel_gallons
FROM bronze.driver_monthly_metrics
WHERE total_fuel_gallons < 0;


-- =============================================================
-- 5. Rate & Hours Checks
-- =============================================================

-- On-time delivery rate range check (should be 0 to 1)
SELECT
    MIN(on_time_delivery_rate) AS min_otd_rate,
    MAX(on_time_delivery_rate) AS max_otd_rate
FROM bronze.driver_monthly_metrics;

-- Check for out-of-range on_time_delivery_rate
SELECT on_time_delivery_rate
FROM bronze.driver_monthly_metrics
WHERE on_time_delivery_rate < 0 OR on_time_delivery_rate > 1;

-- Average idle hours range check
SELECT
    MIN(average_idle_hours) AS min_idle,
    MAX(average_idle_hours) AS max_idle
FROM bronze.driver_monthly_metrics;

-- Check for negative idle hours
SELECT average_idle_hours
FROM bronze.driver_monthly_metrics
WHERE average_idle_hours < 0;


-- =============================================================
-- 6. Row Count
-- =============================================================
SELECT
    COUNT(*) AS total_rows
FROM bronze.driver_monthly_metrics;
