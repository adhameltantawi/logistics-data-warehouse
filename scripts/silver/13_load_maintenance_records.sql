/*
===============================================================================
Silver Layer -- Load Maintenance Records (Stored Procedure)
===============================================================================
Script Purpose:
    Creates and registers the stored procedure silver.load_maintenance_records.
    This procedure transforms and loads data from bronze.maintenance_records
    into silver.maintenance_records with full data cleansing.

Procedure: silver.load_maintenance_records
Target Table: silver.maintenance_records
Source Table: bronze.maintenance_records

Transformations Applied:
    - TRIM on string columns (maintenance_type, facility_location, service_description)
    - Validate odometer_reading >= 0
    - Validate labor_hours >= 0, downtime_hours >= 0
    - Validate labor_cost >= 0, parts_cost >= 0, total_cost >= 0
    - Deduplication on maintenance_id using ROW_NUMBER()
    - dwh_create_date audit timestamp

Dependencies:
    Run after: scripts/silver/02_create_transactions.sql
    Run after: scripts/bronze/05_load_transactions.sql (bronze data must exist)

Execution:
    This procedure is registered here but NOT executed automatically.
    To run the full Silver pipeline, execute: EXEC silver.load_silver;
    To run this procedure individually: EXEC silver.load_maintenance_records;
===============================================================================
*/

CREATE OR ALTER PROCEDURE silver.load_maintenance_records AS
BEGIN
    DECLARE @start_time DATETIME2,
            @end_time   DATETIME2,
            @rows       INT;

    SET NOCOUNT ON;

    BEGIN TRY
        SET @start_time = SYSDATETIME();
        PRINT '>> Truncating Table: silver.maintenance_records';
        TRUNCATE TABLE silver.maintenance_records;

        PRINT '>> Loading Data into Table: silver.maintenance_records';
        INSERT INTO silver.maintenance_records
        (
            maintenance_id,
            truck_id,
            maintenance_date,
            maintenance_type,
            odometer_reading,
            labor_hours,
            labor_cost,
            parts_cost,
            total_cost,
            facility_location,
            downtime_hours,
            service_description
        )
        SELECT
            maintenance_id,
            truck_id,
            maintenance_date,
            TRIM(maintenance_type)                                     AS maintenance_type,
            CASE
                WHEN odometer_reading >= 0 THEN odometer_reading
                ELSE NULL
            END                                                        AS odometer_reading,
            CASE
                WHEN labor_hours >= 0 THEN labor_hours
                ELSE NULL
            END                                                        AS labor_hours,
            CASE
                WHEN labor_cost >= 0 THEN labor_cost
                ELSE NULL
            END                                                        AS labor_cost,
            CASE
                WHEN parts_cost >= 0 THEN parts_cost
                ELSE NULL
            END                                                        AS parts_cost,
            CASE
                WHEN total_cost >= 0 THEN total_cost
                ELSE NULL
            END                                                        AS total_cost,
            TRIM(facility_location)                                    AS facility_location,
            CASE
                WHEN downtime_hours >= 0 THEN downtime_hours
                ELSE NULL
            END                                                        AS downtime_hours,
            TRIM(service_description)                                  AS service_description
        FROM
        (
            SELECT
                *,
                ROW_NUMBER() OVER (PARTITION BY maintenance_id ORDER BY maintenance_id) AS rn
            FROM bronze.maintenance_records
            WHERE maintenance_id IS NOT NULL
        ) AS deduped
        WHERE rn = 1;

        SELECT @rows = @@ROWCOUNT;
        SET @end_time = SYSDATETIME();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(MILLISECOND, @start_time, @end_time) AS NVARCHAR(50)) + ' ms';
        PRINT '>> SUCCESS: maintenance_records ............ ' + CAST(@rows AS NVARCHAR(20)) + ' rows';

    END TRY
    BEGIN CATCH
        PRINT '-----------------------------------------------------------';
        PRINT 'ERROR OCCURRED DURING LOADING MAINTENANCE_RECORDS IN SILVER LAYER';
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT 'Error Number:  ' + CAST(ERROR_NUMBER() AS NVARCHAR(10));
        PRINT 'Error State:   ' + CAST(ERROR_STATE()  AS NVARCHAR(10));
        PRINT 'Error Line:    ' + CAST(ERROR_LINE()   AS NVARCHAR(10));
        PRINT '-----------------------------------------------------------';
    END CATCH

END;
GO
