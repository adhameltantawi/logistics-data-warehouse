-- =============================================================
-- Quality Checks: bronze.delivery_events
-- Purpose : Validate data integrity and readiness for Silver
--           layer transformation before loading.
-- Table   : bronze.delivery_events
-- =============================================================


-- =============================================================
-- 1. Raw Data Preview
-- =============================================================
SELECT
    event_id,
    load_id,
    trip_id,
    event_type,
    facility_id,
    scheduled_datetime,
    actual_datetime,
    detention_minutes,
    on_time_flag,
    location_city,
    location_state
FROM bronze.delivery_events;


-- =============================================================
-- 2. Uniqueness & Nulls Checks
-- =============================================================

-- Check for NULL event_id (primary key must never be NULL)
SELECT event_id
FROM bronze.delivery_events
WHERE event_id IS NULL;

-- Check for duplicate event_id
SELECT
    event_id,
    COUNT(*)
FROM bronze.delivery_events
GROUP BY event_id
HAVING COUNT(*) > 1;


-- =============================================================
-- 3. Foreign Key Checks
-- =============================================================

-- Check for NULL load_id
SELECT load_id
FROM bronze.delivery_events
WHERE load_id IS NULL;

-- Check for NULL trip_id
SELECT trip_id
FROM bronze.delivery_events
WHERE trip_id IS NULL;

-- Check for NULL facility_id
SELECT facility_id
FROM bronze.delivery_events
WHERE facility_id IS NULL;


-- =============================================================
-- 4. Categorical Field Checks
-- =============================================================

-- Review distinct event types
SELECT DISTINCT event_type
FROM bronze.delivery_events;

-- Check for NULL, empty, or untrimmed event_type
SELECT event_type
FROM bronze.delivery_events
WHERE event_type IS NULL OR event_type = '' OR event_type != TRIM(event_type);

-- Review distinct on_time_flag values
SELECT DISTINCT on_time_flag
FROM bronze.delivery_events;

-- Check for NULL on_time_flag
SELECT on_time_flag
FROM bronze.delivery_events
WHERE on_time_flag IS NULL OR on_time_flag = '';


-- =============================================================
-- 5. Detention Minutes Checks
-- =============================================================

-- Detention minutes range sanity check
SELECT
    MIN(detention_minutes) AS min_detention,
    MAX(detention_minutes) AS max_detention,
    AVG(detention_minutes) AS avg_detention
FROM bronze.delivery_events;

-- Check for negative detention minutes
SELECT detention_minutes
FROM bronze.delivery_events
WHERE detention_minutes < 0;


-- =============================================================
-- 6. Location Checks
-- =============================================================

-- Check for NULL, empty, or untrimmed location_city
SELECT location_city
FROM bronze.delivery_events
WHERE location_city IS NULL OR location_city = '' OR location_city != TRIM(location_city);

-- Check for NULL, empty, or invalid length location_state
SELECT location_state
FROM bronze.delivery_events
WHERE location_state IS NULL OR location_state = '' OR LEN(TRIM(location_state)) != 2;

-- Review distinct location states
SELECT DISTINCT TRIM(location_state) AS location_state
FROM bronze.delivery_events
ORDER BY location_state;


-- =============================================================
-- 7. DateTime Checks
-- =============================================================

-- Check for NULL scheduled_datetime
SELECT scheduled_datetime
FROM bronze.delivery_events
WHERE scheduled_datetime IS NULL;

-- Check for NULL actual_datetime
SELECT actual_datetime
FROM bronze.delivery_events
WHERE actual_datetime IS NULL;


-- =============================================================
-- 8. Row Count
-- =============================================================
SELECT
    COUNT(*) AS total_rows
FROM bronze.delivery_events;
