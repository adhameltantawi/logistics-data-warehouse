CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
    DECLARE @batch_start_time DATETIME2, @batch_end_time DATETIME2
    SET NOCOUNT ON;
    SET @batch_start_time = SYSDATETIME();

        PRINT '===========================================================';
        PRINT 'Loading Bronze Layer';
        PRINT '===========================================================';
        EXEC bronze.load_reference_bronze;
        EXEC bronze.load_transactions_bronze;
        EXEC bronze.load_analytics_bronze;

    SET @batch_end_time = SYSDATETIME();
        PRINT '================================================';
        PRINT 'Loading Bronze Layer is Completed';
        PRINT '   - Total Load Duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR(50)) + ' seconds';
        PRINT '================================================';

END;
GO

EXEC bronze.load_bronze;