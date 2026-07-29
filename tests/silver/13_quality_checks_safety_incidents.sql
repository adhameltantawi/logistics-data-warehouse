-- =============================================================
-- Quality Checks: bronze.safety_incidents
-- Purpose : Validate data integrity and readiness for Silver
--           layer transformation before loading.
-- Table   : bronze.safety_incidents
-- =============================================================


-- =============================================================
-- 1. Raw Data Preview
-- =============================================================
SELECT
    incident_id,
    trip_id,
    truck_id,
    driver_id,
    incident_date,
    incident_type,
    location_city,
    location_state,
    at_fault_flag,
    injury_flag,
    vehicle_damage_cost,
    cargo_damage_cost,
    claim_amount,
    preventable_flag,
    description
FROM bronze.safety_incidents;


-- =============================================================
-- 2. Uniqueness & Nulls Checks
-- =============================================================

-- Check for NULL incident_id
SELECT incident_id
FROM bronze.safety_incidents
WHERE incident_id IS NULL;

-- Check for duplicate incident_id
SELECT
    incident_id,
    COUNT(*)
FROM bronze.safety_incidents
GROUP BY incident_id
HAVING COUNT(*) > 1;


-- =============================================================
-- 3. Foreign Key Checks
-- =============================================================

-- Check for NULL trip_id
SELECT trip_id
FROM bronze.safety_incidents
WHERE trip_id IS NULL;

-- Check for NULL truck_id
SELECT truck_id
FROM bronze.safety_incidents
WHERE truck_id IS NULL;

-- Check for NULL driver_id
SELECT driver_id
FROM bronze.safety_incidents
WHERE driver_id IS NULL;


-- =============================================================
-- 4. Categorical & Flag Field Checks
-- =============================================================

-- Review distinct incident types
SELECT DISTINCT incident_type
FROM bronze.safety_incidents;

-- Check for NULL, empty, or untrimmed incident_type
SELECT incident_type
FROM bronze.safety_incidents
WHERE incident_type IS NULL OR incident_type = '' OR incident_type != TRIM(incident_type);

-- Review distinct flag values
SELECT DISTINCT at_fault_flag    FROM bronze.safety_incidents;
SELECT DISTINCT injury_flag      FROM bronze.safety_incidents;
SELECT DISTINCT preventable_flag FROM bronze.safety_incidents;

-- Check for NULL flags
SELECT at_fault_flag, injury_flag, preventable_flag
FROM bronze.safety_incidents
WHERE at_fault_flag IS NULL OR injury_flag IS NULL OR preventable_flag IS NULL;


-- =============================================================
-- 5. Cost & Claim Checks
-- =============================================================

-- Damage cost range sanity check
SELECT
    MIN(vehicle_damage_cost) AS min_vehicle_dmg,
    MAX(vehicle_damage_cost) AS max_vehicle_dmg,
    MIN(cargo_damage_cost)   AS min_cargo_dmg,
    MAX(cargo_damage_cost)   AS max_cargo_dmg,
    MIN(claim_amount)        AS min_claim,
    MAX(claim_amount)        AS max_claim
FROM bronze.safety_incidents;

-- Check for negative costs
SELECT vehicle_damage_cost, cargo_damage_cost, claim_amount
FROM bronze.safety_incidents
WHERE vehicle_damage_cost < 0 OR cargo_damage_cost < 0 OR claim_amount < 0;


-- =============================================================
-- 6. Location Checks
-- =============================================================

-- Check for NULL, empty, or untrimmed location_city
SELECT location_city
FROM bronze.safety_incidents
WHERE location_city IS NULL OR location_city = '' OR location_city != TRIM(location_city);

-- Check for NULL or invalid location_state
SELECT location_state
FROM bronze.safety_incidents
WHERE location_state IS NULL OR location_state = '' OR LEN(TRIM(location_state)) != 2;


-- =============================================================
-- 7. Date Checks
-- =============================================================

-- Incident date range sanity check
SELECT
    MIN(incident_date) AS min_incident_date,
    MAX(incident_date) AS max_incident_date
FROM bronze.safety_incidents;

-- Check for NULL incident_date
SELECT incident_date
FROM bronze.safety_incidents
WHERE incident_date IS NULL;


-- =============================================================
-- 8. Row Count
-- =============================================================
SELECT
    COUNT(*) AS total_rows
FROM bronze.safety_incidents;
