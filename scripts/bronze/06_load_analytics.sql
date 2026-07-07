/*
===============================================================================
Bronze Layer -- Load Analytics Tables (Stored Procedure)
===============================================================================
Script Purpose:
    Creates and registers the stored procedure bronze.load_analytics_bronze.
    This procedure loads raw CSV data into the 2 pre-aggregated analytics
    staging tables using BULK INSERT with timing and row-count logging.

Procedure: bronze.load_analytics_bronze
Tables Loaded:
    - bronze.driver_monthly_metrics
    - bronze.truck_utilization_metrics

Dependencies:
    Run after: scripts/init_database.sql
    Run after: scripts/bronze/03_create_analytics.sql

Execution:
    This procedure is registered here but NOT executed automatically.
    To run the full Bronze pipeline, execute: scripts/bronze/07_load_bronze_layer.sql
    To run this procedure individually: EXEC bronze.load_analytics_bronze;
===============================================================================
*/

CREATE OR ALTER PROCEDURE bronze.load_analytics_bronze AS
BEGIN
    DECLARE @start_time       DATETIME2,
            @end_time         DATETIME2,
            @start_batch_time DATETIME2,
            @end_batch_time   DATETIME2,
            @rows             INT;

    SET NOCOUNT ON;

    BEGIN TRY
        SET @start_batch_time = SYSDATETIME();
        PRINT '-----------------------------------------------------------';
        PRINT 'Loading Analytics CSV files into Bronze layer';
        PRINT '-----------------------------------------------------------';

        -- -------------------------------------------------------
        -- bronze.driver_monthly_metrics
        -- -------------------------------------------------------
        SET @start_time = SYSDATETIME();
        PRINT '>> Truncating Table: bronze.driver_monthly_metrics';
        TRUNCATE TABLE bronze.driver_monthly_metrics;

        PRINT '>> Loading Data into Table: bronze.driver_monthly_metrics';
        BULK INSERT bronze.driver_monthly_metrics
        FROM 'D:\data\data projects\logistics-data-warehouse\datasets\analytics\driver_monthly_metrics.csv'
        WITH
        (
            FIRSTROW        = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR   = '0x0A',
            TABLOCK
        );
        SELECT @rows = @@ROWCOUNT;
        SET @end_time = SYSDATETIME();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(50)) + ' seconds';
        PRINT '>> SUCCESS: driver_monthly_metrics ............ ' + CAST(@rows AS NVARCHAR(20)) + ' rows';

        -- -------------------------------------------------------
        -- bronze.truck_utilization_metrics
        -- -------------------------------------------------------
        SET @start_time = SYSDATETIME();
        PRINT '>> Truncating Table: bronze.truck_utilization_metrics';
        TRUNCATE TABLE bronze.truck_utilization_metrics;

        PRINT '>> Loading Data into Table: bronze.truck_utilization_metrics';
        BULK INSERT bronze.truck_utilization_metrics
        FROM 'D:\data\data projects\logistics-data-warehouse\datasets\analytics\truck_utilization_metrics.csv'
        WITH
        (
            FIRSTROW        = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR   = '0x0A',
            TABLOCK
        );
        SELECT @rows = @@ROWCOUNT;
        SET @end_time = SYSDATETIME();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(50)) + ' seconds';
        PRINT '>> SUCCESS: truck_utilization_metrics ............ ' + CAST(@rows AS NVARCHAR(20)) + ' rows';

        SET @end_batch_time = SYSDATETIME();
        PRINT '-----------------------------------------------------------';
        PRINT 'Analytics Data Load Completed Successfully';
        PRINT '   - Total Load Duration: ' + CAST(DATEDIFF(SECOND, @start_batch_time, @end_batch_time) AS NVARCHAR(50)) + ' seconds';
        PRINT '-----------------------------------------------------------';
        PRINT '';

    END TRY
    BEGIN CATCH
        PRINT '-----------------------------------------------------------';
        PRINT 'ERROR OCCURRED DURING LOADING ANALYTICS IN BRONZE LAYER';
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT 'Error Number:  ' + CAST(ERROR_NUMBER() AS NVARCHAR(10));
        PRINT 'Error State:   ' + CAST(ERROR_STATE()  AS NVARCHAR(10));
        PRINT 'Error Line:    ' + CAST(ERROR_LINE()   AS NVARCHAR(10));
        PRINT '-----------------------------------------------------------';
    END CATCH

END;
GO

-- Verification queries (uncomment to run after loading)
-- SELECT * FROM bronze.driver_monthly_metrics;
-- SELECT * FROM bronze.truck_utilization_metrics;
