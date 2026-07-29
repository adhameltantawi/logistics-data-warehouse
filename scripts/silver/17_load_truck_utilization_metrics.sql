/*
===============================================================================
Silver Layer -- Load Truck Utilization Metrics (Stored Procedure)
===============================================================================
Script Purpose:
    Creates and registers the stored procedure silver.load_truck_utilization_metrics.
    This procedure transforms and loads data from bronze.truck_utilization_metrics
    into silver.truck_utilization_metrics with full data cleansing.

Procedure: silver.load_truck_utilization_metrics
Target Table: silver.truck_utilization_metrics
Source Table: bronze.truck_utilization_metrics

Transformations Applied:
    - Validate trips_completed >= 0, total_miles >= 0
    - Validate total_revenue >= 0, maintenance_cost >= 0
    - Validate average_mpg >= 0, downtime_hours >= 0
    - Validate maintenance_events >= 0
    - Validate utilization_rate between 0 and 1
    - Deduplication on (truck_id, month) using ROW_NUMBER()
    - dwh_create_date audit timestamp

Dependencies:
    Run after: scripts/silver/03_create_analytics.sql
    Run after: scripts/bronze/06_load_analytics.sql (bronze data must exist)

Execution:
    This procedure is registered here but NOT executed automatically.
    To run the full Silver pipeline, execute: EXEC silver.load_silver;
    To run this procedure individually: EXEC silver.load_truck_utilization_metrics;
===============================================================================
*/

CREATE OR ALTER PROCEDURE silver.load_truck_utilization_metrics AS
BEGIN
    DECLARE @start_time DATETIME2,
            @end_time   DATETIME2,
            @rows       INT;

    SET NOCOUNT ON;

    BEGIN TRY
        SET @start_time = SYSDATETIME();
        PRINT '>> Truncating Table: silver.truck_utilization_metrics';
        TRUNCATE TABLE silver.truck_utilization_metrics;

        PRINT '>> Loading Data into Table: silver.truck_utilization_metrics';
        INSERT INTO silver.truck_utilization_metrics
        (
            truck_id,
            month,
            trips_completed,
            total_miles,
            total_revenue,
            average_mpg,
            maintenance_events,
            maintenance_cost,
            downtime_hours,
            utilization_rate
        )
        SELECT
            truck_id,
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
                WHEN maintenance_events >= 0 THEN maintenance_events
                ELSE NULL
            END                                                        AS maintenance_events,
            CASE
                WHEN maintenance_cost >= 0 THEN maintenance_cost
                ELSE NULL
            END                                                        AS maintenance_cost,
            CASE
                WHEN downtime_hours >= 0 THEN downtime_hours
                ELSE NULL
            END                                                        AS downtime_hours,
            CASE
                WHEN utilization_rate BETWEEN 0 AND 1 THEN utilization_rate
                ELSE NULL
            END                                                        AS utilization_rate
        FROM
        (
            SELECT
                *,
                ROW_NUMBER() OVER (PARTITION BY truck_id, month ORDER BY truck_id) AS rn
            FROM bronze.truck_utilization_metrics
            WHERE truck_id IS NOT NULL
              AND month IS NOT NULL
        ) AS deduped
        WHERE rn = 1;

        SELECT @rows = @@ROWCOUNT;
        SET @end_time = SYSDATETIME();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(MILLISECOND, @start_time, @end_time) AS NVARCHAR(50)) + ' ms';
        PRINT '>> SUCCESS: truck_utilization_metrics ............ ' + CAST(@rows AS NVARCHAR(20)) + ' rows';

    END TRY
    BEGIN CATCH
        PRINT '-----------------------------------------------------------';
        PRINT 'ERROR OCCURRED DURING LOADING TRUCK_UTILIZATION_METRICS IN SILVER LAYER';
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT 'Error Number:  ' + CAST(ERROR_NUMBER() AS NVARCHAR(10));
        PRINT 'Error State:   ' + CAST(ERROR_STATE()  AS NVARCHAR(10));
        PRINT 'Error Line:    ' + CAST(ERROR_LINE()   AS NVARCHAR(10));
        PRINT '-----------------------------------------------------------';
    END CATCH

END;
GO
