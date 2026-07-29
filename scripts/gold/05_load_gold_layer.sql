/*
===============================================================================
Gold Layer -- Master Load Orchestrator (Stored Procedure)
===============================================================================
Script Purpose:
    Creates and registers the master orchestrator procedure gold.load_gold.
    This is the single entry point to load the entire Gold layer.
    It calls the two sub-procedures in the correct dependency order:
        1. gold.load_dimensions  (dimension tables must be loaded first)
        2. gold.load_facts       (fact tables reference dimension surrogate keys)

Procedure: gold.load_gold

Dependencies:
    Run after:
        - scripts/gold/01_create_dimensions.sql
        - scripts/gold/02_create_facts.sql
        - scripts/gold/03_load_dimensions.sql
        - scripts/gold/04_load_facts.sql

    Silver layer must be loaded first: EXEC silver.load_silver;

Execution:
    EXEC gold.load_gold;
===============================================================================
*/

CREATE OR ALTER PROCEDURE gold.load_gold AS
BEGIN
    DECLARE @batch_start_time DATETIME2,
            @batch_end_time   DATETIME2;

    SET NOCOUNT ON;

    BEGIN TRY
        SET @batch_start_time = SYSDATETIME();

        PRINT '===========================================================';
        PRINT 'Loading Gold Layer';
        PRINT '===========================================================';

        -- -----------------------------------------------------------
        -- 1. Dimension Tables (must load before facts)
        -- -----------------------------------------------------------
        EXEC gold.load_dimensions;

        -- -----------------------------------------------------------
        -- 2. Fact Tables (depend on dimension surrogate keys)
        -- -----------------------------------------------------------
        EXEC gold.load_facts;

        SET @batch_end_time = SYSDATETIME();
        PRINT '===========================================================';
        PRINT 'Gold Layer Load Completed Successfully';
        PRINT '   - Total Load Duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR(50)) + ' seconds';
        PRINT '===========================================================';

    END TRY
    BEGIN CATCH
        PRINT '===========================================================';
        PRINT 'ERROR OCCURRED DURING GOLD LAYER LOAD';
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT 'Error Number:  ' + CAST(ERROR_NUMBER() AS NVARCHAR(10));
        PRINT 'Error State:   ' + CAST(ERROR_STATE()  AS NVARCHAR(10));
        PRINT 'Error Line:    ' + CAST(ERROR_LINE()   AS NVARCHAR(10));
        PRINT '===========================================================';
    END CATCH

END;
GO
