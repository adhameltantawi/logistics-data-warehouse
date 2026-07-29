/*
===============================================================================
Gold Layer -- Load Dimension Tables (Stored Procedure)
===============================================================================
Script Purpose:
    Creates and registers the stored procedure gold.load_dimensions.
    This procedure populates all 7 dimension tables from the Silver layer.

Procedure: gold.load_dimensions
Tables Loaded:
    - gold.dim_driver     (from silver.drivers)
    - gold.dim_truck      (from silver.trucks)
    - gold.dim_trailer    (from silver.trailers)
    - gold.dim_customer   (from silver.customers)
    - gold.dim_facility   (from silver.facilities)
    - gold.dim_route      (from silver.routes)
    - gold.dim_date       (generated date calendar 2020-01-01 to 2030-12-31)

Enrichments:
    - dim_driver:   full_name = first_name + ' ' + last_name
    - dim_truck:    truck_age_years = YEAR(GETDATE()) - model_year
    - dim_route:    lane_description = origin_city + ', ' + origin_state
                    + ' → ' + destination_city + ', ' + destination_state
    - dim_date:     Full calendar dimension with year, quarter, month,
                    week, day, weekend flag, etc.

Dependencies:
    Run after: scripts/gold/01_create_dimensions.sql
    Silver layer must be loaded first: EXEC silver.load_silver;

Execution:
    EXEC gold.load_dimensions;
===============================================================================
*/

