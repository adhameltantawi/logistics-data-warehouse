/*
===============================================================================
Gold Layer -- SCD Type 2 Implementation for dim_driver
===============================================================================
Script Purpose:
    Implements Slowly Changing Dimension Type 2 (SCD2) for gold.dim_driver.

    SCD Type 2 preserves the full history of dimension changes by:
        - Keeping old rows with an effective_end_date and is_current = 0
        - Inserting new rows for changed attributes with is_current = 1

    Columns tracked for changes (Type 2 attributes):
        home_terminal, employment_status, cdl_class, years_experience

    Columns NOT tracked (Type 1 — overwrite):
        first_name, last_name, license_number, license_state, date_of_birth

Design:
    - Uses MERGE statement: WHEN MATCHED + WHEN NOT MATCHED
    - A new surrogate key is generated for each new version of a driver
    - Natural key (driver_id) is retained on all rows for traceability
    - dim_driver table must have the 3 SCD2 columns added (see Step A below)

Usage:
    After running this script once, replace the TRUNCATE+INSERT pattern
    inside gold.load_dimensions with EXEC gold.load_dim_driver_scd2
    for the driver dimension only.

Execution:
    EXEC gold.load_dim_driver_scd2;
===============================================================================
*/

-- =============================================================
-- Step A: Add SCD2 tracking columns to gold.dim_driver
--         (Safe to run on existing table — only adds if not present)
-- =============================================================

IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('gold.dim_driver')
      AND name = 'effective_start_date'
)
BEGIN
    ALTER TABLE gold.dim_driver
        ADD effective_start_date DATE     NOT NULL DEFAULT CAST(GETDATE() AS DATE),
            effective_end_date   DATE     NULL,            -- NULL = currently active
            is_current           BIT      NOT NULL DEFAULT 1;

    PRINT '>> Added SCD2 columns to gold.dim_driver';
END
ELSE
    PRINT '>> SCD2 columns already exist on gold.dim_driver (skipped)';

GO

-- =============================================================
-- Step B: Create the SCD2 load procedure
-- =============================================================

