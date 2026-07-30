/*
===============================================================================
Gold Layer -- Create Fact Tables
===============================================================================
Script Purpose:
    Creates the Star Schema fact tables in the Gold schema.
    These tables store quantitative, measurable business events with
    foreign key references to dimension surrogate keys.

Tables Created:
    - gold.fact_trip          — Core shipment execution fact (grain: one trip)
    - gold.fact_fuel_purchase — Fuel transaction fact (grain: one purchase)
    - gold.fact_maintenance   — Maintenance event fact (grain: one service record)
    - gold.fact_safety        — Safety incident fact (grain: one incident)
    - gold.fact_delivery      — Delivery event fact (grain: one pickup/delivery)

Design Decisions:
    - All dimension references use surrogate keys (*_key)
    - date_key references gold.dim_date for time-based analysis
    - Additive measures (revenue, cost, miles, etc.) for aggregation
    - SCD Type 1 (overwrite) — full truncate-and-reload on each run

Dependencies:
    Run after: scripts/gold/01_create_dimensions.sql

Warning:
    This script drops and recreates the listed tables.
    All existing data in these tables will be lost.
===============================================================================
*/

-- ============================================================
-- gold.fact_trip
-- ============================================================
IF OBJECT_ID('gold.fact_trip', 'U') IS NOT NULL
  DROP TABLE gold.fact_trip;

GO

CREATE TABLE gold.fact_trip
  (
     trip_key              INT IDENTITY(1,1)  NOT NULL,
     -- Dimension keys
     driver_key            INT                NULL,
     truck_key             INT                NULL,
     trailer_key           INT                NULL,
     customer_key          INT                NULL,
     route_key             INT                NULL,
     dispatch_date_key     INT                NULL,
     -- Natural keys (for traceability)
     trip_id               NVARCHAR(20)       NOT NULL,
     load_id               NVARCHAR(20)       NULL,
     -- Measures: Trip performance
     actual_distance_miles INT                NULL,
     actual_duration_hours FLOAT              NULL,
     fuel_gallons_used     FLOAT              NULL,
     average_mpg           FLOAT              NULL,
     idle_time_hours       FLOAT              NULL,
     -- Measures: Load financials
     revenue               DECIMAL(18, 3)     NULL,
     fuel_surcharge        DECIMAL(18, 3)     NULL,
     accessorial_charges   INT                NULL,
     total_revenue         DECIMAL(18, 3)     NULL,
     weight_lbs            INT                NULL,
     pieces                INT                NULL,
     -- Descriptive
     load_type             NVARCHAR(20)       NULL,
     load_status           NVARCHAR(20)       NULL,
     booking_type          NVARCHAR(20)       NULL,
     trip_status           NVARCHAR(15)       NULL,
     -- Audit
     dwh_create_date       DATETIME2          DEFAULT SYSDATETIME(),
     CONSTRAINT pk_fact_trip PRIMARY KEY (trip_key)
  );

GO

-- ============================================================
-- gold.fact_fuel_purchase
-- ============================================================
IF OBJECT_ID('gold.fact_fuel_purchase', 'U') IS NOT NULL
  DROP TABLE gold.fact_fuel_purchase;

GO

CREATE TABLE gold.fact_fuel_purchase
  (
     fuel_purchase_key INT IDENTITY(1,1)  NOT NULL,
     -- Dimension keys
     driver_key        INT                NULL,
     truck_key         INT                NULL,
     purchase_date_key INT                NULL,
     -- Natural keys
     fuel_purchase_id  NVARCHAR(20)       NOT NULL,
     trip_id           NVARCHAR(20)       NULL,
     -- Measures
     gallons           FLOAT              NULL,
     price_per_gallon  DECIMAL(10, 3)     NULL,
     total_cost        DECIMAL(18, 3)     NULL,
     -- Descriptive
     location_city     NVARCHAR(20)       NULL,
     location_state    NCHAR(2)           NULL,
     fuel_card_number  NVARCHAR(20)       NULL,
     -- Audit
     dwh_create_date   DATETIME2          DEFAULT SYSDATETIME(),
     CONSTRAINT pk_fact_fuel_purchase PRIMARY KEY (fuel_purchase_key)
  );

GO

-- ============================================================
-- gold.fact_maintenance
-- ============================================================
IF OBJECT_ID('gold.fact_maintenance', 'U') IS NOT NULL
  DROP TABLE gold.fact_maintenance;

GO

CREATE TABLE gold.fact_maintenance
  (
     maintenance_key     INT IDENTITY(1,1)  NOT NULL,
     -- Dimension keys
     truck_key           INT                NULL,
     maintenance_date_key INT               NULL,
     -- Natural keys
     maintenance_id      NVARCHAR(20)       NOT NULL,
     -- Measures
     odometer_reading    INT                NULL,
     labor_hours         FLOAT              NULL,
     labor_cost          DECIMAL(18, 3)     NULL,
     parts_cost          DECIMAL(18, 3)     NULL,
     total_cost          DECIMAL(18, 3)     NULL,
     downtime_hours      FLOAT              NULL,
     -- Descriptive
     maintenance_type    NVARCHAR(20)       NULL,
     facility_location   NVARCHAR(20)       NULL,
     service_description NVARCHAR(50)       NULL,
     -- Audit
     dwh_create_date     DATETIME2          DEFAULT SYSDATETIME(),
     CONSTRAINT pk_fact_maintenance PRIMARY KEY (maintenance_key)
  );

