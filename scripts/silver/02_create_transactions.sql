/*
===============================================================================
Silver Layer -- Create Transaction Tables
===============================================================================
Script Purpose:
    Creates the operational transaction staging tables in the Silver schema.
    These tables store raw transactional data loaded directly from source CSVs.

Tables Created:
    - silver.delivery_events
    - silver.fuel_purchases
    - silver.loads
    - silver.maintenance_records
    - silver.safety_incidents
    - silver.trips

Note:
    All columns are defined as NULLable to accommodate raw, unvalidated
    source data. Constraints and validation are applied in the Silver layer.

Dependencies:
    Run after: scripts/init_database.sql
    Run after: scripts/silver/01_create_reference.sql

Warning:
    This script drops and recreates the listed tables.
    All existing data in these tables will be lost.
===============================================================================
*/

-- ============================================================
-- silver.delivery_events
-- ============================================================
IF OBJECT_ID('silver.delivery_events', 'U') IS NOT NULL
  DROP TABLE silver.delivery_events;

GO

CREATE TABLE silver.delivery_events
  (
     event_id           NVARCHAR(20) NULL,
     load_id            NVARCHAR(20) NULL,
     trip_id            NVARCHAR(20) NULL,
     event_type         NVARCHAR(15) NULL,
     facility_id        NVARCHAR(20) NULL,
     scheduled_datetime TIME         NULL,
     actual_datetime    TIME         NULL,
     detention_minutes  INT          NULL,
     on_time_flag       NVARCHAR(5)  NULL,
     location_city      NVARCHAR(50) NULL,
     location_state     NCHAR(2)     NULL
  );

GO

-- ============================================================
-- silver.fuel_purchases
-- ============================================================
IF OBJECT_ID('silver.fuel_purchases', 'U') IS NOT NULL
  DROP TABLE silver.fuel_purchases;

GO

CREATE TABLE silver.fuel_purchases
  (
     fuel_purchase_id NVARCHAR(20)   NULL,
     trip_id          NVARCHAR(20)   NULL,
     truck_id         NVARCHAR(20)   NULL,
     driver_id        NVARCHAR(20)   NULL,
     purchase_date    DATETIME2      NULL,
     location_city    NVARCHAR(20)   NULL,
     location_state   NCHAR(2)       NULL,
     gallons          FLOAT          NULL,
     price_per_gallon DECIMAL(10, 3) NULL,
     total_cost       DECIMAL(18, 3) NULL,
     fuel_card_number NVARCHAR(20)   NULL
  );

GO

-- ============================================================
-- silver.loads
-- ============================================================
IF OBJECT_ID('silver.loads', 'U') IS NOT NULL
  DROP TABLE silver.loads;

GO

CREATE TABLE silver.loads
  (
     load_id             NVARCHAR(20)   NULL,
     customer_id         NVARCHAR(20)   NULL,
     route_id            NVARCHAR(20)   NULL,
     load_date           DATE           NULL,
     load_type           NVARCHAR(20)   NULL,
     weight_lbs          INT            NULL,
     pieces              INT            NULL,
     revenue             DECIMAL(18, 3) NULL,
     fuel_surcharge      DECIMAL(18, 3) NULL,
     accessorial_charges INT            NULL,
     load_status         NVARCHAR(20)   NULL,
     booking_type        NVARCHAR(20)   NULL
  );

GO

-- ============================================================
-- silver.maintenance_records
-- ============================================================
IF OBJECT_ID('silver.maintenance_records', 'U') IS NOT NULL
  DROP TABLE silver.maintenance_records;

GO

CREATE TABLE silver.maintenance_records
  (
     maintenance_id      NVARCHAR(20)   NULL,
     truck_id            NVARCHAR(20)   NULL,
     maintenance_date    DATE           NULL,
     maintenance_type    NVARCHAR(20)   NULL,
     odometer_reading    INT            NULL,
     labor_hours         FLOAT          NULL,
     labor_cost          DECIMAL(18, 3) NULL,
     parts_cost          DECIMAL(18, 3) NULL,
     total_cost          DECIMAL(18, 3) NULL,
     facility_location   NVARCHAR(20)   NULL,
     downtime_hours      FLOAT          NULL,
     service_description NVARCHAR(50)   NULL
  );

GO

-- ============================================================
-- silver.safety_incidents
-- ============================================================
IF OBJECT_ID('silver.safety_incidents', 'U') IS NOT NULL
  DROP TABLE silver.safety_incidents;

GO

CREATE TABLE silver.safety_incidents
  (
     incident_id         NVARCHAR(20)   NULL,
     trip_id             NVARCHAR(20)   NULL,
     truck_id            NVARCHAR(20)   NULL,
     driver_id           NVARCHAR(20)   NULL,
     incident_date       DATETIME2      NULL,
     incident_type       NVARCHAR(50)   NULL,
     location_city       NVARCHAR(20)   NULL,
     location_state      NCHAR(2)       NULL,
     at_fault_flag       NVARCHAR(5)    NULL,
     injury_flag         NVARCHAR(5)    NULL,
     vehicle_damage_cost DECIMAL(18, 3) NULL,
     cargo_damage_cost   DECIMAL(18, 3) NULL,
     claim_amount        DECIMAL(18, 3) NULL,
     preventable_flag    NVARCHAR(5)    NULL,
     description         NVARCHAR(200)  NULL
  );

GO

-- ============================================================
-- silver.trips
-- ============================================================
IF OBJECT_ID('silver.trips', 'U') IS NOT NULL
  DROP TABLE silver.trips;

GO

CREATE TABLE silver.trips
  (
     trip_id               NVARCHAR(20) NULL,
     load_id               NVARCHAR(20) NULL,
     driver_id             NVARCHAR(20) NULL,
     truck_id              NVARCHAR(20) NULL,
     trailer_id            NVARCHAR(20) NULL,
     dispatch_date         DATE         NULL,
     actual_distance_miles INT          NULL,
     actual_duration_hours FLOAT        NULL,
     fuel_gallons_used     FLOAT        NULL,
     average_mpg           FLOAT        NULL,
     idle_time_hours       FLOAT        NULL,
     trip_status           NVARCHAR(15) NULL
  );

GO