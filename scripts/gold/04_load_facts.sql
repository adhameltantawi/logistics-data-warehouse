/*
===============================================================================
Gold Layer -- Load Fact Tables (Stored Procedure)
===============================================================================
Script Purpose:
    Creates and registers the stored procedure gold.load_facts.
    This procedure populates all 5 fact tables by joining Silver layer
    transactional data with Gold dimension tables to resolve surrogate keys.

Procedure: gold.load_facts
Tables Loaded:
    - gold.fact_trip          (silver.trips + silver.loads + dimensions)
    - gold.fact_fuel_purchase (silver.fuel_purchases + dimensions)
    - gold.fact_maintenance   (silver.maintenance_records + dimensions)
    - gold.fact_safety        (silver.safety_incidents + dimensions)
    - gold.fact_delivery      (silver.delivery_events + dimensions)

Key Logic:
    - Surrogate keys resolved via LEFT JOIN to dimension tables on natural keys
    - date_key derived as CAST(FORMAT(date_col, 'yyyyMMdd') AS INT)
    - Derived measures: total_revenue, total_damage_cost

Dependencies:
    Run after: scripts/gold/02_create_facts.sql
    Run after: EXEC gold.load_dimensions; (dimensions must be loaded first)

Execution:
    EXEC gold.load_facts;
===============================================================================
*/