GO

-- ============================================================
-- gold.fact_safety
-- ============================================================
IF OBJECT_ID('gold.fact_safety', 'U') IS NOT NULL
  DROP TABLE gold.fact_safety;

GO

CREATE TABLE gold.fact_safety
  (
     safety_key          INT IDENTITY(1,1)  NOT NULL,
     -- Dimension keys
     driver_key          INT                NULL,
     truck_key           INT                NULL,
     incident_date_key   INT                NULL,
     -- Natural keys
     incident_id         NVARCHAR(20)       NOT NULL,
     trip_id             NVARCHAR(20)       NULL,
     -- Measures
     vehicle_damage_cost DECIMAL(18, 3)     NULL,
     cargo_damage_cost   DECIMAL(18, 3)     NULL,
     claim_amount        DECIMAL(18, 3)     NULL,
     total_damage_cost   DECIMAL(18, 3)     NULL,
     -- Descriptive / Flags
     incident_type       NVARCHAR(50)       NULL,
     location_city       NVARCHAR(20)       NULL,
     location_state      NCHAR(2)           NULL,
     at_fault_flag       NVARCHAR(5)        NULL,
     injury_flag         NVARCHAR(5)        NULL,
     preventable_flag    NVARCHAR(5)        NULL,
     description         NVARCHAR(200)      NULL,
     -- Audit
     dwh_create_date     DATETIME2          DEFAULT SYSDATETIME(),
     CONSTRAINT pk_fact_safety PRIMARY KEY (safety_key)
  );

GO

-- ============================================================
-- gold.fact_delivery
-- ============================================================
IF OBJECT_ID('gold.fact_delivery', 'U') IS NOT NULL
  DROP TABLE gold.fact_delivery;

GO

CREATE TABLE gold.fact_delivery
  (
     delivery_key       INT IDENTITY(1,1)  NOT NULL,
     -- Dimension keys (conformed — connects to full star)
     facility_key       INT                NULL,
     driver_key         INT                NULL,
     truck_key          INT                NULL,
     customer_key       INT                NULL,
     route_key          INT                NULL,
     event_date_key     INT                NULL,
     -- Natural keys
     event_id           NVARCHAR(20)       NOT NULL,
     load_id            NVARCHAR(20)       NULL,
     trip_id            NVARCHAR(20)       NULL,
     -- Measures
     detention_minutes  INT                NULL,
     -- Descriptive / Flags
     event_type         NVARCHAR(15)       NULL,
     scheduled_datetime TIME               NULL,
     actual_datetime    TIME               NULL,
     on_time_flag       NVARCHAR(5)        NULL,
     location_city      NVARCHAR(50)       NULL,
     location_state     NCHAR(2)           NULL,
     -- Audit
     dwh_create_date    DATETIME2          DEFAULT SYSDATETIME(),
     CONSTRAINT pk_fact_delivery PRIMARY KEY (delivery_key)
  );

GO

-- ============================================================
-- Performance Indexes — Fact Table Foreign Keys
-- ============================================================
-- These non-clustered indexes accelerate dimension lookups
-- (e.g. Power BI filter/slicer operations) by avoiding
-- full table scans on FK columns.
-- ============================================================

-- fact_trip indexes
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

-- fact_fuel_purchase indexes
CREATE NONCLUSTERED INDEX ix_fact_fuel_driver_key
    ON gold.fact_fuel_purchase (driver_key);
CREATE NONCLUSTERED INDEX ix_fact_fuel_truck_key
    ON gold.fact_fuel_purchase (truck_key);
CREATE NONCLUSTERED INDEX ix_fact_fuel_purchase_date_key
    ON gold.fact_fuel_purchase (purchase_date_key);

-- fact_maintenance indexes
CREATE NONCLUSTERED INDEX ix_fact_maint_truck_key
    ON gold.fact_maintenance (truck_key);
CREATE NONCLUSTERED INDEX ix_fact_maint_date_key
    ON gold.fact_maintenance (maintenance_date_key);

-- fact_safety indexes
CREATE NONCLUSTERED INDEX ix_fact_safety_driver_key
    ON gold.fact_safety (driver_key);
CREATE NONCLUSTERED INDEX ix_fact_safety_truck_key
    ON gold.fact_safety (truck_key);
CREATE NONCLUSTERED INDEX ix_fact_safety_date_key
    ON gold.fact_safety (incident_date_key);

-- fact_delivery indexes
CREATE NONCLUSTERED INDEX ix_fact_delivery_facility_key
    ON gold.fact_delivery (facility_key);
CREATE NONCLUSTERED INDEX ix_fact_delivery_driver_key
    ON gold.fact_delivery (driver_key);
CREATE NONCLUSTERED INDEX ix_fact_delivery_truck_key
    ON gold.fact_delivery (truck_key);
CREATE NONCLUSTERED INDEX ix_fact_delivery_customer_key
    ON gold.fact_delivery (customer_key);
CREATE NONCLUSTERED INDEX ix_fact_delivery_route_key
    ON gold.fact_delivery (route_key);
CREATE NONCLUSTERED INDEX ix_fact_delivery_event_date_key
    ON gold.fact_delivery (event_date_key);

GO

