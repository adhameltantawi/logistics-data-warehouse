IF OBJECT_ID('bronze.delivery_events', 'U') IS NOT NULL
    DROP TABLE bronze.delivery_events;
GO

CREATE TABLE bronze.delivery_events
(
    event_id NVARCHAR(20) NULL,
    load_id NVARCHAR(20) NULL,
    trip_id NVARCHAR(20) NULL,
    event_type NVARCHAR(15) NULL,
    facility_id NVARCHAR(20) NULL,
    scheduled_datetime TIME NULL,
    actual_datetime TIME NULL,
    detention_minutes INT NULL,
    on_time_flag TIME NULL,
    location_city NVARCHAR(50) NULL,
    location_state NCHAR(2) NULL
);
GO

IF OBJECT_ID('bronze.fuel_purchases', 'U') IS NOT NULL
    DROP TABLE bronze.fuel_purchases;
GO

CREATE TABLE bronze.fuel_purchases
(
    fuel_purchase_id NVARCHAR(20) NULL,
    trip_id NVARCHAR(20) NULL,
    truck_id NVARCHAR(20) NULL,
    driver_id NVARCHAR(20) NULL,
    purchase_date DATETIME2 NULL,
    location_city NVARCHAR(20) NULL,
    location_state NCHAR(2) NULL,
    gallons FLOAT NULL,
    price_per_gallon DECIMAL(10,3) NULL,
    total_cost DECIMAL(10,3) NULL,
    fuel_card_number NVARCHAR(20) NULL
);
GO

IF OBJECT_ID('bronze.loads', 'U') IS NOT NULL
    DROP TABLE bronze.loads;
GO

CREATE TABLE bronze.loads
(
    load_id NVARCHAR(20) NULL,
    customer_id NVARCHAR(20) NULL,
    route_id NVARCHAR(20) NULL,
    load_date DATE NULL,
    load_type NVARCHAR(20) NULL,
    weight_lbs INT NULL,
    pieces INT NULL,
    revenue DECIMAL(10,3) NULL,
    fuel_surcharge DECIMAL(10,3) NULL,
    accessorial_charges INT NULL,
    load_status NVARCHAR(20) NULL,
    booking_type NVARCHAR(20) NULL
);
GO

IF OBJECT_ID('bronze.maintenance_records', 'U') IS NOT NULL
    DROP TABLE bronze.maintenance_records;
GO

CREATE TABLE bronze.maintenance_records
(
    maintenance_id NVARCHAR(20) NULL,
    truck_id NVARCHAR(20) NULL,
    maintenance_date DATE NULL,
    maintenance_type NVARCHAR(20) NULL,
    odometer_reading INT NULL,
    labor_hours FLOAT NULL,
    labor_cost DECIMAL(10,3) NULL,
    parts_cost DECIMAL(10,3) NULL,
    total_cost DECIMAL(10,3) NULL,
    facility_location NVARCHAR(20) NULL,
    downtime_hours FLOAT NULL,
    service_description NVARCHAR(50) NULL
);
GO