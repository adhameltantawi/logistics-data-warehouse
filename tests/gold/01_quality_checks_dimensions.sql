-- =============================================================
-- Quality Checks: Gold Layer — Dimensions
-- Purpose : Validate dimensional integrity after loading
--           the Gold layer Star Schema.
-- =============================================================


-- =============================================================
-- 1. Row Count Summary — All Dimensions
-- =============================================================
SELECT 'gold.dim_driver'   AS dimension_table, COUNT(*) AS rows FROM gold.dim_driver
UNION ALL
SELECT 'gold.dim_truck',    COUNT(*) FROM gold.dim_truck
UNION ALL
SELECT 'gold.dim_trailer',  COUNT(*) FROM gold.dim_trailer
UNION ALL
SELECT 'gold.dim_customer', COUNT(*) FROM gold.dim_customer
UNION ALL
SELECT 'gold.dim_facility', COUNT(*) FROM gold.dim_facility
UNION ALL
SELECT 'gold.dim_route',    COUNT(*) FROM gold.dim_route
UNION ALL
SELECT 'gold.dim_date',     COUNT(*) FROM gold.dim_date;


-- =============================================================
-- 2. Surrogate Key Uniqueness (should return 0 rows each)
-- =============================================================

SELECT 'dim_driver duplicates' AS check_name, driver_key, COUNT(*) AS cnt
FROM gold.dim_driver GROUP BY driver_key HAVING COUNT(*) > 1;

SELECT 'dim_truck duplicates' AS check_name, truck_key, COUNT(*) AS cnt
FROM gold.dim_truck GROUP BY truck_key HAVING COUNT(*) > 1;

SELECT 'dim_customer duplicates' AS check_name, customer_key, COUNT(*) AS cnt
FROM gold.dim_customer GROUP BY customer_key HAVING COUNT(*) > 1;

SELECT 'dim_route duplicates' AS check_name, route_key, COUNT(*) AS cnt
FROM gold.dim_route GROUP BY route_key HAVING COUNT(*) > 1;


-- =============================================================
-- 3. Natural Key Uniqueness (should return 0 rows each)
-- =============================================================

SELECT 'driver_id duplicates' AS check_name, driver_id, COUNT(*) AS cnt
FROM gold.dim_driver GROUP BY driver_id HAVING COUNT(*) > 1;

SELECT 'truck_id duplicates' AS check_name, truck_id, COUNT(*) AS cnt
FROM gold.dim_truck GROUP BY truck_id HAVING COUNT(*) > 1;

SELECT 'customer_id duplicates' AS check_name, customer_id, COUNT(*) AS cnt
FROM gold.dim_customer GROUP BY customer_id HAVING COUNT(*) > 1;

SELECT 'route_id duplicates' AS check_name, route_id, COUNT(*) AS cnt
FROM gold.dim_route GROUP BY route_id HAVING COUNT(*) > 1;


-- =============================================================
-- 4. Derived Column Checks
-- =============================================================

-- Verify full_name is populated for drivers
SELECT driver_key, first_name, last_name, full_name
FROM gold.dim_driver
WHERE full_name IS NULL OR full_name = '';

-- Verify truck_age_years is reasonable
SELECT truck_key, model_year, truck_age_years
FROM gold.dim_truck
WHERE truck_age_years < 0 OR truck_age_years > 40;

-- Verify lane_description is populated for routes
SELECT route_key, origin_city, destination_city, lane_description
FROM gold.dim_route
WHERE lane_description IS NULL OR lane_description = '';


-- =============================================================
-- 5. Date Dimension Completeness
-- =============================================================

-- Verify date range covers expected period
SELECT
    MIN(full_date) AS min_date,
    MAX(full_date) AS max_date,
    COUNT(*)       AS total_days
FROM gold.dim_date;

-- Verify no gaps (total should equal date range span + 1)
SELECT
    DATEDIFF(DAY, MIN(full_date), MAX(full_date)) + 1 AS expected_days,
    COUNT(*) AS actual_days
FROM gold.dim_date;

-- Verify date_key format (should be YYYYMMDD integers)
SELECT TOP 5 date_key, full_date
FROM gold.dim_date
ORDER BY full_date;


-- =============================================================
-- 6. Silver-to-Gold Row Count Reconciliation
-- =============================================================

-- Drivers: Silver count should match Gold dim count
SELECT
    (SELECT COUNT(*) FROM silver.drivers)    AS silver_drivers,
    (SELECT COUNT(*) FROM gold.dim_driver)   AS gold_dim_driver;

-- Trucks: Silver count should match Gold dim count
SELECT
    (SELECT COUNT(*) FROM silver.trucks)     AS silver_trucks,
    (SELECT COUNT(*) FROM gold.dim_truck)    AS gold_dim_truck;

-- Customers: Silver count should match Gold dim count
SELECT
    (SELECT COUNT(*) FROM silver.customers)  AS silver_customers,
    (SELECT COUNT(*) FROM gold.dim_customer) AS gold_dim_customer;

-- Routes: Silver count should match Gold dim count
SELECT
    (SELECT COUNT(*) FROM silver.routes)     AS silver_routes,
    (SELECT COUNT(*) FROM gold.dim_route)    AS gold_dim_route;
