/*
===============================================================================
Analytics / Business Intelligence Layer
Business Questions Queries
===============================================================================
Script Purpose:
    Provides analytical SQL queries to answer the 8 core business questions 
    outlined in the project README. 
    
    These queries leverage the Gold layer Star Schema directly, demonstrating 
    the analytical power and simplicity achieved by the Medallion Architecture.

Execution:
    These are SELECT queries meant for data analysts or BI tools.
    You can highlight and run them individually in SSMS/Azure Data Studio.
===============================================================================
*/

USE logistics_dwh;
GO

-- ==============================================================================
-- 1. Which drivers have the best on-time delivery rates?
-- ==============================================================================
-- Metric: On-time delivery percentage per driver (min. 10 deliveries to qualify)
SELECT TOP 20
    d.full_name                             AS DriverName,
    COUNT(del.delivery_key)                 AS TotalDeliveries,
    SUM(CASE WHEN del.on_time_flag = 'Y' THEN 1 ELSE 0 END) AS OnTimeDeliveries,
    CASE 
        WHEN COUNT(del.delivery_key) = 0 THEN 0
        ELSE ROUND((CAST(SUM(CASE WHEN del.on_time_flag = 'Y' THEN 1 ELSE 0 END) AS FLOAT) / COUNT(del.delivery_key)) * 100, 2)
    END                                     AS OnTimePercentage
FROM gold.fact_delivery del
JOIN gold.fact_trip t ON del.trip_id = t.trip_id
JOIN gold.dim_driver d ON t.driver_key = d.driver_key
GROUP BY d.full_name
HAVING COUNT(del.delivery_key) >= 10
ORDER BY OnTimePercentage DESC, TotalDeliveries DESC;


-- ==============================================================================
-- 2. Which routes are the most profitable?
-- ==============================================================================
-- Metric: Revenue, avg revenue per trip, and revenue per mile by route lane
SELECT TOP 20
    r.lane_description                      AS RouteLane,
    COUNT(t.trip_key)                       AS TotalTrips,
    SUM(t.actual_distance_miles)            AS TotalMiles,
    SUM(t.total_revenue)                    AS TotalRevenue,
    ROUND(AVG(t.total_revenue), 2)          AS AvgRevenuePerTrip,
    CASE 
        WHEN SUM(t.actual_distance_miles) = 0 THEN 0
        ELSE ROUND(SUM(t.total_revenue) / SUM(t.actual_distance_miles), 2)
    END                                     AS RevenuePerMile
FROM gold.fact_trip t
JOIN gold.dim_route r ON t.route_key = r.route_key
GROUP BY r.lane_description
ORDER BY TotalRevenue DESC;


-- ==============================================================================
-- 3. How does truck age affect maintenance costs?
-- ==============================================================================
-- Metric: Average maintenance cost and downtime grouped by truck age brackets
SELECT 
    CASE 
        WHEN tr.truck_age_years <= 2 THEN '0-2 Years (New)'
        WHEN tr.truck_age_years <= 5 THEN '3-5 Years (Mid)'
        WHEN tr.truck_age_years <= 8 THEN '6-8 Years (Old)'
        ELSE '9+ Years (Very Old)'
    END                                     AS TruckAgeBracket,
    COUNT(DISTINCT tr.truck_key)            AS NumberOfTrucks,
    COUNT(m.maintenance_key)                AS TotalMaintenanceEvents,
    ROUND(AVG(m.total_cost), 2)             AS AvgCostPerEvent,
    Sum(m.total_cost)                       AS TotalMaintenanceCost,
    ROUND(AVG(m.downtime_hours), 2)         AS AvgDowntimeHours
FROM gold.fact_maintenance m
JOIN gold.dim_truck tr ON m.truck_key = tr.truck_key
GROUP BY 
    CASE 
        WHEN tr.truck_age_years <= 2 THEN '0-2 Years (New)'
        WHEN tr.truck_age_years <= 5 THEN '3-5 Years (Mid)'
        WHEN tr.truck_age_years <= 8 THEN '6-8 Years (Old)'
        ELSE '9+ Years (Very Old)'
    END
ORDER BY TruckAgeBracket;


