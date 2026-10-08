/*
===============================================================================
Gold Layer -- Add Foreign Key Constraints on Fact Tables
===============================================================================
Script Purpose:
    Adds explicit FOREIGN KEY constraints from fact table dimension key
    columns to the corresponding dimension table primary keys.

    This enforces referential integrity at the database engine level —
    not just via application-layer checks in the tests/ scripts.

Design Decisions:
    - All FK constraints use ON DELETE NO ACTION (default — safe)
    - Constraints are NOCHECK during initial load (for performance),
      then CHECK-enabled after. This is intentional for a truncate-and-
      reload pattern: dimension tables are always loaded before facts.
    - Script is idempotent: drops existing constraints before recreating.

    NOTE: Because the pipeline uses truncate-and-reload, FK constraints
    must be DISABLED before truncating dimension tables and RE-ENABLED
    after loading fact tables. The orchestrator procedures handle this
    via ALTER TABLE ... NOCHECK / CHECK CONSTRAINT ALL.

Execution:
    Run after:
        - scripts/gold/01_create_dimensions.sql
        - scripts/gold/02_create_facts.sql
        - EXEC gold.load_gold;   (data must exist before enabling checks)
===============================================================================
*/

-- =============================================================
-- Drop existing FK constraints (safe re-run)
-- =============================================================

-- fact_trip
IF OBJECT_ID('gold.fk_fact_trip_driver',    'F') IS NOT NULL  ALTER TABLE gold.fact_trip DROP CONSTRAINT fk_fact_trip_driver;
IF OBJECT_ID('gold.fk_fact_trip_truck',     'F') IS NOT NULL  ALTER TABLE gold.fact_trip DROP CONSTRAINT fk_fact_trip_truck;
IF OBJECT_ID('gold.fk_fact_trip_trailer',   'F') IS NOT NULL  ALTER TABLE gold.fact_trip DROP CONSTRAINT fk_fact_trip_trailer;
IF OBJECT_ID('gold.fk_fact_trip_customer',  'F') IS NOT NULL  ALTER TABLE gold.fact_trip DROP CONSTRAINT fk_fact_trip_customer;
IF OBJECT_ID('gold.fk_fact_trip_route',     'F') IS NOT NULL  ALTER TABLE gold.fact_trip DROP CONSTRAINT fk_fact_trip_route;
IF OBJECT_ID('gold.fk_fact_trip_date',      'F') IS NOT NULL  ALTER TABLE gold.fact_trip DROP CONSTRAINT fk_fact_trip_date;

-- fact_fuel_purchase
IF OBJECT_ID('gold.fk_fact_fuel_driver',    'F') IS NOT NULL  ALTER TABLE gold.fact_fuel_purchase DROP CONSTRAINT fk_fact_fuel_driver;
IF OBJECT_ID('gold.fk_fact_fuel_truck',     'F') IS NOT NULL  ALTER TABLE gold.fact_fuel_purchase DROP CONSTRAINT fk_fact_fuel_truck;
IF OBJECT_ID('gold.fk_fact_fuel_date',      'F') IS NOT NULL  ALTER TABLE gold.fact_fuel_purchase DROP CONSTRAINT fk_fact_fuel_date;

-- fact_maintenance
IF OBJECT_ID('gold.fk_fact_maint_truck',    'F') IS NOT NULL  ALTER TABLE gold.fact_maintenance DROP CONSTRAINT fk_fact_maint_truck;
IF OBJECT_ID('gold.fk_fact_maint_date',     'F') IS NOT NULL  ALTER TABLE gold.fact_maintenance DROP CONSTRAINT fk_fact_maint_date;

-- fact_safety
IF OBJECT_ID('gold.fk_fact_safety_driver',  'F') IS NOT NULL  ALTER TABLE gold.fact_safety DROP CONSTRAINT fk_fact_safety_driver;
IF OBJECT_ID('gold.fk_fact_safety_truck',   'F') IS NOT NULL  ALTER TABLE gold.fact_safety DROP CONSTRAINT fk_fact_safety_truck;
IF OBJECT_ID('gold.fk_fact_safety_date',    'F') IS NOT NULL  ALTER TABLE gold.fact_safety DROP CONSTRAINT fk_fact_safety_date;

