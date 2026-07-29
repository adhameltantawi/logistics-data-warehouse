/*
===============================================================================
Silver Layer -- Create Analytics Tables
===============================================================================
Script Purpose:
    Creates the pre-aggregated analytics tables in the Silver schema.
    These tables store cleansed, standardised, and deduplicated data
    transformed from the Bronze layer.

Tables Created:
    - silver.driver_monthly_metrics
    - silver.truck_utilization_metrics

Audit Column:
    dwh_create_date — Timestamp of when each record was loaded into Silver.

Dependencies:
    Run after: scripts/init_database.sql

Warning:
    This script drops and recreates the listed tables.
    All existing data in these tables will be lost.
===============================================================================
*/

-- ============================================================
-- silver.driver_monthly_metrics
-- ============================================================
IF OBJECT_ID('silver.driver_monthly_metrics', 'U') IS NOT NULL
  DROP TABLE silver.driver_monthly_metrics;

GO

CREATE TABLE silver.driver_monthly_metrics
  (
     driver_id             NVARCHAR(20)   NULL,
     month                 DATE           NULL,
     trips_completed       INT            NULL,
     total_miles           INT            NULL,
     total_revenue         DECIMAL(18, 3) NULL,
     average_mpg           DECIMAL(10, 3) NULL,
     total_fuel_gallons    DECIMAL(18, 3) NULL,
     on_time_delivery_rate FLOAT          NULL,
     average_idle_hours    FLOAT          NULL,
     dwh_create_date       DATETIME2      DEFAULT SYSDATETIME()
  );

GO

-- ============================================================
-- silver.truck_utilization_metrics
-- ============================================================
IF OBJECT_ID('silver.truck_utilization_metrics', 'U') IS NOT NULL
  DROP TABLE silver.truck_utilization_metrics;

GO

CREATE TABLE silver.truck_utilization_metrics
  (
     truck_id           NVARCHAR(20)   NULL,
     month              DATE           NULL,
     trips_completed    INT            NULL,
     total_miles        INT            NULL,
     total_revenue      DECIMAL(18, 3) NULL,
     average_mpg        DECIMAL(10, 3) NULL,
     maintenance_events INT            NULL,
     maintenance_cost   DECIMAL(18, 3) NULL,
     downtime_hours     FLOAT          NULL,
     utilization_rate   FLOAT          NULL,
     dwh_create_date    DATETIME2      DEFAULT SYSDATETIME()
  );

GO