/*
===============================================================================
Pipeline Execution Log — Table + Logging Stored Procedure
===============================================================================
Script Purpose:
    Creates a persistent log table (bronze.pipeline_log) that records
    every ETL run at the table level — table name, rows loaded, start time,
    end time, duration, and status (SUCCESS / ERROR).

    Also creates a helper procedure bronze.log_pipeline_event to keep
    logging consistent across all load procedures.

Benefits:
    - Full audit trail of every pipeline execution
    - Quickly identify which tables are slow or failing
    - Compare row counts across runs to detect unexpected changes
    - Essential for production DWH monitoring

Usage:
    EXEC bronze.log_pipeline_event
        @layer      = 'bronze',     -- or 'silver' / 'gold'
        @table_name = 'drivers',
        @rows_loaded = 500,
        @start_time = @start_time,
        @end_time   = @end_time,
        @status     = 'SUCCESS';    -- or 'ERROR'

    To view the log:
        SELECT * FROM bronze.pipeline_log ORDER BY log_id DESC;
===============================================================================
*/

-- =============================================================
-- 1. Create Log Table
-- =============================================================

IF OBJECT_ID('bronze.pipeline_log', 'U') IS NULL
BEGIN
    CREATE TABLE bronze.pipeline_log
    (
        log_id          INT IDENTITY(1,1)  NOT NULL,
        layer           NVARCHAR(10)       NOT NULL,  -- 'bronze' | 'silver' | 'gold'
        table_name      NVARCHAR(100)      NOT NULL,
        rows_loaded     INT                NULL,
        start_time      DATETIME2          NULL,
        end_time        DATETIME2          NULL,
        duration_ms     INT                NULL,      -- computed from start/end
        status          NVARCHAR(10)       NOT NULL,  -- 'SUCCESS' | 'ERROR'
        error_message   NVARCHAR(MAX)      NULL,
        logged_at       DATETIME2          NOT NULL DEFAULT SYSDATETIME(),
        CONSTRAINT pk_pipeline_log PRIMARY KEY (log_id)
    );

    PRINT '>> Created table: bronze.pipeline_log';
END
ELSE
    PRINT '>> Table already exists: bronze.pipeline_log (skipped)';

GO

-- =============================================================
-- 2. Create Logging Helper Procedure
-- =============================================================

CREATE OR ALTER PROCEDURE bronze.log_pipeline_event
    @layer         NVARCHAR(10),
    @table_name    NVARCHAR(100),
    @rows_loaded   INT            = NULL,
    @start_time    DATETIME2      = NULL,
    @end_time      DATETIME2      = NULL,
    @status        NVARCHAR(10),
    @error_message NVARCHAR(MAX)  = NULL
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO bronze.pipeline_log
    (
        layer, table_name, rows_loaded,
        start_time, end_time, duration_ms,
        status, error_message
    )
    VALUES
    (
        @layer,
        @table_name,
        @rows_loaded,
        @start_time,
        @end_time,
        CASE
            WHEN @start_time IS NOT NULL AND @end_time IS NOT NULL
            THEN DATEDIFF(MILLISECOND, @start_time, @end_time)
            ELSE NULL
        END,
        @status,
        @error_message
    );
END;

GO

PRINT '>> Created procedure: bronze.log_pipeline_event';

-- =============================================================
-- 3. Convenience view — Latest run summary
-- =============================================================

CREATE OR ALTER VIEW bronze.vw_pipeline_last_run AS
SELECT
    layer,
    table_name,
    rows_loaded,
    duration_ms,
    status,
    error_message,
    logged_at
FROM bronze.pipeline_log
WHERE log_id IN
(
    SELECT MAX(log_id)
    FROM bronze.pipeline_log
    GROUP BY layer, table_name
);

GO

PRINT '>> Created view: bronze.vw_pipeline_last_run';
PRINT '==============================================================';
PRINT 'Pipeline log infrastructure created successfully.';
PRINT 'Query: SELECT * FROM bronze.vw_pipeline_last_run;';
PRINT '==============================================================';
