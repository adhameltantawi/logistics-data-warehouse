CREATE OR ALTER PROCEDURE bronze.load_transactions_bronze AS
BEGIN
    DECLARE @start_time DATETIME2, @end_time DATETIME2, @start_batch_time DATETIME2, @end_batch_time DATETIME2, @rows INT
    SET NOCOUNT ON;
    BEGIN TRY
        SET @start_batch_time = SYSDATETIME();
        PRINT '-----------------------------------------------------------';
        PRINT 'Loading Transactions csv files into bronze layer';
        PRINT '-----------------------------------------------------------';

        SET @start_time = SYSDATETIME();
        PRINT '>> Truncating Table: bronze.delivery_events';
        TRUNCATE TABLE bronze.delivery_events

        PRINT '>> Loading Data into Table: bronze.delivery_events';
        BULK INSERT bronze.delivery_events
        FROM 'D:\data\data projects\logistics-data-warehouse\datasets\transactions\delivery_events.csv'
        WITH
        ( 
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0A',
            TABLOCK
        );
        SELECT @rows = @@ROWCOUNT;
        SET @end_time = SYSDATETIME();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(50)) + ' seconds';
        PRINT '>> SUCCESS: delivery_events ............ '+  CAST(@rows AS NVARCHAR(20)) + ' rows';


        SET @start_time = SYSDATETIME();
        PRINT '>> Truncating Table: bronze.fuel_purchases';
        TRUNCATE TABLE bronze.fuel_purchases

        PRINT '>> Loading Data into Table: bronze.fuel_purchases';        
        BULK INSERT bronze.fuel_purchases
        FROM 'D:\data\data projects\logistics-data-warehouse\datasets\transactions\fuel_purchases.csv'
        WITH
        (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0A',
            TABLOCK
        );
        SELECT @rows = @@ROWCOUNT;
        SET @end_time = SYSDATETIME();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(50)) + ' seconds';
        PRINT '>> SUCCESS: fuel_purchases ............ '+  CAST(@rows AS NVARCHAR(20)) + ' rows';


        SET @start_time = SYSDATETIME();
        PRINT '>> Truncating Table: bronze.loads';
        TRUNCATE TABLE bronze.loads

        PRINT '>> Loading Data into Table: bronze.loads';
        BULK INSERT bronze.loads
        FROM 'D:\data\data projects\logistics-data-warehouse\datasets\transactions\loads.csv'
        WITH
        (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0A',
            TABLOCK
        );
        SELECT @rows = @@ROWCOUNT;
        SET @end_time = SYSDATETIME();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(50)) + ' seconds';
        PRINT '>> SUCCESS: loads ............ '+  CAST(@rows AS NVARCHAR(20)) + ' rows';


        SET @start_time = SYSDATETIME();
        PRINT '>> Truncating Table: bronze.maintenance_records';
        TRUNCATE TABLE bronze.maintenance_records

        PRINT '>> Loading Data into Table: bronze.maintenance_records';
        BULK INSERT bronze.maintenance_records
        FROM 'D:\data\data projects\logistics-data-warehouse\datasets\transactions\maintenance_records.csv'
        WITH
        (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0A',
            TABLOCK
        );
        SELECT @rows = @@ROWCOUNT;
        SET @end_time = SYSDATETIME();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(50)) + ' seconds';
        PRINT '>> SUCCESS: maintenance_records ............ '+  CAST(@rows AS NVARCHAR(20)) + ' rows';


        SET @start_time = SYSDATETIME();
        PRINT '>> Truncating Table: bronze.safety_incidents';
        TRUNCATE TABLE bronze.safety_incidents

        PRINT '>> Loading Data into Table: bronze.safety_incidents';
        BULK INSERT bronze.safety_incidents
        FROM 'D:\data\data projects\logistics-data-warehouse\datasets\transactions\safety_incidents.csv'
        WITH
        (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0A',
            TABLOCK
        );
        SELECT @rows = @@ROWCOUNT;
        SET @end_time = SYSDATETIME();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(50)) + ' seconds';
        PRINT '>> SUCCESS: safety_incidents ............ '+  CAST(@rows AS NVARCHAR(20)) + ' rows';


        SET @start_time = SYSDATETIME();
        PRINT '>> Truncating Table: bronze.trips';
        TRUNCATE TABLE bronze.trips

        PRINT '>> Loading Data into Table: bronze.trips';
        BULK INSERT bronze.trips
        FROM 'D:\data\data projects\logistics-data-warehouse\datasets\transactions\trips.csv'
        WITH
        (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0A',
            TABLOCK
        );
        SELECT @rows = @@ROWCOUNT;
        SET @end_time = SYSDATETIME();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(50)) + ' seconds';
        PRINT '>> SUCCESS: trips ............ '+  CAST(@rows AS NVARCHAR(20)) + ' rows';


        SET @end_batch_time = SYSDATETIME();
        PRINT '-----------------------------------------------------------';
        PRINT 'Transactions Data Load Completed Successfully';
        PRINT '   - Total Load Duration: ' + CAST(DATEDIFF(SECOND, @start_batch_time, @end_batch_time) AS NVARCHAR(50)) + ' seconds';
        PRINT '-----------------------------------------------------------';
        PRINT '';


    END TRY
    BEGIN CATCH
        PRINT '-----------------------------------------------------------';
        PRINT 'ERROR OCCURRED DURING LOADING TRANSACTIONS IN BRONZE LAYER';
        PRINT 'Error Message: ' + ERROR_MESSAGE() ;
        PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS NVARCHAR(10));
        PRINT 'Error State: ' + CAST(ERROR_STATE() AS NVARCHAR(10));
        PRINT '-----------------------------------------------------------';
    END CATCH
END;
GO
EXEC bronze.load_transactions_bronze


-- SELECT * FROM bronze.delivery_events
-- SELECT * FROM bronze.fuel_purchases
-- SELECT * FROM bronze.loads
-- SELECT * FROM bronze.maintenance_records
-- SELECT * FROM bronze.safety_incidents
-- SELECT * FROM bronze.trips