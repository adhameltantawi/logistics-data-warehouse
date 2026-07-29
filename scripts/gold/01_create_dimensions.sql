/*
===============================================================================
Gold Layer -- Create Dimension Tables
===============================================================================
Script Purpose:
    Creates the Star Schema dimension tables in the Gold schema.
    These tables are denormalised, analytics-ready, and enriched with
    surrogate keys (identity columns) for optimal join performance.

Tables Created:
    - gold.dim_driver
    - gold.dim_truck
    - gold.dim_trailer
    - gold.dim_customer
    - gold.dim_facility
    - gold.dim_route
    - gold.dim_date

Design Decisions:
    - Surrogate keys (INT IDENTITY) for fast joins on fact tables
    - Natural keys retained for traceability back to Silver
    - Derived columns added for analytical convenience
    - SCD Type 1 (overwrite) — full truncate-and-reload on each run

Dependencies:
    Run after: scripts/init_database.sql

Warning:
    This script drops and recreates the listed tables.
    All existing data in these tables will be lost.
===============================================================================
*/

-- ============================================================
-- gold.dim_driver
-- ============================================================
IF OBJECT_ID('gold.dim_driver', 'U') IS NOT NULL
  DROP TABLE gold.dim_driver;

GO

CREATE TABLE gold.dim_driver
  (
     driver_key        INT IDENTITY(1,1) NOT NULL,
     driver_id         NVARCHAR(20)      NOT NULL,
     first_name        NVARCHAR(50)      NULL,
     last_name         NVARCHAR(50)      NULL,
     full_name         NVARCHAR(101)     NULL,
     hire_date         DATE              NULL,
     termination_date  DATE              NULL,
     license_number    NVARCHAR(50)      NULL,
     license_state     NCHAR(2)          NULL,
     date_of_birth     DATE              NULL,
     home_terminal     NVARCHAR(50)      NULL,
     employment_status NVARCHAR(50)      NULL,
     cdl_class         NCHAR(1)          NULL,
     years_experience  INT               NULL,
     dwh_create_date   DATETIME2         DEFAULT SYSDATETIME(),
     CONSTRAINT pk_dim_driver PRIMARY KEY (driver_key)
  );

GO

-- ============================================================
-- gold.dim_truck
-- ============================================================
IF OBJECT_ID('gold.dim_truck', 'U') IS NOT NULL
  DROP TABLE gold.dim_truck;

GO

CREATE TABLE gold.dim_truck
  (
     truck_key             INT IDENTITY(1,1) NOT NULL,
     truck_id              NVARCHAR(20)      NOT NULL,
     unit_number           INT               NULL,
     make                  NVARCHAR(50)      NULL,
     model_year            INT               NULL,
     vin                   NVARCHAR(25)      NULL,
     acquisition_date      DATE              NULL,
     acquisition_mileage   INT               NULL,
     fuel_type             NVARCHAR(50)      NULL,
     tank_capacity_gallons INT               NULL,
     status                NVARCHAR(50)      NULL,
     home_terminal         NVARCHAR(50)      NULL,
     truck_age_years       INT               NULL,
     dwh_create_date       DATETIME2         DEFAULT SYSDATETIME(),
     CONSTRAINT pk_dim_truck PRIMARY KEY (truck_key)
  );

GO

-- ============================================================
-- gold.dim_trailer
-- ============================================================
IF OBJECT_ID('gold.dim_trailer', 'U') IS NOT NULL
  DROP TABLE gold.dim_trailer;

GO

CREATE TABLE gold.dim_trailer
  (
     trailer_key      INT IDENTITY(1,1) NOT NULL,
     trailer_id       NVARCHAR(20)      NOT NULL,
     trailer_number   INT               NULL,
     trailer_type     NVARCHAR(50)      NULL,
     length_feet      INT               NULL,
     model_year       INT               NULL,
     vin              NVARCHAR(25)      NULL,
     acquisition_date DATE              NULL,
     status           NVARCHAR(50)      NULL,
     current_location NVARCHAR(50)      NULL,
     dwh_create_date  DATETIME2         DEFAULT SYSDATETIME(),
     CONSTRAINT pk_dim_trailer PRIMARY KEY (trailer_key)
  );