CREATE OR ALTER PROCEDURE gold.load_dim_driver_scd2 AS
BEGIN
    DECLARE @start_time  DATETIME2 = SYSDATETIME(),
            @end_time    DATETIME2,
            @rows_ins    INT = 0,
            @rows_upd    INT = 0;

    SET NOCOUNT ON;

    BEGIN TRY

        PRINT '>> Starting SCD2 load for gold.dim_driver';

        -- -------------------------------------------------------
        -- MERGE: Compare silver.drivers against current dim_driver
        -- rows (is_current = 1) on the natural key driver_id.
        -- -------------------------------------------------------
        MERGE gold.dim_driver AS tgt
        USING (
            -- Source: only latest Silver record per driver
            SELECT
                driver_id,
                first_name,
                last_name,
                TRIM(first_name) + ' ' + TRIM(last_name)  AS full_name,
                hire_date,
                termination_date,
                license_number,
                license_state,
                date_of_birth,
                home_terminal,
                -- Apply same Title Case standardisation as silver proc
                CASE UPPER(TRIM(employment_status))
                    WHEN 'ACTIVE'     THEN 'Active'
                    WHEN 'INACTIVE'   THEN 'Inactive'
                    WHEN 'TERMINATED' THEN 'Terminated'
                    WHEN 'ON LEAVE'   THEN 'On Leave'
                    ELSE TRIM(employment_status)
                END                                        AS employment_status,
                cdl_class,
                years_experience
            FROM silver.drivers
        ) AS src
        ON (tgt.driver_id = src.driver_id AND tgt.is_current = 1)

        -- -------------------------------------------------------
        -- WHEN MATCHED: Check if any Type 2 attribute has changed.
        -- If yes → expire the current row (set end_date + is_current=0).
        -- A new row will be inserted by the INSERT below.
        -- -------------------------------------------------------
        WHEN MATCHED AND (
               ISNULL(tgt.home_terminal,     '') <> ISNULL(src.home_terminal,     '')
            OR ISNULL(tgt.employment_status, '') <> ISNULL(src.employment_status, '')
            OR ISNULL(tgt.cdl_class,         '') <> ISNULL(src.cdl_class,         '')
            OR ISNULL(tgt.years_experience,   0) <> ISNULL(src.years_experience,   0)
        )
        THEN UPDATE SET
            tgt.effective_end_date = CAST(GETDATE() AS DATE),
            tgt.is_current         = 0

        -- -------------------------------------------------------
        -- WHEN NOT MATCHED BY TARGET: Brand-new driver → insert.
        -- -------------------------------------------------------
        WHEN NOT MATCHED BY TARGET
        THEN INSERT
        (
            driver_id, first_name, last_name, full_name,
            hire_date, termination_date, license_number,
            license_state, date_of_birth, home_terminal,
            employment_status, cdl_class, years_experience,
            effective_start_date, effective_end_date, is_current
        )
        VALUES
        (
            src.driver_id, src.first_name, src.last_name, src.full_name,
            src.hire_date, src.termination_date, src.license_number,
            src.license_state, src.date_of_birth, src.home_terminal,
            src.employment_status, src.cdl_class, src.years_experience,
            CAST(GETDATE() AS DATE), NULL, 1
        );

        SET @rows_upd = @@ROWCOUNT;

        -- -------------------------------------------------------
        -- INSERT new versions for rows that were just expired above
        -- (MERGE cannot INSERT and UPDATE the same row in one pass)
        -- -------------------------------------------------------
        INSERT INTO gold.dim_driver
        (
            driver_id, first_name, last_name, full_name,
            hire_date, termination_date, license_number,
            license_state, date_of_birth, home_terminal,
            employment_status, cdl_class, years_experience,
            effective_start_date, effective_end_date, is_current
        )
        SELECT
            s.driver_id,
            s.first_name,
            s.last_name,
            TRIM(s.first_name) + ' ' + TRIM(s.last_name),
            s.hire_date,
            s.termination_date,
            s.license_number,
            s.license_state,
            s.date_of_birth,
            s.home_terminal,
            CASE UPPER(TRIM(s.employment_status))
                WHEN 'ACTIVE'     THEN 'Active'
                WHEN 'INACTIVE'   THEN 'Inactive'
                WHEN 'TERMINATED' THEN 'Terminated'
                WHEN 'ON LEAVE'   THEN 'On Leave'
                ELSE TRIM(s.employment_status)
            END,
            s.cdl_class,
            s.years_experience,
            CAST(GETDATE() AS DATE),
            NULL,
            1
        FROM silver.drivers s
        INNER JOIN gold.dim_driver d
            ON  s.driver_id = d.driver_id
            AND d.is_current = 0
            AND d.effective_end_date = CAST(GETDATE() AS DATE)  -- just expired today
        WHERE NOT EXISTS (
            -- Avoid duplicating if current row already exists
            SELECT 1 FROM gold.dim_driver d2
            WHERE d2.driver_id = s.driver_id AND d2.is_current = 1
        );

        SET @rows_ins = @@ROWCOUNT;

        SET @end_time = SYSDATETIME();
        PRINT '>> SCD2 dim_driver: ' + CAST(@rows_upd AS NVARCHAR) + ' rows expired, '
              + CAST(@rows_ins AS NVARCHAR) + ' new versions inserted';
        PRINT '>> Duration: ' + CAST(DATEDIFF(MILLISECOND, @start_time, @end_time) AS NVARCHAR) + ' ms';

    END TRY
    BEGIN CATCH
        PRINT 'ERROR in gold.load_dim_driver_scd2: ' + ERROR_MESSAGE();
    END CATCH

END;
GO

PRINT '==============================================================';
PRINT 'SCD2 infrastructure for dim_driver created successfully.';
PRINT 'Run: EXEC gold.load_dim_driver_scd2;';
PRINT '==============================================================';
