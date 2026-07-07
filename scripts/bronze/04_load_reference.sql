/*
===============================================================================
Bronze Layer -- Load Reference Tables (Stored Procedure)
===============================================================================
Script Purpose:
    Creates and registers the stored procedure bronze.load_reference_bronze.
    This procedure loads raw CSV data into the 6 reference staging tables
    using BULK INSERT with timing and row-count logging per table.

Procedure: bronze.load_reference_bronze
Tables Loaded:
    - bronze.drivers
    - bronze.customers
    - bronze.facilities
    - bronze.routes
    - bronze.trailers
    - bronze.trucks

Dependencies:
    Run after: scripts/init_database.sql
    Run after: scripts/bronze/01_create_reference.sql

Execution:
    This procedure is registered here but NOT executed automatically.
    To run the full Bronze pipeline, execute: scripts/bronze/07_load_bronze_layer.sql
    To run this procedure individually: EXEC bronze.load_reference_bronze;
===============================================================================
*/

CREATE OR ALTER PROCEDURE bronze.load_reference_bronze AS
BEGIN
    DECLARE @start_time      DATETIME2,
            @end_time        DATETIME2,
            @start_batch_time DATETIME2,
            @end_batch_time  DATETIME2,
            @rows            INT;

    SET NOCOUNT ON;

    BEGIN TRY
        SET @start_batch_time = SYSDATETIME();
        PRINT '-----------------------------------------------------------';
        PRINT 'Loading Reference CSV files into Bronze layer';
        PRINT '-----------------------------------------------------------';

        -- -------------------------------------------------------
        -- bronze.drivers
        -- -------------------------------------------------------
        SET @start_time = SYSDATETIME();
        PRINT '>> Truncating Table: bronze.drivers';
        TRUNCATE TABLE bronze.drivers;

        PRINT '>> Loading Data into Table: bronze.drivers';
        BULK INSERT bronze.drivers
        FROM 'D:\data\data projects\logistics-data-warehouse\datasets\reference\drivers.csv'
        WITH
        (
            FIRSTROW       = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR  = '0x0A',
            TABLOCK
        );
        SELECT @rows = @@ROWCOUNT;
        SET @end_time = SYSDATETIME();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(MILLISECOND, @start_time, @end_time) AS NVARCHAR(50)) + ' ms';
        PRINT '>> SUCCESS: drivers ............ ' + CAST(@rows AS NVARCHAR(20)) + ' rows';

        -- -------------------------------------------------------
        -- bronze.customers
        -- -------------------------------------------------------
        SET @start_time = SYSDATETIME();
        PRINT '>> Truncating Table: bronze.customers';
        TRUNCATE TABLE bronze.customers;

        PRINT '>> Loading Data into Table: bronze.customers';
        BULK INSERT bronze.customers
        FROM 'D:\data\data projects\logistics-data-warehouse\datasets\reference\customers.csv'
        WITH
        (
            FIRSTROW       = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR  = '0x0A',
            TABLOCK
        );
        SELECT @rows = @@ROWCOUNT;
        SET @end_time = SYSDATETIME();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(MILLISECOND, @start_time, @end_time) AS NVARCHAR(50)) + ' ms';
        PRINT '>> SUCCESS: customers ............ ' + CAST(@rows AS NVARCHAR(20)) + ' rows';

        -- -------------------------------------------------------
        -- bronze.facilities
        -- -------------------------------------------------------
        SET @start_time = SYSDATETIME();
        PRINT '>> Truncating Table: bronze.facilities';
        TRUNCATE TABLE bronze.facilities;

        PRINT '>> Loading Data into Table: bronze.facilities';
        BULK INSERT bronze.facilities
        FROM 'D:\data\data projects\logistics-data-warehouse\datasets\reference\facilities.csv'
        WITH
        (
            FIRSTROW       = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR  = '0x0A',
            TABLOCK
        );
        SELECT @rows = @@ROWCOUNT;
        SET @end_time = SYSDATETIME();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(MILLISECOND, @start_time, @end_time) AS NVARCHAR(50)) + ' ms';
        PRINT '>> SUCCESS: facilities ............ ' + CAST(@rows AS NVARCHAR(20)) + ' rows';

        -- -------------------------------------------------------
        -- bronze.routes
        -- -------------------------------------------------------
        SET @start_time = SYSDATETIME();
        PRINT '>> Truncating Table: bronze.routes';
        TRUNCATE TABLE bronze.routes;

        PRINT '>> Loading Data into Table: bronze.routes';
        BULK INSERT bronze.routes
        FROM 'D:\data\data projects\logistics-data-warehouse\datasets\reference\routes.csv'
        WITH
        (
            FIRSTROW       = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR  = '0x0A',
            TABLOCK
        );
        SELECT @rows = @@ROWCOUNT;
        SET @end_time = SYSDATETIME();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(MILLISECOND, @start_time, @end_time) AS NVARCHAR(50)) + ' ms';
        PRINT '>> SUCCESS: routes ............ ' + CAST(@rows AS NVARCHAR(20)) + ' rows';

        -- -------------------------------------------------------
        -- bronze.trailers
        -- -------------------------------------------------------
        SET @start_time = SYSDATETIME();
        PRINT '>> Truncating Table: bronze.trailers';
        TRUNCATE TABLE bronze.trailers;

        PRINT '>> Loading Data into Table: bronze.trailers';
        BULK INSERT bronze.trailers
        FROM 'D:\data\data projects\logistics-data-warehouse\datasets\reference\trailers.csv'
        WITH
        (
            FIRSTROW       = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR  = '0x0A',
            TABLOCK
        );
        SELECT @rows = @@ROWCOUNT;
        SET @end_time = SYSDATETIME();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(MILLISECOND, @start_time, @end_time) AS NVARCHAR(50)) + ' ms';
        PRINT '>> SUCCESS: trailers ............ ' + CAST(@rows AS NVARCHAR(20)) + ' rows';

        -- -------------------------------------------------------
        -- bronze.trucks
        -- -------------------------------------------------------
        SET @start_time = SYSDATETIME();
        PRINT '>> Truncating Table: bronze.trucks';
        TRUNCATE TABLE bronze.trucks;

        PRINT '>> Loading Data into Table: bronze.trucks';
        BULK INSERT bronze.trucks
        FROM 'D:\data\data projects\logistics-data-warehouse\datasets\reference\trucks.csv'
        WITH
        (
            FIRSTROW       = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR  = '0x0A',
            TABLOCK
        );
        SELECT @rows = @@ROWCOUNT;
        SET @end_time = SYSDATETIME();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(MILLISECOND, @start_time, @end_time) AS NVARCHAR(50)) + ' ms';
        PRINT '>> SUCCESS: trucks ............ ' + CAST(@rows AS NVARCHAR(20)) + ' rows';

        SET @end_batch_time = SYSDATETIME();
        PRINT '-----------------------------------------------------------';
        PRINT 'Reference Data Load Completed Successfully';
        PRINT '   - Total Load Duration: ' + CAST(DATEDIFF(SECOND, @start_batch_time, @end_batch_time) AS NVARCHAR(50)) + ' seconds';
        PRINT '-----------------------------------------------------------';
        PRINT '';

    END TRY
    BEGIN CATCH
        PRINT '-----------------------------------------------------------';
        PRINT 'ERROR OCCURRED DURING LOADING REFERENCE IN BRONZE LAYER';
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT 'Error Number:  ' + CAST(ERROR_NUMBER() AS NVARCHAR(10));
        PRINT 'Error State:   ' + CAST(ERROR_STATE()  AS NVARCHAR(10));
        PRINT 'Error Line:    ' + CAST(ERROR_LINE()   AS NVARCHAR(10));
        PRINT '-----------------------------------------------------------';
    END CATCH

END;
GO

-- Verification queries (uncomment to run after loading)
-- SELECT * FROM bronze.drivers;
-- SELECT * FROM bronze.customers;
-- SELECT * FROM bronze.facilities;
-- SELECT * FROM bronze.routes;
-- SELECT * FROM bronze.trailers;
-- SELECT * FROM bronze.trucks;