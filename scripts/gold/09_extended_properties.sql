/*
===============================================================================
Gold Layer -- Extended Properties (Column-Level Documentation)
===============================================================================
Script Purpose:
    Adds MS_Description extended properties to every Gold layer table
    and its key columns. This makes the database self-documenting —
    visible in SSMS Object Explorer tooltips, SQL Server Data Tools,
    and any tool that reads system extended properties.

How to verify:
    SELECT
        t.name  AS table_name,
        c.name  AS column_name,
        ep.value AS description
    FROM sys.extended_properties ep
    JOIN sys.tables   t ON ep.major_id = t.object_id
    JOIN sys.columns  c ON ep.major_id = c.object_id AND ep.minor_id = c.column_id
    WHERE ep.name = 'MS_Description'
      AND SCHEMA_NAME(t.schema_id) = 'gold'
    ORDER BY t.name, c.column_id;

Execution:
    Run after: EXEC gold.load_gold;
    Safe to re-run: drops and re-adds each property.
===============================================================================
*/

-- Helper macro-style pattern: drop-then-add for idempotency
-- (SQL Server does not support CREATE OR ALTER on extended properties)

-- ==============================================================================
-- gold.dim_driver
-- ==============================================================================

-- Table description
IF EXISTS (SELECT 1 FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('gold.dim_driver') AND minor_id = 0 AND name = 'MS_Description')
    EXEC sys.sp_dropextendedproperty  'MS_Description','SCHEMA','gold','TABLE','dim_driver';
EXEC sys.sp_addextendedproperty     'MS_Description','Driver dimension — one row per driver per SCD2 version. Tracks employment, CDL class, and home terminal history.','SCHEMA','gold','TABLE','dim_driver';

EXEC sys.sp_addextendedproperty 'MS_Description','Surrogate key (IDENTITY). Primary key for all fact table JOINs.','SCHEMA','gold','TABLE','dim_driver','COLUMN','driver_key';
EXEC sys.sp_addextendedproperty 'MS_Description','Natural key from source. Consistent across SCD2 versions.','SCHEMA','gold','TABLE','dim_driver','COLUMN','driver_id';
EXEC sys.sp_addextendedproperty 'MS_Description','Concatenated first + last name for display.','SCHEMA','gold','TABLE','dim_driver','COLUMN','full_name';
EXEC sys.sp_addextendedproperty 'MS_Description','SCD2: Date this version became active. NULL means original record.','SCHEMA','gold','TABLE','dim_driver','COLUMN','effective_start_date';
EXEC sys.sp_addextendedproperty 'MS_Description','SCD2: Date this version was superseded. NULL = currently active row.','SCHEMA','gold','TABLE','dim_driver','COLUMN','effective_end_date';
EXEC sys.sp_addextendedproperty 'MS_Description','SCD2: 1 = active/current version, 0 = historical version.','SCHEMA','gold','TABLE','dim_driver','COLUMN','is_current';

PRINT '>> Extended properties added: gold.dim_driver';

-- ==============================================================================
-- gold.dim_truck
-- ==============================================================================

IF EXISTS (SELECT 1 FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('gold.dim_truck') AND minor_id = 0 AND name = 'MS_Description')
    EXEC sys.sp_dropextendedproperty  'MS_Description','SCHEMA','gold','TABLE','dim_truck';
EXEC sys.sp_addextendedproperty     'MS_Description','Truck (tractor unit) dimension — one row per fleet unit. Enriched with truck_age_years computed at load time.','SCHEMA','gold','TABLE','dim_truck';

EXEC sys.sp_addextendedproperty 'MS_Description','Surrogate key (IDENTITY).','SCHEMA','gold','TABLE','dim_truck','COLUMN','truck_key';
EXEC sys.sp_addextendedproperty 'MS_Description','Natural key from source fleet system.','SCHEMA','gold','TABLE','dim_truck','COLUMN','truck_id';
EXEC sys.sp_addextendedproperty 'MS_Description','Derived: YEAR(GETDATE()) − model_year. Recomputed on every Gold load.','SCHEMA','gold','TABLE','dim_truck','COLUMN','truck_age_years';

PRINT '>> Extended properties added: gold.dim_truck';

-- ==============================================================================
-- gold.dim_customer
-- ==============================================================================

IF EXISTS (SELECT 1 FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('gold.dim_customer') AND minor_id = 0 AND name = 'MS_Description')
    EXEC sys.sp_dropextendedproperty  'MS_Description','SCHEMA','gold','TABLE','dim_customer';
