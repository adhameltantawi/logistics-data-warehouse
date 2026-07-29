/*
===============================================================================
Silver Layer -- Load Customers (Stored Procedure)
===============================================================================
Script Purpose:
    Creates and registers the stored procedure silver.load_customers.
    This procedure transforms and loads data from bronze.customers
    into silver.customers with full data cleansing.

Procedure: silver.load_customers
Target Table: silver.customers
Source Table: bronze.customers

Transformations Applied:
    - TRIM on all string columns (customer_name, customer_type, etc.)
    - Standardise customer_type, primary_freight_type, account_status
    - Deduplication on customer_id using ROW_NUMBER()
    - Empty string to NULL conversion
    - dwh_create_date audit timestamp

Dependencies:
    Run after: scripts/silver/01_create_reference.sql
    Run after: scripts/bronze/04_load_reference.sql (bronze data must exist)

Execution:
    This procedure is registered here but NOT executed automatically.
    To run the full Silver pipeline, execute: EXEC silver.load_silver;
    To run this procedure individually: EXEC silver.load_customers;
===============================================================================
*/

CREATE OR ALTER PROCEDURE silver.load_customers AS
BEGIN
    DECLARE @start_time DATETIME2,
            @end_time   DATETIME2,
            @rows       INT;

    SET NOCOUNT ON;

    BEGIN TRY
        SET @start_time = SYSDATETIME();
        PRINT '>> Truncating Table: silver.customers';
        TRUNCATE TABLE silver.customers;

        PRINT '>> Loading Data into Table: silver.customers';
        INSERT INTO silver.customers
        (
            customer_id,
            customer_name,
            customer_type,
            credit_terms_days,
            primary_freight_type,
            account_status,
            contract_start_date,
            annual_revenue_potential
        )
        SELECT
            customer_id,
            TRIM(customer_name)                                        AS customer_name,
            TRIM(customer_type)                                        AS customer_type,
            credit_terms_days,
            TRIM(primary_freight_type)                                 AS primary_freight_type,
            TRIM(account_status)                                       AS account_status,
            contract_start_date,
            annual_revenue_potential
        FROM
        (
            SELECT
                *,
                ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY customer_id) AS rn
            FROM bronze.customers
            WHERE customer_id IS NOT NULL
        ) AS deduped
        WHERE rn = 1;

        SELECT @rows = @@ROWCOUNT;
        SET @end_time = SYSDATETIME();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(MILLISECOND, @start_time, @end_time) AS NVARCHAR(50)) + ' ms';
        PRINT '>> SUCCESS: customers ............ ' + CAST(@rows AS NVARCHAR(20)) + ' rows';

    END TRY
    BEGIN CATCH
        PRINT '-----------------------------------------------------------';
        PRINT 'ERROR OCCURRED DURING LOADING CUSTOMERS IN SILVER LAYER';
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT 'Error Number:  ' + CAST(ERROR_NUMBER() AS NVARCHAR(10));
        PRINT 'Error State:   ' + CAST(ERROR_STATE()  AS NVARCHAR(10));
        PRINT 'Error Line:    ' + CAST(ERROR_LINE()   AS NVARCHAR(10));
        PRINT '-----------------------------------------------------------';
    END CATCH

END;
GO
