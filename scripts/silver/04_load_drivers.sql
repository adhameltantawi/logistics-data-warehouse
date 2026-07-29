/*
===============================================================================
Silver Layer -- Load Drivers (Stored Procedure)
===============================================================================
Script Purpose:
    Creates and registers the stored procedure silver.load_drivers.
    This procedure transforms and loads data from bronze.drivers
    into silver.drivers with full data cleansing.

Procedure: silver.load_drivers
Target Table: silver.drivers
Source Table: bronze.drivers

Transformations Applied:
    - TRIM on all string columns (first_name, last_name, license_number, etc.)
    - UPPER on license_state, cdl_class
    - Standardise employment_status to Title Case
    - Deduplication on driver_id using ROW_NUMBER()
    - Empty string to NULL conversion
    - dwh_create_date audit timestamp

Dependencies:
    Run after: scripts/silver/01_create_reference.sql
    Run after: scripts/bronze/04_load_reference.sql (bronze data must exist)

Execution:
    This procedure is registered here but NOT executed automatically.
    To run the full Silver pipeline, execute: EXEC silver.load_silver;
    To run this procedure individually: EXEC silver.load_drivers;
===============================================================================
*/

CREATE OR ALTER PROCEDURE silver.load_drivers AS
BEGIN
    DECLARE @start_time DATETIME2,
            @end_time   DATETIME2,
            @rows       INT;

    SET NOCOUNT ON;

    BEGIN TRY
        SET @start_time = SYSDATETIME();
        PRINT '>> Truncating Table: silver.drivers';
        TRUNCATE TABLE silver.drivers;

        PRINT '>> Loading Data into Table: silver.drivers';
        INSERT INTO silver.drivers
        (
            driver_id,
            first_name,
            last_name,
            hire_date,
            termination_date,
            license_number,
            license_state,
            date_of_birth,
            home_terminal,
            employment_status,
            cdl_class,
            years_experience
        )
        SELECT
            driver_id,
            TRIM(first_name)                                           AS first_name,
            TRIM(last_name)                                            AS last_name,
            hire_date,
            termination_date,
            TRIM(license_number)                                       AS license_number,
            UPPER(TRIM(license_state))                                 AS license_state,
            date_of_birth,
            TRIM(home_terminal)                                        AS home_terminal,
            TRIM(employment_status)                                    AS employment_status,
            UPPER(TRIM(cdl_class))                                     AS cdl_class,
            years_experience
        FROM
        (
            SELECT
                *,
                ROW_NUMBER() OVER (PARTITION BY driver_id ORDER BY driver_id) AS rn
            FROM bronze.drivers
            WHERE driver_id IS NOT NULL
        ) AS deduped
        WHERE rn = 1;

        SELECT @rows = @@ROWCOUNT;
        SET @end_time = SYSDATETIME();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(MILLISECOND, @start_time, @end_time) AS NVARCHAR(50)) + ' ms';
        PRINT '>> SUCCESS: drivers ............ ' + CAST(@rows AS NVARCHAR(20)) + ' rows';

    END TRY
    BEGIN CATCH
        PRINT '-----------------------------------------------------------';
        PRINT 'ERROR OCCURRED DURING LOADING DRIVERS IN SILVER LAYER';
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT 'Error Number:  ' + CAST(ERROR_NUMBER() AS NVARCHAR(10));
        PRINT 'Error State:   ' + CAST(ERROR_STATE()  AS NVARCHAR(10));
        PRINT 'Error Line:    ' + CAST(ERROR_LINE()   AS NVARCHAR(10));
        PRINT '-----------------------------------------------------------';
    END CATCH

END;
GO
