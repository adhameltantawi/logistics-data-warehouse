/*
===============================================================================
Silver Layer -- Master Load Orchestrator (Stored Procedure)
===============================================================================
Script Purpose:
    Creates and registers the master orchestrator procedure silver.load_silver.
    This is the single entry point to load the entire Silver layer.
    It calls all 14 sub-procedures in the correct dependency order:
        1. Reference tables  (drivers, customers, facilities, routes, trailers, trucks)
        2. Transaction tables (delivery_events, fuel_purchases, loads,
                               maintenance_records, safety_incidents, trips)
        3. Analytics tables   (driver_monthly_metrics, truck_utilization_metrics)

Procedure: silver.load_silver

Dependencies:
    Run after:
        - scripts/init_database.sql
        - scripts/silver/01_create_reference.sql
        - scripts/silver/02_create_transactions.sql
        - scripts/silver/03_create_analytics.sql
        - scripts/silver/04_load_drivers.sql
        - scripts/silver/05_load_customers.sql
        - scripts/silver/06_load_facilities.sql
        - scripts/silver/07_load_routes.sql
        - scripts/silver/08_load_trailers.sql
        - scripts/silver/09_load_trucks.sql
        - scripts/silver/10_load_delivery_events.sql
        - scripts/silver/11_load_fuel_purchases.sql
        - scripts/silver/12_load_loads.sql
        - scripts/silver/13_load_maintenance_records.sql
        - scripts/silver/14_load_safety_incidents.sql
        - scripts/silver/15_load_trips.sql
        - scripts/silver/16_load_driver_monthly_metrics.sql
        - scripts/silver/17_load_truck_utilization_metrics.sql

    Bronze layer must be loaded first: EXEC bronze.load_bronze;

Execution:
    EXEC silver.load_silver;
===============================================================================
*/

CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
    DECLARE @batch_start_time DATETIME2,
            @batch_end_time   DATETIME2;

    SET NOCOUNT ON;

    BEGIN TRY
        SET @batch_start_time = SYSDATETIME();

        PRINT '===========================================================';
        PRINT 'Loading Silver Layer';
        PRINT '===========================================================';

        -- -----------------------------------------------------------
        -- 1. Reference Tables
        -- -----------------------------------------------------------
        PRINT '-----------------------------------------------------------';
        PRINT 'Loading Reference Tables into Silver layer';
        PRINT '-----------------------------------------------------------';

        EXEC silver.load_drivers;
        EXEC silver.load_customers;
        EXEC silver.load_facilities;
        EXEC silver.load_routes;
        EXEC silver.load_trailers;
        EXEC silver.load_trucks;

        -- -----------------------------------------------------------
        -- 2. Transaction Tables
        -- -----------------------------------------------------------
        PRINT '-----------------------------------------------------------';
        PRINT 'Loading Transaction Tables into Silver layer';
        PRINT '-----------------------------------------------------------';

        EXEC silver.load_delivery_events;
        EXEC silver.load_fuel_purchases;
        EXEC silver.load_loads;
        EXEC silver.load_maintenance_records;
        EXEC silver.load_safety_incidents;
        EXEC silver.load_trips;

        -- -----------------------------------------------------------
        -- 3. Analytics Tables
        -- -----------------------------------------------------------
        PRINT '-----------------------------------------------------------';
        PRINT 'Loading Analytics Tables into Silver layer';
        PRINT '-----------------------------------------------------------';

        EXEC silver.load_driver_monthly_metrics;
        EXEC silver.load_truck_utilization_metrics;

        SET @batch_end_time = SYSDATETIME();
        PRINT '===========================================================';
        PRINT 'Silver Layer Load Completed Successfully';
        PRINT '   - Total Load Duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR(50)) + ' seconds';
        PRINT '===========================================================';

    END TRY
    BEGIN CATCH
        PRINT '===========================================================';
        PRINT 'ERROR OCCURRED DURING SILVER LAYER LOAD';
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT 'Error Number:  ' + CAST(ERROR_NUMBER() AS NVARCHAR(10));
        PRINT 'Error State:   ' + CAST(ERROR_STATE()  AS NVARCHAR(10));
        PRINT 'Error Line:    ' + CAST(ERROR_LINE()   AS NVARCHAR(10));
        PRINT '===========================================================';
    END CATCH

END;
GO