-- fact_delivery
IF OBJECT_ID('gold.fk_fact_delivery_facility', 'F') IS NOT NULL  ALTER TABLE gold.fact_delivery DROP CONSTRAINT fk_fact_delivery_facility;
IF OBJECT_ID('gold.fk_fact_delivery_date',     'F') IS NOT NULL  ALTER TABLE gold.fact_delivery DROP CONSTRAINT fk_fact_delivery_date;

GO

-- =============================================================
-- gold.fact_trip — 6 FK constraints
-- =============================================================

ALTER TABLE gold.fact_trip
    ADD CONSTRAINT fk_fact_trip_driver
        FOREIGN KEY (driver_key)       REFERENCES gold.dim_driver   (driver_key);

ALTER TABLE gold.fact_trip
    ADD CONSTRAINT fk_fact_trip_truck
        FOREIGN KEY (truck_key)        REFERENCES gold.dim_truck    (truck_key);

ALTER TABLE gold.fact_trip
    ADD CONSTRAINT fk_fact_trip_trailer
        FOREIGN KEY (trailer_key)      REFERENCES gold.dim_trailer  (trailer_key);

ALTER TABLE gold.fact_trip
    ADD CONSTRAINT fk_fact_trip_customer
        FOREIGN KEY (customer_key)     REFERENCES gold.dim_customer (customer_key);

ALTER TABLE gold.fact_trip
    ADD CONSTRAINT fk_fact_trip_route
        FOREIGN KEY (route_key)        REFERENCES gold.dim_route    (route_key);

ALTER TABLE gold.fact_trip
    ADD CONSTRAINT fk_fact_trip_date
        FOREIGN KEY (dispatch_date_key) REFERENCES gold.dim_date    (date_key);

PRINT '>> FK constraints added on gold.fact_trip';

-- =============================================================
-- gold.fact_fuel_purchase — 3 FK constraints
-- =============================================================

ALTER TABLE gold.fact_fuel_purchase
    ADD CONSTRAINT fk_fact_fuel_driver
        FOREIGN KEY (driver_key)       REFERENCES gold.dim_driver   (driver_key);

ALTER TABLE gold.fact_fuel_purchase
    ADD CONSTRAINT fk_fact_fuel_truck
        FOREIGN KEY (truck_key)        REFERENCES gold.dim_truck    (truck_key);

ALTER TABLE gold.fact_fuel_purchase
    ADD CONSTRAINT fk_fact_fuel_date
        FOREIGN KEY (purchase_date_key) REFERENCES gold.dim_date    (date_key);

PRINT '>> FK constraints added on gold.fact_fuel_purchase';

-- =============================================================
-- gold.fact_maintenance — 2 FK constraints
-- =============================================================

ALTER TABLE gold.fact_maintenance
    ADD CONSTRAINT fk_fact_maint_truck
        FOREIGN KEY (truck_key)           REFERENCES gold.dim_truck (truck_key);

ALTER TABLE gold.fact_maintenance
    ADD CONSTRAINT fk_fact_maint_date
        FOREIGN KEY (maintenance_date_key) REFERENCES gold.dim_date (date_key);

PRINT '>> FK constraints added on gold.fact_maintenance';

-- =============================================================
-- gold.fact_safety — 3 FK constraints
-- =============================================================

ALTER TABLE gold.fact_safety
    ADD CONSTRAINT fk_fact_safety_driver
        FOREIGN KEY (driver_key)       REFERENCES gold.dim_driver   (driver_key);

ALTER TABLE gold.fact_safety
    ADD CONSTRAINT fk_fact_safety_truck
        FOREIGN KEY (truck_key)        REFERENCES gold.dim_truck    (truck_key);

ALTER TABLE gold.fact_safety
    ADD CONSTRAINT fk_fact_safety_date
        FOREIGN KEY (incident_date_key) REFERENCES gold.dim_date    (date_key);

PRINT '>> FK constraints added on gold.fact_safety';

-- =============================================================
-- gold.fact_delivery — 2 FK constraints
-- =============================================================

ALTER TABLE gold.fact_delivery
    ADD CONSTRAINT fk_fact_delivery_facility
        FOREIGN KEY (facility_key)      REFERENCES gold.dim_facility (facility_key);

ALTER TABLE gold.fact_delivery
    ADD CONSTRAINT fk_fact_delivery_date
        FOREIGN KEY (delivery_date_key) REFERENCES gold.dim_date     (date_key);

PRINT '>> FK constraints added on gold.fact_delivery';

PRINT '==============================================================';
PRINT 'All Gold FK constraints created successfully.';
PRINT '==============================================================';