CREATE OR ALTER PROCEDURE gold.load_facts AS
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
        PRINT 'Loading Fact Tables into Gold layer';
        PRINT '-----------------------------------------------------------';

        -- -------------------------------------------------------
        -- gold.fact_trip
        -- -------------------------------------------------------
        SET @start_time = SYSDATETIME();
        PRINT '>> Truncating Table: gold.fact_trip';
        TRUNCATE TABLE gold.fact_trip;

        PRINT '>> Loading Data into Table: gold.fact_trip';
        INSERT INTO gold.fact_trip
        (
            driver_key, truck_key, trailer_key, customer_key, route_key,
            dispatch_date_key,
            trip_id, load_id,
            actual_distance_miles, actual_duration_hours,
            fuel_gallons_used, average_mpg, idle_time_hours,
            revenue, fuel_surcharge, accessorial_charges, total_revenue,
            weight_lbs, pieces,
            load_type, load_status, booking_type, trip_status
        )
        SELECT
            dd.driver_key,
            dt.truck_key,
            dtr.trailer_key,
            dc.customer_key,
            dr.route_key,
            CAST(FORMAT(t.dispatch_date, 'yyyyMMdd') AS INT)           AS dispatch_date_key,
            t.trip_id,
            t.load_id,
            t.actual_distance_miles,
            t.actual_duration_hours,
            t.fuel_gallons_used,
            t.average_mpg,
            t.idle_time_hours,
            l.revenue,
            l.fuel_surcharge,
            l.accessorial_charges,
            ISNULL(l.revenue, 0) + ISNULL(l.fuel_surcharge, 0)
            + ISNULL(l.accessorial_charges, 0)                         AS total_revenue,
            l.weight_lbs,
            l.pieces,
            l.load_type,
            l.load_status,
            l.booking_type,
            t.trip_status
        FROM silver.trips t
        LEFT JOIN silver.loads l
            ON t.load_id = l.load_id
        LEFT JOIN gold.dim_driver dd
            ON t.driver_id = dd.driver_id
        LEFT JOIN gold.dim_truck dt
            ON t.truck_id = dt.truck_id
        LEFT JOIN gold.dim_trailer dtr
            ON t.trailer_id = dtr.trailer_id
        LEFT JOIN gold.dim_customer dc
            ON l.customer_id = dc.customer_id
        LEFT JOIN gold.dim_route dr
            ON l.route_id = dr.route_id;

        SELECT @rows = @@ROWCOUNT;
        SET @end_time = SYSDATETIME();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(MILLISECOND, @start_time, @end_time) AS NVARCHAR(50)) + ' ms';
        PRINT '>> SUCCESS: fact_trip ............ ' + CAST(@rows AS NVARCHAR(20)) + ' rows';

        -- -------------------------------------------------------
        -- gold.fact_fuel_purchase
        -- -------------------------------------------------------
        SET @start_time = SYSDATETIME();
        PRINT '>> Truncating Table: gold.fact_fuel_purchase';
        TRUNCATE TABLE gold.fact_fuel_purchase;

        PRINT '>> Loading Data into Table: gold.fact_fuel_purchase';
        INSERT INTO gold.fact_fuel_purchase
        (
            driver_key, truck_key, purchase_date_key,
            fuel_purchase_id, trip_id,
            gallons, price_per_gallon, total_cost,
            location_city, location_state, fuel_card_number
        )
        SELECT
            dd.driver_key,
            dt.truck_key,
            CAST(FORMAT(CAST(fp.purchase_date AS DATE), 'yyyyMMdd') AS INT)
                                                                       AS purchase_date_key,
            fp.fuel_purchase_id,
            fp.trip_id,
            fp.gallons,
            fp.price_per_gallon,
            fp.total_cost,
            fp.location_city,
            fp.location_state,
            fp.fuel_card_number
        FROM silver.fuel_purchases fp
        LEFT JOIN gold.dim_driver dd
            ON fp.driver_id = dd.driver_id
        LEFT JOIN gold.dim_truck dt
            ON fp.truck_id = dt.truck_id;

        SELECT @rows = @@ROWCOUNT;
        SET @end_time = SYSDATETIME();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(MILLISECOND, @start_time, @end_time) AS NVARCHAR(50)) + ' ms';
        PRINT '>> SUCCESS: fact_fuel_purchase ............ ' + CAST(@rows AS NVARCHAR(20)) + ' rows';

        -- -------------------------------------------------------
        -- gold.fact_maintenance
        -- -------------------------------------------------------
        SET @start_time = SYSDATETIME();
        PRINT '>> Truncating Table: gold.fact_maintenance';
        TRUNCATE TABLE gold.fact_maintenance;

        PRINT '>> Loading Data into Table: gold.fact_maintenance';
        INSERT INTO gold.fact_maintenance
        (
            truck_key, maintenance_date_key,
            maintenance_id,
            odometer_reading, labor_hours, labor_cost, parts_cost,
            total_cost, downtime_hours,
            maintenance_type, facility_location, service_description
        )
        SELECT
            dt.truck_key,
            CAST(FORMAT(mr.maintenance_date, 'yyyyMMdd') AS INT)       AS maintenance_date_key,
            mr.maintenance_id,
            mr.odometer_reading,
            mr.labor_hours,
            mr.labor_cost,
            mr.parts_cost,
            mr.total_cost,
            mr.downtime_hours,
            mr.maintenance_type,
            mr.facility_location,
            mr.service_description
        FROM silver.maintenance_records mr
        LEFT JOIN gold.dim_truck dt
            ON mr.truck_id = dt.truck_id;

        SELECT @rows = @@ROWCOUNT;
        SET @end_time = SYSDATETIME();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(MILLISECOND, @start_time, @end_time) AS NVARCHAR(50)) + ' ms';
        PRINT '>> SUCCESS: fact_maintenance ............ ' + CAST(@rows AS NVARCHAR(20)) + ' rows';

        -- -------------------------------------------------------
        -- gold.fact_safety
        -- -------------------------------------------------------
        SET @start_time = SYSDATETIME();
        PRINT '>> Truncating Table: gold.fact_safety';
        TRUNCATE TABLE gold.fact_safety;

        PRINT '>> Loading Data into Table: gold.fact_safety';
        INSERT INTO gold.fact_safety
        (
            driver_key, truck_key, incident_date_key,
            incident_id, trip_id,
            vehicle_damage_cost, cargo_damage_cost, claim_amount,
            total_damage_cost,
            incident_type, location_city, location_state,
            at_fault_flag, injury_flag, preventable_flag, description
        )
        SELECT
            dd.driver_key,
            dt.truck_key,
            CAST(FORMAT(CAST(si.incident_date AS DATE), 'yyyyMMdd') AS INT)
                                                                       AS incident_date_key,
            si.incident_id,
            si.trip_id,
            si.vehicle_damage_cost,
            si.cargo_damage_cost,
            si.claim_amount,
            ISNULL(si.vehicle_damage_cost, 0)
            + ISNULL(si.cargo_damage_cost, 0)                          AS total_damage_cost,
            si.incident_type,
            si.location_city,
            si.location_state,
            si.at_fault_flag,
            si.injury_flag,
            si.preventable_flag,
            si.description
        FROM silver.safety_incidents si
        LEFT JOIN gold.dim_driver dd
            ON si.driver_id = dd.driver_id
        LEFT JOIN gold.dim_truck dt
            ON si.truck_id = dt.truck_id;

        SELECT @rows = @@ROWCOUNT;
        SET @end_time = SYSDATETIME();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(MILLISECOND, @start_time, @end_time) AS NVARCHAR(50)) + ' ms';
        PRINT '>> SUCCESS: fact_safety ............ ' + CAST(@rows AS NVARCHAR(20)) + ' rows';

        -- -------------------------------------------------------
        -- gold.fact_delivery
        -- -------------------------------------------------------
        SET @start_time = SYSDATETIME();
        PRINT '>> Truncating Table: gold.fact_delivery';
        TRUNCATE TABLE gold.fact_delivery;

        PRINT '>> Loading Data into Table: gold.fact_delivery';
        INSERT INTO gold.fact_delivery
        (
            facility_key, driver_key, truck_key,
            customer_key, route_key, event_date_key,
            event_id, load_id, trip_id,
            detention_minutes,
            event_type, scheduled_datetime, actual_datetime,
            on_time_flag, location_city, location_state
        )
        SELECT
            df.facility_key,
            dd.driver_key,
            dt.truck_key,
            dc.customer_key,
            dr.route_key,
            CAST(FORMAT(t.dispatch_date, 'yyyyMMdd') AS INT)               AS event_date_key,
            de.event_id,
            de.load_id,
            de.trip_id,
            de.detention_minutes,
            de.event_type,
            de.scheduled_datetime,
            de.actual_datetime,
            de.on_time_flag,
            de.location_city,
            de.location_state
        FROM silver.delivery_events de
        LEFT JOIN silver.trips t
            ON de.trip_id = t.trip_id
        LEFT JOIN silver.loads l
            ON de.load_id = l.load_id
        LEFT JOIN gold.dim_facility df
            ON de.facility_id = df.facility_id
        LEFT JOIN gold.dim_driver dd
            ON t.driver_id = dd.driver_id
        LEFT JOIN gold.dim_truck dt
            ON t.truck_id = dt.truck_id
        LEFT JOIN gold.dim_customer dc
            ON l.customer_id = dc.customer_id
        LEFT JOIN gold.dim_route dr
            ON l.route_id = dr.route_id;

        SELECT @rows = @@ROWCOUNT;
        SET @end_time = SYSDATETIME();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(MILLISECOND, @start_time, @end_time) AS NVARCHAR(50)) + ' ms';
        PRINT '>> SUCCESS: fact_delivery ............ ' + CAST(@rows AS NVARCHAR(20)) + ' rows';

        SET @end_batch_time = SYSDATETIME();
        PRINT '-----------------------------------------------------------';
        PRINT 'Fact Tables Load Completed Successfully';
        PRINT '   - Total Load Duration: ' + CAST(DATEDIFF(SECOND, @start_batch_time, @end_batch_time) AS NVARCHAR(50)) + ' seconds';
        PRINT '-----------------------------------------------------------';
        PRINT '';

    END TRY
    BEGIN CATCH
        PRINT '-----------------------------------------------------------';
        PRINT 'ERROR OCCURRED DURING LOADING FACTS IN GOLD LAYER';
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT 'Error Number:  ' + CAST(ERROR_NUMBER() AS NVARCHAR(10));
        PRINT 'Error State:   ' + CAST(ERROR_STATE()  AS NVARCHAR(10));
        PRINT 'Error Line:    ' + CAST(ERROR_LINE()   AS NVARCHAR(10));
        PRINT '-----------------------------------------------------------';
    END CATCH

END;
GO
