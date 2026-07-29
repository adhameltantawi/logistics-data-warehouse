/*
===============================================================================
Silver Layer -- Load Trips (Stored Procedure)
===============================================================================
Script Purpose:
    Creates and registers the stored procedure silver.load_trips.
    This procedure transforms and loads data from bronze.trips
    into silver.trips with full data cleansing.

Procedure: silver.load_trips
Target Table: silver.trips
Source Table: bronze.trips

Transformations Applied:
    - TRIM on trip_status
    - Validate actual_distance_miles > 0
    - Validate actual_duration_hours >= 0
    - Validate fuel_gallons_used >= 0, average_mpg >= 0
    - Validate idle_time_hours >= 0
    - Deduplication on trip_id using ROW_NUMBER()
    - dwh_create_date audit timestamp

Dependencies:
    Run after: scripts/silver/02_create_transactions.sql
    Run after: scripts/bronze/05_load_transactions.sql (bronze data must exist)

Execution:
    This procedure is registered here but NOT executed automatically.
    To run the full Silver pipeline, execute: EXEC silver.load_silver;
    To run this procedure individually: EXEC silver.load_trips;
===============================================================================
*/

CREATE OR ALTER PROCEDURE silver.load_trips AS
BEGIN
    DECLARE @start_time DATETIME2,
            @end_time   DATETIME2,
            @rows       INT;

    SET NOCOUNT ON;

    BEGIN TRY
        SET @start_time = SYSDATETIME();
        PRINT '>> Truncating Table: silver.trips';
        TRUNCATE TABLE silver.trips;

        PRINT '>> Loading Data into Table: silver.trips';
        INSERT INTO silver.trips
        (
            trip_id,
            load_id,
            driver_id,
            truck_id,
            trailer_id,
            dispatch_date,
            actual_distance_miles,
            actual_duration_hours,
            fuel_gallons_used,
            average_mpg,
            idle_time_hours,
            trip_status
        )
        SELECT
            trip_id,
            load_id,
            driver_id,
            truck_id,
            trailer_id,
            dispatch_date,
            CASE
                WHEN actual_distance_miles > 0 THEN actual_distance_miles
                ELSE NULL
            END                                                        AS actual_distance_miles,
            CASE
                WHEN actual_duration_hours >= 0 THEN actual_duration_hours
                ELSE NULL
            END                                                        AS actual_duration_hours,
            CASE
                WHEN fuel_gallons_used >= 0 THEN fuel_gallons_used
                ELSE NULL
            END                                                        AS fuel_gallons_used,
            CASE
                WHEN average_mpg >= 0 THEN average_mpg
                ELSE NULL
            END                                                        AS average_mpg,
            CASE
                WHEN idle_time_hours >= 0 THEN idle_time_hours
                ELSE NULL
            END                                                        AS idle_time_hours,
            TRIM(trip_status)                                          AS trip_status
        FROM
        (
            SELECT
                *,
                ROW_NUMBER() OVER (PARTITION BY trip_id ORDER BY trip_id) AS rn
            FROM bronze.trips
            WHERE trip_id IS NOT NULL
        ) AS deduped
        WHERE rn = 1;

        SELECT @rows = @@ROWCOUNT;
        SET @end_time = SYSDATETIME();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(MILLISECOND, @start_time, @end_time) AS NVARCHAR(50)) + ' ms';
        PRINT '>> SUCCESS: trips ............ ' + CAST(@rows AS NVARCHAR(20)) + ' rows';

    END TRY
    BEGIN CATCH
        PRINT '-----------------------------------------------------------';
        PRINT 'ERROR OCCURRED DURING LOADING TRIPS IN SILVER LAYER';
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT 'Error Number:  ' + CAST(ERROR_NUMBER() AS NVARCHAR(10));
        PRINT 'Error State:   ' + CAST(ERROR_STATE()  AS NVARCHAR(10));
        PRINT 'Error Line:    ' + CAST(ERROR_LINE()   AS NVARCHAR(10));
        PRINT '-----------------------------------------------------------';
    END CATCH

END;
GO
