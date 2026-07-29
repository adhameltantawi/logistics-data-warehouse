/*
===============================================================================
Silver Layer -- Load Fuel Purchases (Stored Procedure)
===============================================================================
Script Purpose:
    Creates and registers the stored procedure silver.load_fuel_purchases.
    This procedure transforms and loads data from bronze.fuel_purchases
    into silver.fuel_purchases with full data cleansing.

Procedure: silver.load_fuel_purchases
Target Table: silver.fuel_purchases
Source Table: bronze.fuel_purchases

Transformations Applied:
    - TRIM on string columns (location_city, fuel_card_number)
    - UPPER on location_state
    - Validate gallons > 0, price_per_gallon > 0, total_cost >= 0
    - Deduplication on fuel_purchase_id using ROW_NUMBER()
    - dwh_create_date audit timestamp

Dependencies:
    Run after: scripts/silver/02_create_transactions.sql
    Run after: scripts/bronze/05_load_transactions.sql (bronze data must exist)

Execution:
    This procedure is registered here but NOT executed automatically.
    To run the full Silver pipeline, execute: EXEC silver.load_silver;
    To run this procedure individually: EXEC silver.load_fuel_purchases;
===============================================================================
*/

CREATE OR ALTER PROCEDURE silver.load_fuel_purchases AS
BEGIN
    DECLARE @start_time DATETIME2,
            @end_time   DATETIME2,
            @rows       INT;

    SET NOCOUNT ON;

    BEGIN TRY
        SET @start_time = SYSDATETIME();
        PRINT '>> Truncating Table: silver.fuel_purchases';
        TRUNCATE TABLE silver.fuel_purchases;

        PRINT '>> Loading Data into Table: silver.fuel_purchases';
        INSERT INTO silver.fuel_purchases
        (
            fuel_purchase_id,
            trip_id,
            truck_id,
            driver_id,
            purchase_date,
            location_city,
            location_state,
            gallons,
            price_per_gallon,
            total_cost,
            fuel_card_number
        )
        SELECT
            fuel_purchase_id,
            trip_id,
            truck_id,
            driver_id,
            purchase_date,
            TRIM(location_city)                                        AS location_city,
            UPPER(TRIM(location_state))                                AS location_state,
            CASE
                WHEN gallons > 0 THEN gallons
                ELSE NULL
            END                                                        AS gallons,
            CASE
                WHEN price_per_gallon > 0 THEN price_per_gallon
                ELSE NULL
            END                                                        AS price_per_gallon,
            CASE
                WHEN total_cost >= 0 THEN total_cost
                ELSE NULL
            END                                                        AS total_cost,
            TRIM(fuel_card_number)                                     AS fuel_card_number
        FROM
        (
            SELECT
                *,
                ROW_NUMBER() OVER (PARTITION BY fuel_purchase_id ORDER BY fuel_purchase_id) AS rn
            FROM bronze.fuel_purchases
            WHERE fuel_purchase_id IS NOT NULL
        ) AS deduped
        WHERE rn = 1;

        SELECT @rows = @@ROWCOUNT;
        SET @end_time = SYSDATETIME();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(MILLISECOND, @start_time, @end_time) AS NVARCHAR(50)) + ' ms';
        PRINT '>> SUCCESS: fuel_purchases ............ ' + CAST(@rows AS NVARCHAR(20)) + ' rows';

    END TRY
    BEGIN CATCH
        PRINT '-----------------------------------------------------------';
        PRINT 'ERROR OCCURRED DURING LOADING FUEL_PURCHASES IN SILVER LAYER';
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT 'Error Number:  ' + CAST(ERROR_NUMBER() AS NVARCHAR(10));
        PRINT 'Error State:   ' + CAST(ERROR_STATE()  AS NVARCHAR(10));
        PRINT 'Error Line:    ' + CAST(ERROR_LINE()   AS NVARCHAR(10));
        PRINT '-----------------------------------------------------------';
    END CATCH

END;
GO
