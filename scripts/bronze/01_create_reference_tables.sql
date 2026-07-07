IF OBJECT_ID('bronze.drivers', 'U') IS NOT NULL
    DROP TABLE bronze.drivers;
GO
CREATE TABLE bronze.drivers 
(
    driver_id NVARCHAR(50) NULL,
    first_name NVARCHAR(50) NULL, 
    last_name NVARCHAR(50) NULL,
    hire_date DATE NULL,
    termination_date DATE NULL,
    license_number NVARCHAR(50) NULL,
    license_state NCHAR(2) NULL,
    date_of_birth DATE NULL,
    home_terminal NVARCHAR(50) NULL,
    employment_status NVARCHAR(50) NULL,
    cdl_class NCHAR(1) NULL,
    years_experience INT NULL   
);
GO


IF OBJECT_ID('bronze.customers', 'U') IS NOT NULL
    DROP TABLE bronze.customers;
GO
CREATE TABLE bronze.customers
(
    customer_id NVARCHAR(50) NULL,
    customer_name NVARCHAR(50) NULL,
    customer_type NVARCHAR(50) NULL,
    credit_terms_days INT NULL,
    primary_freight_type NVARCHAR(50) NULL,
    account_status NVARCHAR(50) NULL,
    contract_start_date DATE NULL,
    annual_revenue_potential INT NULL
);
GO


IF OBJECT_ID('bronze.facilities', 'U') IS NOT NULL
    DROP TABLE bronze.facilities;
GO
CREATE TABLE bronze.facilities
(
    facility_id NVARCHAR(50) NULL,
    facility_name NVARCHAR(50) NULL,
    facility_type NVARCHAR(50) NULL,
    city NVARCHAR(50) NULL,
    state NCHAR(2) NULL,
    latitude FLOAT NULL,
    longitude FLOAT NULL,
    dock_doors INT NULL,
    operating_hours NVARCHAR(50) NULL
);
GO


IF OBJECT_ID('bronze.routes', 'U') IS NOT NULL
    DROP TABLE bronze.routes;
GO
CREATE TABLE bronze.routes
(
    route_id NVARCHAR(50) NULL,
    origin_city NVARCHAR(50) NULL,
    origin_state NCHAR(2),
    destination_city NVARCHAR(50) NULL,
    destination_state NCHAR(2),
    typical_distance_miles INT NULL,
    base_rate_per_mile FLOAT NULL,
    fuel_surcharge_rate FLOAT NULL,
    typical_transit_days INT NULL
);
GO


IF OBJECT_ID('bronze.trailers', 'U') IS NOT NULL
    DROP TABLE bronze.trailers;
GO
CREATE TABLE bronze.trailers
(
    trailer_id NVARCHAR(50) NULL,
    trailer_number INT NULL,
    trailer_type NVARCHAR(50) NULL,
    length_feet INT NULL,
    model_year INT NULL,
    vin NVARCHAR(50) NULL,
    acquisition_date DATE NULL,
    status NVARCHAR(50) NULL,
    current_location NVARCHAR(50) NULL

);
GO


IF OBJECT_ID('bronze.trucks', 'U') IS NOT NULL
    DROP TABLE bronze.trucks;
GO
CREATE TABLE bronze.trucks
(
    truck_id NVARCHAR(50) NULL,
    unit_number INT NULL,
    make NVARCHAR(50) NULL,
    model_year INT NULL,
    vin NVARCHAR(50) NULL,
    acquisition_date DATE NULL,
    acquisition_mileage INT NULL,
    fuel_type NVARCHAR(50) NULL,
    tank_capacity_gallons INT NULL,
    status NVARCHAR(50) NULL,
    home_terminal NVARCHAR(50) NULL
);
GO
