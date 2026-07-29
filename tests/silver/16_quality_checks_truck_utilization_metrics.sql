-- =============================================================
-- Quality Checks: bronze.truck_utilization_metrics
-- Purpose : Validate data integrity and readiness for Silver
--           layer transformation before loading.
-- Table   : bronze.truck_utilization_metrics
-- =============================================================


-- =============================================================
-- 1. Raw Data Preview
-- =============================================================
SELECT
    truck_id,
    month,
    trips_completed,
    total_miles,
    total_revenue,
    average_mpg,
    maintenance_events,
    maintenance_cost,
    downtime_hours,
    utilization_rate
FROM bronze.truck_utilization_metrics;


-- =============================================================
-- 2. Uniqueness & Nulls Checks (Composite Key: truck_id + month)
-- =============================================================

-- Check for NULL truck_id
SELECT truck_id
FROM bronze.truck_utilization_metrics
WHERE truck_id IS NULL;

-- Check for NULL month
SELECT month
FROM bronze.truck_utilization_metrics
WHERE month IS NULL;

-- Check for duplicate (truck_id, month) combinations
SELECT
    truck_id,
    month,
    COUNT(*)
FROM bronze.truck_utilization_metrics
GROUP BY truck_id, month
HAVING COUNT(*) > 1;


-- =============================================================
-- 3. Month/Date Checks
-- =============================================================

-- Month range sanity check
SELECT
    MIN(month) AS min_month,
    MAX(month) AS max_month
FROM bronze.truck_utilization_metrics;


-- =============================================================
-- 4. Numeric Range Checks
-- =============================================================

-- Trips completed range check
SELECT
    MIN(trips_completed) AS min_trips,
    MAX(trips_completed) AS max_trips
FROM bronze.truck_utilization_metrics;

-- Check for negative trips
SELECT trips_completed
FROM bronze.truck_utilization_metrics
WHERE trips_completed < 0;

-- Total miles range check
SELECT
    MIN(total_miles) AS min_miles,
    MAX(total_miles) AS max_miles
FROM bronze.truck_utilization_metrics;

-- Check for negative miles
SELECT total_miles
FROM bronze.truck_utilization_metrics
WHERE total_miles < 0;

-- Revenue range check
SELECT
    MIN(total_revenue) AS min_revenue,
    MAX(total_revenue) AS max_revenue
FROM bronze.truck_utilization_metrics;

-- Check for negative revenue
SELECT total_revenue
FROM bronze.truck_utilization_metrics
WHERE total_revenue < 0;

-- MPG range check
SELECT
    MIN(average_mpg) AS min_mpg,
    MAX(average_mpg) AS max_mpg
FROM bronze.truck_utilization_metrics;


-- =============================================================
-- 5. Maintenance & Utilization Checks
-- =============================================================

-- Maintenance events range check
SELECT
    MIN(maintenance_events) AS min_maint_events,
    MAX(maintenance_events) AS max_maint_events
FROM bronze.truck_utilization_metrics;

-- Check for negative maintenance events
SELECT maintenance_events
FROM bronze.truck_utilization_metrics
WHERE maintenance_events < 0;

-- Maintenance cost range check
SELECT
    MIN(maintenance_cost) AS min_maint_cost,
    MAX(maintenance_cost) AS max_maint_cost
FROM bronze.truck_utilization_metrics;

-- Check for negative maintenance cost
SELECT maintenance_cost
FROM bronze.truck_utilization_metrics
WHERE maintenance_cost < 0;

-- Downtime hours range check
SELECT
    MIN(downtime_hours) AS min_downtime,
    MAX(downtime_hours) AS max_downtime
FROM bronze.truck_utilization_metrics;

-- Check for negative downtime
SELECT downtime_hours
FROM bronze.truck_utilization_metrics
WHERE downtime_hours < 0;

-- Utilization rate range check (should be 0 to 1)
SELECT
    MIN(utilization_rate) AS min_util_rate,
    MAX(utilization_rate) AS max_util_rate
FROM bronze.truck_utilization_metrics;

-- Check for out-of-range utilization_rate
SELECT utilization_rate
FROM bronze.truck_utilization_metrics
WHERE utilization_rate < 0 OR utilization_rate > 1;


-- =============================================================
-- 6. Row Count
-- =============================================================
SELECT
    COUNT(*) AS total_rows
FROM bronze.truck_utilization_metrics;
