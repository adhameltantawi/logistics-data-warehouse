/*
===============================================================================
Bronze Layer -- Create Reference Tables
===============================================================================
Script Purpose:
    Creates the dimension/reference staging tables in the Bronze schema.
    These tables store raw master data loaded directly from source CSVs.

Tables Created:
    - bronze.drivers
    - bronze.customers
    - bronze.facilities
    - bronze.routes
    - bronze.trailers
    - bronze.trucks

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
-- bronze.drivers
-- ============================================================
IF OBJECT_ID('bronze.drivers', 'U') IS NOT NULL
  DROP TABLE bronze.drivers;

GO

CREATE TABLE bronze.drivers
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
-- bronze.customers
-- ============================================================
IF OBJECT_ID('bronze.customers', 'U') IS NOT NULL
  DROP TABLE bronze.customers;

GO

CREATE TABLE bronze.customerss
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
-- bronze.facilities
-- ============================================================
IF OBJECT_ID('bronze.facilities', 'U') IS NOT NULL
  DROP TABLE bronze.facilities;

GO

CREATE TABLE bronze.facilities
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
-- bronze.routes
-- ============================================================
IF OBJECT_ID('bronze.routes', 'U') IS NOT NULL
  DROP TABLE bronze.routes;

GO

CREATE TABLE bronze.routes
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
-- bronze.trailers
-- ============================================================
IF OBJECT_ID('bronze.trailers', 'U') IS NOT NULL
  DROP TABLE bronze.trailers;

GO

CREATE TABLE bronze.trailers
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
-- bronze.trucks
-- ============================================================
IF OBJECT_ID('bronze.trucks', 'U') IS NOT NULL
  DROP TABLE bronze.trucks;

GO

CREATE TABLE bronze.trucks
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