/*
===============================================================================
Bronze Layer -- Create Analytics Tables
===============================================================================
Script Purpose:
    Creates the pre-aggregated analytics staging tables in the Bronze schema.
    These tables store monthly KPI snapshots loaded directly from source CSVs.

Tables Created:
    - bronze.driver_monthly_metrics
    - bronze.truck_utilization_metrics

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
-- bronze.driver_monthly_metrics
-- ============================================================
IF OBJECT_ID('bronze.driver_monthly_metrics', 'U') IS NOT NULL
  DROP TABLE bronze.driver_monthly_metrics;

GO

CREATE TABLE bronze.driver_monthly_metrics
  (
     driver_id             NVARCHAR(20)   NULL,
     month                 DATE           NULL,
     trips_completed       INT            NULL,
     total_miles           INT            NULL,
     total_revenue         DECIMAL(18, 3) NULL,
     average_mpg           DECIMAL(10, 3) NULL,
     total_fuel_gallons    DECIMAL(18, 3) NULL,
     on_time_delivery_rate FLOAT          NULL,
     average_idle_hours    FLOAT          NULL
  );

GO

-- ============================================================
-- bronze.truck_utilization_metrics
-- ============================================================
IF OBJECT_ID('bronze.truck_utilization_metrics', 'U') IS NOT NULL
  DROP TABLE bronze.truck_utilization_metrics;

GO

CREATE TABLE bronze.truck_utilization_metrics
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
     utilization_rate   FLOAT          NULL
  );

GO