/*
===============================================================================
Silver Layer -- Load Facilities (Stored Procedure)
===============================================================================
Script Purpose:
    Creates and registers the stored procedure silver.load_facilities.
    This procedure transforms and loads data from bronze.facilities
    into silver.facilities with full data cleansing.

Procedure: silver.load_facilities
Target Table: silver.facilities
Source Table: bronze.facilities

Transformations Applied:
    - TRIM on all string columns (facility_name, facility_type, city, etc.)
    - UPPER on state
    - Validate latitude (-90 to 90) and longitude (-180 to 180)
    - Deduplication on facility_id using ROW_NUMBER()
    - Empty string to NULL conversion
    - dwh_create_date audit timestamp

Dependencies:
    Run after: scripts/silver/01_create_reference.sql
    Run after: scripts/bronze/04_load_reference.sql (bronze data must exist)

Execution:
    This procedure is registered here but NOT executed automatically.
    To run the full Silver pipeline, execute: EXEC silver.load_silver;
    To run this procedure individually: EXEC silver.load_facilities;
===============================================================================
*/

CREATE OR ALTER PROCEDURE silver.load_facilities AS
BEGIN
    DECLARE @start_time DATETIME2,
            @end_time   DATETIME2,
            @rows       INT;

    SET NOCOUNT ON;

    BEGIN TRY
        SET @start_time = SYSDATETIME();
        PRINT '>> Truncating Table: silver.facilities';
        TRUNCATE TABLE silver.facilities;

        PRINT '>> Loading Data into Table: silver.facilities';
        INSERT INTO silver.facilities
        (
            facility_id,
            facility_name,
            facility_type,
            city,
            state,
            latitude,
            longitude,
            dock_doors,
            operating_hours
        )
        SELECT
            facility_id,
            TRIM(facility_name)                                        AS facility_name,
            TRIM(facility_type)                                        AS facility_type,
            TRIM(city)                                                 AS city,
            UPPER(TRIM(state))                                         AS state,
            CASE
                WHEN latitude BETWEEN -90 AND 90 THEN latitude
                ELSE NULL
            END                                                        AS latitude,
            CASE
                WHEN longitude BETWEEN -180 AND 180 THEN longitude
                ELSE NULL
            END                                                        AS longitude,
            dock_doors,
            TRIM(operating_hours)                                      AS operating_hours
        FROM
        (
            SELECT
                *,
                ROW_NUMBER() OVER (PARTITION BY facility_id ORDER BY facility_id) AS rn
            FROM bronze.facilities
            WHERE facility_id IS NOT NULL
        ) AS deduped
        WHERE rn = 1;

        SELECT @rows = @@ROWCOUNT;
        SET @end_time = SYSDATETIME();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(MILLISECOND, @start_time, @end_time) AS NVARCHAR(50)) + ' ms';
        PRINT '>> SUCCESS: facilities ............ ' + CAST(@rows AS NVARCHAR(20)) + ' rows';

    END TRY
    BEGIN CATCH
        PRINT '-----------------------------------------------------------';
        PRINT 'ERROR OCCURRED DURING LOADING FACILITIES IN SILVER LAYER';
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT 'Error Number:  ' + CAST(ERROR_NUMBER() AS NVARCHAR(10));
        PRINT 'Error State:   ' + CAST(ERROR_STATE()  AS NVARCHAR(10));
        PRINT 'Error Line:    ' + CAST(ERROR_LINE()   AS NVARCHAR(10));
        PRINT '-----------------------------------------------------------';
    END CATCH

END;
GO
