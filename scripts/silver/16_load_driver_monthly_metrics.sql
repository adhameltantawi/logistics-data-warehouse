/*
===============================================================================
Silver Layer -- Load Driver Monthly Metrics (Stored Procedure)
===============================================================================
Script Purpose:
    Creates and registers the stored procedure silver.load_driver_monthly_metrics.
    This procedure transforms and loads data from bronze.driver_monthly_metrics
    into silver.driver_monthly_metrics with full data cleansing.

Procedure: silver.load_driver_monthly_metrics
Target Table: silver.driver_monthly_metrics
Source Table: bronze.driver_monthly_metrics

Transformations Applied:
    - Validate trips_completed >= 0, total_miles >= 0
    - Validate total_revenue >= 0, total_fuel_gallons >= 0
    - Validate average_mpg >= 0, average_idle_hours >= 0
    - Validate on_time_delivery_rate between 0 and 1
    - Deduplication on (driver_id, month) using ROW_NUMBER()
    - dwh_create_date audit timestamp

Dependencies:
    Run after: scripts/silver/03_create_analytics.sql
    Run after: scripts/bronze/06_load_analytics.sql (bronze data must exist)

Execution:
    This procedure is registered here but NOT executed automatically.
    To run the full Silver pipeline, execute: EXEC silver.load_silver;
    To run this procedure individually: EXEC silver.load_driver_monthly_metrics;
===============================================================================
*/

CREATE OR ALTER PROCEDURE silver.load_driver_monthly_metrics AS
BEGIN
    DECLARE @start_time DATETIME2,
            @end_time   DATETIME2,
            @rows       INT;

    SET NOCOUNT ON;

    BEGIN TRY
        SET @start_time = SYSDATETIME();
        PRINT '>> Truncating Table: silver.driver_monthly_metrics';
        TRUNCATE TABLE silver.driver_monthly_metrics;

        PRINT '>> Loading Data into Table: silver.driver_monthly_metrics';
        INSERT INTO silver.driver_monthly_metrics
        (
            driver_id,
            month,
            trips_completed,
            total_miles,
            total_revenue,
            average_mpg,
            total_fuel_gallons,
            on_time_delivery_rate,
            average_idle_hours
        )
        SELECT
            driver_id,
            month,
            CASE
                WHEN trips_completed >= 0 THEN trips_completed
                ELSE NULL
            END                                                        AS trips_completed,
            CASE
                WHEN total_miles >= 0 THEN total_miles
                ELSE NULL
            END                                                        AS total_miles,
            CASE
                WHEN total_revenue >= 0 THEN total_revenue
                ELSE NULL
            END                                                        AS total_revenue,
            CASE
                WHEN average_mpg >= 0 THEN average_mpg
                ELSE NULL
            END                                                        AS average_mpg,
            CASE
                WHEN total_fuel_gallons >= 0 THEN total_fuel_gallons
                ELSE NULL
            END                                                        AS total_fuel_gallons,
            CASE
                WHEN on_time_delivery_rate BETWEEN 0 AND 1 THEN on_time_delivery_rate
                ELSE NULL
            END                                                        AS on_time_delivery_rate,
            CASE
                WHEN average_idle_hours >= 0 THEN average_idle_hours
                ELSE NULL
            END                                                        AS average_idle_hours
        FROM
        (
            SELECT
                *,
                ROW_NUMBER() OVER (PARTITION BY driver_id, month ORDER BY driver_id) AS rn
            FROM bronze.driver_monthly_metrics
            WHERE driver_id IS NOT NULL
              AND month IS NOT NULL
        ) AS deduped
        WHERE rn = 1;

        SELECT @rows = @@ROWCOUNT;
        SET @end_time = SYSDATETIME();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(MILLISECOND, @start_time, @end_time) AS NVARCHAR(50)) + ' ms';
        PRINT '>> SUCCESS: driver_monthly_metrics ............ ' + CAST(@rows AS NVARCHAR(20)) + ' rows';

    END TRY
    BEGIN CATCH
        PRINT '-----------------------------------------------------------';
        PRINT 'ERROR OCCURRED DURING LOADING DRIVER_MONTHLY_METRICS IN SILVER LAYER';
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT 'Error Number:  ' + CAST(ERROR_NUMBER() AS NVARCHAR(10));
        PRINT 'Error State:   ' + CAST(ERROR_STATE()  AS NVARCHAR(10));
        PRINT 'Error Line:    ' + CAST(ERROR_LINE()   AS NVARCHAR(10));
        PRINT '-----------------------------------------------------------';
    END CATCH

END;
GO
