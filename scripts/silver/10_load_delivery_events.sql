/*
===============================================================================
Silver Layer -- Load Delivery Events (Stored Procedure)
===============================================================================
Script Purpose:
    Creates and registers the stored procedure silver.load_delivery_events.
    This procedure transforms and loads data from bronze.delivery_events
    into silver.delivery_events with full data cleansing.

Procedure: silver.load_delivery_events
Target Table: silver.delivery_events
Source Table: bronze.delivery_events

Transformations Applied:
    - TRIM on string columns (event_type, location_city, on_time_flag)
    - UPPER on event_type, location_state, on_time_flag
    - Validate detention_minutes >= 0
    - Deduplication on event_id using ROW_NUMBER()
    - dwh_create_date audit timestamp

Dependencies:
    Run after: scripts/silver/02_create_transactions.sql
    Run after: scripts/bronze/05_load_transactions.sql (bronze data must exist)

Execution:
    This procedure is registered here but NOT executed automatically.
    To run the full Silver pipeline, execute: EXEC silver.load_silver;
    To run this procedure individually: EXEC silver.load_delivery_events;
===============================================================================
*/

CREATE OR ALTER PROCEDURE silver.load_delivery_events AS
BEGIN
    DECLARE @start_time DATETIME2,
            @end_time   DATETIME2,
            @rows       INT;

    SET NOCOUNT ON;

    BEGIN TRY
        SET @start_time = SYSDATETIME();
        PRINT '>> Truncating Table: silver.delivery_events';
        TRUNCATE TABLE silver.delivery_events;

        PRINT '>> Loading Data into Table: silver.delivery_events';
        INSERT INTO silver.delivery_events
        (
            event_id,
            load_id,
            trip_id,
            event_type,
            facility_id,
            scheduled_datetime,
            actual_datetime,
            detention_minutes,
            on_time_flag,
            location_city,
            location_state
        )
        SELECT
            event_id,
            load_id,
            trip_id,
            UPPER(TRIM(event_type))                                    AS event_type,
            facility_id,
            scheduled_datetime,
            actual_datetime,
            CASE
                WHEN detention_minutes >= 0 THEN detention_minutes
                ELSE NULL
            END                                                        AS detention_minutes,
            UPPER(TRIM(on_time_flag))                                  AS on_time_flag,
            TRIM(location_city)                                        AS location_city,
            UPPER(TRIM(location_state))                                AS location_state
        FROM
        (
            SELECT
                *,
                ROW_NUMBER() OVER (PARTITION BY event_id ORDER BY event_id) AS rn
            FROM bronze.delivery_events
            WHERE event_id IS NOT NULL
        ) AS deduped
        WHERE rn = 1;

        SELECT @rows = @@ROWCOUNT;
        SET @end_time = SYSDATETIME();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(MILLISECOND, @start_time, @end_time) AS NVARCHAR(50)) + ' ms';
        PRINT '>> SUCCESS: delivery_events ............ ' + CAST(@rows AS NVARCHAR(20)) + ' rows';

    END TRY
    BEGIN CATCH
        PRINT '-----------------------------------------------------------';
        PRINT 'ERROR OCCURRED DURING LOADING DELIVERY_EVENTS IN SILVER LAYER';
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT 'Error Number:  ' + CAST(ERROR_NUMBER() AS NVARCHAR(10));
        PRINT 'Error State:   ' + CAST(ERROR_STATE()  AS NVARCHAR(10));
        PRINT 'Error Line:    ' + CAST(ERROR_LINE()   AS NVARCHAR(10));
        PRINT '-----------------------------------------------------------';
    END CATCH

END;
GO
