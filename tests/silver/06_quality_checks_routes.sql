-- =============================================================
-- Quality Checks: bronze.routes
-- Purpose : Validate data integrity and readiness for Silver
--           layer transformation before loading.
-- Table   : bronze.routes
-- =============================================================


-- =============================================================
-- 1. Raw Data Preview
-- =============================================================
SELECT
    route_id,
    origin_city,
    origin_state,
    destination_city,
    destination_state,
    typical_distance_miles,
    base_rate_per_mile,
    fuel_surcharge_rate,
    typical_transit_days
FROM bronze.routes;


-- =============================================================
-- 2. Uniqueness & Nulls Checks
-- =============================================================

-- Check for NULL route_id (primary key must never be NULL)
SELECT route_id
FROM bronze.routes
WHERE route_id IS NULL;

-- Check for duplicate route_id
SELECT
    route_id,
    COUNT(*)
FROM bronze.routes
GROUP BY route_id
HAVING COUNT(*) > 1;


-- =============================================================
-- 3. City & State Field Checks
-- =============================================================

-- Check for NULL, empty, or untrimmed origin_city
SELECT origin_city
FROM bronze.routes
WHERE origin_city IS NULL OR origin_city = '' OR origin_city != TRIM(origin_city);

-- Check for NULL, empty, or untrimmed destination_city
SELECT destination_city
FROM bronze.routes
WHERE destination_city IS NULL OR destination_city = '' OR destination_city != TRIM(destination_city);

-- Check for NULL, empty, or invalid length origin_state
SELECT origin_state
FROM bronze.routes
WHERE origin_state IS NULL OR origin_state = '' OR LEN(TRIM(origin_state)) != 2;

-- Check for NULL, empty, or invalid length destination_state
SELECT destination_state
FROM bronze.routes
WHERE destination_state IS NULL OR destination_state = '' OR LEN(TRIM(destination_state)) != 2;

-- Review distinct origin states
SELECT DISTINCT TRIM(origin_state) AS origin_state
FROM bronze.routes
ORDER BY origin_state;

-- Review distinct destination states
SELECT DISTINCT TRIM(destination_state) AS destination_state
FROM bronze.routes
ORDER BY destination_state;


-- =============================================================
-- 4. Distance & Rate Checks
-- =============================================================

-- Distance range sanity check
SELECT
    MIN(typical_distance_miles) AS min_distance,
    MAX(typical_distance_miles) AS max_distance,
    AVG(typical_distance_miles) AS avg_distance
FROM bronze.routes;

-- Check for NULL or zero/negative distances
SELECT typical_distance_miles
FROM bronze.routes
WHERE typical_distance_miles IS NULL OR typical_distance_miles <= 0;

-- Rate range sanity check
SELECT
    MIN(base_rate_per_mile)  AS min_rate,
    MAX(base_rate_per_mile)  AS max_rate,
    MIN(fuel_surcharge_rate) AS min_surcharge,
    MAX(fuel_surcharge_rate) AS max_surcharge
FROM bronze.routes;

-- Check for negative rates
SELECT base_rate_per_mile, fuel_surcharge_rate
FROM bronze.routes
WHERE base_rate_per_mile < 0 OR fuel_surcharge_rate < 0;


-- =============================================================
-- 5. Transit Days Checks
-- =============================================================

-- Transit days range sanity check
SELECT
    MIN(typical_transit_days) AS min_transit_days,
    MAX(typical_transit_days) AS max_transit_days
FROM bronze.routes;

-- Check for NULL or zero/negative transit days
SELECT typical_transit_days
FROM bronze.routes
WHERE typical_transit_days IS NULL OR typical_transit_days <= 0;


-- =============================================================
-- 6. Duplicate Route Checks (same origin-destination pair)
-- =============================================================

SELECT
    origin_city,
    origin_state,
    destination_city,
    destination_state,
    COUNT(*) AS route_count
FROM bronze.routes
GROUP BY origin_city, origin_state, destination_city, destination_state
HAVING COUNT(*) > 1;


-- =============================================================
-- 7. Row Count
-- =============================================================
SELECT
    COUNT(*) AS total_rows
FROM bronze.routes;
