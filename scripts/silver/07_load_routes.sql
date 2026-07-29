/*
===============================================================================
Silver Layer -- Load Routes (Stored Procedure)
===============================================================================
Script Purpose:
    Creates and registers the stored procedure silver.load_routes.
    This procedure transforms and loads data from bronze.routes
    into silver.routes with full data cleansing.

Procedure: silver.load_routes
Target Table: silver.routes
Source Table: bronze.routes

Transformations Applied:
    - TRIM on all string columns (origin_city, destination_city)
    - UPPER on origin_state, destination_state
    - Validate typical_distance_miles > 0
    - Validate base_rate_per_mile >= 0, fuel_surcharge_rate >= 0
    - Deduplication on route_id using ROW_NUMBER()
    - dwh_create_date audit timestamp

Dependencies:
    Run after: scripts/silver/01_create_reference.sql
    Run after: scripts/bronze/04_load_reference.sql (bronze data must exist)

Execution:
    This procedure is registered here but NOT executed automatically.
    To run the full Silver pipeline, execute: EXEC silver.load_silver;
    To run this procedure individually: EXEC silver.load_routes;
===============================================================================
*/

CREATE OR ALTER PROCEDURE silver.load_routes AS
BEGIN
    DECLARE @start_time DATETIME2,
            @end_time   DATETIME2,
            @rows       INT;

    SET NOCOUNT ON;

    BEGIN TRY
        SET @start_time = SYSDATETIME();
        PRINT '>> Truncating Table: silver.routes';
        TRUNCATE TABLE silver.routes;

        PRINT '>> Loading Data into Table: silver.routes';
        INSERT INTO silver.routes
        (
            route_id,
            origin_city,
            origin_state,
            destination_city,
            destination_state,
            typical_distance_miles,
            base_rate_per_mile,
            fuel_surcharge_rate,
            typical_transit_days
        )
        SELECT
            route_id,
            TRIM(origin_city)                                          AS origin_city,
            UPPER(TRIM(origin_state))                                  AS origin_state,
            TRIM(destination_city)                                     AS destination_city,
            UPPER(TRIM(destination_state))                             AS destination_state,
            CASE
                WHEN typical_distance_miles > 0 THEN typical_distance_miles
                ELSE NULL
            END                                                        AS typical_distance_miles,
            CASE
                WHEN base_rate_per_mile >= 0 THEN base_rate_per_mile
                ELSE NULL
            END                                                        AS base_rate_per_mile,
            CASE
                WHEN fuel_surcharge_rate >= 0 THEN fuel_surcharge_rate
                ELSE NULL
            END                                                        AS fuel_surcharge_rate,
            CASE
                WHEN typical_transit_days > 0 THEN typical_transit_days
                ELSE NULL
            END                                                        AS typical_transit_days
        FROM
        (
            SELECT
                *,
                ROW_NUMBER() OVER (PARTITION BY route_id ORDER BY route_id) AS rn
            FROM bronze.routes
            WHERE route_id IS NOT NULL
        ) AS deduped
        WHERE rn = 1;

        SELECT @rows = @@ROWCOUNT;
        SET @end_time = SYSDATETIME();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(MILLISECOND, @start_time, @end_time) AS NVARCHAR(50)) + ' ms';
        PRINT '>> SUCCESS: routes ............ ' + CAST(@rows AS NVARCHAR(20)) + ' rows';

    END TRY
    BEGIN CATCH
        PRINT '-----------------------------------------------------------';
        PRINT 'ERROR OCCURRED DURING LOADING ROUTES IN SILVER LAYER';
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT 'Error Number:  ' + CAST(ERROR_NUMBER() AS NVARCHAR(10));
        PRINT 'Error State:   ' + CAST(ERROR_STATE()  AS NVARCHAR(10));
        PRINT 'Error Line:    ' + CAST(ERROR_LINE()   AS NVARCHAR(10));
        PRINT '-----------------------------------------------------------';
    END CATCH

END;
GO
