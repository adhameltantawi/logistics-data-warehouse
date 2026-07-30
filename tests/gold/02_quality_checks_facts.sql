-- =============================================================
-- Quality Checks: Gold Layer — Fact Tables
-- Purpose : Validate fact table integrity after loading
--           the Gold layer Star Schema.
-- =============================================================


-- =============================================================
-- 1. Row Count Summary — All Facts
-- =============================================================
SELECT 'gold.fact_trip'          AS fact_table, COUNT(*) AS rows FROM gold.fact_trip
UNION ALL
SELECT 'gold.fact_fuel_purchase', COUNT(*) FROM gold.fact_fuel_purchase
UNION ALL
SELECT 'gold.fact_maintenance',   COUNT(*) FROM gold.fact_maintenance
UNION ALL
SELECT 'gold.fact_safety',        COUNT(*) FROM gold.fact_safety
UNION ALL
SELECT 'gold.fact_delivery',      COUNT(*) FROM gold.fact_delivery;


-- =============================================================
-- 2. Surrogate Key Uniqueness (should return 0 rows)
-- =============================================================

SELECT 'fact_trip duplicates' AS check_name, trip_key, COUNT(*) AS cnt
FROM gold.fact_trip GROUP BY trip_key HAVING COUNT(*) > 1;

SELECT 'fact_fuel duplicates' AS check_name, fuel_purchase_key, COUNT(*) AS cnt
FROM gold.fact_fuel_purchase GROUP BY fuel_purchase_key HAVING COUNT(*) > 1;

SELECT 'fact_maint duplicates' AS check_name, maintenance_key, COUNT(*) AS cnt
FROM gold.fact_maintenance GROUP BY maintenance_key HAVING COUNT(*) > 1;


-- =============================================================
-- 3. Referential Integrity (orphaned dimension keys)
-- =============================================================

-- fact_trip: Check for orphaned driver_key
SELECT 'fact_trip → dim_driver' AS check_name, COUNT(*) AS orphans
FROM gold.fact_trip ft
WHERE ft.driver_key IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM gold.dim_driver dd WHERE dd.driver_key = ft.driver_key);

-- fact_trip: Check for orphaned truck_key
SELECT 'fact_trip → dim_truck' AS check_name, COUNT(*) AS orphans
FROM gold.fact_trip ft
WHERE ft.truck_key IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM gold.dim_truck dt WHERE dt.truck_key = ft.truck_key);

-- fact_trip: Check for orphaned customer_key
SELECT 'fact_trip → dim_customer' AS check_name, COUNT(*) AS orphans
FROM gold.fact_trip ft
WHERE ft.customer_key IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM gold.dim_customer dc WHERE dc.customer_key = ft.customer_key);

-- fact_trip: Check for orphaned route_key
SELECT 'fact_trip → dim_route' AS check_name, COUNT(*) AS orphans
FROM gold.fact_trip ft
WHERE ft.route_key IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM gold.dim_route dr WHERE dr.route_key = ft.route_key);

-- fact_fuel_purchase: Check for orphaned driver_key
SELECT 'fact_fuel → dim_driver' AS check_name, COUNT(*) AS orphans
FROM gold.fact_fuel_purchase ff
WHERE ff.driver_key IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM gold.dim_driver dd WHERE dd.driver_key = ff.driver_key);

-- fact_maintenance: Check for orphaned truck_key
SELECT 'fact_maint → dim_truck' AS check_name, COUNT(*) AS orphans
FROM gold.fact_maintenance fm
WHERE fm.truck_key IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM gold.dim_truck dt WHERE dt.truck_key = fm.truck_key);

-- fact_safety: Check for orphaned driver_key
SELECT 'fact_safety → dim_driver' AS check_name, COUNT(*) AS orphans
FROM gold.fact_safety fs
WHERE fs.driver_key IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM gold.dim_driver dd WHERE dd.driver_key = fs.driver_key);

-- fact_delivery: Check for orphaned facility_key
SELECT 'fact_delivery → dim_facility' AS check_name, COUNT(*) AS orphans
FROM gold.fact_delivery fd
WHERE fd.facility_key IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM gold.dim_facility df WHERE df.facility_key = fd.facility_key);

-- fact_delivery: Check for orphaned driver_key
SELECT 'fact_delivery → dim_driver' AS check_name, COUNT(*) AS orphans
FROM gold.fact_delivery fd
WHERE fd.driver_key IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM gold.dim_driver dd WHERE dd.driver_key = fd.driver_key);

