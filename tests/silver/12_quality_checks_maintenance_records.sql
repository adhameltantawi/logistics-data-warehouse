-- =============================================================
-- Quality Checks: bronze.maintenance_records
-- Purpose : Validate data integrity and readiness for Silver
--           layer transformation before loading.
-- Table   : bronze.maintenance_records
-- =============================================================


-- =============================================================
-- 1. Raw Data Preview
-- =============================================================
SELECT
    maintenance_id,
    truck_id,
    maintenance_date,
    maintenance_type,
    odometer_reading,
    labor_hours,
    labor_cost,
    parts_cost,
    total_cost,
    facility_location,
    downtime_hours,
    service_description
FROM bronze.maintenance_records;


-- =============================================================
-- 2. Uniqueness & Nulls Checks
-- =============================================================

-- Check for NULL maintenance_id
SELECT maintenance_id
FROM bronze.maintenance_records
WHERE maintenance_id IS NULL;

-- Check for duplicate maintenance_id
SELECT
    maintenance_id,
    COUNT(*)
FROM bronze.maintenance_records
GROUP BY maintenance_id
HAVING COUNT(*) > 1;


-- =============================================================
-- 3. Foreign Key Checks
-- =============================================================

-- Check for NULL truck_id
SELECT truck_id
FROM bronze.maintenance_records
WHERE truck_id IS NULL;


-- =============================================================
-- 4. Categorical Field Checks
-- =============================================================

-- Review distinct maintenance types
SELECT DISTINCT maintenance_type
FROM bronze.maintenance_records;

-- Check for NULL, empty, or untrimmed maintenance_type
SELECT maintenance_type
FROM bronze.maintenance_records
WHERE maintenance_type IS NULL OR maintenance_type = '' OR maintenance_type != TRIM(maintenance_type);

-- Check for NULL, empty, or untrimmed facility_location
SELECT facility_location
FROM bronze.maintenance_records
WHERE facility_location IS NULL OR facility_location = '' OR facility_location != TRIM(facility_location);

-- Check for NULL, empty, or untrimmed service_description
SELECT service_description
FROM bronze.maintenance_records
WHERE service_description IS NULL OR service_description = '' OR service_description != TRIM(service_description);


-- =============================================================
-- 5. Numeric & Cost Checks
-- =============================================================

-- Odometer reading range sanity check
SELECT
    MIN(odometer_reading) AS min_odometer,
    MAX(odometer_reading) AS max_odometer
FROM bronze.maintenance_records;

-- Check for negative odometer readings
SELECT odometer_reading
FROM bronze.maintenance_records
WHERE odometer_reading < 0;

-- Labor hours range check
SELECT
    MIN(labor_hours) AS min_labor_hrs,
    MAX(labor_hours) AS max_labor_hrs
FROM bronze.maintenance_records;

-- Check for negative labor hours
SELECT labor_hours
FROM bronze.maintenance_records
WHERE labor_hours < 0;

-- Cost range sanity check
SELECT
    MIN(labor_cost) AS min_labor_cost,
    MAX(labor_cost) AS max_labor_cost,
    MIN(parts_cost) AS min_parts_cost,
    MAX(parts_cost) AS max_parts_cost,
    MIN(total_cost) AS min_total_cost,
    MAX(total_cost) AS max_total_cost
FROM bronze.maintenance_records;

-- Check for negative costs
SELECT labor_cost, parts_cost, total_cost
FROM bronze.maintenance_records
WHERE labor_cost < 0 OR parts_cost < 0 OR total_cost < 0;

-- Verify total_cost ≈ labor_cost + parts_cost
SELECT
    maintenance_id,
    labor_cost,
    parts_cost,
    total_cost,
    (labor_cost + parts_cost) AS calculated_total,
    ABS(total_cost - (labor_cost + parts_cost)) AS cost_diff
FROM bronze.maintenance_records
WHERE ABS(total_cost - (labor_cost + parts_cost)) > 1;

-- Downtime hours range check
SELECT
    MIN(downtime_hours) AS min_downtime,
    MAX(downtime_hours) AS max_downtime
FROM bronze.maintenance_records;

-- Check for negative downtime
SELECT downtime_hours
FROM bronze.maintenance_records
WHERE downtime_hours < 0;


-- =============================================================
-- 6. Date Checks
-- =============================================================

-- Maintenance date range sanity check
SELECT
    MIN(maintenance_date) AS min_maint_date,
    MAX(maintenance_date) AS max_maint_date
FROM bronze.maintenance_records;

-- Check for NULL maintenance_date
SELECT maintenance_date
FROM bronze.maintenance_records
WHERE maintenance_date IS NULL;


-- =============================================================
-- 7. Row Count
-- =============================================================
SELECT
    COUNT(*) AS total_rows
FROM bronze.maintenance_records;
