/*
===============================================================================
Analytics Layer -- Key Performance Indicator (KPI) Views
===============================================================================
Script Purpose:
    Creates aggregate KPI views over the Gold Star Schema.
    These views serve as the semantic layer connecting backend data 
    to reporting tools like Power BI, SSRS, or dashboards. 
    
    By abstracting complexity into views, BI tools don't need to write 
    complex JOINs and business logic is kept in the database.

Views Created:
    - gold.vw_driver_performance   (On-time %, revenue, incidents)
    - gold.vw_route_profitability  (Route-level margin/revenue tracking)
    - gold.vw_fleet_utilization    (Truck mileage and efficiency over time)
    - gold.vw_fuel_efficiency      (MPG tracking by truck and driver)

Dependencies:
    Run after Gold layer is instantiated.
===============================================================================
*/

USE logistics_dwh;
GO

-- ==============================================================================
-- View: gold.vw_driver_performance
-- Description: Driver-level KPIs (trips, miles, revenue generation, safety)
-- ==============================================================================

IF OBJECT_ID('gold.vw_driver_performance', 'V') IS NOT NULL
    DROP VIEW gold.vw_driver_performance;
GO

CREATE VIEW gold.vw_driver_performance AS
WITH SafetyStats AS (
    SELECT 
        driver_key,
        COUNT(safety_key) AS total_safety_incidents,
        SUM(total_damage_cost) AS total_damage_cost
    FROM gold.fact_safety
    GROUP BY driver_key
),
DeliveryStats AS (
    SELECT 
        t.driver_key,
        SUM(CASE WHEN d.on_time_flag = 'Y' THEN 1 ELSE 0 END) AS on_time_deliveries,
        COUNT(d.delivery_key) AS total_deliveries
    FROM gold.fact_trip t
    JOIN gold.fact_delivery d ON t.trip_id = d.trip_id
    GROUP BY t.driver_key
)
SELECT 
    d.driver_id,
    d.full_name,
    d.home_terminal,
    COUNT(t.trip_key) AS total_trips,
    SUM(t.actual_distance_miles) AS total_miles,
    SUM(t.total_revenue) AS total_revenue_generated,
    ISNULL(s.total_safety_incidents, 0) AS total_safety_incidents,
    ISNULL(s.total_damage_cost, 0) AS total_damage_cost_caused,
    -- On-Time calc
    del.total_deliveries,
    CASE 
        WHEN ISNULL(del.total_deliveries, 0) = 0 THEN 0
        ELSE ROUND((CAST(del.on_time_deliveries AS FLOAT) / del.total_deliveries) * 100, 2)
    END AS on_time_delivery_pct
FROM gold.dim_driver d
LEFT JOIN gold.fact_trip t ON d.driver_key = t.driver_key
LEFT JOIN SafetyStats s ON d.driver_key = s.driver_key
LEFT JOIN DeliveryStats del ON d.driver_key = del.driver_key
GROUP BY 
    d.driver_id, 
    d.full_name, 
    d.home_terminal,
    s.total_safety_incidents,
    s.total_damage_cost,
    del.total_deliveries,
    del.on_time_deliveries;
GO


-- ==============================================================================
-- View: gold.vw_route_profitability
-- Description: Lane-level profitability including revenue and distance averages
-- ==============================================================================

IF OBJECT_ID('gold.vw_route_profitability', 'V') IS NOT NULL
    DROP VIEW gold.vw_route_profitability;
GO

CREATE VIEW gold.vw_route_profitability AS
SELECT 
    r.route_id,
    r.lane_description,
    r.typical_distance_miles,
    COUNT(t.trip_key) AS trip_count,
    SUM(t.actual_distance_miles) AS actual_miles_driven,
    SUM(t.total_revenue) AS total_revenue,
    SUM(t.fuel_gallons_used) AS total_gallons_used,
    ROUND(SUM(t.total_revenue) / NULLIF(COUNT(t.trip_key), 0), 2) AS avg_revenue_per_trip,
    ROUND(SUM(t.total_revenue) / NULLIF(SUM(t.actual_distance_miles), 0), 2) AS revenue_per_mile
