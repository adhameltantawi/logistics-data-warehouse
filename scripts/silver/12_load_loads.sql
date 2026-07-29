/*
===============================================================================
Silver Layer -- Load Loads (Stored Procedure)
===============================================================================
Script Purpose:
    Creates and registers the stored procedure silver.load_loads.
    This procedure transforms and loads data from bronze.loads
    into silver.loads with full data cleansing.

Procedure: silver.load_loads
Target Table: silver.loads
Source Table: bronze.loads

Transformations Applied:
    - TRIM on all string columns (load_type, load_status, booking_type)
    - Validate weight_lbs > 0, pieces > 0
    - Validate revenue >= 0, fuel_surcharge >= 0, accessorial_charges >= 0
    - Deduplication on load_id using ROW_NUMBER()
    - dwh_create_date audit timestamp

Dependencies:
    Run after: scripts/silver/02_create_transactions.sql
    Run after: scripts/bronze/05_load_transactions.sql (bronze data must exist)

Execution:
    This procedure is registered here but NOT executed automatically.
    To run the full Silver pipeline, execute: EXEC silver.load_silver;
    To run this procedure individually: EXEC silver.load_loads;
===============================================================================
*/

CREATE OR ALTER PROCEDURE silver.load_loads AS
BEGIN
    DECLARE @start_time DATETIME2,
            @end_time   DATETIME2,
            @rows       INT;

    SET NOCOUNT ON;

    BEGIN TRY
        SET @start_time = SYSDATETIME();
        PRINT '>> Truncating Table: silver.loads';
        TRUNCATE TABLE silver.loads;

        PRINT '>> Loading Data into Table: silver.loads';
        INSERT INTO silver.loads
        (
            load_id,
            customer_id,
            route_id,
            load_date,
            load_type,
            weight_lbs,
            pieces,
            revenue,
            fuel_surcharge,
            accessorial_charges,
            load_status,
            booking_type
        )
        SELECT
            load_id,
            customer_id,
            route_id,
            load_date,
            TRIM(load_type)                                            AS load_type,
            CASE
                WHEN weight_lbs > 0 THEN weight_lbs
                ELSE NULL
            END                                                        AS weight_lbs,
            CASE
                WHEN pieces > 0 THEN pieces
                ELSE NULL
            END                                                        AS pieces,
            CASE
                WHEN revenue >= 0 THEN revenue
                ELSE NULL
            END                                                        AS revenue,
            CASE
                WHEN fuel_surcharge >= 0 THEN fuel_surcharge
                ELSE NULL
            END                                                        AS fuel_surcharge,
            CASE
                WHEN accessorial_charges >= 0 THEN accessorial_charges
                ELSE NULL
            END                                                        AS accessorial_charges,
            TRIM(load_status)                                          AS load_status,
            TRIM(booking_type)                                         AS booking_type
        FROM
        (
            SELECT
                *,
                ROW_NUMBER() OVER (PARTITION BY load_id ORDER BY load_id) AS rn
            FROM bronze.loads
            WHERE load_id IS NOT NULL
        ) AS deduped
        WHERE rn = 1;

        SELECT @rows = @@ROWCOUNT;
        SET @end_time = SYSDATETIME();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(MILLISECOND, @start_time, @end_time) AS NVARCHAR(50)) + ' ms';
        PRINT '>> SUCCESS: loads ............ ' + CAST(@rows AS NVARCHAR(20)) + ' rows';

    END TRY
    BEGIN CATCH
        PRINT '-----------------------------------------------------------';
        PRINT 'ERROR OCCURRED DURING LOADING LOADS IN SILVER LAYER';
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT 'Error Number:  ' + CAST(ERROR_NUMBER() AS NVARCHAR(10));
        PRINT 'Error State:   ' + CAST(ERROR_STATE()  AS NVARCHAR(10));
        PRINT 'Error Line:    ' + CAST(ERROR_LINE()   AS NVARCHAR(10));
        PRINT '-----------------------------------------------------------';
    END CATCH

END;
GO
