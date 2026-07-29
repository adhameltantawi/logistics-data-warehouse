/*
===============================================================================
Silver Layer -- Load Trucks (Stored Procedure)
===============================================================================
Script Purpose:
    Creates and registers the stored procedure silver.load_trucks.
    This procedure transforms and loads data from bronze.trucks
    into silver.trucks with full data cleansing.

Procedure: silver.load_trucks
Target Table: silver.trucks
Source Table: bronze.trucks

Transformations Applied:
    - TRIM on all string columns (make, fuel_type, status, home_terminal)
    - UPPER on vin
    - Validate model_year within reasonable range (1990-2030)
    - Validate acquisition_mileage >= 0
    - Validate tank_capacity_gallons > 0
    - Deduplication on truck_id using ROW_NUMBER()
    - dwh_create_date audit timestamp

Dependencies:
    Run after: scripts/silver/01_create_reference.sql
    Run after: scripts/bronze/04_load_reference.sql (bronze data must exist)

Execution:
    This procedure is registered here but NOT executed automatically.
    To run the full Silver pipeline, execute: EXEC silver.load_silver;
    To run this procedure individually: EXEC silver.load_trucks;
===============================================================================
*/

CREATE OR ALTER PROCEDURE silver.load_trucks AS
BEGIN
    DECLARE @start_time DATETIME2,
            @end_time   DATETIME2,
            @rows       INT;

    SET NOCOUNT ON;

    BEGIN TRY
        SET @start_time = SYSDATETIME();
        PRINT '>> Truncating Table: silver.trucks';
        TRUNCATE TABLE silver.trucks;

        PRINT '>> Loading Data into Table: silver.trucks';
        INSERT INTO silver.trucks
        (
            truck_id,
            unit_number,
            make,
            model_year,
            vin,
            acquisition_date,
            acquisition_mileage,
            fuel_type,
            tank_capacity_gallons,
            status,
            home_terminal
        )
        SELECT
            truck_id,
            unit_number,
            TRIM(make)                                                 AS make,
            CASE
                WHEN model_year BETWEEN 1990 AND 2030 THEN model_year
                ELSE NULL
            END                                                        AS model_year,
            UPPER(TRIM(vin))                                           AS vin,
            acquisition_date,
            CASE
                WHEN acquisition_mileage >= 0 THEN acquisition_mileage
                ELSE NULL
            END                                                        AS acquisition_mileage,
            TRIM(fuel_type)                                            AS fuel_type,
            CASE
                WHEN tank_capacity_gallons > 0 THEN tank_capacity_gallons
                ELSE NULL
            END                                                        AS tank_capacity_gallons,
            TRIM(status)                                               AS status,
            TRIM(home_terminal)                                        AS home_terminal
        FROM
        (
            SELECT
                *,
                ROW_NUMBER() OVER (PARTITION BY truck_id ORDER BY truck_id) AS rn
            FROM bronze.trucks
            WHERE truck_id IS NOT NULL
        ) AS deduped
        WHERE rn = 1;

        SELECT @rows = @@ROWCOUNT;
        SET @end_time = SYSDATETIME();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(MILLISECOND, @start_time, @end_time) AS NVARCHAR(50)) + ' ms';
        PRINT '>> SUCCESS: trucks ............ ' + CAST(@rows AS NVARCHAR(20)) + ' rows';

    END TRY
    BEGIN CATCH
        PRINT '-----------------------------------------------------------';
        PRINT 'ERROR OCCURRED DURING LOADING TRUCKS IN SILVER LAYER';
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT 'Error Number:  ' + CAST(ERROR_NUMBER() AS NVARCHAR(10));
        PRINT 'Error State:   ' + CAST(ERROR_STATE()  AS NVARCHAR(10));
        PRINT 'Error Line:    ' + CAST(ERROR_LINE()   AS NVARCHAR(10));
        PRINT '-----------------------------------------------------------';
    END CATCH

END;
GO
