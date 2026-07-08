-- reference tables
SELECT TOP 100 * FROM bronze.drivers;
SELECT TOP 100 * FROM bronze.customers;
SELECT TOP 100 * FROM bronze.facilities;
SELECT TOP 100 * FROM bronze.routes;
SELECT TOP 100 * FROM bronze.trailers;
SELECT TOP 100 * FROM bronze.trucks;

-- transactions tables
SELECT TOP 100 * FROM bronze.delivery_events;
SELECT TOP 100 * FROM bronze.fuel_purchases;
SELECT TOP 100 * FROM bronze.loads;
SELECT TOP 100 * FROM bronze.maintenance_records;
SELECT TOP 100 * FROM bronze.safety_incidents;
SELECT TOP 100 * FROM bronze.trips;

-- analytics tables
SELECT TOP 100 * FROM bronze.driver_monthly_metrics;
SELECT TOP 100 * FROM bronze.truck_utilization_metrics;