-- ==============================================================================
-- 4. What is the average fuel cost per trip by route?
-- ==============================================================================
-- Metric: Fuel cost average per route lane
SELECT TOP 20
    r.lane_description                      AS RouteLane,
    COUNT(t.trip_key)                       AS TotalTrips,
    SUM(fp.total_cost)                      AS TotalFuelCost,
    ROUND(AVG(fp.total_cost), 2)            AS AvgFuelCostPerTrip,
    -- Simple margin proxy: (Revenue - Fuel) / Revenue
    ROUND(((SUM(t.total_revenue) - SUM(fp.total_cost)) / NULLIF(SUM(t.total_revenue), 0)) * 100, 2) AS FuelAdjustedMarginPct
FROM gold.fact_trip t
JOIN gold.dim_route r ON t.route_key = r.route_key
-- Aggregate fuel purchases per trip to join back
JOIN (
    SELECT trip_id, SUM(total_cost) AS total_cost
    FROM gold.fact_fuel_purchase
    WHERE trip_id IS NOT NULL
    GROUP BY trip_id
) fp ON t.trip_id = fp.trip_id
GROUP BY r.lane_description
ORDER BY AvgFuelCostPerTrip DESC;


-- ==============================================================================
-- 5. Which customers generate the highest revenue?
-- ==============================================================================
-- Metric: Total revenue, trip count, and credit terms per customer
SELECT TOP 15
    c.customer_name                         AS CustomerName,
    c.customer_type                         AS CustomerType,
    c.credit_terms_days                     AS CreditTermsDays,
    COUNT(t.trip_key)                       AS TotalTrips,
    SUM(t.total_revenue)                    AS TotalRevenue,
    ROUND(SUM(t.total_revenue) / NULLIF(COUNT(t.trip_key),0), 2) AS AvgRevenuePerTrip
FROM gold.fact_trip t
JOIN gold.dim_customer c ON t.customer_key = c.customer_key
GROUP BY c.customer_name, c.customer_type, c.credit_terms_days
ORDER BY TotalRevenue DESC;


-- ==============================================================================
-- 6. How do seasonal patterns affect load volumes and rates?
-- ==============================================================================
-- Metric: Trip volume, revenue, and revenue per mile over time (Year/Month)
SELECT 
    d.year                                  AS Year,
    d.month_name                            AS Month,
    -- Use d.month for correct chronological sorting instead of alphabetical
    -- but display month_name
    COUNT(t.trip_key)                       AS TripVolume,
    SUM(t.actual_distance_miles)            AS TotalMiles,
    SUM(t.total_revenue)                    AS TotalRevenue,
    ROUND(SUM(t.total_revenue) / NULLIF(SUM(t.actual_distance_miles), 0), 2) AS AvgRevenuePerMile
FROM gold.fact_trip t
JOIN gold.dim_date d ON t.dispatch_date_key = d.date_key
GROUP BY d.year, d.month, d.month_name
ORDER BY d.year, d.month;


-- ==============================================================================
-- 7. What is the fleet utilisation rate per truck per month?
-- ==============================================================================
-- Metric: Number of trips and miles driven per active truck per month
SELECT 
    d.year_month                            AS YearMonth,
    COUNT(DISTINCT t.truck_key)             AS ActiveTrucks,
    COUNT(t.trip_key)                       AS TotalTrips,
    ROUND(CAST(COUNT(t.trip_key) AS FLOAT) / NULLIF(COUNT(DISTINCT t.truck_key), 0), 2) AS AvgTripsPerTruck,
    SUM(t.actual_distance_miles)            AS TotalMiles,
    ROUND(SUM(t.actual_distance_miles) / NULLIF(COUNT(DISTINCT t.truck_key), 0), 0) AS AvgMilesPerTruck
FROM gold.fact_trip t
JOIN gold.dim_date d ON t.dispatch_date_key = d.date_key
GROUP BY d.year_month
ORDER BY d.year_month;


-- ==============================================================================
-- 8. Which safety incidents were most costly?
-- ==============================================================================
-- Metric: Safety incident categories by total damage costs & frequency
SELECT 
    s.incident_type                         AS IncidentType,
    s.preventable_flag                      AS Preventable,
    COUNT(s.safety_key)                     AS TotalIncidents,
    SUM(s.vehicle_damage_cost)              AS TotalVehicleDamage,
    SUM(s.cargo_damage_cost)                AS TotalCargoDamage,
    SUM(s.total_damage_cost)                AS TotalDamageCost,
    ROUND(AVG(s.total_damage_cost), 2)      AS AvgCostPerIncident
FROM gold.fact_safety s
GROUP BY s.incident_type, s.preventable_flag
ORDER BY TotalDamageCost DESC;