CREATE OR ALTER PROCEDURE gold.load_dimensions AS
BEGIN
    DECLARE @start_time       DATETIME2,
            @end_time         DATETIME2,
            @start_batch_time DATETIME2,
            @end_batch_time   DATETIME2,
            @rows             INT;

    SET NOCOUNT ON;

    BEGIN TRY
        SET @start_batch_time = SYSDATETIME();
        PRINT '-----------------------------------------------------------';
        PRINT 'Loading Dimension Tables into Gold layer';
        PRINT '-----------------------------------------------------------';

        -- -------------------------------------------------------
        -- gold.dim_driver
        -- -------------------------------------------------------
        SET @start_time = SYSDATETIME();
        PRINT '>> Truncating Table: gold.dim_driver';
        TRUNCATE TABLE gold.dim_driver;

        PRINT '>> Loading Data into Table: gold.dim_driver';
        INSERT INTO gold.dim_driver
        (
            driver_id, first_name, last_name, full_name,
            hire_date, termination_date, license_number,
            license_state, date_of_birth, home_terminal,
            employment_status, cdl_class, years_experience
        )
        SELECT
            driver_id,
            first_name,
            last_name,
            TRIM(first_name) + ' ' + TRIM(last_name)   AS full_name,
            hire_date,
            termination_date,
            license_number,
            license_state,
            date_of_birth,
            home_terminal,
            employment_status,
            cdl_class,
            years_experience
        FROM silver.drivers;

        SELECT @rows = @@ROWCOUNT;
        SET @end_time = SYSDATETIME();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(MILLISECOND, @start_time, @end_time) AS NVARCHAR(50)) + ' ms';
        PRINT '>> SUCCESS: dim_driver ............ ' + CAST(@rows AS NVARCHAR(20)) + ' rows';

        -- -------------------------------------------------------
        -- gold.dim_truck
        -- -------------------------------------------------------
        SET @start_time = SYSDATETIME();
        PRINT '>> Truncating Table: gold.dim_truck';
        TRUNCATE TABLE gold.dim_truck;

        PRINT '>> Loading Data into Table: gold.dim_truck';
        INSERT INTO gold.dim_truck
        (
            truck_id, unit_number, make, model_year, vin,
            acquisition_date, acquisition_mileage, fuel_type,
            tank_capacity_gallons, status, home_terminal, truck_age_years
        )
        SELECT
            truck_id,
            unit_number,
            make,
            model_year,
            vin,
            acquisition_date,
            acquisition_mileage,
            fuel_type,
            tank_capacity_gallons,
            status,
            home_terminal,
            YEAR(GETDATE()) - model_year                AS truck_age_years
        FROM silver.trucks;

        SELECT @rows = @@ROWCOUNT;
        SET @end_time = SYSDATETIME();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(MILLISECOND, @start_time, @end_time) AS NVARCHAR(50)) + ' ms';
        PRINT '>> SUCCESS: dim_truck ............ ' + CAST(@rows AS NVARCHAR(20)) + ' rows';

        -- -------------------------------------------------------
        -- gold.dim_trailer
        -- -------------------------------------------------------
        SET @start_time = SYSDATETIME();
        PRINT '>> Truncating Table: gold.dim_trailer';
        TRUNCATE TABLE gold.dim_trailer;

        PRINT '>> Loading Data into Table: gold.dim_trailer';
        INSERT INTO gold.dim_trailer
        (
            trailer_id, trailer_number, trailer_type, length_feet,
            model_year, vin, acquisition_date, status, current_location
        )
        SELECT
            trailer_id,
            trailer_number,
            trailer_type,
            length_feet,
            model_year,
            vin,
            acquisition_date,
            status,
            current_location
        FROM silver.trailers;

        SELECT @rows = @@ROWCOUNT;
        SET @end_time = SYSDATETIME();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(MILLISECOND, @start_time, @end_time) AS NVARCHAR(50)) + ' ms';
        PRINT '>> SUCCESS: dim_trailer ............ ' + CAST(@rows AS NVARCHAR(20)) + ' rows';

        -- -------------------------------------------------------
        -- gold.dim_customer
        -- -------------------------------------------------------
        SET @start_time = SYSDATETIME();
        PRINT '>> Truncating Table: gold.dim_customer';
        TRUNCATE TABLE gold.dim_customer;

        PRINT '>> Loading Data into Table: gold.dim_customer';
        INSERT INTO gold.dim_customer
        (
            customer_id, customer_name, customer_type,
            credit_terms_days, primary_freight_type,
            account_status, contract_start_date, annual_revenue_potential
        )
        SELECT
            customer_id,
            customer_name,
            customer_type,
            credit_terms_days,
            primary_freight_type,
            account_status,
            contract_start_date,
            annual_revenue_potential
        FROM silver.customers;

        SELECT @rows = @@ROWCOUNT;
        SET @end_time = SYSDATETIME();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(MILLISECOND, @start_time, @end_time) AS NVARCHAR(50)) + ' ms';
        PRINT '>> SUCCESS: dim_customer ............ ' + CAST(@rows AS NVARCHAR(20)) + ' rows';

        -- -------------------------------------------------------
        -- gold.dim_facility
        -- -------------------------------------------------------
        SET @start_time = SYSDATETIME();
        PRINT '>> Truncating Table: gold.dim_facility';
        TRUNCATE TABLE gold.dim_facility;

        PRINT '>> Loading Data into Table: gold.dim_facility';
        INSERT INTO gold.dim_facility
        (
            facility_id, facility_name, facility_type,
            city, state, latitude, longitude,
            dock_doors, operating_hours
        )
        SELECT
            facility_id,
            facility_name,
            facility_type,
            city,
            state,
            latitude,
            longitude,
            dock_doors,
            operating_hours
        FROM silver.facilities;

        SELECT @rows = @@ROWCOUNT;
        SET @end_time = SYSDATETIME();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(MILLISECOND, @start_time, @end_time) AS NVARCHAR(50)) + ' ms';
        PRINT '>> SUCCESS: dim_facility ............ ' + CAST(@rows AS NVARCHAR(20)) + ' rows';

        -- -------------------------------------------------------
        -- gold.dim_route
        -- -------------------------------------------------------
        SET @start_time = SYSDATETIME();
        PRINT '>> Truncating Table: gold.dim_route';
        TRUNCATE TABLE gold.dim_route;

        PRINT '>> Loading Data into Table: gold.dim_route';
        INSERT INTO gold.dim_route
        (
            route_id, origin_city, origin_state,
            destination_city, destination_state,
            typical_distance_miles, base_rate_per_mile,
            fuel_surcharge_rate, typical_transit_days, lane_description
        )
        SELECT
            route_id,
            origin_city,
            origin_state,
            destination_city,
            destination_state,
            typical_distance_miles,
            base_rate_per_mile,
            fuel_surcharge_rate,
            typical_transit_days,
            TRIM(origin_city) + ', ' + TRIM(origin_state)
            + ' → ' + TRIM(destination_city) + ', ' + TRIM(destination_state)
                                                        AS lane_description
        FROM silver.routes;

        SELECT @rows = @@ROWCOUNT;
        SET @end_time = SYSDATETIME();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(MILLISECOND, @start_time, @end_time) AS NVARCHAR(50)) + ' ms';
        PRINT '>> SUCCESS: dim_route ............ ' + CAST(@rows AS NVARCHAR(20)) + ' rows';

        -- -------------------------------------------------------
        -- gold.dim_date (Calendar 2020-01-01 to 2030-12-31)
        -- -------------------------------------------------------
        SET @start_time = SYSDATETIME();
        PRINT '>> Truncating Table: gold.dim_date';
        TRUNCATE TABLE gold.dim_date;

        PRINT '>> Generating Date Dimension: gold.dim_date';
        ;WITH date_cte AS
        (
            SELECT CAST('2020-01-01' AS DATE) AS dt
            UNION ALL
            SELECT DATEADD(DAY, 1, dt)
            FROM date_cte
            WHERE dt < '2030-12-31'
        )
        INSERT INTO gold.dim_date
        (
            date_key, full_date, year, quarter, month, month_name,
            week, day_of_month, day_of_week, day_name, is_weekend, year_month
        )
        SELECT
            CAST(FORMAT(dt, 'yyyyMMdd') AS INT)         AS date_key,
            dt                                          AS full_date,
            YEAR(dt)                                    AS year,
            DATEPART(QUARTER, dt)                       AS quarter,
            MONTH(dt)                                   AS month,
            DATENAME(MONTH, dt)                         AS month_name,
            DATEPART(WEEK, dt)                          AS week,
            DAY(dt)                                     AS day_of_month,
            DATEPART(WEEKDAY, dt)                       AS day_of_week,
            DATENAME(WEEKDAY, dt)                       AS day_name,
            CASE
                WHEN DATEPART(WEEKDAY, dt) IN (1, 7) THEN 1
                ELSE 0
            END                                         AS is_weekend,
            FORMAT(dt, 'yyyy-MM')                       AS year_month
        FROM date_cte
        OPTION (MAXRECURSION 5000);

        SELECT @rows = @@ROWCOUNT;
        SET @end_time = SYSDATETIME();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(MILLISECOND, @start_time, @end_time) AS NVARCHAR(50)) + ' ms';
        PRINT '>> SUCCESS: dim_date ............ ' + CAST(@rows AS NVARCHAR(20)) + ' rows';

        SET @end_batch_time = SYSDATETIME();
        PRINT '-----------------------------------------------------------';
        PRINT 'Dimension Tables Load Completed Successfully';
        PRINT '   - Total Load Duration: ' + CAST(DATEDIFF(SECOND, @start_batch_time, @end_batch_time) AS NVARCHAR(50)) + ' seconds';
        PRINT '-----------------------------------------------------------';
        PRINT '';

    END TRY
    BEGIN CATCH
        PRINT '-----------------------------------------------------------';
        PRINT 'ERROR OCCURRED DURING LOADING DIMENSIONS IN GOLD LAYER';
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT 'Error Number:  ' + CAST(ERROR_NUMBER() AS NVARCHAR(10));
        PRINT 'Error State:   ' + CAST(ERROR_STATE()  AS NVARCHAR(10));
        PRINT 'Error Line:    ' + CAST(ERROR_LINE()   AS NVARCHAR(10));
        PRINT '-----------------------------------------------------------';
    END CATCH

END;
GO
