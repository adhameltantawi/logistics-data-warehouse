/*
===============================================================================
Gold Layer -- Create Non-Clustered Indexes on Fact Tables
===============================================================================
Script Purpose:
    Adds non-clustered indexes on all foreign-key columns in the 5 Gold
    fact tables. These are the columns most frequently used in JOIN and
    WHERE clauses during analytical queries.

    Without these indexes, every analytical query on large fact tables
    (e.g. fact_trip ~50,000 rows) must perform a full table scan.

Design Decisions:
    - One index per FK column (simple, predictable, easy to maintain)
    - Naming convention: ix_<table>_<column>
    - Run after: scripts/gold/02_create_facts.sql

Execution:
    Run this script once after the Gold DDL scripts.
    Safe to re-run (uses DROP IF EXISTS before each CREATE).
===============================================================================
*/

-- =============================================================
-- gold.fact_trip — 6 FK columns
-- =============================================================

DROP INDEX IF EXISTS ix_fact_trip_driver_key        ON gold.fact_trip;
DROP INDEX IF EXISTS ix_fact_trip_truck_key         ON gold.fact_trip;
DROP INDEX IF EXISTS ix_fact_trip_trailer_key       ON gold.fact_trip;
DROP INDEX IF EXISTS ix_fact_trip_customer_key      ON gold.fact_trip;
DROP INDEX IF EXISTS ix_fact_trip_route_key         ON gold.fact_trip;
DROP INDEX IF EXISTS ix_fact_trip_dispatch_date_key ON gold.fact_trip;
GO

CREATE NONCLUSTERED INDEX ix_fact_trip_driver_key
    ON gold.fact_trip (driver_key);

CREATE NONCLUSTERED INDEX ix_fact_trip_truck_key
    ON gold.fact_trip (truck_key);

CREATE NONCLUSTERED INDEX ix_fact_trip_trailer_key
    ON gold.fact_trip (trailer_key);

CREATE NONCLUSTERED INDEX ix_fact_trip_customer_key
    ON gold.fact_trip (customer_key);

CREATE NONCLUSTERED INDEX ix_fact_trip_route_key
    ON gold.fact_trip (route_key);

CREATE NONCLUSTERED INDEX ix_fact_trip_dispatch_date_key
    ON gold.fact_trip (dispatch_date_key);

GO

PRINT '>> Indexes created on gold.fact_trip';

-- =============================================================
-- gold.fact_fuel_purchase — 3 FK columns
-- =============================================================

DROP INDEX IF EXISTS ix_fact_fuel_driver_key       ON gold.fact_fuel_purchase;
DROP INDEX IF EXISTS ix_fact_fuel_truck_key        ON gold.fact_fuel_purchase;
DROP INDEX IF EXISTS ix_fact_fuel_date_key         ON gold.fact_fuel_purchase;
GO

CREATE NONCLUSTERED INDEX ix_fact_fuel_driver_key
    ON gold.fact_fuel_purchase (driver_key);

CREATE NONCLUSTERED INDEX ix_fact_fuel_truck_key
    ON gold.fact_fuel_purchase (truck_key);

CREATE NONCLUSTERED INDEX ix_fact_fuel_date_key
    ON gold.fact_fuel_purchase (purchase_date_key);

GO

PRINT '>> Indexes created on gold.fact_fuel_purchase';

-- =============================================================
-- gold.fact_maintenance — 2 FK columns
-- =============================================================

DROP INDEX IF EXISTS ix_fact_maint_truck_key       ON gold.fact_maintenance;
DROP INDEX IF EXISTS ix_fact_maint_date_key        ON gold.fact_maintenance;
GO

CREATE NONCLUSTERED INDEX ix_fact_maint_truck_key
    ON gold.fact_maintenance (truck_key);

CREATE NONCLUSTERED INDEX ix_fact_maint_date_key
    ON gold.fact_maintenance (maintenance_date_key);

GO

PRINT '>> Indexes created on gold.fact_maintenance';

-- =============================================================
-- gold.fact_safety — 3 FK columns
-- =============================================================

DROP INDEX IF EXISTS ix_fact_safety_driver_key     ON gold.fact_safety;
DROP INDEX IF EXISTS ix_fact_safety_truck_key      ON gold.fact_safety;
DROP INDEX IF EXISTS ix_fact_safety_date_key       ON gold.fact_safety;
GO

CREATE NONCLUSTERED INDEX ix_fact_safety_driver_key
    ON gold.fact_safety (driver_key);

CREATE NONCLUSTERED INDEX ix_fact_safety_truck_key
    ON gold.fact_safety (truck_key);

CREATE NONCLUSTERED INDEX ix_fact_safety_date_key
    ON gold.fact_safety (incident_date_key);

GO

PRINT '>> Indexes created on gold.fact_safety';

-- =============================================================
-- gold.fact_delivery — 2 FK columns
-- =============================================================

DROP INDEX IF EXISTS ix_fact_delivery_facility_key ON gold.fact_delivery;
DROP INDEX IF EXISTS ix_fact_delivery_date_key     ON gold.fact_delivery;
GO

CREATE NONCLUSTERED INDEX ix_fact_delivery_facility_key
    ON gold.fact_delivery (facility_key);

CREATE NONCLUSTERED INDEX ix_fact_delivery_date_key
    ON gold.fact_delivery (delivery_date_key);

GO

PRINT '>> Indexes created on gold.fact_delivery';

PRINT '==============================================================';
PRINT 'All Gold fact table indexes created successfully.';
PRINT '==============================================================';
