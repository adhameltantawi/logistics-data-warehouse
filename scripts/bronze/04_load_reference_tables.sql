CREATE OR ALTER PROCEDURE bronze.load_reference_bronze AS
BEGIN
    DECLARE @start_time DATETIME2, @end_time DATETIME2, @start_batch_time DATETIME2, @end_batch_time DATETIME2
    SET NOCOUNT ON;
    BEGIN TRY
        SET @start_batch_time = SYSDATETIME();
        PRINT '========================================================';
        PRINT 'Loading Reference csv files into bronze layer';
        PRINT '========================================================';

        SET @start_time = SYSDATETIME();
        PRINT '>> Truncating Table: bronze.drivers';
        TRUNCATE TABLE bronze.drivers

        PRINT '>> Loading Data into Table: bronze.drivers';
        BULK INSERT bronze.drivers
        FROM 'D:\data\data projects\logistics-data-warehouse\datasets\reference\drivers.csv'
        WITH
        ( 
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0A',
            TABLOCK
        );
        SET @end_time = SYSDATETIME();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(50)) + ' seconds';
        PRINT '>> ✔ drivers ............ '+  CAST(@@ROWCOUNT AS NVARCHAR(20)) + ' rows';


        SET @start_time = SYSDATETIME();
        PRINT '>> Truncating Table: bronze.customers';
        TRUNCATE TABLE bronze.customers

        PRINT '>> Loading Data into Table: bronze.customers';        
        BULK INSERT bronze.customers
        FROM 'D:\data\data projects\logistics-data-warehouse\datasets\reference\customers.csv'
        WITH
        (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0A',
            TABLOCK
        );
        SET @end_time = SYSDATETIME();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(50)) + ' seconds';
        PRINT '>> -------------';


        SET @start_time = SYSDATETIME();
        PRINT '>> Truncating Table: bronze.facilities';
        TRUNCATE TABLE bronze.facilities

        PRINT '>> Loading Data into Table: bronze.facilities';
        BULK INSERT bronze.facilities
        FROM 'D:\data\data projects\logistics-data-warehouse\datasets\reference\facilities.csv'
        WITH
        (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0A',
            TABLOCK
        );
        SET @end_time = SYSDATETIME();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(50)) + ' seconds';
        PRINT '>> -------------';


        SET @start_time = SYSDATETIME();
        PRINT '>> Truncating Table: bronze.routes';
        TRUNCATE TABLE bronze.routes

        PRINT '>> Loading Data into Table: bronze.routes';
        BULK INSERT bronze.routes
        FROM 'D:\data\data projects\logistics-data-warehouse\datasets\reference\routes.csv'
        WITH
        (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0A',
            TABLOCK
        );
        SET @end_time = SYSDATETIME();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(50)) + ' seconds';
        PRINT '>> -------------';


        SET @start_time = SYSDATETIME();
        PRINT '>> Truncating Table: bronze.trailers';
        TRUNCATE TABLE bronze.trailers

        PRINT '>> Loading Data into Table: bronze.trailers';
        BULK INSERT bronze.trailers
        FROM 'D:\data\data projects\logistics-data-warehouse\datasets\reference\trailers.csv'
        WITH
        (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0A',
            TABLOCK
        );
        SET @end_time = SYSDATETIME();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(50)) + ' seconds';
        PRINT '>> -------------';


        SET @start_time = SYSDATETIME();
        PRINT '>> Truncating Table: bronze.trucks';
        TRUNCATE TABLE bronze.trucks

        PRINT '>> Loading Data into Table: bronze.trucks';
        BULK INSERT bronze.trucks
        FROM 'D:\data\data projects\logistics-data-warehouse\datasets\reference\trucks.csv'
        WITH
        (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0A',
            TABLOCK
        );
        SET @end_time = SYSDATETIME();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(50)) + ' seconds';
        PRINT '>> -------------';
        SET @end_batch_time = SYSDATETIME();
        PRINT '========================================================';
        PRINT 'Reference Data Load Completed Successfully';
        PRINT '   - Total Load Duration: ' + CAST(DATEDIFF(SECOND, @start_batch_time, @end_batch_time) AS NVARCHAR(50)) + ' seconds';
        PRINT '========================================================';


    END TRY
    BEGIN CATCH
        PRINT '========================================================';
        PRINT 'ERROR OCCURRED DURING LOADING REFERENCE IN BRONZE LAYER';
        PRINT 'Error Message: ' + ERROR_MESSAGE() ;
        PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS NVARCHAR(10));
        PRINT 'Error State: ' + CAST(ERROR_STATE() AS NVARCHAR(10));
        PRINT '========================================================';
    END CATCH
END;
GO
EXEC bronze.load_reference_bronze


-- SELECT * FROM bronze.drivers
-- SELECT * FROM bronze.customers
-- SELECT * FROM bronze.facilities
-- SELECT * FROM bronze.routes
-- SELECT * FROM bronze.trailers
-- SELECT * FROM bronze.trucks