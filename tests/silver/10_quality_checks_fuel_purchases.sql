-- =============================================================
-- Quality Checks: bronze.fuel_purchases
-- Purpose : Validate data integrity and readiness for Silver
--           layer transformation before loading.
-- Table   : bronze.fuel_purchases
-- =============================================================


-- =============================================================
-- 1. Raw Data Preview
-- =============================================================
SELECT
    fuel_purchase_id,
    trip_id,
    truck_id,
    driver_id,
    purchase_date,
    location_city,
    location_state,
    gallons,
    price_per_gallon,
    total_cost,
    fuel_card_number
FROM bronze.fuel_purchases;


-- =============================================================
-- 2. Uniqueness & Nulls Checks
-- =============================================================

-- Check for NULL fuel_purchase_id
SELECT fuel_purchase_id
FROM bronze.fuel_purchases
WHERE fuel_purchase_id IS NULL;

-- Check for duplicate fuel_purchase_id
SELECT
    fuel_purchase_id,
    COUNT(*)
FROM bronze.fuel_purchases
GROUP BY fuel_purchase_id
HAVING COUNT(*) > 1;


-- =============================================================
-- 3. Foreign Key Checks
-- =============================================================

-- Check for NULL trip_id
SELECT trip_id
FROM bronze.fuel_purchases
WHERE trip_id IS NULL;

-- Check for NULL truck_id
SELECT truck_id
FROM bronze.fuel_purchases
WHERE truck_id IS NULL;

-- Check for NULL driver_id
SELECT driver_id
FROM bronze.fuel_purchases
WHERE driver_id IS NULL;


-- =============================================================
-- 4. Fuel Amount & Cost Checks
-- =============================================================

-- Gallons range sanity check
SELECT
    MIN(gallons)          AS min_gallons,
    MAX(gallons)          AS max_gallons,
    AVG(gallons)          AS avg_gallons
FROM bronze.fuel_purchases;

-- Check for NULL, zero, or negative gallons
SELECT gallons
FROM bronze.fuel_purchases
WHERE gallons IS NULL OR gallons <= 0;

-- Price per gallon range sanity check
SELECT
    MIN(price_per_gallon) AS min_price,
    MAX(price_per_gallon) AS max_price,
    AVG(price_per_gallon) AS avg_price
FROM bronze.fuel_purchases;

-- Check for NULL, zero, or negative price per gallon
SELECT price_per_gallon
FROM bronze.fuel_purchases
WHERE price_per_gallon IS NULL OR price_per_gallon <= 0;

-- Total cost range sanity check
SELECT
    MIN(total_cost) AS min_total_cost,
    MAX(total_cost) AS max_total_cost,
    AVG(total_cost) AS avg_total_cost
FROM bronze.fuel_purchases;

-- Check for negative total cost
SELECT total_cost
FROM bronze.fuel_purchases
WHERE total_cost < 0;

-- Verify total_cost ≈ gallons * price_per_gallon
SELECT
    fuel_purchase_id,
    gallons,
    price_per_gallon,
    total_cost,
    gallons * price_per_gallon AS calculated_cost,
    ABS(total_cost - (gallons * price_per_gallon)) AS cost_diff
FROM bronze.fuel_purchases
WHERE ABS(total_cost - (gallons * price_per_gallon)) > 1;


-- =============================================================
-- 5. Location Checks
-- =============================================================

-- Check for NULL, empty, or untrimmed location_city
SELECT location_city
FROM bronze.fuel_purchases
WHERE location_city IS NULL OR location_city = '' OR location_city != TRIM(location_city);

-- Check for NULL, empty, or invalid location_state
SELECT location_state
FROM bronze.fuel_purchases
WHERE location_state IS NULL OR location_state = '' OR LEN(TRIM(location_state)) != 2;


-- =============================================================
-- 6. Date Checks
-- =============================================================

-- Purchase date range sanity check
SELECT
    MIN(purchase_date) AS min_purchase_date,
    MAX(purchase_date) AS max_purchase_date
FROM bronze.fuel_purchases;

-- Check for NULL purchase_date
SELECT purchase_date
FROM bronze.fuel_purchases
WHERE purchase_date IS NULL;

-- Check for future purchase dates
SELECT purchase_date
FROM bronze.fuel_purchases
WHERE purchase_date > GETDATE();


-- =============================================================
-- 7. Fuel Card Checks
-- =============================================================

-- Check for NULL or empty fuel_card_number
SELECT fuel_card_number
FROM bronze.fuel_purchases
WHERE fuel_card_number IS NULL OR fuel_card_number = '';

-- Fuel card number length distribution
SELECT DISTINCT LEN(fuel_card_number) AS card_length
FROM bronze.fuel_purchases;


-- =============================================================
-- 8. Row Count
-- =============================================================
SELECT
    COUNT(*) AS total_rows
FROM bronze.fuel_purchases;