FROM gold.dim_route r
LEFT JOIN gold.fact_trip t ON r.route_key = t.route_key
GROUP BY 
    r.route_id,
    r.lane_description,
    r.typical_distance_miles;
GO


-- ==============================================================================
-- View: gold.vw_fleet_utilization
-- Description: Truck-level KPIs per Month (monthly grain) 
-- ==============================================================================

IF OBJECT_ID('gold.vw_fleet_utilization', 'V') IS NOT NULL
    DROP VIEW gold.vw_fleet_utilization;
GO

CREATE VIEW gold.vw_fleet_utilization AS
WITH MaintStats AS (
    SELECT
        truck_key,
        CAST(FORMAT(CAST(CAST(maintenance_date_key AS VARCHAR(8)) AS DATE), 'yyyyMM') AS INT) AS maint_year_month,
        COUNT(maintenance_key) AS maint_events,
        SUM(total_cost) AS maint_cost,
        SUM(downtime_hours) AS downtime_hours
    FROM gold.fact_maintenance
    GROUP BY 
        truck_key,
        CAST(FORMAT(CAST(CAST(maintenance_date_key AS VARCHAR(8)) AS DATE), 'yyyyMM') AS INT)
)
SELECT 
    dt.truck_id,
    dt.make,
    dt.model_year,
    dt.truck_age_years,
    d.year_month,
    COUNT(ft.trip_key) AS total_trips,
    SUM(ft.actual_distance_miles) AS total_miles_driven,
    SUM(ft.total_revenue) AS revenue_generated,
    ISNULL(m.maint_events, 0) AS maintenance_events,
    ISNULL(m.maint_cost, 0) AS maintenance_cost,
    ISNULL(m.downtime_hours, 0) AS downtime_hours
FROM gold.dim_truck dt
JOIN gold.fact_trip ft ON dt.truck_key = ft.truck_key
JOIN gold.dim_date d ON ft.dispatch_date_key = d.date_key
LEFT JOIN MaintStats m ON dt.truck_key = m.truck_key 
    AND REPLACE(d.year_month, '-', '') = CAST(m.maint_year_month AS VARCHAR(6))
GROUP BY 
    dt.truck_id,
    dt.make,
    dt.model_year,
    dt.truck_age_years,
    d.year_month,
    m.maint_events,
    m.maint_cost,
    m.downtime_hours;
GO


-- ==============================================================================
-- View: gold.vw_fuel_efficiency
-- Description: Fleet MPG tracking over time, evaluating drivers and trucks
-- ==============================================================================

IF OBJECT_ID('gold.vw_fuel_efficiency', 'V') IS NOT NULL
    DROP VIEW gold.vw_fuel_efficiency;
GO

CREATE VIEW gold.vw_fuel_efficiency AS
SELECT
    t.trip_id,
    d.full_name AS driver_name,
    tr.truck_id,
    tr.make AS truck_make,
    tr.truck_age_years,
    dt.year_month AS dispatch_month,
    t.actual_distance_miles,
    t.fuel_gallons_used,
    t.idle_time_hours,
    -- Robust MPG calculation (prevent divide by zero)
    CASE 
        WHEN ISNULL(t.fuel_gallons_used, 0) = 0 THEN NULL
        ELSE ROUND(CAST(t.actual_distance_miles AS FLOAT) / t.fuel_gallons_used, 2)
    END AS actual_mpg,
    -- Compare actual MPG to truck's reported average MPG
    t.average_mpg AS expected_mpg
FROM gold.fact_trip t
JOIN gold.dim_driver d ON t.driver_key = d.driver_key
JOIN gold.dim_truck tr ON t.truck_key = tr.truck_key
JOIN gold.dim_date dt ON t.dispatch_date_key = dt.date_key
WHERE t.actual_distance_miles > 0 
  AND t.fuel_gallons_used > 0;
GO

PRINT '==============================================================';
PRINT 'All KPI Views created successfully in Gold layer.';
PRINT '==============================================================';