EXEC sys.sp_addextendedproperty     'MS_Description','Customer dimension — one row per customer account.','SCHEMA','gold','TABLE','dim_customer';

EXEC sys.sp_addextendedproperty 'MS_Description','Surrogate key (IDENTITY).','SCHEMA','gold','TABLE','dim_customer','COLUMN','customer_key';
EXEC sys.sp_addextendedproperty 'MS_Description','Contracted revenue ceiling per year (USD).','SCHEMA','gold','TABLE','dim_customer','COLUMN','annual_revenue_potential';

PRINT '>> Extended properties added: gold.dim_customer';

-- ==============================================================================
-- gold.dim_route
-- ==============================================================================

IF EXISTS (SELECT 1 FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('gold.dim_route') AND minor_id = 0 AND name = 'MS_Description')
    EXEC sys.sp_dropextendedproperty  'MS_Description','SCHEMA','gold','TABLE','dim_route';
EXEC sys.sp_addextendedproperty     'MS_Description','Route (lane) dimension — one row per origin-destination pair. lane_description provides a human-readable label.','SCHEMA','gold','TABLE','dim_route';

EXEC sys.sp_addextendedproperty 'MS_Description','Derived: origin_city, origin_state → destination_city, destination_state.','SCHEMA','gold','TABLE','dim_route','COLUMN','lane_description';
EXEC sys.sp_addextendedproperty 'MS_Description','Revenue rate per mile in USD (base, excluding surcharges).','SCHEMA','gold','TABLE','dim_route','COLUMN','base_rate_per_mile';

PRINT '>> Extended properties added: gold.dim_route';

-- ==============================================================================
-- gold.dim_date
-- ==============================================================================

IF EXISTS (SELECT 1 FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('gold.dim_date') AND minor_id = 0 AND name = 'MS_Description')
    EXEC sys.sp_dropextendedproperty  'MS_Description','SCHEMA','gold','TABLE','dim_date';
EXEC sys.sp_addextendedproperty     'MS_Description','Calendar date dimension — one row per calendar day from 2020-01-01 to 2030-12-31. Includes weekend and US federal holiday flags.','SCHEMA','gold','TABLE','dim_date';

EXEC sys.sp_addextendedproperty 'MS_Description','Integer date key in YYYYMMDD format. FK target for all fact tables.','SCHEMA','gold','TABLE','dim_date','COLUMN','date_key';
EXEC sys.sp_addextendedproperty 'MS_Description','1 = Saturday or Sunday, 0 = weekday.','SCHEMA','gold','TABLE','dim_date','COLUMN','is_weekend';
EXEC sys.sp_addextendedproperty 'MS_Description','1 = US Federal Holiday. See holiday_name for the holiday label.','SCHEMA','gold','TABLE','dim_date','COLUMN','is_holiday';
EXEC sys.sp_addextendedproperty 'MS_Description','Name of the US Federal Holiday if is_holiday = 1, otherwise NULL.','SCHEMA','gold','TABLE','dim_date','COLUMN','holiday_name';
EXEC sys.sp_addextendedproperty 'MS_Description','Formatted string yyyy-MM for easy monthly grouping in BI tools.','SCHEMA','gold','TABLE','dim_date','COLUMN','year_month';

PRINT '>> Extended properties added: gold.dim_date';

-- ==============================================================================
-- gold.fact_trip
-- ==============================================================================

IF EXISTS (SELECT 1 FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('gold.fact_trip') AND minor_id = 0 AND name = 'MS_Description')
    EXEC sys.sp_dropextendedproperty  'MS_Description','SCHEMA','gold','TABLE','fact_trip';
EXEC sys.sp_addextendedproperty     'MS_Description','Core shipment fact — grain is one completed trip. Contains revenue, distance, duration, and fuel measures linked to 6 dimensions.','SCHEMA','gold','TABLE','fact_trip';

EXEC sys.sp_addextendedproperty 'MS_Description','Base freight revenue (USD) from the load record.','SCHEMA','gold','TABLE','fact_trip','COLUMN','revenue';
EXEC sys.sp_addextendedproperty 'MS_Description','Derived: revenue + fuel_surcharge + accessorial_charges (USD). Additive across all dimensions.','SCHEMA','gold','TABLE','fact_trip','COLUMN','total_revenue';
EXEC sys.sp_addextendedproperty 'MS_Description','Miles driven on the actual trip (may differ from route typical distance).','SCHEMA','gold','TABLE','fact_trip','COLUMN','actual_distance_miles';
EXEC sys.sp_addextendedproperty 'MS_Description','Fuel economy achieved on this trip (miles per gallon).','SCHEMA','gold','TABLE','fact_trip','COLUMN','average_mpg';