-- fact_delivery: Check for orphaned truck_key
SELECT 'fact_delivery → dim_truck' AS check_name, COUNT(*) AS orphans
FROM gold.fact_delivery fd
WHERE fd.truck_key IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM gold.dim_truck dt WHERE dt.truck_key = fd.truck_key);

-- fact_delivery: Check for orphaned customer_key
SELECT 'fact_delivery → dim_customer' AS check_name, COUNT(*) AS orphans
FROM gold.fact_delivery fd
WHERE fd.customer_key IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM gold.dim_customer dc WHERE dc.customer_key = fd.customer_key);

-- fact_delivery: Check for orphaned route_key
SELECT 'fact_delivery → dim_route' AS check_name, COUNT(*) AS orphans
FROM gold.fact_delivery fd
WHERE fd.route_key IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM gold.dim_route dr WHERE dr.route_key = fd.route_key);

-- fact_delivery: Check for orphaned event_date_key
SELECT 'fact_delivery → dim_date' AS check_name, COUNT(*) AS orphans
FROM gold.fact_delivery fd
WHERE fd.event_date_key IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM gold.dim_date dd WHERE dd.date_key = fd.event_date_key);


-- =============================================================
-- 4. Measure Sanity Checks — fact_trip
-- =============================================================

-- Revenue distribution
SELECT
    MIN(revenue)       AS min_revenue,
    MAX(revenue)       AS max_revenue,
    AVG(revenue)       AS avg_revenue,
    MIN(total_revenue) AS min_total_revenue,
    MAX(total_revenue) AS max_total_revenue,
    SUM(total_revenue) AS sum_total_revenue
FROM gold.fact_trip;

-- Check for negative revenue
SELECT COUNT(*) AS negative_revenue_count
FROM gold.fact_trip
WHERE revenue < 0;

-- Distance and duration sanity
SELECT
    MIN(actual_distance_miles) AS min_miles,
    MAX(actual_distance_miles) AS max_miles,
    AVG(actual_distance_miles) AS avg_miles,
    MIN(actual_duration_hours) AS min_hours,
    MAX(actual_duration_hours) AS max_hours
FROM gold.fact_trip;


-- =============================================================
-- 5. Measure Sanity Checks — fact_fuel_purchase
-- =============================================================

SELECT
    MIN(gallons)          AS min_gallons,
    MAX(gallons)          AS max_gallons,
    MIN(price_per_gallon) AS min_price,
    MAX(price_per_gallon) AS max_price,
    SUM(total_cost)       AS sum_fuel_cost
FROM gold.fact_fuel_purchase;


-- =============================================================
-- 6. Measure Sanity Checks — fact_maintenance
-- =============================================================

SELECT
    MIN(total_cost)    AS min_maint_cost,
    MAX(total_cost)    AS max_maint_cost,
    SUM(total_cost)    AS sum_maint_cost,
    MIN(downtime_hours) AS min_downtime,
    MAX(downtime_hours) AS max_downtime
FROM gold.fact_maintenance;


-- =============================================================
-- 7. Measure Sanity Checks — fact_safety
-- =============================================================

SELECT
    MIN(total_damage_cost) AS min_damage,
    MAX(total_damage_cost) AS max_damage,
    SUM(total_damage_cost) AS sum_damage,
    SUM(claim_amount)      AS sum_claims,
    COUNT(*)               AS total_incidents
FROM gold.fact_safety;


-- =============================================================
-- 8. Silver-to-Gold Row Count Reconciliation — Facts
-- =============================================================

SELECT
    (SELECT COUNT(*) FROM silver.trips)              AS silver_trips,
    (SELECT COUNT(*) FROM gold.fact_trip)             AS gold_fact_trip;

SELECT
    (SELECT COUNT(*) FROM silver.fuel_purchases)     AS silver_fuel_purchases,
    (SELECT COUNT(*) FROM gold.fact_fuel_purchase)   AS gold_fact_fuel;

SELECT
    (SELECT COUNT(*) FROM silver.maintenance_records) AS silver_maintenance,
    (SELECT COUNT(*) FROM gold.fact_maintenance)      AS gold_fact_maintenance;

SELECT
    (SELECT COUNT(*) FROM silver.safety_incidents)   AS silver_safety,
    (SELECT COUNT(*) FROM gold.fact_safety)          AS gold_fact_safety;

SELECT
    (SELECT COUNT(*) FROM silver.delivery_events)    AS silver_delivery,
    (SELECT COUNT(*) FROM gold.fact_delivery)        AS gold_fact_delivery;
