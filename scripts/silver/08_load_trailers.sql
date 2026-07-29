/*
===============================================================================
Silver Layer -- Load Trailers (Stored Procedure)
===============================================================================
Script Purpose:
    Creates and registers the stored procedure silver.load_trailers.
    This procedure transforms and loads data from bronze.trailers
    into silver.trailers with full data cleansing.

Procedure: silver.load_trailers
Target Table: silver.trailers
Source Table: bronze.trailers

Transformations Applied:
    - TRIM on all string columns (trailer_type, vin, current_location)
    - UPPER on vin
    - Standardise status (TRIM)
    - Validate model_year within reasonable range (1990-2030)
    - Validate length_feet > 0
    - Deduplication on trailer_id using ROW_NUMBER()
    - dwh_create_date audit timestamp

Dependencies:
    Run after: scripts/silver/01_create_reference.sql
    Run after: scripts/bronze/04_load_reference.sql (bronze data must exist)

Execution:
    This procedure is registered here but NOT executed automatically.
    To run the full Silver pipeline, execute: EXEC silver.load_silver;
    To run this procedure individually: EXEC silver.load_trailers;
===============================================================================
*/

CREATE OR ALTER PROCEDURE silver.load_trailers AS
BEGIN
    DECLARE @start_time DATETIME2,
            @end_time   DATETIME2,
            @rows       INT;

    SET NOCOUNT ON;

    BEGIN TRY
        SET @start_time = SYSDATETIME();
        PRINT '>> Truncating Table: silver.trailers';
        TRUNCATE TABLE silver.trailers;

        PRINT '>> Loading Data into Table: silver.trailers';
        INSERT INTO silver.trailers
        (
            trailer_id,
            trailer_number,
            trailer_type,
            length_feet,
            model_year,
            vin,
            acquisition_date,
            status,
            current_location
        )
        SELECT
            trailer_id,
            trailer_number,
            TRIM(trailer_type)                                         AS trailer_type,
            CASE
                WHEN length_feet > 0 THEN length_feet
                ELSE NULL
            END                                                        AS length_feet,
            CASE
                WHEN model_year BETWEEN 1990 AND 2030 THEN model_year
                ELSE NULL
            END                                                        AS model_year,
            UPPER(TRIM(vin))                                           AS vin,
            acquisition_date,
            TRIM(status)                                               AS status,
            TRIM(current_location)                                     AS current_location
        FROM
        (
            SELECT
                *,
                ROW_NUMBER() OVER (PARTITION BY trailer_id ORDER BY trailer_id) AS rn
            FROM bronze.trailers
            WHERE trailer_id IS NOT NULL
        ) AS deduped
        WHERE rn = 1;

        SELECT @rows = @@ROWCOUNT;
        SET @end_time = SYSDATETIME();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(MILLISECOND, @start_time, @end_time) AS NVARCHAR(50)) + ' ms';
        PRINT '>> SUCCESS: trailers ............ ' + CAST(@rows AS NVARCHAR(20)) + ' rows';

    END TRY
    BEGIN CATCH
        PRINT '-----------------------------------------------------------';
        PRINT 'ERROR OCCURRED DURING LOADING TRAILERS IN SILVER LAYER';
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT 'Error Number:  ' + CAST(ERROR_NUMBER() AS NVARCHAR(10));
        PRINT 'Error State:   ' + CAST(ERROR_STATE()  AS NVARCHAR(10));
        PRINT 'Error Line:    ' + CAST(ERROR_LINE()   AS NVARCHAR(10));
        PRINT '-----------------------------------------------------------';
    END CATCH

END;
GO
