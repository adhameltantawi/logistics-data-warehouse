/*
===============================================================================
Silver Layer -- Create Reference Tables
===============================================================================
Script Purpose:
    Creates the dimension/reference staging tables in the Silver schema.
    These tables store raw master data loaded directly from source CSVs.

Tables Created:
    - silver.drivers
    - silver.customers
    - silver.facilities
    - silver.routes
    - silver.trailers
    - silver.trucks

Note:
    All columns are defined as NULLable to accommodate raw, unvalidated
    source data. Constraints and validation are applied in the Silver layer.

Dependencies:
    Run after: scripts/init_database.sql

Warning:
    This script drops and recreates the listed tables.
    All existing data in these tables will be lost.
===============================================================================
*/

-- ============================================================
-- silver.drivers
-- ============================================================
IF OBJECT_ID('silver.drivers', 'U') IS NOT NULL
  DROP TABLE silver.drivers;

GO

CREATE TABLE silver.drivers
  (
     driver_id         NVARCHAR(20) NULL,
     first_name        NVARCHAR(50) NULL,
     last_name         NVARCHAR(50) NULL,
     hire_date         DATE         NULL,
     termination_date  DATE         NULL,
     license_number    NVARCHAR(50) NULL,
     license_state     NCHAR(2)     NULL,
     date_of_birth     DATE         NULL,
     home_terminal     NVARCHAR(50) NULL,
     employment_status NVARCHAR(50) NULL,
     cdl_class         NCHAR(1)     NULL,
     years_experience  INT          NULL
  );

GO

-- ============================================================
-- silver.customers
-- ============================================================
IF OBJECT_ID('silver.customers', 'U') IS NOT NULL
  DROP TABLE silver.customers;

GO

CREATE TABLE silver.customers
  (
     customer_id              NVARCHAR(20)  NULL,
     customer_name            NVARCHAR(100) NULL,
     customer_type            NVARCHAR(50)  NULL,
     credit_terms_days        INT           NULL,
     primary_freight_type     NVARCHAR(50)  NULL,
     account_status           NVARCHAR(50)  NULL,
     contract_start_date      DATE          NULL,
     annual_revenue_potential INT           NULL
  );

GO

-- ============================================================
-- silver.facilities
-- ============================================================
IF OBJECT_ID('silver.facilities', 'U') IS NOT NULL
  DROP TABLE silver.facilities;

GO

CREATE TABLE silver.facilities
  (
     facility_id     NVARCHAR(20)  NULL,
     facility_name   NVARCHAR(100) NULL,
     facility_type   NVARCHAR(50)  NULL,
     city            NVARCHAR(50)  NULL,
     state           NCHAR(2)      NULL,
     latitude        FLOAT         NULL,
     longitude       FLOAT         NULL,
     dock_doors      INT           NULL,
     operating_hours NVARCHAR(50)  NULL
  );

GO

-- ============================================================
-- silver.routes
-- ============================================================
IF OBJECT_ID('silver.routes', 'U') IS NOT NULL
  DROP TABLE silver.routes;

GO

CREATE TABLE silver.routes
  (
     route_id               NVARCHAR(20)  NULL,
     origin_city            NVARCHAR(50)  NULL,
     origin_state           NCHAR(2)      NULL,
     destination_city       NVARCHAR(50)  NULL,
     destination_state      NCHAR(2)      NULL,
     typical_distance_miles INT           NULL,
     base_rate_per_mile     DECIMAL(10,2) NULL,
     fuel_surcharge_rate    DECIMAL(10,2) NULL,
     typical_transit_days   INT           NULL
  );

GO

-- ============================================================
-- silver.trailers
-- ============================================================
IF OBJECT_ID('silver.trailers', 'U') IS NOT NULL
  DROP TABLE silver.trailers;

GO

CREATE TABLE silver.trailers
  (
     trailer_id       NVARCHAR(20) NULL,
     trailer_number   INT          NULL,
     trailer_type     NVARCHAR(50) NULL,
     length_feet      INT          NULL,
     model_year       INT          NULL,
     vin              NVARCHAR(25) NULL,
     acquisition_date DATE         NULL,
     status           NVARCHAR(50) NULL,
     current_location NVARCHAR(50) NULL
  );

GO

-- ============================================================
-- silver.trucks
-- ============================================================
IF OBJECT_ID('silver.trucks', 'U') IS NOT NULL
  DROP TABLE silver.trucks;

GO

CREATE TABLE silver.trucks
  (
     truck_id              NVARCHAR(20) NULL,
     unit_number           INT          NULL,
     make                  NVARCHAR(50) NULL,
     model_year            INT          NULL,
     vin                   NVARCHAR(25) NULL,
     acquisition_date      DATE         NULL,
     acquisition_mileage   INT          NULL,
     fuel_type             NVARCHAR(50) NULL,
     tank_capacity_gallons INT          NULL,
     status                NVARCHAR(50) NULL,
     home_terminal         NVARCHAR(50) NULL
  );

GO