GO

-- ============================================================
-- gold.dim_customer
-- ============================================================
IF OBJECT_ID('gold.dim_customer', 'U') IS NOT NULL
  DROP TABLE gold.dim_customer;

GO

CREATE TABLE gold.dim_customer
  (
     customer_key            INT IDENTITY(1,1) NOT NULL,
     customer_id             NVARCHAR(20)      NOT NULL,
     customer_name           NVARCHAR(100)     NULL,
     customer_type           NVARCHAR(50)      NULL,
     credit_terms_days       INT               NULL,
     primary_freight_type    NVARCHAR(50)      NULL,
     account_status          NVARCHAR(50)      NULL,
     contract_start_date     DATE              NULL,
     annual_revenue_potential INT              NULL,
     dwh_create_date         DATETIME2         DEFAULT SYSDATETIME(),
     CONSTRAINT pk_dim_customer PRIMARY KEY (customer_key)
  );

GO

-- ============================================================
-- gold.dim_facility
-- ============================================================
IF OBJECT_ID('gold.dim_facility', 'U') IS NOT NULL
  DROP TABLE gold.dim_facility;

GO

CREATE TABLE gold.dim_facility
  (
     facility_key    INT IDENTITY(1,1) NOT NULL,
     facility_id     NVARCHAR(20)      NOT NULL,
     facility_name   NVARCHAR(100)     NULL,
     facility_type   NVARCHAR(50)      NULL,
     city            NVARCHAR(50)      NULL,
     state           NCHAR(2)          NULL,
     latitude        FLOAT             NULL,
     longitude       FLOAT             NULL,
     dock_doors      INT               NULL,
     operating_hours NVARCHAR(50)      NULL,
     dwh_create_date DATETIME2         DEFAULT SYSDATETIME(),
     CONSTRAINT pk_dim_facility PRIMARY KEY (facility_key)
  );

GO

-- ============================================================
-- gold.dim_route
-- ============================================================
IF OBJECT_ID('gold.dim_route', 'U') IS NOT NULL
  DROP TABLE gold.dim_route;

GO

CREATE TABLE gold.dim_route
  (
     route_key              INT IDENTITY(1,1) NOT NULL,
     route_id               NVARCHAR(20)      NOT NULL,
     origin_city            NVARCHAR(50)      NULL,
     origin_state           NCHAR(2)          NULL,
     destination_city       NVARCHAR(50)      NULL,
     destination_state      NCHAR(2)          NULL,
     typical_distance_miles INT               NULL,
     base_rate_per_mile     DECIMAL(10,2)     NULL,
     fuel_surcharge_rate    DECIMAL(10,2)     NULL,
     typical_transit_days   INT               NULL,
     lane_description       NVARCHAR(120)     NULL,
     dwh_create_date        DATETIME2         DEFAULT SYSDATETIME(),
     CONSTRAINT pk_dim_route PRIMARY KEY (route_key)
  );

GO

-- ============================================================
-- gold.dim_date
-- ============================================================
IF OBJECT_ID('gold.dim_date', 'U') IS NOT NULL
  DROP TABLE gold.dim_date;

GO

CREATE TABLE gold.dim_date
  (
     date_key       INT          NOT NULL,
     full_date      DATE         NOT NULL,
     year           INT          NOT NULL,
     quarter        INT          NOT NULL,
     month          INT          NOT NULL,
     month_name     NVARCHAR(10) NOT NULL,
     week           INT          NOT NULL,
     day_of_month   INT          NOT NULL,
     day_of_week    INT          NOT NULL,
     day_name       NVARCHAR(10) NOT NULL,
     is_weekend     BIT          NOT NULL,
     year_month     NVARCHAR(7)  NOT NULL,
     CONSTRAINT pk_dim_date PRIMARY KEY (date_key)
  );

GO
