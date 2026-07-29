/*
===============================================================================
Silver Layer -- Load Safety Incidents (Stored Procedure)
===============================================================================
Script Purpose:
    Creates and registers the stored procedure silver.load_safety_incidents.
    This procedure transforms and loads data from bronze.safety_incidents
    into silver.safety_incidents with full data cleansing.

Procedure: silver.load_safety_incidents
Target Table: silver.safety_incidents
Source Table: bronze.safety_incidents

Transformations Applied:
    - TRIM on string columns (incident_type, location_city, description)
    - UPPER on location_state, at_fault_flag, injury_flag, preventable_flag
    - Validate vehicle_damage_cost >= 0, cargo_damage_cost >= 0, claim_amount >= 0
    - Deduplication on incident_id using ROW_NUMBER()
    - dwh_create_date audit timestamp

Dependencies:
    Run after: scripts/silver/02_create_transactions.sql
    Run after: scripts/bronze/05_load_transactions.sql (bronze data must exist)

Execution:
    This procedure is registered here but NOT executed automatically.
    To run the full Silver pipeline, execute: EXEC silver.load_silver;
    To run this procedure individually: EXEC silver.load_safety_incidents;
===============================================================================
*/

CREATE OR ALTER PROCEDURE silver.load_safety_incidents AS
BEGIN
    DECLARE @start_time DATETIME2,
            @end_time   DATETIME2,
            @rows       INT;

    SET NOCOUNT ON;

    BEGIN TRY
        SET @start_time = SYSDATETIME();
        PRINT '>> Truncating Table: silver.safety_incidents';
        TRUNCATE TABLE silver.safety_incidents;

        PRINT '>> Loading Data into Table: silver.safety_incidents';
        INSERT INTO silver.safety_incidents
        (
            incident_id,
            trip_id,
            truck_id,
            driver_id,
            incident_date,
            incident_type,
            location_city,
            location_state,
            at_fault_flag,
            injury_flag,
            vehicle_damage_cost,
            cargo_damage_cost,
            claim_amount,
            preventable_flag,
            description
        )
        SELECT
            incident_id,
            trip_id,
            truck_id,
            driver_id,
            incident_date,
            TRIM(incident_type)                                        AS incident_type,
            TRIM(location_city)                                        AS location_city,
            UPPER(TRIM(location_state))                                AS location_state,
            UPPER(TRIM(at_fault_flag))                                 AS at_fault_flag,
            UPPER(TRIM(injury_flag))                                   AS injury_flag,
            CASE
                WHEN vehicle_damage_cost >= 0 THEN vehicle_damage_cost
                ELSE NULL
            END                                                        AS vehicle_damage_cost,
            CASE
                WHEN cargo_damage_cost >= 0 THEN cargo_damage_cost
                ELSE NULL
            END                                                        AS cargo_damage_cost,
            CASE
                WHEN claim_amount >= 0 THEN claim_amount
                ELSE NULL
            END                                                        AS claim_amount,
            UPPER(TRIM(preventable_flag))                              AS preventable_flag,
            TRIM(description)                                          AS description
        FROM
        (
            SELECT
                *,
                ROW_NUMBER() OVER (PARTITION BY incident_id ORDER BY incident_id) AS rn
            FROM bronze.safety_incidents
            WHERE incident_id IS NOT NULL
        ) AS deduped
        WHERE rn = 1;

        SELECT @rows = @@ROWCOUNT;
        SET @end_time = SYSDATETIME();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(MILLISECOND, @start_time, @end_time) AS NVARCHAR(50)) + ' ms';
        PRINT '>> SUCCESS: safety_incidents ............ ' + CAST(@rows AS NVARCHAR(20)) + ' rows';

    END TRY
    BEGIN CATCH
        PRINT '-----------------------------------------------------------';
        PRINT 'ERROR OCCURRED DURING LOADING SAFETY_INCIDENTS IN SILVER LAYER';
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT 'Error Number:  ' + CAST(ERROR_NUMBER() AS NVARCHAR(10));
        PRINT 'Error State:   ' + CAST(ERROR_STATE()  AS NVARCHAR(10));
        PRINT 'Error Line:    ' + CAST(ERROR_LINE()   AS NVARCHAR(10));
        PRINT '-----------------------------------------------------------';
    END CATCH

END;
GO