PRINT '>> Extended properties added: gold.fact_trip';

-- ==============================================================================
-- gold.fact_fuel_purchase
-- ==============================================================================

IF EXISTS (SELECT 1 FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('gold.fact_fuel_purchase') AND minor_id = 0 AND name = 'MS_Description')
    EXEC sys.sp_dropextendedproperty  'MS_Description','SCHEMA','gold','TABLE','fact_fuel_purchase';
EXEC sys.sp_addextendedproperty     'MS_Description','Fuel transaction fact — grain is one fuel stop. Linked to driver, truck, and date dimensions.','SCHEMA','gold','TABLE','fact_fuel_purchase';

EXEC sys.sp_addextendedproperty 'MS_Description','Derived: gallons × price_per_gallon (USD).','SCHEMA','gold','TABLE','fact_fuel_purchase','COLUMN','total_cost';

PRINT '>> Extended properties added: gold.fact_fuel_purchase';

-- ==============================================================================
-- gold.fact_maintenance
-- ==============================================================================

IF EXISTS (SELECT 1 FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('gold.fact_maintenance') AND minor_id = 0 AND name = 'MS_Description')
    EXEC sys.sp_dropextendedproperty  'MS_Description','SCHEMA','gold','TABLE','fact_maintenance';
EXEC sys.sp_addextendedproperty     'MS_Description','Maintenance event fact — grain is one service record. Measures labor/parts costs and downtime hours per truck.','SCHEMA','gold','TABLE','fact_maintenance';

EXEC sys.sp_addextendedproperty 'MS_Description','Derived: labor_cost + parts_cost (USD).','SCHEMA','gold','TABLE','fact_maintenance','COLUMN','total_cost';
EXEC sys.sp_addextendedproperty 'MS_Description','Hours the truck was unavailable due to this maintenance event.','SCHEMA','gold','TABLE','fact_maintenance','COLUMN','downtime_hours';

PRINT '>> Extended properties added: gold.fact_maintenance';

-- ==============================================================================
-- gold.fact_safety
-- ==============================================================================

IF EXISTS (SELECT 1 FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('gold.fact_safety') AND minor_id = 0 AND name = 'MS_Description')
    EXEC sys.sp_dropextendedproperty  'MS_Description','SCHEMA','gold','TABLE','fact_safety';
EXEC sys.sp_addextendedproperty     'MS_Description','Safety incident fact — grain is one recorded incident. Links to driver, truck, and date. Measures damage and claim costs.','SCHEMA','gold','TABLE','fact_safety';

EXEC sys.sp_addextendedproperty 'MS_Description','Derived: vehicle_damage_cost + cargo_damage_cost (USD).','SCHEMA','gold','TABLE','fact_safety','COLUMN','total_damage_cost';
EXEC sys.sp_addextendedproperty 'MS_Description','Y/N flag — was the incident determined to be preventable?','SCHEMA','gold','TABLE','fact_safety','COLUMN','preventable_flag';

PRINT '>> Extended properties added: gold.fact_safety';

-- ==============================================================================
-- gold.fact_delivery
-- ==============================================================================

IF EXISTS (SELECT 1 FROM sys.extended_properties
           WHERE major_id = OBJECT_ID('gold.fact_delivery') AND minor_id = 0 AND name = 'MS_Description')
    EXEC sys.sp_dropextendedproperty  'MS_Description','SCHEMA','gold','TABLE','fact_delivery';
EXEC sys.sp_addextendedproperty     'MS_Description','Delivery event fact — grain is one pickup or drop-off event. Measures detention time and on-time performance per facility.','SCHEMA','gold','TABLE','fact_delivery';

EXEC sys.sp_addextendedproperty 'MS_Description','Minutes the truck was held at the facility beyond scheduled time (detention cost driver).','SCHEMA','gold','TABLE','fact_delivery','COLUMN','detention_minutes';
EXEC sys.sp_addextendedproperty 'MS_Description','Y/N flag — did the delivery meet the scheduled window?','SCHEMA','gold','TABLE','fact_delivery','COLUMN','on_time_flag';
EXEC sys.sp_addextendedproperty 'MS_Description','Date key (YYYYMMDD) derived from actual_datetime (falls back to scheduled_datetime). FK → gold.dim_date.','SCHEMA','gold','TABLE','fact_delivery','COLUMN','delivery_date_key';

PRINT '>> Extended properties added: gold.fact_delivery';

PRINT '==============================================================';
PRINT 'All Gold layer extended properties applied successfully.';
PRINT '==============================================================';
