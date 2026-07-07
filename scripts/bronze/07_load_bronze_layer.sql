/*
===============================================================================
Bronze Layer -- Master Load Orchestrator (Stored Procedure)
===============================================================================
Script Purpose:
    Creates and executes the master orchestrator procedure bronze.load_bronze.
    This is the single entry point to load the entire Bronze layer.
    It calls the three sub-procedures in the correct dependency order:
        1. bronze.load_reference_bronze    (reference/dimension tables)
        2. bronze.load_transactions_bronze (operational transaction tables)
        3. bronze.load_analytics_bronze    (pre-aggregated analytics tables)

Procedure: bronze.load_bronze

Dependencies:
    Run after:
        - scripts/init_database.sql
        - scripts/bronze/01_create_reference.sql
        - scripts/bronze/02_create_transactions.sql
        - scripts/bronze/03_create_analytics.sql
        - scripts/bronze/04_load_reference.sql
        - scripts/bronze/05_load_transactions.sql
        - scripts/bronze/06_load_analytics.sql

Execution:
    EXEC bronze.load_bronze;
===============================================================================
*/

CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
    DECLARE @batch_start_time DATETIME2,
            @batch_end_time   DATETIME2;

    SET NOCOUNT ON;

    BEGIN TRY
        SET @batch_start_time = SYSDATETIME();

        PRINT '===========================================================';
        PRINT 'Loading Bronze Layer';
        PRINT '===========================================================';

        EXEC bronze.load_reference_bronze;
        EXEC bronze.load_transactions_bronze;
        EXEC bronze.load_analytics_bronze;

        SET @batch_end_time = SYSDATETIME();
        PRINT '===========================================================';
        PRINT 'Bronze Layer Load Completed Successfully';
        PRINT '   - Total Load Duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR(50)) + ' seconds';
        PRINT '===========================================================';

    END TRY
    BEGIN CATCH
        PRINT '===========================================================';
        PRINT 'ERROR OCCURRED DURING BRONZE LAYER LOAD';
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT 'Error Number:  ' + CAST(ERROR_NUMBER() AS NVARCHAR(10));
        PRINT 'Error State:   ' + CAST(ERROR_STATE()  AS NVARCHAR(10));
        PRINT 'Error Line:    ' + CAST(ERROR_LINE()   AS NVARCHAR(10));
        PRINT '===========================================================';
    END CATCH

END;
GO

-- Execute the full Bronze pipeline
EXEC bronze.load_bronze;