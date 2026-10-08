/*
===============================================================================
Silver Layer -- Parameterized Single-Table Load Procedure
===============================================================================
Script Purpose:
    Creates silver.load_table — a parameterized wrapper that lets you
    re-run any ONE Silver load procedure by name without reloading the
    entire Silver layer.

    This is essential in production when:
        - A single source table has a data quality issue
        - You want to re-process one table after a bug fix
        - Debugging or testing a specific table transformation

Procedure: silver.load_table

Parameters:
    @table_name NVARCHAR(100) — The target Silver table name.
                                Must match a registered load procedure.

Supported Values (case-insensitive):
    'drivers'                  → silver.load_drivers
    'customers'                → silver.load_customers
    'facilities'               → silver.load_facilities
    'routes'                   → silver.load_routes
    'trailers'                 → silver.load_trailers
    'trucks'                   → silver.load_trucks
    'delivery_events'          → silver.load_delivery_events
    'fuel_purchases'           → silver.load_fuel_purchases
    'loads'                    → silver.load_loads
    'maintenance_records'      → silver.load_maintenance_records
    'safety_incidents'         → silver.load_safety_incidents
    'trips'                    → silver.load_trips
    'driver_monthly_metrics'   → silver.load_driver_monthly_metrics
    'truck_utilization_metrics'→ silver.load_truck_utilization_metrics

Execution Examples:
    EXEC silver.load_table @table_name = 'drivers';
    EXEC silver.load_table @table_name = 'trips';
    EXEC silver.load_table @table_name = 'fuel_purchases';
===============================================================================
*/

CREATE OR ALTER PROCEDURE silver.load_table
    @table_name NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @proc_name NVARCHAR(100);

    -- Map input to the correct stored procedure name
    SET @proc_name = CASE LOWER(TRIM(@table_name))
        WHEN 'drivers'                   THEN 'silver.load_drivers'
        WHEN 'customers'                 THEN 'silver.load_customers'
        WHEN 'facilities'                THEN 'silver.load_facilities'
        WHEN 'routes'                    THEN 'silver.load_routes'
        WHEN 'trailers'                  THEN 'silver.load_trailers'
        WHEN 'trucks'                    THEN 'silver.load_trucks'
        WHEN 'delivery_events'           THEN 'silver.load_delivery_events'
        WHEN 'fuel_purchases'            THEN 'silver.load_fuel_purchases'
        WHEN 'loads'                     THEN 'silver.load_loads'
        WHEN 'maintenance_records'       THEN 'silver.load_maintenance_records'
        WHEN 'safety_incidents'          THEN 'silver.load_safety_incidents'
        WHEN 'trips'                     THEN 'silver.load_trips'
        WHEN 'driver_monthly_metrics'    THEN 'silver.load_driver_monthly_metrics'
        WHEN 'truck_utilization_metrics' THEN 'silver.load_truck_utilization_metrics'
        ELSE NULL
    END;

    -- Guard: reject unknown table names early
    IF @proc_name IS NULL
    BEGIN
        PRINT '==============================================================';
        PRINT 'ERROR: Unknown table name ''' + @table_name + '''';
        PRINT 'Valid values: drivers, customers, facilities, routes, trailers,';
        PRINT '  trucks, delivery_events, fuel_purchases, loads,';
        PRINT '  maintenance_records, safety_incidents, trips,';
        PRINT '  driver_monthly_metrics, truck_utilization_metrics';
        PRINT '==============================================================';
        RETURN;
    END;

    PRINT '==============================================================';
    PRINT 'Running single-table Silver load: ' + @proc_name;
    PRINT '==============================================================';

    BEGIN TRY
        EXEC (@proc_name);
    END TRY
    BEGIN CATCH
        PRINT '==============================================================';
        PRINT 'ERROR executing ' + @proc_name;
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT '==============================================================';
    END CATCH

END;
GO

PRINT '>> Created procedure: silver.load_table';
PRINT '>> Usage: EXEC silver.load_table @table_name = ''trips'';';
