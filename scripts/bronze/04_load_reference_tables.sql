CREATE OR ALTER PROCEDURE bronze.load_reference_bronze AS
BEGIN
    BEGIN TRY
        TRUNCATE TABLE bronze.drivers
        BULK INSERT bronze.drivers
        FROM 'D:\data\data projects\logistics-data-warehouse\datasets\reference\drivers.csv'
        WITH
        (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0A',
            TABLOCK
        );

        TRUNCATE TABLE bronze.customers
        BULK INSERT bronze.customers
        FROM 'D:\data\data projects\logistics-data-warehouse\datasets\reference\customers.csv'
        WITH
        (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0A',
            TABLOCK
        );

        TRUNCATE TABLE bronze.facilities
        BULK INSERT bronze.facilities
        FROM 'D:\data\data projects\logistics-data-warehouse\datasets\reference\facilities.csv'
        WITH
        (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0A',
            TABLOCK
        );

        TRUNCATE TABLE bronze.routes
        BULK INSERT bronze.routes
        FROM 'D:\data\data projects\logistics-data-warehouse\datasets\reference\routes.csv'
        WITH
        (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0A',
            TABLOCK
        );

        TRUNCATE TABLE bronze.trailers
        BULK INSERT bronze.trailers
        FROM 'D:\data\data projects\logistics-data-warehouse\datasets\reference\trailers.csv'
        WITH
        (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0A',
            TABLOCK
        );

        TRUNCATE TABLE bronze.trucks
        BULK INSERT bronze.trucks
        FROM 'D:\data\data projects\logistics-data-warehouse\datasets\reference\trucks.csv'
        WITH
        (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0A',
            TABLOCK
        );
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

EXEC bronze.load_reference_bronze


-- SELECT * FROM bronze.drivers
-- SELECT * FROM bronze.customers
-- SELECT * FROM bronze.facilities
-- SELECT * FROM bronze.routes
-- SELECT * FROM bronze.trailers
-- SELECT * FROM bronze.trucks