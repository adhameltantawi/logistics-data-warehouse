IF OBJECT_ID('bronze.driver_monthly_metrics', 'U') IS NOT NULL
    DROP TABLE bronze.driver_monthly_metrics;
GO
CREATE TABLE bronze.driver_monthly_metrics
(
    driver_id NVARCHAR(20) NULL,
    month DATE NULL,
    trips_completed INT NULL,
    total_miles INT NULL,
    total_revenue DECIMAL(18,3) NULL,
    average_mpg DECIMAL(10,3) NULL,
    total_fuel_gallons DECIMAL(18,3) NULL,
    on_time_delivery_rate FLOAT NULL,
    average_idle_hours FLOAT NULL
);
GO

IF OBJECT_ID('bronze.truck_utilization_metrics', 'U') IS NOT NULL
    DROP TABLE bronze.truck_utilization_metrics;
GO
CREATE TABLE bronze.truck_utilization_metrics
(
    truck_id NVARCHAR(20) NULL,
    month DATE NULL,
    trips_completed INT NULL,
    total_miles INT NULL,
    total_revenue DECIMAL(18,3) NULL,
    average_mpg DECIMAL(10,3) NULL,
    maintenance_events INT NULL,
    maintenance_cost DECIMAL(18,3) NULL,
    downtime_hours FLOAT NULL,
    utilization_rate FLOAT NULL
);
